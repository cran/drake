## ----cautionstart, echo = F----------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
suppressMessages(suppressWarnings(library(magrittr)))
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))
knitr::opts_chunk$set(
  collapse = TRUE,
  error = TRUE,
  warning = TRUE
)

## ----filethenevaluate----------------------------------------------------
library(magrittr) # for the pipe operator %>%
drake_plan(
  data = readRDS("data_DATASIZE__rds")
) %>%
  rbind(drake::drake_plan(
    file.csv = write.csv(
      data_DATASIZE__, # nolint
      "file_DATASIZE__csv"
    ),
    strings_in_dots = "literals",
    file_targets = T
  )) %>%
  evaluate_plan(
    rules = list(DATASIZE__ = c("small", "large"))
  )

## ----correctevaldatasize-------------------------------------------------
rules <- list(DATASIZE__ = c("small", "large"))
datasets <- drake_plan(data = readRDS("data_DATASIZE__rds")) %>%
  evaluate_plan(rules = rules)

## ----correctevaldatasize2------------------------------------------------
files <- drake_plan(
  file = write.csv(data_DATASIZE__, "file_DATASIZE__csv"), # nolint
  strings_in_dots = "literals"
) %>%
  evaluate_plan(rules = rules)

## ----correctevaldatasize3------------------------------------------------
files$target <- paste0(
  files$target, ".csv"
) %>%
  as_drake_filename

## ----correctevaldatasize4------------------------------------------------
rbind(datasets, files)

## ----tidyplancaution-----------------------------------------------------
drake_plan(
  target1 = 1 + 1 - sqrt(sqrt(3)),
  target2 = my_function(web_scraped_data) %>% my_tidy
)

## ----diagnosecaution-----------------------------------------------------
diagnose()

f <- function(){
  stop("unusual error")
}

bad_plan <- drake_plan(target = f())

withr::with_message_sink(
  stdout(),
  make(bad_plan)
)

failed() # From the last make() only

diagnose() # From all previous make()s

error <- diagnose(target)

str(error)

error$calls # View the traceback.

## ----envircaution--------------------------------------------------------
library(drake)
clean(verbose = FALSE)
envir <- new.env(parent = globalenv())
eval(
  expression({
    f <- function(x){
      g(x) + 1
    }
    g <- function(x){
      x + 1
    }
  }
  ),
  envir = envir
)
myplan <- drake_plan(out = f(1:3))

make(myplan, envir = envir)

ls() # Check that your workspace did not change.

ls(envir) # Check your evaluation environment.

envir$out

readd(out)

## ----devtools1, eval = FALSE---------------------------------------------
#  env <- devtools::load_all("yourProject")$env # Has all your imported functions
#  drake::make(my_plan, envir = env)            # Run the project normally.

## ----devtools2, eval = FALSE---------------------------------------------
#  env <- devtools::load_all("yourProject")$env
#  env <- list2env(as.list(env), parent = globalenv())

## ----devtools3, eval = FALSE---------------------------------------------
#  for (name in ls(env)){
#    assign(
#      x = name,
#      envir = env,
#      value = `environment<-`(get(n, envir = env), env)
#    )
#  }

## ----devtools4, eval = FALSE---------------------------------------------
#  package_name <- "yourProject" # devtools::as.package(".")$package # nolint
#  packages_to_load <- setdiff(.packages(), package_name)

## ----devtools5, eval = FALSE---------------------------------------------
#  make(
#    my_plan,                    # Prepared in advance
#    envir = env,                # Environment of package "yourProject"
#    parallelism = "Makefile",   # Or "parLapply"
#    jobs = 2,
#    packages = packages_to_load # Does not include "yourProject"
#  )

## ----lazyloadfuture, eval = FALSE----------------------------------------
#  library(future)
#  future::plan(multisession)
#  load_basic_example() # Get the code with drake_example("basic").
#  make(my_plan, lazy_load = TRUE, parallelism = "future_lapply")

## ----helpfuncitons, eval = FALSE-----------------------------------------
#  ?deps
#  ?tracked
#  ?vis_drake_graph

## ----cautiondeps---------------------------------------------------------
f <- function(){
  b <- get("x", envir = globalenv())           # x is incorrectly ignored
  file_dependency <- readRDS('input_file.rds') # 'input_file.rds' is incorrectly ignored # nolint
  digest::digest(file_dependency)
}

deps(f)

command <- "x <- digest::digest('input_file.rds'); assign(\"x\", 1); x"
deps(command)

## ----knitrdeps1----------------------------------------------------------
load_basic_example() # Get the code with drake_example("basic").
my_plan[1, ]

## ----knitr2--------------------------------------------------------------
deps("knit('report.Rmd')")

deps("render('report.Rmd')")

deps("'report.Rmd'") # These are actually dependencies of 'report.md' (output)

## ----badknitr, eval = FALSE----------------------------------------------
#  var <- "good_target"
#  # Works in isolation, but drake sees "var" literally as a dependency,
#  # not "good_target".
#  readd(target = var, character_only = TRUE)
#  loadd(list = var)
#  # All cached items are loaded, but none are treated as dependencies.
#  loadd()
#  loadd(imports_only = TRUE)

## ----vectorizedfunctioncaution, eval = FALSE-----------------------------
#  args <- lapply(as.list(match.call())[-1L], eval, parent.frame())
#  names <- if (is.null(names(args)))
#      character(length(args)) else names(args)
#  dovec <- names %in% vectorize.args
#  do.call("mapply", c(FUN = FUN, args[dovec], MoreArgs = list(args[!dovec]),
#      SIMPLIFY = SIMPLIFY, USE.NAMES = USE.NAMES))

## ----writexamples, eval = FALSE------------------------------------------
#  drake_example("sge")    # Sun/Univa Grid Engine workflow and supporting files
#  drake_example("slurm")  # SLURM
#  drake_example("torque") # TORQUE

## ----makejobs, eval = FALSE----------------------------------------------
#  make(..., parallelism = "Makefile", jobs = 2, args = "--jobs=4")

## ----cautionzombies, eval = FALSE----------------------------------------
#  fork_kill_zombies <- function(){
#    require(inline)
#    includes <- "#include <sys/wait.h>"
#    code <- "int wstat; while (waitpid(-1, &wstat, WNOHANG) > 0) {};"
#  
#    wait <- inline::cfunction(
#      body = code,
#      includes = includes,
#      convention = ".C"
#    )
#  
#    invisible(wait())
#  }

## ----rmfiles_caution, echo = FALSE---------------------------------------
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

