# Get dependencies in strings of code using pryr::call_tree()
dep = function(x = NULL) vdep(x) %>% unlist() %>% as.character() %>%
  unique()

sdep = function(x){
  if(!length(x)) return(character(0))
  if(is.na(x)) return(character(0))
  tidied = tidy(x, keep_single = FALSE)
  nback1 = str_count(x, pattern = "`")
  out = capture.output(parse(text = tidied) %>% call_tree()) %>%
    gsub(pattern = "^ *\\\\- `?", replacement = "") %>%
    str_trim(side = "both") %>%
    unique() %>%
    parseable() %>%
    gsub(pattern = "^\"|\"$", replacement = "'") %>%
    vars_and_files(text = x)
  nback2 = paste(out, collapse = "") %>% str_count(pattern = "`")
  if(nback1 != nback2)
    warning("you confused drake's parser with the backtick symbol `.",
      " Surround backticks in escaped quotes or beware!")
  subset(out, nchar(out) > 0)
}

vdep = Vectorize(sdep, vectorize.args = "x", SIMPLIFY = TRUE)

parseable = Vectorize(function(x){
  if(tryCatch({parse(text = x); FALSE}, error = function(e) TRUE))
    return("")
  is_numeric = !is.na(suppressWarnings(as.numeric(x)))
  if(is_numeric) return("")
  x
}, "x", SIMPLIFY = TRUE)

vars_and_files = function(x, text){
  x[!is_quoted(x) | sapply(x, safe_grepl, x = text)]
}

is_file = function(x = NULL){
  safe_grepl(pattern = "^[']", x = x) &
    safe_grepl(pattern = "[']$", x = x)
}

is_not_file = function(x = NULL){
  !is_file(x)
}

is_quoted = Vectorize(function(x){
  safe_grepl(pattern = "^[\"']", x = x) &
    safe_grepl(pattern = "[\"']$", x = x)
}, "x")

safe_grepl = function(pattern, x){
  tryCatch(grepl(pattern, x), error = function(e) FALSE)
}

cycle_msg = paste(
  "You have circular dependencies in your workflow plan.",
  "If output A depends on output B, then B cannot depend on A."
)
