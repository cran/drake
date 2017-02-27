#' @title Function \code{plan}
#' @description Turns a named collection of code/output pairs into 
#' a workflow plan data frame for \code{\link{make}} and 
#' \code{\link{check}}.
#' Use the \code{\link{help_drake}} function to get more help.
#' @details Drake uses single quotes to denote external files
#' and double-quoted strings as ordinary strings. 
#' Quotes in the \code{list} argument are left alone,
#' but R messes with quotes when it parses the freeform 
#' arguments in \code{...}, so use the \code{strings_in_dots}
#' argument to control the quoting in \code{...}.
#' Use the \code{\link{help_drake}} function to get more help.
#' @seealso \code{link{check}}, \code{\link{make}}, 
#' \code{\link{help_drake}}
#' @export
#' @return data frame of outputs and code
#' @param ... pieces of code named according to their respective outputs.
#' Recall that drake uses single quotes to denote external files
#' and double-quoted strings as ordinary strings.
#' Use the \code{strings_in_dots} argument to control the
#' quoting in \code{...}.
#' @param list named character vector of pieces of code named
#' according to their respective outputs
#' @param file_outputs logical. If \code{TRUE}, outputs are single-quoted
#' to tell drake that these are external files that should be generated
#' in the next call to \code{\link{make}()}.
#' @param strings_in_dots character scalar. If \code{"file_deps"},
#' all character strings in \code{...} will be treated as file
#' dependencies (single-quoted). If \code{"not_deps"}, all
#' character strings in \code{...} will be treated as ordinary
#' strings, not dependencies of any sort (double-quoted). 
#' (This does not affect the names of free-form arguments passed to 
#' \code{...}). Because of R's
#' automatic parsing/deparsing behavior, strings in \code{...}
#' cannot simply be left alone.
plan = function(..., list = character(0), file_outputs = FALSE,
  strings_in_dots = c("file_deps", "not_deps")) {
  strings_in_dots = match.arg(strings_in_dots)
  dots = match.call(expand.dots = FALSE)$...
  output = lapply(dots, deparse)
  names(output) = names(dots)
  x = c(output, list)
  if(!length(x)) return(data.frame(output = character(0),
    code = character(0)))
  out = data.frame(output = names(x), code = as.character(x),
    stringsAsFactors = FALSE)
  i = out$output %in% names(output)
  if(file_outputs) out$output = quotes(out$output, single = T)
  if(strings_in_dots == "file_deps") 
    out$code[i] = gsub("\"", "'", out$code[i])
  sanitize(out)
}
