.onLoad <- function(libname, pkgname) {
  if(file.exists(".RData")) 
    warning("Auto-saved workspace file '.RData' detected. ",
      "This is bad for reproducible code. ",
      "Drake says you should remove it with unlink('.RData').")
  invisible()
}
