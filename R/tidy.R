tidy = function(x, keep_single = TRUE){
  if(!length(x)) return(character(0))
  tidy_vec(x, keep_single = keep_single) %>% as.character
}

tidy_vec = Vectorize(function(x, keep_single = TRUE){
  if(is.na(x)) return(NA)
  out = tidy_source(text = as.character(x),
    arrow = TRUE, blank = FALSE, brace.newline = FALSE,
    comment = FALSE, output = FALSE, WIDTH.CUTOFF = Inf)$text.tidy %>%
    paste(collapse = ";\n")
  if(keep_single) out = restore_single_quotes(tidy = out, messy = x)
  out
}, "x", USE.NAMES = F)

restore_single_quotes = function(tidy, messy){
  s = single_quoted(messy)
  pat = quotes(s, single = TRUE)
  names(pat) = quotes(s, single = FALSE)
  str_replace_all(string = tidy, pattern = pat)
}

single_quoted = function(x){
  if(!safe_grepl("'", x)) return(character(0))
  y = str_split(x, "'")[[1]]
  y[seq(from = 2, to = length(y), by = 2)]
}
