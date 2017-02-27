#' @title Function \code{help_drake}
#' @description Prints links for tutorials, troubleshooting, bug reports, etc.
#' @seealso \code{\link{plan}}, \code{\link{make}}
#' @export
#' @return useful links
help_drake = function(){
  cat(
    "The package vignette has a full tutorial, and it is available at the following webpages.",
    "    https://CRAN.R-project.org/package=drake/vignettes/drake.html",
    "    https://cran.r-project.org/web/packages/drake/vignettes/drake.html",
#    "The vignette of the development version has a full tutorial at the webpage below.",
#    "    http://will-landau.com/drake/articles/drake.html",
    "For troubleshooting, navigate to the link below.",
    "    https://github.com/wlandau-lilly/drake/blob/master/TROUBLESHOOTING.md",
    "To submit bug reports, usage questions, feature requests, etc., navigate to the link below.",
    "    https://github.com/wlandau-lilly/drake/issues",
  sep = "\n")
}
