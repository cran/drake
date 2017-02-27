#' @title Function \code{clean}
#' @description Cleans up all work done by \code{\link{make}}. 
#' Your working directory (\code{\link{getwd}()}) must be the 
#' root directory of your drake project.
#' WARNING:
#' This deletes ALL \code{\link{make}} output, which includes 
#' file outputs as well as the entire drake cache. Only use \code{clean}
#' if you're sure you won't lose any important work.
#' @seealso \code{\link{prune}}, \code{\link{make}}, 
#' \code{\link{help_drake}}
#' @export
#' @param destroy logical, whether to totally remove the drake cache. 
#' If \code{destroy} is \code{FALSE}, only the outputs from \code{make}()
#' are removed. If \code{TRUE}, the whole cache is removed, including
#' session metadata. 
clean = function(destroy = FALSE){
  if(!file.exists(cache_path)) return(invisible())
  cache = storr_rds(cache_path, mangle_key = TRUE)
  files = cached(search = FALSE) %>% Filter(f = is_file) 
  remove_output_files(files, cache)
  if(destroy){
    unlink(cache_path, recursive = TRUE)
  } else {
    cache$clear()
    cache$clear(namespace = "depends")
  }
  invisible()
}

#' @title Function \code{prune}
#' @description Removes any cached output objects and drake-generated 
#' files not listed in \code{plan$output$}. 
#' Your working directory (\code{\link{getwd}()}) must be the
#' root directory of your drake project.
#' WARNING: this removes files.
#' Only do this if you're sure you won't lose any important work.
#' @seealso \code{\link{clean}}, \code{\link{make}},
#' \code{\link{help_drake}}
#' @export
#' @param plan data frame, drake workflow like the one generated
#' by \code{\link{example_plan}}. 
prune = function(plan){
  plan = sanitize(plan)
  if(!file.exists(cache_path)) return(invisible())
  cache = storr_rds(cache_path, mangle_key = TRUE)
  remove = setdiff(cached(search = FALSE), plan$output)
  files = Filter(remove, f = is_file)
  remove_output_files(files, cache)
  lapply(remove, function(x){
    cache$del(x)
    cache$del(x, namespace = "depends")
  })
  invisible()
}

remove_output_files = Vectorize(function(file, cache){
  if(!is_imported(file)) unlink(unquote(file), recursive = TRUE)
}, "file")
