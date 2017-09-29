## ----suppression_timing, echo = F----------------------------------------
suppressMessages(suppressWarnings(library(drake)))
clean(destroy = TRUE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

## ----timing_intro--------------------------------------------------------
library(drake)
load_basic_example()
make(my_plan, jobs = 2, verbose = FALSE) # See also max_useful_jobs(my_plan).
build_times(digits = 8) # From the cache.
build_times(digits = 8, targets_only = TRUE)

## ----predict_runtime-----------------------------------------------------
predict_runtime(
  my_plan,
  digits = 8,
  verbose = FALSE,
  targets_only = TRUE
)

## ----predict_runtime_scratch---------------------------------------------
predict_runtime(
  my_plan,
  from_scratch = TRUE,
  digits = 8,
  verbose = FALSE,
  targets_only = TRUE
)

## ----changedep_timing----------------------------------------------------
reg2 <- function(d){
  d$x3 <- d$x ^ 3
  lm(y ~ x3, data = d)
}
predict_runtime(
  my_plan,
  digits = 8,
  verbose = FALSE,
  targets_only = TRUE
)

## ----future_jobs---------------------------------------------------------
predict_runtime(
  my_plan,
  future_jobs = 1,
  from_scratch = TRUE,
  digits = 8,
  verbose = FALSE,
  targets_only = TRUE
)
predict_runtime(
  my_plan,
  future_jobs = 2,
  from_scratch = TRUE,
  digits = 8,
  verbose = FALSE,
  targets_only = TRUE
)
predict_runtime(
  my_plan,
  future_jobs = 4,
  from_scratch = TRUE,
  digits = 8,
  verbose = FALSE,
  targets_only = TRUE
)

## ----faketiminggraph, eval = FALSE---------------------------------------
#  # Hover, click, drag, zoom, and pan.
#  plot_graph(my_plan, width = "100%", height = "500px")

## ----rate_limiting_targets-----------------------------------------------
rate_limiting_times(
  my_plan,
  from_scratch = TRUE,
  digits = 8,
  verbose = FALSE,
  targets_only = TRUE
)
rate_limiting_times(
  my_plan,
  future_jobs = 2,
  from_scratch = TRUE,
  digits = 8,
  verbose = FALSE,
  targets_only = TRUE
)
rate_limiting_times(
  my_plan,
  future_jobs = 4,
  from_scratch = TRUE,
  digits = 8,
  verbose = FALSE,
  targets_only = TRUE
)

## ----endofline_timing, echo = F------------------------------------------
clean(destroy = TRUE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

