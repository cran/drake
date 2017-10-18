## ---- echo = F-----------------------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
clean(destroy = TRUE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

## ----firstintroindrake---------------------------------------------------
library(drake)
load_basic_example() # Also (over)writes report.Rmd.
my_plan              # Each target is a file (single-quoted) or object.

## ----makedrakenoevalrmd, eval = FALSE------------------------------------
#  make(my_plan) # Run the commands to build the targets.

## ----devinstall, eval = FALSE--------------------------------------------
#  install.packages("drake") # latest CRAN release
#  devtools::install_github(
#    "wlandau-lilly/drake@v4.2.0",
#    build = TRUE
#  ) # GitHub release
#  devtools::install_github("wlandau-lilly/drake", build = TRUE) # dev version

## ----quickstartdrakermd, eval = FALSE------------------------------------
#  library(drake)
#  load_basic_example() # Also (over)writes report.Rmd.
#  plot_graph(my_plan)  # Hover, click, drag, zoom, pan.
#  outdated(my_plan)    # Which targets need to be (re)built?
#  missed(my_plan)      # Are you missing anything from your workspace?
#  check(my_plan)       # Are you missing files? Is your workflow plan okay?
#  make(my_plan)        # Run the workflow.
#  outdated(my_plan)    # Everything is up to date.
#  plot_graph(my_plan)  # The graph also shows what is up to date.

## ----examplesdrakermd, eval = FALSE--------------------------------------
#  example_drake("basic") # Write the code files of the canonical tutorial.
#  examples_drake()       # List the other examples.
#  vignette("quickstart") # See https://cran.r-project.org/package=drake/vignettes

## ----learndrakermd, eval = FALSE-----------------------------------------
#  load_basic_example()
#  drake_tip()
#  examples_drake()
#  example_drake()

## ----plandrakermd, eval = FALSE------------------------------------------
#  plan()
#  analyses()
#  summaries()
#  evaluate()
#  expand()
#  gather()
#  wildcard() # from the wildcard package

## ----draakedepsdrakermd, eval = FALSE------------------------------------
#  outdated()
#  missed()
#  plot_graph()
#  dataframes_graph()
#  render_graph()
#  read_graph()
#  deps()
#  knitr_deps
#  tracked()

## ----cachedrakermd, eval = FALSE-----------------------------------------
#  clean()
#  cached()
#  imported()
#  built()
#  readd()
#  loadd()
#  find_project()
#  find_cache()

## ----timesdrakermd, eval = FALSE-----------------------------------------
#  build_times()
#  predict_runtime()
#  rate_limiting_times()

## ----speeddrakermd, eval = FALSE-----------------------------------------
#  make() # with jobs > 2
#  max_useful_jobs()
#  parallelism_choices()
#  shell_file()

## ----hashcachedrakermd, eval = FALSE-------------------------------------
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

## ----debugdrakermd, eval = FALSE-----------------------------------------
#  check()
#  session()
#  in_progress()
#  progress()
#  config()
#  read_config()

## ----vignettesdrakermd, eval = FALSE-------------------------------------
#  vignette(package = "drake")            # List the vignettes.
#  vignette("drake")                      # High-level intro.
#  vignette("quickstart")                 # Walk through a simple example.
#  vignette("parallelism") # Lots of parallel computing support.
#  vignette("storage")                    # Learn how drake stores your stuff.
#  vignette("timing")                     # Build times, runtime predictions
#  vignette("caution")                    # Avoid common pitfalls.

## ----reproducibilitydrakermd, eval = FALSE-------------------------------
#  library(drake)
#  load_basic_example()
#  outdated(my_plan) # Which targets need to be (re)built?
#  make(my_plan)     # Build what needs to be built.
#  outdated(my_plan) # Everything is up to date.
#  # Change one of your functions.
#  reg2 <- function(d) {
#    d$x3 <- d$x ^ 3
#    lm(y ~ x3, data = d)
#  }
#  outdated(my_plan)   # Some targets depend on reg2().
#  plot_graph(my_plan) # Set targets_only to TRUE for smaller graphs.
#  make(my_plan)       # Rebuild just the outdated targets.
#  outdated(my_plan)   # Everything is up to date again.
#  plot_graph(my_plan) # The colors changed in the graph.

## ----drakermdquickvignette, eval = FALSE---------------------------------
#  vignette("quickstart")

## ----basicgraph----------------------------------------------------------
library(drake)
load_basic_example()
make(my_plan, jobs = 2, verbose = FALSE) # Parallelize with 2 jobs.
# Change one of your functions.
reg2 <- function(d){
  d$x3 <- d$x ^ 3
  lm(y ~ x3, data = d)
}

## ----fakegraphdrakermd, eval = FALSE-------------------------------------
#  # Hover, click, drag, zoom, and pan.
#  plot_graph(my_plan, width = "100%", height = "500px")

## ----drakermdhpcvignette, eval = FALSE-----------------------------------
#  vignette("parallelism")

## ----rmfiles_main, echo = FALSE------------------------------------------
clean(destroy = TRUE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

