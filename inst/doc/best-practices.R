## ----cautionstart, echo = F----------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
suppressMessages(suppressWarnings(library(magrittr)))
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))
knitr::opts_chunk$set(
  collapse = TRUE,
  error = TRUE,
  warning = TRUE
)
tmp <- file.create("data.csv")

## ----sourcefunctions, eval = FALSE---------------------------------------
#  # Load functions get_data(), analyze_data, and summarize_results()
#  source("my_functions.R")

## ----storecode1----------------------------------------------------------
good_plan <- drake_plan(
  my_data = get_data('data.csv'), # External files need to be in commands explicitly. # nolint
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
  my_data = source('get_data.R'),           # nolint
  my_analysis = source('analyze_data.R'),   # nolint
  my_summaries = source('summarize_data.R') # nolint
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

## ----rmfiles_caution, echo = FALSE---------------------------------------
clean(destroy = TRUE, verbose = FALSE)
file.remove()
unlink(
  c(
    "data.csv", "Makefile", "report.Rmd",
    "shell.sh", "STDIN.o*", "Thumbs.db"
  )
)

