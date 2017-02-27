#' @title Function \code{make}
#' @description This is the main function of the package
#' It reproducibly execute/update an analysis plan so that
#' your results are up to date with your code. The analysis plan
#' is a data frame of code fragments and output names. See
#' the vignette for details.
#' @details Run \code{\link{help_drake}} to see helpful links.
#' @seealso \code{\link{help_drake}},
#' \code{\link{plan}}, \code{\link{check}}, 
#' \code{\link{cached}}, \code{\link{readd}}
#' @export
#'
#' @param plan workflow plan data frame. Must contain at least
#' (1) a column named "output" for the names of generated objects
#' and (2) a column named "code" with the code fragments that 
#' produce the outputs. Outputs that are external files should
#' be wrapped in single quotes. The \code{\link{plan}} function
#' can help you write this data frame. See the vignette for details.
#'
#' @param output character vector of the names of the output
#' objects to make. Must be members of \code{plan$output}.
#' 
#' @param verbose logical scalar. Set to \code{TRUE} to print progress
#' to the console, \code{FALSE} to hide it. For \code{makefile == TRUE},
#' \code{verbose} does not control output from the \code{Makefile}. 
#' To suppress \code{Makefile} output, use something like
#' \code{make(..., makefile = TRUE, command = "make", args = "--silent")}.
#' Console output is color-coded in the Mac/Linux terminal.
#'
#' @param envir an environment containing user-defined functions,
#' objects, etc. referenced in \code{plan$code}. This is the 
#' environment into which your inputs are imported and your 
#' functions are evaluated. It defaults to 
#' the calling environment for your convenience, so you don't 
#' usually have to do anything. But if your workspace is messy,
#' than you may want to manually create it. An easy way to do this is
#' \code{envir = enivronment()} (to pull everything from your 
#' workspace) or \code{envir = list2env(my_list)}, where \code{my_list}
#' is a list of objects that your functions and \code{plan$code}
#' need to see.
#'
#' @param makefile logical. If \code{TRUE}, \code{make}()
#' writes a proper makefile to your current working directory
#' to govern the workflow, then executes the Makefile
#' with \code{\link{system2}(command, args)} 
#' (\code{command} and \code{args} are arguments to \code{make}()
#' passed to \code{\link{system2}()} to run the Makefile). 
#' This lets you distribute
#' the work over multiple processes, cores, CPUs, or nodes
#' on a cluster or supercomputer. Here, \code{make}() is
#' more than a mere job scheduler. Using the dummy timestamp
#' files that drake creates in a hidden cache, it knows
#' what jobs need to run and which ones can be skipped.
#' A WORD OF WARNING: DO NOT RUN THE MAKEFILE MANUALLY.
#' ONLY RUN IT USING \code{make(..., makefile = TRUE)}.
#' The Makefile does not work outside of \code{drake::make}().
#' 
#' @param command character scalar, only applies if \code{makefile} is \code{TRUE}. 
#' This argument names the command to run the \code{Makefile}. Like \code{args},
#' it is passed to \code{\link{system2}()} to run the \code{Makefile}. Examples:
#' \code{make(..., command = "make", args= "--jobs=2")} will distribute the work
#' over at most two simultaneous jobs, and 
#' \code{make(..., command="make", args=c("--jobs=4", "--silent"))}
#' will use at most four jobs and silence \code{Makefile} output to the console. 
#' To turn your workflow into a heavy-duty persistant batch 
#' of parallel jobs, I recommend saving your workflow in an R script
#' (say, \code{my_script.R}) that ends with something like
#' \code{make(..., command = "make", args = "--jobs=8")}. Then, 
#' to run the workflow from the Mac/Linux command line with
#' \code{nohup nice -19 R CMD BATCH my_script.R &}. \code{Nohup} 
#' tells the Makefile to continue after you log out, \code{nice} tells
#' the parent process to be smart with resources, and the amperstand
#' says to run the workflow in the background. See the vignette
#' or the \code{prepend} argument for how to connect \code{make}()
#' to a cluster or supercomputer.
#' 
#' @param args Arguments to the command named by \code{command}. 
#' \code{command} and \code{args} are passed to \code{\link{system2}()}
#' to run the \code{Makefile}.
#' 
#' @param run logical, only applies if \code{makefile} is \code{TRUE}. 
#' If \code{run} is \code{TRUE}, any generated Makefile
#' will be executed with \code{system2(command)} (using the
#' \code{command} argument to \code{make}()).
#' If \code{FALSE}, the Makefile is simply written
#' and nothing else is done.
#'
#' @param prepend character vector of lines to prepend to the Makefile.
#' Only applies if \code{makefile} is \code{TRUE}.
#' You can use this to define variables in your Makefile. For instance,
#' \code{make(..., prepend = "SHELL=./shell.sh")} writes a Makefile with
#' "SHELL=./shell.sh" at the very top. For the write file \code{shell.sh},
#' you can tell Makefile jobs to scatter across nodes of a cluster or
#' supercomputer. For more details on this, see the vignette.
#' 
#' @param packages character vector of packages that you work
#' depends on. Only applies of \code{makefile} is \code{TRUE}.
#' Defaults to \code{loadedNamespaces()}, so you shouldn't usually
#' have to set it manually. Just call \code{library(your_package)}
#' before calling \code{make()}. But if you need your packages
#' loaded in a certain order, list the packages from first to last.
#' If you supply \code{packages} manually, the packages in 
#' \code{loadedNamespaces()} will not be automatically loaded.
#' Packages are not reproducibly tracked and are not treated
#' as dependencies.
#' 
#' @param global character vector of code chunks to be run 
#' in the global environment right before the build of each 
#' output in \code{plan$output}.
#' Only applies of \code{makefile} is \code{TRUE}.
#' These code chunks could contain \code{library()} calls to load 
#' packages to load (after the \code{packages} argument),
#' global options. Variables defined here will be set in the
#' global environment and they will not be reproducibly tracked
#' nor treated as dependencies for anything in \code{plan}. 
#' Do you find it annoying to enclose all your code in quotes?
#' Try the \code{strings} function from package \code{eply}.
#' Just be sure to use \code{<-} instead of \code{=}.
#'
#' @param force_rehash logical scalar. If
#' \code{TRUE}, imported/input files are always rehashed 
#' on every call to \code{make()}. Force rehashing
#' could slow down your workflow, and you only need to do it if you
#' plan to manually edit files and call multiple instances of 
#' \code{make}() simultaneously or crazily fast. 
make = function(plan = plan(), output = plan$output,
    verbose = TRUE, envir = parent.frame(), makefile = FALSE,
    command = "make", args = "--jobs=2", run = TRUE, prepend = character(0), 
    packages = loadedNamespaces(), global = character(0), 
    force_rehash = FALSE){
  force(envir)
  if(makefile)
    makefile(plan = plan, output = output, 
      verbose = verbose, envir = envir, command = command, args = args, 
      run = run, prepend = prepend, packages = packages,
      global = global, force_rehash = force_rehash)
  else
    make_plain(plan = plan, output = output, verbose = verbose,
      envir = envir, force_rehash = force_rehash)
}

