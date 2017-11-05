## ---- echo = FALSE-------------------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
knitr::opts_chunk$set(eval = FALSE)

## ----graphoutdated-------------------------------------------------------
#  library(drake)
#  load_basic_example()
#  plot_graph(my_plan)

## ----graphmake-----------------------------------------------------------
#  make(my_plan, jobs = 4)
#  plot_graph(my_plan)

## ----reg2graphvisual-----------------------------------------------------
#  reg2 <- function(d){
#    d$x3 <- d$x ^ 3
#    lm(y ~ x3, data = d)
#  }
#  plot_graph(my_plan)

## ----subsetgraph---------------------------------------------------------
#  plot_graph(my_plan, subset = c("regression2_small", "'report.md'"))

## ----targetsonly---------------------------------------------------------
#  plot_graph(my_plan, targets_only = TRUE)

## ----fromout-------------------------------------------------------------
#  plot_graph(my_plan, from = c("regression2_small", "regression2_large"))

## ----fromin--------------------------------------------------------------
#  plot_graph(my_plan, from = "small", mode = "in")

## ----fromall-------------------------------------------------------------
#  plot_graph(my_plan, from = "small", mode = "all", order = 1)

## ----smallplan, eval = TRUE----------------------------------------------
f <- function(x){
  x
}
small_plan <- workplan(a = 1, b = f(2))
small_plan

## ----plotgraphusualsmall-------------------------------------------------
#  plot_graph(small_plan)

## ----plotgraphsmalldistributed-------------------------------------------
#  
#  plot_graph(small_plan, parallelism = "future_lapply")

## ----listbackendsgraph, eval = TRUE--------------------------------------
parallelism_choices()
parallelism_choices(distributed_only = TRUE)

## ----lookupparallelism---------------------------------------------------
#  ?parallelism_choices

