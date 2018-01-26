## ---- echo = FALSE-------------------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
knitr::opts_chunk$set(eval = FALSE)
knitr::opts_chunk$set(
  collapse = TRUE,
  error = TRUE,
  warning = TRUE
)

## ----graphoutdated-------------------------------------------------------
#  library(drake)
#  load_basic_example() # Get the code with drake_example("basic").
#  config <- drake_config(my_plan)
#  vis_drake_graph(config) # Same as drake_graph()

## ----graphmake-----------------------------------------------------------
#  config <- make(my_plan, jobs = 4, verbose = FALSE)
#  vis_drake_graph(config)

## ----reg2graphvisual-----------------------------------------------------
#  reg2 <- function(d){
#    d$x3 <- d$x ^ 3
#    lm(y ~ x3, data = d)
#  }
#  vis_drake_graph(config)

## ----subsetgraph---------------------------------------------------------
#  vis_drake_graph(config, subset = c("regression2_small", "'report.md'"))

## ----targetsonly---------------------------------------------------------
#  vis_drake_graph(config, targets_only = TRUE)

## ----fromout-------------------------------------------------------------
#  vis_drake_graph(config, from = c("regression2_small", "regression2_large"))

## ----fromin--------------------------------------------------------------
#  vis_drake_graph(config, from = "small", mode = "in")

## ----fromall-------------------------------------------------------------
#  vis_drake_graph(config, from = "small", mode = "all", order = 1)

