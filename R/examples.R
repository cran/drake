#' @title Function \code{example_plan}
#' @description Return an example workflow plan for \code{\link{make}}.
#' @details The \code{"debug"} example (\code{x <- example_plan("debug")})
#' requires you to run \code{\link{debug_setup}()} before 
#' running \code{\link{make}(x)}. That way, the required inputs
#' are generated.
#' Run \code{\link{help_drake}} to see helpful links.
#' @seealso \code{\link{example_plans}}, \code{\link{make}}, 
#' \code{\link{help_drake}}
#' @export
#' @param x name of workflow plan (character scalar)
#' @return example workflow plan for \code{\link{make}}
example_plan = function(x = drake::example_plans()){
  x = match.arg(x)
  example_plan_list[[x]] %>% sanitize()
}

#' @title Function \code{example_plans}
#' @description List the names of example drake workflow plans.
#' @details Run \code{\link{help_drake}} to see helpful links.
#' @seealso \code{\link{example_plan}}, \code{\link{make}}, 
#' \code{\link{help_drake}}
#' @export
#' @return names of example drake workflow plans
example_plans = function(){
  names(example_plan_list)
}

#' @title Function \code{debug_setup}
#' @description For the \code{"debug"} example 
#' (\code{example_plan('debug')}),
#' write the required input files and load the required functions
#' into the calling environment.
#' @seealso \code{\link{example_plan}}, \code{\link{make}},
#' \code{\link{help_drake}}
#' @export
debug_setup = function(){
  matrix(1:25, nrow = 5) %>% write.csv(file="input")
  eval(parse(text = "global <- 2"), envir = parent.frame())
  eval(parse(text = "f <- function(x){y(x+1) + g(x)}"), 
    envir = parent.frame())
  eval(parse(text = "y <- function(f){f+1+global}"), 
    envir = parent.frame())
  eval(parse(text = "g = function(x){h(x) + i(x)}"),
    envir = parent.frame())
  eval(parse(text = "h <- function(x){2*x+5}"),
    envir = parent.frame())
  eval(parse(text = "i <- function(x){j(x)+9}"),
    envir = parent.frame())
  eval(parse(text = "j <- function(x){x}"), 
    envir = parent.frame())
  invisible()
}

#' @title Function \code{debug_cleanup}
#' @description For the \code{"debug"} example
#' (\code{example_plan('debug')}),
#' remove the files and cache
#' @seealso \code{\link{example_plan}}, \code{\link{make}},
#' \code{\link{help_drake}}
#' @export
debug_cleanup = function(){
  unlink(c("d", "e", "input", "Makefile"), recursive = TRUE)
  clean(destroy = TRUE)
}

example_plan_list = list(
  small = data.frame(
    output = letters[1:6],
    code = c("b+c", "d+e", "d+f", "1+1", "2+2", "3+3"),
    stringsAsFactors = FALSE),
  debug = data.frame(
    output = c(letters[1:5], "'d'", "'e'", "final"),
    code = c("as.numeric(as.matrix(read.csv('input')))", 
      "a+1", "a +2", "f(b+c)", "g(b+d)", "saveRDS(d, \"d\")", 
      "saveRDS(e, \"e\")", "readRDS('e')"), 
    stringsAsFactors = FALSE)
)
