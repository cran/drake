## ----suppression, echo = F-----------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))
knitr::opts_chunk$set(
  collapse = TRUE,
  error = TRUE,
  warning = TRUE
)

## ----quickstartquickstart, eval = FALSE----------------------------------
#  library(drake)
#  load_basic_example()            # Get the code with drake_example("basic").
#  config <- drake_config(my_plan) # Master configuration list
#  vis_drake_graph(config)         # Hover, click, drag, zoom, pan.
#  make(my_plan)                   # Run the workflow.
#  outdated(config)                # Everything is up to date.

## ----quickdebug, eval = FALSE--------------------------------------------
#  failed()                 # Targets that failed in the most recent `make()`
#  diagnose()               # Targets that failed in any previous `make()`
#  error <- diagnose(large) # Most recent verbose error log of `large`
#  str(error)               # Object of class "error"
#  error$calls              # Call stack / traceback

## ----noeval2, eval = FALSE-----------------------------------------------
#  drake_example("basic") # Write the code files.
#  drake_examples()       # List the other examples.
#  vignette("quickstart") # This vignette

## ----mtcarsquickstart----------------------------------------------------
# ?mtcars # more info
head(mtcars)

## ----libs----------------------------------------------------------------
library(knitr) # Drake knows which packages you load.
library(drake)

## ----sim-----------------------------------------------------------------
simulate <- function(n){
  # Pick a random set of cars to bootstrap from the mtcars data.
  index <- sample.int(n = nrow(mtcars), size = n, replace = TRUE)
  data <- mtcars[index, ]

  # x is the car's weight, and y is the fuel efficiency.
  data.frame(
    x = data$wt,
    y = data$mpg
  )
}

## ----reg-----------------------------------------------------------------
# Is fuel efficiency linearly related to weight?
reg1 <- function(d){
  lm(y ~ + x, data = d)
}

# Is fuel efficiency related to the SQUARE of the weight?
reg2 <- function(d){
  d$x2 <- d$x ^ 2
  lm(y ~ x2, data = d)
}

## ----file----------------------------------------------------------------
path <- file.path("examples", "basic", "report.Rmd")
report_file <- system.file(path, package = "drake", mustWork = TRUE)
file.copy(from = report_file, to = getwd(), overwrite = TRUE)

## ----readlinesofreport---------------------------------------------------
cat(readLines("report.Rmd"), sep = "\n")

## ----robjimportsquickstart-----------------------------------------------
ls()

## ----filesystemimportsquickstart-----------------------------------------
list.files()

## ----previewmyplan-------------------------------------------------------
load_basic_example() # Get the code with drake_example("basic").
my_plan

## ----graph1quick, eval = FALSE-------------------------------------------
#  # Hover, click, drag, zoom, and pan.
#  config <- drake_config(my_plan)
#  vis_drake_graph(config, width = "100%", height = "500px") # Also drake_graph()

## ----checkdeps-----------------------------------------------------------
deps(reg2)

deps(my_plan$command[1]) # Files like report.Rmd are single-quoted.

deps(my_plan$command[nrow(my_plan)])

## ----tracked-------------------------------------------------------------
tracked(my_plan, targets = "small")

tracked(my_plan)

## ----check---------------------------------------------------------------
check_plan(my_plan)

## ----datasets------------------------------------------------------------
my_datasets <- drake_plan(
  small = simulate(48),
  large = simulate(64))
my_datasets

## ----expand--------------------------------------------------------------
expand_plan(my_datasets, values = c("rep1", "rep2"))

## ----methods-------------------------------------------------------------
methods <- drake_plan(
  regression1 = reg1(dataset__),
  regression2 = reg2(dataset__))
methods

## ----analyses------------------------------------------------------------
my_analyses <- plan_analyses(methods, data = my_datasets)
my_analyses

## ----summaries-----------------------------------------------------------
summary_types <- drake_plan(
  summ = suppressWarnings(summary(analysis__$residuals)),
  coef = suppressWarnings(summary(analysis__))$coefficients
)
summary_types