make_plain = function(plan, output, verbose, envir, force_rehash){
  force(envir)
  x = setup(plan = plan, output = output, verbose = verbose, 
    envir = envir, force_rehash = force_rehash)
  x$make()
  invisible()
}

#' @title Function \code{check}
#' @description Check a workflow plan and outputs
#' and return an error if there are problems such as
#' conflicting objects or circular dependencies.
#' @details Run \code{\link{help_drake}} to see helpful links.
#' @seealso \code{\link{help_drake}}, \code{\link{plan}},
#' \code{\link{make}}, \code{\link{cached}}, \code{\link{readd}}
#' @export
#' @param plan workflow plan
#' @param output output object(s) to make
#' @param envir environment containing user-defined functions
check = function(plan, output = plan$output, envir = parent.frame()){
  force(envir)
  setup(plan = plan, output = output, verbose = TRUE, envir = envir)
  check_strings(plan)
  invisible()
}

setup = function(plan, output, verbose, envir, force_rehash = FALSE,
  run = F, makefile = F, prepend = character(0), packages = character(0),
  global = character(0), command = character(0), args = character(0)){
  plan = sanitize(plan)
  check_make_args(plan, output = output, envir = envir,
    verbose = verbose, force_rehash = force_rehash,
    run = run, makefile = makefile, prepend = prepend, 
    packages = packages,
    global = global, command = command, args = args)
  x = Make$new(plan = plan, verbose = verbose, envir = envir, 
    output = output, force_rehash = force_rehash)
  find_files(x$plan, envir)
  x
}

check_make_args = function(plan, output, envir, verbose, force_rehash,
  run, makefile, prepend, packages, global, command, args){
  if(!nrow(plan))
    stop("Plan is empty.")
  if(!length(output))
    stop("No output to make or check.")
  if(!all(output %in% plan$output))
    stop("All output must be in plan$output.")
  if(!is.environment(envir))
    stop("envir must be an environment.")
  assert_logical_scalar(verbose)
  assert_logical_scalar(force_rehash)
  assert_logical_scalar(run)
  assert_logical_scalar(makefile)
  stopifnot(is.character(prepend))
  stopifnot(is.character(command))
  stopifnot(is.character(packages))
  stopifnot(is.character(global))
}

assert_logical_scalar = function(x){
  if(length(x) != 1) stop("need a logical scalar.")
  stopifnot(is.logical(x) & !is.na(x))
}

find_files = function(plan, envir){
  imports = plan$output[is.na(plan$code)]
  files = imports[is_file(imports)] %>% unquote
  if(!all(file.exists(files))){
    msg = paste(quotes(files, single = TRUE), collapse = ", ")
    stop("Missing files: ", msg, "\n")
  }
}

check_strings = function(plan){
  x = stri_extract_all_regex(plan$code, '(?<=").*?(?=")')
  names(x) = plan$output
  x = x[!is.na(x)]
  if(!length(x)) return()
  x = lapply(x, function(y){
    if(length(y) > 2) return(y[seq(from = 1, to = length(y), by = 2)])
    else return(y)
  })
  cat("Double-quoted strings were found in plan$code.",
    "Should these be single-quoted instead?",
    "Remember: single-quoted strings are file dependencies/outputs", 
    "and double-quoted strings are just ordinary strings.",
    sep = "\n")
  for(i in 1:length(x)){
    cat("\noutput:", names(x)[i], "\n")
    cat("strings in code:", paste0("\"", x[[i]], "\""), "\n")
  }
}
