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

## ----file----------------------------------------------------------------
lines <- c(
  "---",
  "title: Example Report",
  "author: You",
  "output: html_document",
  "---",
  "",
  "Look how I read outputs from the drake cache.",
  "Drake notices that `small`, `coef_regression2_small`,",
  "and `large` are dependencies of the",
  "future compiled output report file target, `report.md`.",
  "Just be sure that the workflow plan command for the target `'report.md'`",
  "has an explicit call to `knit()`, something like `knit('report.Rmd')` or",
  "`knitr::knit(input = 'report.Rmd', quiet = TRUE)`.",
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
deps(my_plan$command[nrow(my_plan)])

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
  regression1 = reg1(..dataset..), # nolint
  regression2 = reg2(..dataset..)) # nolint
methods

## ----analyses------------------------------------------------------------
my_analyses <- analyses(methods, data = my_datasets)
my_analyses

## ----summaries-----------------------------------------------------------
summary_types <- plan(
  summ = suppressWarnings(summary(..analysis..)), # nolint
  coef = coefficients(..analysis..)) # nolint
summary_types

results <- summaries(summary_types, analyses = my_analyses,
  datasets = my_datasets, gather = NULL)
results

## ----reportplan----------------------------------------------------------
report <- plan(
  report.md = knit('report.Rmd', quiet = TRUE), # nolint
  file_targets = TRUE, strings_in_dots = "filenames")
report

## ----wholeplan-----------------------------------------------------------
my_plan <- rbind(report, my_datasets, my_analyses, results)
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
ls()

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

## ----endofline_quickstart, echo = F--------------------------------------
clean(destroy = TRUE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

