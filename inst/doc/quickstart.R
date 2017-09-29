## ----suppression, echo = F-----------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
clean(destroy = TRUE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

## ----quickstartquickstart, eval = FALSE----------------------------------
#  library(drake)
#  load_basic_example() # Also (over)writes report.Rmd.
#  plot_graph(my_plan) # Hover, click, drag, zoom, pan.
#  make(my_plan) # Run the workflow.
#  make(my_plan) # Check that everything is already up to date.

## ----noeval2, eval = FALSE-----------------------------------------------
#  example_drake("basic") # Write the code files.
#  examples_drake() # List the other examples.
#  vignette("quickstart") # This vignette

## ----examplesquick, eval = FALSE-----------------------------------------
#  load_basic_example()
#  drake_tip()
#  examples_drake()
#  example_drake()

## ----planquick, eval = FALSE---------------------------------------------
#  plan()
#  analyses()
#  summaries()
#  evaluate()
#  expand()
#  gather()
#  wildcard() # from the wildcard package

## ----depquick, eval = FALSE----------------------------------------------
#  outdated()
#  missed()
#  plot_graph()
#  dataframes_graph()
#  render_graph()
#  read_graph()
#  deps()
#  tracked()

## ----cachequicklist, eval = FALSE----------------------------------------
#  clean()
#  cached()
#  imported()
#  built()
#  readd()
#  loadd()
#  find_project()
#  find_cache()

## ----timesquick, eval = FALSE--------------------------------------------
#  build_times()
#  predict_runtime()
#  rate_limiting_times()

## ----speedquick, eval = FALSE--------------------------------------------
#  make() # with jobs > 2
#  max_useful_jobs()
#  parallelism_choices()
#  shell_file()

## ----cachequick, eval = FALSE--------------------------------------------
#  available_hash_algos()
#  cache_path()
#  cache_types()
#  configure_cache()
#  default_long_hash_algo()
#  default_short_hash_algo()
#  long_hash()
#  short_hash()
#  new_cache()
#  recover_cache()
#  this_cache()
#  type_of_cache()

## ----debugquick, eval = FALSE--------------------------------------------
#  check()
#  session()
#  in_progress()
#  progress()
#  config()
#  read_config()

## ----libs----------------------------------------------------------------
library(knitr)
library(drake)

## ----sim-----------------------------------------------------------------
simulate <- function(n){
  data.frame(
    x = stats::rnorm(n),
    y = rpois(n, 1)
  )
}

## ----reg-----------------------------------------------------------------
reg1 <- function(d){
  lm(y ~ + x, data = d)
}

reg2 <- function(d){
  d$x2 <- d$x ^ 2
  lm(y ~ x2, data = d)
}

## ----knit----------------------------------------------------------------
my_knit <- function(file, ...){
  knit(file)
}

## ----file----------------------------------------------------------------
lines <- c(
  "---",
  "title: Example Report",
  "author: You",
  "output: html_document",
  "---",
  "",
  "Look how I read outputs from the drake cache.",
  "",
  "```{r example_chunk}",
  "library(drake)",
  "readd(small)",
  "readd(coef_regression2_small)",
  "loadd(large)",
  "head(large)",
  "```")
writeLines(lines, "report.Rmd")

## ----previewmyplan-------------------------------------------------------
load_basic_example()
my_plan

## ----graph1quick, eval = FALSE-------------------------------------------
#  # Hover, click, drag, zoom, and pan.
#  plot_graph(my_plan, width = "100%", height = "500px")

## ----checkdeps-----------------------------------------------------------
deps(reg2)
deps(my_plan$command[1]) # Files like report.Rmd are single-quoted.
deps(my_plan$command[16])

## ----tracked-------------------------------------------------------------
tracked(my_plan, targets = "small")
tracked(my_plan)

## ----check---------------------------------------------------------------
check(my_plan)

## ----datasets------------------------------------------------------------
my_datasets <- plan(
  small = simulate(5),
  large = simulate(50))
my_datasets

## ----expand--------------------------------------------------------------
expand(my_datasets, values = c("rep1", "rep2"))

## ----methods-------------------------------------------------------------
methods <- plan(
  regression1 = reg1(..dataset..),
  regression2 = reg2(..dataset..))
methods

## ----analyses------------------------------------------------------------
my_analyses <- analyses(methods, data = my_datasets)
my_analyses

## ----summaries-----------------------------------------------------------
summary_types <- plan(
  summ = suppressWarnings(summary(..analysis..)),
  coef = coef(..analysis..))
summary_types

results <- summaries(summary_types, analyses = my_analyses,
  datasets = my_datasets, gather = NULL)
results

## ----reportdeps----------------------------------------------------------
load_in_report <- plan(
  report_dependencies = c(small, large, coef_regression2_small))
load_in_report

## ----reportplan----------------------------------------------------------
report <- plan(
  report.md = my_knit('report.Rmd', report_dependencies), # nolint
  file_targets = TRUE, strings_in_dots = "filenames")
report

## ----wholeplan-----------------------------------------------------------
my_plan <- rbind(report, my_datasets, load_in_report, my_analyses, results)
my_plan

## ----more_expansions_and_plans-------------------------------------------
df <- plan(data = simulate(center = MU, scale = SIGMA))
df
df <- expand(df, values = c("rep1", "rep2"))
df
evaluate(df, wildcard = "MU", values = 1:2)
evaluate(df, wildcard = "MU", values = 1:2, expand = FALSE)
evaluate(df, rules = list(MU = 1:2, SIGMA = c(0.1, 1)), expand = FALSE)
evaluate(df, rules = list(MU = 1:2, SIGMA = c(0.1, 1, 10)))
gather(df)
gather(df, target = "my_summaries", gather = "rbind")

## ----firstmake-----------------------------------------------------------
outdated(my_plan, verbose = FALSE) # Targets that need to be (re)built.
missed(my_plan, verbose = FALSE) # Checks your workspace.

## ----firstmakeforreal----------------------------------------------------
make(my_plan)

## ----autoload------------------------------------------------------------
"report_dependencies" %in% ls() # Should be TRUE.

## ----plotgraphfirstmake--------------------------------------------------
outdated(my_plan, verbose = FALSE) # Everything is up to date.
build_times(digits = 4) # How long did it take to make each target?

## ----graph2quick, eval = FALSE-------------------------------------------
#  # Hover, click, drag, zoom, and pan.
#  plot_graph(my_plan, width = "100%", height = "500px")

## ----dfgraph2quick, eval = FALSE-----------------------------------------
#  dataframes_graph(my_plan)

## ----cache---------------------------------------------------------------
readd(coef_regression2_large)
loadd(small)
head(small)
rm(small)
cached(small, large)
cached()
built()
imported()
head(read_plan())
head(progress()) # See also in_progress()
progress(large)
session() # of the last call to make()

## ----uptodateinvig-------------------------------------------------------
make(my_plan)

## ----changereg2invignette------------------------------------------------
reg2 <- function(d) {
  d$x3 <- d$x ^ 3
  lm(y ~ x3, data = d)
}

## ----plotwithreg2--------------------------------------------------------
outdated(my_plan, verbose = FALSE)

## ----graph3quick, eval = FALSE-------------------------------------------
#  # Hover, click, drag, zoom, and pan.
#  plot_graph(my_plan, width = "100%", height = "500px")

## ----remakewithreg2------------------------------------------------------
make(my_plan)

## ----trivial-------------------------------------------------------------
reg2 <- function(d) {
  d$x3 <- d$x ^ 3
    lm(y ~ x3, data = d) # I indented here.
}
outdated(my_plan, verbose = FALSE) # Everything is up to date.

## ----newstuff------------------------------------------------------------
new_simulation <- function(n){
  data.frame(x = rnorm(n), y = rnorm(n))
}

additions <- plan(
  new_data = new_simulation(36) + sqrt(10))
additions

my_plan <- rbind(my_plan, additions)
my_plan

make(my_plan)

## ----cleanup-------------------------------------------------------------
clean(small, reg1) # uncaches individual targets and imported objects
clean() # cleans all targets out of the cache
clean(destroy = TRUE) # removes the cache entirely

## ----plotgraph-----------------------------------------------------------
clean()
load_basic_example()
make(my_plan, jobs = 2, verbose = FALSE) # Parallelize over 2 jobs.
# Change a dependency.
reg2 <- function(d) {
  d$x3 <- d$x ^ 3
  lm(y ~ x3, data = d)
}

## ----graph4quick, eval = FALSE-------------------------------------------
#  # Hover, click, drag, zoom, and pan.
#  plot_graph(my_plan, width = "100%", height = "500px")

## ----hpcquick, eval = FALSE----------------------------------------------
#  library(drake)
#  load_basic_example()
#  plot_graph(my_plan) # Set targets_only to TRUE for smaller graphs.
#  max_useful_jobs(my_plan) # 8
#  max_useful_jobs(my_plan, imports = "files") # 8
#  max_useful_jobs(my_plan, imports = "all") # 10
#  max_useful_jobs(my_plan, imports = "none") # 8
#  make(my_plan, jobs = 4)
#  plot_graph(my_plan)
#  # Ignore the targets already built.
#  max_useful_jobs(my_plan) # 1
#  max_useful_jobs(my_plan, imports = "files") # 1
#  max_useful_jobs(my_plan, imports = "all") # 10
#  max_useful_jobs(my_plan, imports = "none") # 0
#  # Change a function so some targets are now out of date.
#  reg2 <- function(d){
#    d$x3 <- d$x ^ 3
#    lm(y ~ x3, data = d)
#  }
#  plot_graph(my_plan)
#  max_useful_jobs(my_plan) # 4
#  max_useful_jobs(my_plan, from_scratch = TRUE) # 8
#  max_useful_jobs(my_plan, imports = "files") # 4
#  max_useful_jobs(my_plan, imports = "all") # 10
#  max_useful_jobs(my_plan, imports = "none") # 4

## ----cluster, eval = FALSE-----------------------------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 4,
#    prepend = "SHELL=srun")

## ----makefileargsquick, eval = FALSE-------------------------------------
#  make(..., parallelism = "Makefile", jobs = 2, args = "--jobs=4")

## ----endofline_quickstart, echo = F--------------------------------------
clean(destroy = TRUE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

