## ----suppression, echo = F-----------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
clean(destroy = TRUE)

## ----noeval2, eval = FALSE-----------------------------------------------
#  example_drake("basic") # Write the code files.
#  examples_drake() # List the other examples.
#  vignette("quickstart") # Same as https://cran.r-project.org/package=drake/vignettes/quickstart.html

## ----libs----------------------------------------------------------------
library(knitr)
library(drake)

## ----sim-----------------------------------------------------------------
simulate = function(n){
  data.frame(
    x = stats::rnorm(n), # Drake tracks calls like `pkg::fn()` (namespaced functions).
    y = rpois(n, 1)
  )
}

## ----reg-----------------------------------------------------------------
reg1 = function(d){
  lm(y ~ + x, data = d)
}

reg2 = function(d){
  d$x2 = d$x^2
  lm(y ~ x2, data = d)
}

## ----knit----------------------------------------------------------------
my_knit = function(file, ...){
  knit(file)
}

## ----file----------------------------------------------------------------
lines = c(
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
  "readd(coef_regression2_small)", # Return an object from the drake cache.
  "loadd(large)", # Load an object from the drake cache into your workspace.
  "head(large)",
  "```")
writeLines(lines, "report.Rmd")

## ----previewmyplan-------------------------------------------------------
load_basic_example()
my_plan

## ----checkdeps-----------------------------------------------------------
deps(reg2)
deps(my_plan$command[1]) # report.Rmd is single-quoted because it is a file dependency.
deps(my_plan$command[16])

## ----tracked-------------------------------------------------------------
tracked(my_plan, targets = "small")
tracked(my_plan)

## ----check---------------------------------------------------------------
check(my_plan)

## ----datasets------------------------------------------------------------
my_datasets = plan(
  small = simulate(5),
  large = simulate(50))
my_datasets

## ----expand--------------------------------------------------------------
expand(my_datasets, values = c("rep1", "rep2"))

## ----methods-------------------------------------------------------------
methods = plan(
  regression1 = reg1(..dataset..),
  regression2 = reg2(..dataset..))
methods

## ----analyses------------------------------------------------------------
my_analyses = analyses(methods, data = my_datasets)
my_analyses

## ----summaries-----------------------------------------------------------
summary_types = plan(
  summ = suppressWarnings(summary(..analysis..)), # Occasionally there is a perfect regression fit.
  coef = coef(..analysis..))
summary_types

results = summaries(summary_types, analyses = my_analyses, 
  datasets = my_datasets, gather = NULL)
results

## ----reportdeps----------------------------------------------------------
load_in_report = plan(
  report_dependencies = c(small, large, coef_regression2_small))
load_in_report

## ----reportplan----------------------------------------------------------
report = plan(
  report.md = my_knit('report.Rmd', report_dependencies),
  file_targets = TRUE, strings_in_dots = "filenames")
report

## ----wholeplan-----------------------------------------------------------
my_plan = rbind(report, my_datasets, load_in_report, my_analyses, results)
my_plan

## ------------------------------------------------------------------------
df = plan(data = simulate(center = MU, scale = SIGMA))
df
df = expand(df, values = c("rep1", "rep2"))
df
evaluate(df, wildcard = "MU", values = 1:2)
evaluate(df, wildcard = "MU", values = 1:2, expand = FALSE)
evaluate(df, rules = list(MU = 1:2, SIGMA = c(0.1, 1)), expand = FALSE)
evaluate(df, rules = list(MU = 1:2, SIGMA = c(0.1, 1, 10)))
gather(df)
gather(df, target = "my_summaries", gather = "rbind")

## ----firstmake-----------------------------------------------------------
outdated(my_plan, verbose = FALSE) # These are the targets that need to be (re)built.
missed(my_plan, verbose = FALSE) # Make sure nothing is missing from your workspace.

## ----firstmakeforreal----------------------------------------------------
make(my_plan)

## ----autoload------------------------------------------------------------
"report_dependencies" %in% ls() # Should be TRUE.

## ----plotgraphfirstmake--------------------------------------------------
outdated(my_plan, verbose = FALSE) # Everything is up to date.
build_times(digits = 4) # How long did it take to make each target?

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
# read_graph() # Plots the graph of the workflow you just ran.
head(progress()) # See also in_progress()
# session(): sessionInfo() of the last call to make()
progress(large)

## ----uptodateinvig-------------------------------------------------------
make(my_plan)

## ----changereg2invignette------------------------------------------------
reg2 = function(d){
  d$x3 = d$x^3
  lm(y ~ x3, data = d)
}

## ----plotwithreg2--------------------------------------------------------
outdated(my_plan, verbose = FALSE)

## ----remakewithreg2------------------------------------------------------
make(my_plan)

## ----trivial-------------------------------------------------------------
reg2 = function(d){
  d$x3 = d$x^3
    lm(y ~ x3, data = d) # I indented here.
}
outdated(my_plan, verbose = FALSE) # Everything is up to date.

## ----newstuff------------------------------------------------------------
new_simulation = function(n){
  data.frame(x = rnorm(n), y = rnorm(n))
}

additions = plan(
  new_data = new_simulation(36) + sqrt(10))  
additions

my_plan = rbind(my_plan, additions)
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
reg2 = function(d){ # Change a dependency.
  d$x3 = d$x^3
  lm(y ~ x3, data = d)
}

## ----binbash, eval = FALSE-----------------------------------------------
#  #!/bin/bash
#  shift
#  echo "module load R; $*" | qsub -sync y -cwd -j y

## ----cluster, eval = FALSE-----------------------------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 4,
#    prepend = "SHELL=srun")

## ----nohup, eval = FALSE-------------------------------------------------
#  nohup nice -19 R CMD BATCH script.R &

## ----endofline, echo = F-------------------------------------------------
clean(destroy = TRUE) # Totally remove the hidden .drake/ cache.
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db")) # Clean up other files.

