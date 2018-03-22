## ---- echo = F-----------------------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
suppressMessages(suppressWarnings(library(magrittr)))
unlink(".drake", recursive = TRUE)
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))
knitr::opts_chunk$set(
  collapse = TRUE,
  error = TRUE,
  warning = TRUE
)

## ----getthequickstartcode, eval = FALSE----------------------------------
#  drake_example("basic")

## ----mtcarsdrake1--------------------------------------------------------
# ?mtcars # more info
head(mtcars)

## ----drakeimportdrakermd-------------------------------------------------
load_basic_example(verbose = FALSE) # Get the code with drake_example("basic").

# Drake looks for data objects and functions in your R session environment
ls()

# and saved files in your file system.
list.files()

## ----myplandrakevig------------------------------------------------------
my_plan

## ----drake_plangeneration------------------------------------------------
library(magrittr)
dataset_plan <- drake_plan(
  small = simulate(5),
  large = simulate(50)
)
dataset_plan

analysis_methods <- drake_plan(
  regression = regNUMBER(dataset__) # nolint
) %>%
  evaluate_plan(wildcard = "NUMBER", values = 1:2)
analysis_methods

analysis_plan <- plan_analyses(
  plan = analysis_methods,
  datasets = dataset_plan
)
analysis_plan

whole_plan <- rbind(dataset_plan, analysis_plan)
whole_plan

## ----testquasiquoplan----------------------------------------------------
my_variable <- 5

drake_plan(
  a = !!my_variable,
  b = !!my_variable + 1,
  list = c(d = "!!my_variable")
)

drake_plan(
  a = !!my_variable,
  b = !!my_variable + 1,
  list = c(d = "!!my_variable"),
  tidy_evaluation = FALSE
)

## ----drakevisgraph, eval = FALSE-----------------------------------------
#  vis_drake_graph(my_plan)

## ----outdateddrake-------------------------------------------------------
config <- drake_config(my_plan, verbose = FALSE) # Master configuration list
outdated(config)

## ----firstmakedrake------------------------------------------------------
make(my_plan)

## ----getmtcarsanswer-----------------------------------------------------
readd(coef_regression2_small)

## ----makeuptodatedrake---------------------------------------------------
make(my_plan)

## ----reg2makedrake-------------------------------------------------------
reg2 <- function(d){
  d$x3 <- d$x ^ 3
  lm(y ~ x3, data = d)
}

make(my_plan)

## ----endofline_drake, echo = F-------------------------------------------
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

