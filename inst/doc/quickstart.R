## ---- echo = F-----------------------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
clean(destroy = TRUE)

## ----example-------------------------------------------------------------
examples_drake()

## ----basic, eval = FALSE-------------------------------------------------
#  example_drake("basic")

## ----libs----------------------------------------------------------------
library(knitr)
library(rmarkdown)
library(drake)

## ----sim-----------------------------------------------------------------
simulate = function(n){
  data.frame(
    x = rnorm(n),
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
  knit(file) # drake knows you loaded the knitr package
}

my_render = function(file, ...){
  render(file) # drake knows you loaded the rmarkdown package
}

## ----file----------------------------------------------------------------
# Write the R Markdown source for a dynamic knitr report
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
  "readd(coef_regression2_small)",
  "loadd(large)",
  "head(large)",
  "```"
)

writeLines(lines, "report.Rmd")

## ----datasets------------------------------------------------------------
datasets = plan(
  small = simulate(5),
  large = simulate(50))
datasets

## ----expand--------------------------------------------------------------
expand(datasets, values = c("rep1", "rep2"))

## ----methods-------------------------------------------------------------
methods = plan(
  regression1 = reg1(..dataset..),
  regression2 = reg2(..dataset..))
methods

## ----analyses------------------------------------------------------------
analyses = analyses(methods, data = datasets)
analyses

## ----summaries-----------------------------------------------------------
summary_types = plan(summ = summary(..analysis..),
                     coef = coef(..analysis..))
summary_types

results = summaries(summary_types, analyses, datasets, 
  gather = NULL)
results

## ----reportdeps----------------------------------------------------------
load_in_report = plan(
  report_dependencies = c(small, large, coef_regression2_small))
load_in_report

## ----reportplan----------------------------------------------------------
report = plan(
  report.md = my_knit('report.Rmd', report_dependencies),
## The html report requires pandoc. Commented out.
## report.html = my_render('report.md', report_dependencies),
  file_targets = TRUE, strings_in_dots = "filenames")
report

## ----wholeplan-----------------------------------------------------------
plan = rbind(report, datasets, load_in_report, analyses, results)
plan

## ----tracked-------------------------------------------------------------
"small" %in% tracked(plan)
tracked(plan, targets = "small")
tracked(plan)

## ----check---------------------------------------------------------------
check(plan)

## ----firstmake-----------------------------------------------------------
make(plan)

## ----autoload------------------------------------------------------------
"report_dependencies" %in% ls() # Should be TRUE.

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
# read_graph() # reads/plots the tree structure of your workflow plan
head(status()) # What did you last build? Did it finish?
# session(): sessionInfo() of the last call to make()
status(large)

## ----uptodate------------------------------------------------------------
make(plan)

## ----changereg2----------------------------------------------------------
reg2 = function(d){
  d$x3 = d$x^3
  lm(y ~ x3, data = d)
}

## ----partialupdate-------------------------------------------------------
make(plan)

## ----trivial-------------------------------------------------------------
reg2 = function(d){
  d$x3 = d$x^3
    lm(y ~ x3, data = d) # I indented here.
}
make(plan) 

## ----newstuff------------------------------------------------------------
new_simulation = function(n){
  data.frame(x = rnorm(n), y = rnorm(n))
}

additions = plan(
  new_data = new_simulation(36) + sqrt(10))  
additions

plan = rbind(plan, additions)
plan

make(plan)

## ----cleanup-------------------------------------------------------------
clean(small, reg1) # uncaches individual targets and imported objects
clean() # cleans all targets out of the cache
clean(destroy = TRUE) # removes the cache entirely

## ----endofline, echo = F-------------------------------------------------
clean(destroy = TRUE) # Totally remove the hidden .drake/ cache.
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*")) # Clean up other files.

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