results <- plan_summaries(summary_types, analyses = my_analyses,
  datasets = my_datasets, gather = NULL)
results

## ----reportplan----------------------------------------------------------
report <- drake_plan(
  report.md = knit('report.Rmd', quiet = TRUE), # nolint
  file_targets = TRUE, strings_in_dots = "filenames")
report

## ----wholeplan-----------------------------------------------------------
my_plan <- rbind(report, my_datasets, my_analyses, results)
my_plan

## ----more_expansions_and_plans-------------------------------------------
df <- drake_plan(data = simulate(center = MU, scale = SIGMA))
df

df <- expand_plan(df, values = c("rep1", "rep2"))
df

evaluate_plan(df, wildcard = "MU", values = 1:2)

evaluate_plan(df, wildcard = "MU", values = 1:2, expand = FALSE)

evaluate_plan(df, rules = list(MU = 1:2, SIGMA = c(0.1, 1)), expand = FALSE)

evaluate_plan(df, rules = list(MU = 1:2, SIGMA = c(0.1, 1, 10)))

gather_plan(df)

gather_plan(df, target = "my_summaries", gather = "rbind")

## ----firstmake-----------------------------------------------------------
config <- drake_config(my_plan, verbose = FALSE)
outdated(config) # Targets that need to be (re)built.

missed(config) # Checks your workspace.

## ----firstmakeforreal----------------------------------------------------
make(my_plan)

## ----getmtcarsanswer-----------------------------------------------------
readd(coef_regression2_small)

## ----autoload------------------------------------------------------------
ls()

## ----plotgraphfirstmake--------------------------------------------------
outdated(config) # Everything is up to date.

build_times(digits = 4) # How long did it take to make each target?

## ----graph2quick, eval = FALSE-------------------------------------------
#  # Hover, click, drag, zoom, and pan.
#  vis_drake_graph(config, width = "100%", height = "500px")

## ----dfgraph2quick, eval = FALSE-----------------------------------------
#  dataframes_graph(config)

## ----cache---------------------------------------------------------------
readd(coef_regression2_large)

loadd(small)

head(small)

rm(small)
cached(small, large)

cached()

built()

imported()

head(read_drake_plan())

head(progress()) # See also in_progress()

progress(large)

# drake_session() # sessionInfo() of the last make() # nolint

## ----uptodateinvig-------------------------------------------------------
config <- make(my_plan) # Will use config later. See also drake_config().

## ----changereg2invignette------------------------------------------------
reg2 <- function(d) {
  d$x3 <- d$x ^ 3
  lm(y ~ x3, data = d)
}

## ----plotwithreg2--------------------------------------------------------
outdated(config)

## ----depprofile----------------------------------------------------------
dependency_profile(target = "regression2_small", config = config)

config$cache$get_hash(key = "small") # same

config$cache$get_hash(key = "reg2") # different

## ----graph3quick, eval = FALSE-------------------------------------------
#  # Hover, click, drag, zoom, and pan.
#  # Same as drake_graph():
#  vis_drake_graph(config, width = "100%", height = "500px")

## ----remakewithreg2------------------------------------------------------
make(my_plan)

## ----trivial-------------------------------------------------------------
reg2 <- function(d) {
  d$x3 <- d$x ^ 3
    lm(y ~ x3, data = d) # I indented here.
}
outdated(config) # Everything is up to date.

## ----newstuff------------------------------------------------------------
new_simulation <- function(n){
  data.frame(x = rnorm(n), y = rnorm(n))
}

additions <- drake_plan(
  new_data = new_simulation(36) + sqrt(10))
additions

my_plan <- rbind(my_plan, additions)
my_plan

make(my_plan)

## ----cleanup-------------------------------------------------------------
# Uncaches individual targets and imported objects.
clean(small, reg1, verbose = FALSE)
clean(verbose = FALSE) # Cleans all targets out of the cache.
drake_gc(verbose = FALSE) # Just garbage collection.
clean(destroy = TRUE, verbose = FALSE) # removes the cache entirely

## ----endofline_quickstart, echo = F--------------------------------------
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

