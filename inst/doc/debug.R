## ----debugstart, echo = F------------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
suppressMessages(suppressWarnings(library(magrittr)))
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))
knitr::opts_chunk$set(
  collapse = TRUE,
  error = TRUE,
  warning = TRUE
)

## ----debugconfig---------------------------------------------------------
load_basic_example() # Get the code with drake_example("basic").
config <- drake_config(my_plan)

sort(names(config))

## ----readconfig, eval = FALSE--------------------------------------------
#  read_drake_config()

## ----readcompanions, eval = FALSE----------------------------------------
#  read_drake_graph()
#  read_drake_plan()

## ----checkdebug----------------------------------------------------------
load_basic_example() # Get the code with drake_example("basic").
my_plan

check_plan(my_plan) # No issues.

## ----demoplotgraphdebug, eval = FALSE------------------------------------
#  # Hover, click, drag, zoom, and pan. See args 'from' and 'to'.
#  config <- drake_config(my_plan)
#  vis_drake_graph(config, width = "100%", height = "500px")

## ----checkdepsdebug------------------------------------------------------
deps(reg2)

deps(my_plan$command[1]) # File dependencies like report.Rmd are single-quoted.

deps(my_plan$command[nrow(my_plan)])

## ----trackeddebug--------------------------------------------------------
tracked(my_plan, targets = "small")

tracked(my_plan)

## ----misseddebug---------------------------------------------------------
config <- drake_config(my_plan, verbose = FALSE)
missed(config) # Nothing is missing right now.

## ----outdateddebug-------------------------------------------------------
outdated(config)

## ----depprofiledebug-----------------------------------------------------
load_basic_example() # Get the code with drake_example("basic").
config <- make(my_plan, verbose = FALSE)
# Change a dependency.
reg2 <- function(d) {
  d$x3 <- d$x ^ 3
  lm(y ~ x3, data = d)
}
outdated(config)

dependency_profile(target = "regression2_small", config = config)

drake_meta(target = "regression2_small", config = config)

config$cache$get_hash(key = "small", namespace = "kernels") # same

config$cache$get_hash(key = "small") # same

config$cache$get_hash(key = "reg2", namespace = "kernels") # same

config$cache$get_hash(key = "reg2") # different

## ----readdrakemeta-------------------------------------------------------
read_drake_meta("'report.md'")

## ----rushdebug-----------------------------------------------------------
clean(verbose = FALSE) # Start from scratch
config <- make(my_plan, trigger = "missing")

## ----indivtrigger--------------------------------------------------------
my_plan$trigger <- "command"
my_plan$trigger[1] <- "file"
my_plan

# Change an imported dependency:
reg2

reg2 <- function(d) {
  d$x3 <- d$x ^ 3
  lm(y ~ x3, data = d)
}
make(my_plan, trigger = "any") # Nothing changes!

## ----skipimports---------------------------------------------------------
clean(verbose = FALSE)
my_plan$trigger <- NULL

make(my_plan, skip_imports = TRUE)

## ----timeoutretry--------------------------------------------------------
clean(verbose = FALSE)
f <- function(...){
  Sys.sleep(1)
}
debug_plan <- drake_plan(x = 1, y = f(x))
debug_plan

withr::with_message_sink(
  stdout(),
  make(debug_plan, timeout = 1e-3, retries = 2)
)

## ----timeoutretry2-------------------------------------------------------
clean(verbose = FALSE)
debug_plan$timeout <- c(1e-3, 2e-3)
debug_plan$retries <- 1:2

debug_plan

withr::with_message_sink(
  new = stdout(),
  make(debug_plan, timeout = Inf, retries = 0)
)

## ----diagnosedebug-------------------------------------------------------
diagnose(verbose = FALSE)

f <- function(x){
  if (x < 0){
    stop("unusual error")
  }
}
bad_plan <- drake_plan(
  a = 12,
  b = -a,
  my_target = f(b)
)

bad_plan

withr::with_message_sink(
  new = stdout(),
  make(bad_plan)
)

failed(verbose = FALSE) # from the last make() only

diagnose(verbose = FALSE) # from all previous make()'s

error <- diagnose(my_target, verbose = FALSE)

str(error)

error$calls # View the traceback.

## ----loaddeps------------------------------------------------------------
# Pretend we just opened a new R session.
library(drake)

# Unloads target `b`.
config <- drake_config(plan = bad_plan)

# my_target depends on b.
"b" %in% ls()

loadd(my_target, deps = TRUE)

"b" %in% ls()

# Try to build my_target until the error is fixed.
# Skip all that pesky work checking dependencies.
drake_build(target = "my_target", config = config)

diagnose(my_target)$message

f

# Aha! The error was in f(). Let's fix it and try again.
f <- function(x){
  return(x)
}
drake_build(target = "my_target", config = config)

## ----debriefdebug--------------------------------------------------------
make(my_plan, verbose = FALSE)

# drake_session(verbose = FALSE) # Prints the sessionInfo() of the last make(). # nolint

cached(verbose = FALSE)

built(verbose = FALSE)

imported(verbose = FALSE)

loadd(large, verbose = FALSE)

head(large)

readd(small, verbose = FALSE)

progress(verbose = FALSE)

in_progress(verbose = FALSE) # Unfinished targets

## ----finddebug-----------------------------------------------------------
find_project()

find_cache()

## ----examplesdrakedebug--------------------------------------------------
drake_examples()

## ----examplesdrake, eval = FALSE-----------------------------------------
#  drake_example("basic")
#  drake_example("slurm")

## ----rmfiles_debug, echo = FALSE-----------------------------------------
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

