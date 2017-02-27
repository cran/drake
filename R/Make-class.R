Make = R6Class("Make",
  public = list(
    plan = NULL,
    envir = NULL,
    cache = NULL,
    verbose = NULL,
    force_rehash = NULL,

    initialize = function(plan = NULL, verbose = TRUE,
      envir = NULL, output = plan$output, force_rehash = FALSE,
      debug = FALSE){
      self$envir = envir %>% as.list %>%
        list2env(parent = globalenv())
      self$cache = storr_rds(cache_path, mangle_key = TRUE)
      self$verbose = verbose
      self$plan = plan[,c("output", "code")]
      rownames(self$plan) = self$plan$output
      self$force_rehash = force_rehash
      if(!debug){
        self$import()
        self$preprocess(output)
      }
    },

    import = function(){
      if(any(is.na(self$plan$code)) | any(is.na(self$plan$output)))
        stop("NA's found in output or code in plan.")
      self$append(ls(self$envir, all.names = T))
      sapply(self$plan$output, self$deps,
        from_plan_only = F) %>% unlist %>% Filter(f = is_file) %>%
        setdiff(self$plan$output) %>% self$append()
      imports = self$plan$output[is.na(self$plan$code)]
      lapply(imports, function(name){
        if(is.function(self$envir[[name]]))
           environment(self$envir[[name]]) = self$envir
      })
    },

    append = function(x){
      if(!length(x)) return()
      self$plan = rbind(self$plan, data.frame(
        output = x, code = as.character(NA), stringsAsFactors = F)) %>%
        sanitize
      rownames(self$plan) = self$plan$output
    },

    preprocess = function(output){
      g = make_empty_graph() + vertices(self$plan$output)
      for(i in self$plan$output)
        for(j in self$deps(i))
          g = g + edge(i, j)
      ignore = lapply(output, function(v)
        subcomponent(graph = g, v = v, mode = "out")$name
      ) %>% unlist %>% unique %>% setdiff(x = V(g)$name)
      g = delete_vertices(g, v = ignore)
      if(!is_dag(g)) stop(cycle_msg)
      sorted_targets = topological.sort(g)$name %>% rev
      self$plan = self$plan[sorted_targets,] %>% sanitize
    },

    deps = function(name, from_plan_only = TRUE){
      if(is.function(self$envir[[name]])){
        f = self$envir[[name]]
        exclude = c(formalArgs(f),
          self$plan$output[!is.na(self$plan$code)])
        out = body(f) %>% deparse %>% paste(collapse = "\n") %>%
          dep %>% setdiff(y = exclude) %>% 
          Filter(f = function(x) !is_file(x))
      } else if(name %in% self$plan$output){
        out = self$plan[name, "code"] %>% dep
      } else {
        stop("attempting self$deps(x), but x is not in plan.")
      }
      if(from_plan_only)
        out = out[out %in% self$plan$output]
      out
    },

    depends_stamp = function(name){
      list(code = hash_code(self$plan[name, "code"]),
        targets = sapply(self$deps(name), self$stored_hash),
	type = ifelse(is_file(name), "file", "object"))
    },

    stored_hash = function(name){
      if(!(name %in% self$cache$list())) return(NA)
      if(is_file(name))
        self$cache$get(name)$hash
      else
        self$cache$get_hash(name)
    },

    file_stamp = function(name, force_rehash = FALSE){
      path = unquote(name)
      mtime = file.mtime(path)
      if(!force_rehash & (name %in% self$cache$list())){
        old_stamp = self$cache$get(name)
        if(mtime <= old_stamp$mtime) return(old_stamp)
      }
      list(hash = hash_file(path), mtime = mtime)
    },

    prepare_building_envir = function(name){
      object_targets = self$plan$output[!is.na(self$plan$code) &
        !is_file(self$plan$output)]
      deps = self$deps(name) %>% intersect(object_targets)
      loaded = ls(envir = self$envir, all.names = T) %>%
        intersect(object_targets)
      rm(list = setdiff(loaded, deps), envir = self$envir)
      lapply(setdiff(deps, loaded), function(d)
        assign(d, self$cache$get(d), envir = self$envir))
    },

    build = function(name, depends_stamp){
      filename = unquote(name)
      old_mtime = ifelse(file.exists(filename), 
        file.mtime(filename), -Inf)
      code = self$plan[name, "code"]
      if(is.na(code)){
        value = self$envir[[name]]
        if(is.function(value)){
	  depends_stamp$type = "function"
	  value = list(value = deparse(value), depends = depends_stamp)
	}
      } else {
        self$prepare_building_envir(name)
        value = eval(parse(text = code), envir = self$envir)
      }
      if(is_file(name)){
        if(!file.exists(filename))
          stop(name, " neither found nor written.")
        force_rehash = 
          self$force_rehash | 
          (file.size(filename) < 1e5) |
          !is.na(code)
        value = self$file_stamp(name, force_rehash)
      }
      self$cache$set(key = name, value = value)
      self$cache$set(key = name, value = depends_stamp,
        namespace = "depends")
      self$cache$set(name, namespace = "status", 
        value = ifelse(is.na(code), "imported", "built"))
    },

    should_update_file = function(name){
      if(!is_file(name)) return(FALSE)
      if(!(name %in% self$cache$list())) return(TRUE)
      path = unquote(name)
      if(!file.exists(path)) return(TRUE)
      !identical(self$file_stamp(name)$hash, self$cache$get(name)$hash)
    },

    should_update_target = function(name, depends_stamp){
      if(is.na(self$plan[name, "code"])) return(TRUE)
      if(!all(name %in% self$cache$list())) return(TRUE)
      if(self$should_update_file(name)) return(TRUE)
      !identical(depends_stamp, self$cache$get(name,
        namespace = "depends"))
    },

    update = function(name){
      self$cache$set(name, value = "IN PROGRESS", namespace = "status")
      depends_stamp = self$depends_stamp(name)
      do_update = self$should_update_target(name, depends_stamp)
      self$console(name, do_update)
      if(do_update) self$build(name, depends_stamp)
      else self$cache$set(name, value = "skipped", namespace = "status")
    },

    console = function(name, do_update){
      if(!self$verbose) return()
      if(!do_update)
        action = color("skip   ", "dodgerblue3")
      else if(is.na(self$plan[name, "code"]))
        action = color("import ", "darkorchid3")
      else
        action = color("build  ", "forestgreen")
      if(nchar(name) >= 50) name = paste0(substr(name, 1, 47), "...")
      cat(action, name, "\n", sep = "")
    },

    make = function(clear_status = TRUE){
      self$cache$set(key = "session", value = sessionInfo(),
        namespace = "session") 
      if(clear_status)
        self$cache$clear(namespace = "status")
      for(target in self$plan$output) self$update(target)
      invisible()
    }
  )
)
