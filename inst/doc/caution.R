## ---- echo = F-----------------------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
suppressMessages(suppressWarnings(library(magrittr)))
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

## ----filethenevaluate----------------------------------------------------
library(magrittr) # for the pipe operator %>%
workplan(
  data = readRDS("data_..datasize...rds")
) %>%
  rbind(drake::workplan(
    file.csv = write.csv(
      data_..datasize.., # nolint
      "file_..datasize...csv"
    ),
    strings_in_dots = "literals",
    file_targets = T
  )) %>%
  evaluate(
    rules = list(..datasize.. = c("small", "large"))
  )

## ----correctevaldatasize-------------------------------------------------
rules <- list(..datasize.. = c("small", "large"))
datasets <- workplan(data = readRDS("data_..datasize...rds")) %>%
  evaluate(rules = rules)

## ----correctevaldatasize2------------------------------------------------
files <- workplan(
  file = write.csv(data_..datasize.., "file_..datasize...csv"), # nolint
  strings_in_dots = "literals"
) %>%
  evaluate(rules = rules)

## ----correctevaldatasize3------------------------------------------------
files$target <- paste0(
  files$target, ".csv"
) %>%
  as_file

## ----correctevaldatasize4------------------------------------------------
rbind(datasets, files)

## ----tidyplancaution-----------------------------------------------------
workplan(
  target1 = 1 + 1 - sqrt(sqrt(3)),
  target2 = my_function(web_scraped_data) %>% my_tidy
)

## ----diagnosecaution, eval = FALSE---------------------------------------
#  diagnose()
#  f <- function(){
#    stop("unusual error")
#  }
#  bad_plan <- workplan(target = f())
#  make(bad_plan)
#  failed() # From the last make() only
#  diagnose() # From all previous make()s
#  error <- diagnose(y)
#  str(error)
#  error$calls # View the traceback.

## ----envir---------------------------------------------------------------
library(drake)
envir <- new.env(parent = globalenv())
eval(expression({
  f <- function(x){
    g(x) + 1
  }
  g <- function(x){
    x + 1
  }
}
), envir = envir)
myplan <- workplan(out = f(1:3))
make(myplan, envir = envir)
ls() # Check that your workspace did not change.
ls(envir) # Check your evaluation environment.
envir$out
readd(out)

## ----cautionlibdrake, echo = FALSE---------------------------------------
library(drake)

## ----depscheck-----------------------------------------------------------
my_plan <- workplan(list = c(a = "x <- 1; return(x)"))
my_plan
deps(my_plan$command[1])

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
#    my_plan, # Prepared in advance
#    envir = env,
#    parallelism = "Makefile", # Or "parLapply"
#    jobs = 2,
#    packages = packages_to_load # Does not include "yourProject"
#  )

## ----previewmyplan-------------------------------------------------------
load_basic_example()
my_plan

## ----demoplotgraphcaution, eval = FALSE----------------------------------
#  # Hover, click, drag, zoom, and pan. See args 'from' and 'to'.
#  plot_graph(my_plan, width = "100%", height = "500px")

## ----checkdeps-----------------------------------------------------------
deps(reg2)
deps(my_plan$command[1]) # File dependencies like report.Rmd are single-quoted.
deps(my_plan$command[nrow(my_plan)])

## ----tracked-------------------------------------------------------------
tracked(my_plan, targets = "small")
tracked(my_plan)

## ----helpfuncitons, eval = FALSE-----------------------------------------
#  ?deps
#  ?tracked
#  ?plot_graph

## ----cautiondeps---------------------------------------------------------
f <- function(){
  b <- get("x", envir = globalenv()) # x is incorrectly ignored
  file_dependency <- readRDS('input_file.rds') # 'input_file.rds' is incorrectly ignored # nolint
  digest::digest(file_dependency)
}
deps(f)
command <- "x <- digest::digest('input_file.rds'); assign(\"x\", 1); x"
deps(command)

## ----knitrdeps1----------------------------------------------------------
load_basic_example()
my_plan[1, ]

## ----knitr2--------------------------------------------------------------
deps("knit('report.Rmd')")
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
#  example_drake("sge")    # Sun/Univa Grid Engine workflow and supporting files
#  example_drake("slurm")  # SLURM
#  example_drake("torque") # TORQUE

## ----clean, echo = FALSE-------------------------------------------------
clean(destroy = TRUE)
unlink(c("report.Rmd", "Thumbs.db"))

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

