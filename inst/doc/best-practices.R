## ----cautionstart, echo = F----------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
suppressMessages(suppressWarnings(library(magrittr)))
suppressMessages(suppressWarnings(library(curl)))
suppressMessages(suppressWarnings(library(httr)))
suppressMessages(suppressWarnings(library(R.utils)))
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))
knitr::opts_chunk$set(
  collapse = TRUE,
  error = TRUE,
  warning = TRUE
)
tmp <- file.create("data.csv")

## ----exampledrakewritingbestpractices, eval = FALSE----------------------
#  drake_example("basic")
#  drake_example("gsp")
#  drake_example("packages")

## ----sourcefunctions, eval = FALSE---------------------------------------
#  # Load functions get_data(), analyze_data, and summarize_results()
#  source("my_functions.R")

## ----storecode1----------------------------------------------------------
good_plan <- drake_plan(
  my_data = get_data(file_in("data.csv")), # External files need to be in commands explicitly. # nolint
  my_analysis = analyze_data(my_data),
  my_summaries = summarize_results(my_data, my_analysis)
)

good_plan

## ----visgood, eval = FALSE-----------------------------------------------
#  config <- drake_config(good_plan)
#  vis_drake_graph(config)

## ----makestorecode, eval = FALSE-----------------------------------------
#  make(good_plan)

## ----badsource-----------------------------------------------------------
bad_plan <- drake_plan(
  my_data = source(file_in("get_data.R")),
  my_analysis = source(file_in("analyze_data.R")),
  my_summaries = source(file_in("summarize_data.R"))
)

bad_plan

## ----visbad, eval = FALSE------------------------------------------------
#  config <- drake_config(bad_plan)
#  vis_drake_graph(config)

## ----revisitbasic--------------------------------------------------------
# Load all the functions and the workflow plan data frame, my_plan.
load_basic_example() # Get the code with drake_example("basic").

## ----revisitbasicgraph, eval = FALSE-------------------------------------
#  config <- drake_config(my_plan)
#  vis_drake_graph(config)

## ----nestingproblem------------------------------------------------------
library(digest)
g <- function(x){
  digest(x)
}
f <- function(x){
  g(x)
}
plan <- drake_plan(x = f(1))

# Here are the reproducibly tracked objects in the workflow.
tracked(plan)

# But the `digest()` function has dependencies too.
# Because `drake` knows `digest()` is from a package,
# it ignores these dependencies by default.
head(deps(digest), 10)

## ----nestingsolution-----------------------------------------------------
expose_imports(digest)
new_objects <- tracked(plan)
head(new_objects, 10)
length(new_objects)

# Now when you call `make()`, `drake` will dive into `digest`
# to import dependencies.

cache <- storr::storr_environment() # just for examples
make(plan, cache = cache)
head(cached(cache = cache), 10)
length(cached(cache = cache))

## ----rmfiles_caution, echo = FALSE---------------------------------------
clean(destroy = TRUE, verbose = FALSE)
file.remove("report.Rmd")
unlink(
  c(
    "data.csv", "Makefile", "report.Rmd",
    "shell.sh", "STDIN.o*", "Thumbs.db"
  )
)

## ----schoolswildcards1---------------------------------------------------
hard_plan <- drake_plan(
  credits = check_credit_hours(school__),
  students = check_students(school__),
  grads = check_graduations(school__),
  public_funds = check_public_funding(school__)
)

evaluate_plan(
  hard_plan,
  rules = list(school__ = c("schoolA", "schoolB", "schoolC"))
)

## ----rulesgridschools----------------------------------------------------
library(magrittr)
rules_grid <- tibble::tibble(
  school_ =  c("schoolA", "schoolB", "schoolC"),
  funding_ = c("public", "public", "private"),
) %>%
  tidyr::crossing(cohort_ = c("2012", "2013", "2014", "2015")) %>%
  dplyr::filter(!(school_ == "schoolB" & cohort_ %in% c("2012", "2013"))) %>%
  print()

## ----rulesgridevalplan---------------------------------------------------
drake_plan(
  credits = check_credit_hours("school_", "funding_", "cohort_"),
  students = check_students("school_", "funding_", "cohort_"),
  grads = check_graduations("school_", "funding_", "cohort_"),
  public_funds = check_public_funding("school_", "funding_", "cohort_"),
  strings_in_dots = "literals"
) %>% evaluate_plan(
    wildcard = "school_",
    values = rules_grid$school_,
    expand = TRUE
  ) %>%
  evaluate_plan(
    wildcard = "funding_",
    rules = rules_grid,
    expand = FALSE
  ) %>%
  DT::datatable()

## ----logs1---------------------------------------------------------------
library(drake)
library(R.utils) # For unzipping the files we download.
library(curl)    # For downloading data.
library(httr)    # For querying websites.

url <- "http://cran-logs.rstudio.com/2018/2018-02-09-r.csv.gz"

## ----logs2---------------------------------------------------------------
query <- HEAD(url)
timestamp <- query$headers[["last-modified"]]
timestamp

## ----logs3---------------------------------------------------------------
cranlogs_plan <- drake_plan(
  timestamp = HEAD(url)$headers[["last-modified"]],
  logs = get_logs(url, timestamp),
  strings_in_dots = "literals"
)
cranlogs_plan

## ----logs4---------------------------------------------------------------
cranlogs_plan$trigger <- c("always", "any")
cranlogs_plan

## ----logs5---------------------------------------------------------------
# The ... is just so we can write dependencies as function arguments
# in the workflow plan.
get_logs <- function(url, ...){
  curl_download(url, "logs.csv.gz")       # Get a big file.
  gunzip("logs.csv.gz", overwrite = TRUE) # Unzip it.
  out <- read.csv("logs.csv", nrows = 4)  # Extract the data you need.
  unlink(c("logs.csv.gz", "logs.csv"))    # Remove the big files
  out                                     # Value of the target.
}

## ----logs6---------------------------------------------------------------
make(cranlogs_plan)

readd(logs)

## ----endofline_bestpractices, echo = F-----------------------------------
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

