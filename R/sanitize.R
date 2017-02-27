sanitize = function(x = NULL){
  prechecks_sanitize(x)
  x[,c("output", "code")] = lapply(x[,c("output", "code")], tidy) %>% 
    as.data.frame(row.names = NULL, stringsAsFactors = FALSE)
  postchecks_sanitize(x)
  x
}

prechecks_sanitize = function(x){
  if(is.null(dim(x)))
    stop("input must be a data frame.")
  if(length(dim(x)) != 2)
    stop("input must be a data frame.")
  if(!all(c("output", "code") %in% colnames(x)))
    stop("input data frame must have columns named ",
      "\"output\" and \"code\".")
  if(any(safe_grepl("^_", x$output)))
    stop("output names cannot being with underscores, etc. Use legal\n",
      "R symbol names for objects or single-quoted strings for files.")
}

postchecks_sanitize = function(x){
  if(any(safe_grepl("^\"|\"$", x$output)))
    stop("don't use double-quoted strings in your output names.\n", 
      "Use single quotes for file dependencies.")
  if(anyDuplicated(x$output)){
    dup = x$output[duplicated(x$output)] %>% as.character %>%
      paste(collapse = ", ")
    stop("duplicates found (user imports vs planned output).\n", 
      "Check imports with ls() and remove with rm().\n", 
      "Duplicates: ", dup)
  }
}
