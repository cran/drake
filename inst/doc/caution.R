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

## ----tidyplancaution-----------------------------------------------------
drake_plan(
  target1 = 1 + 1 - sqrt(sqrt(3)),
  target2 = my_function(web_scraped_data) %>% my_tidy
)

## ----demotidyeval--------------------------------------------------------
# This workflow plan uses rlang's quasiquotation operator `!!`.
my_plan <- drake_plan(list = c(
  little_b = "\"b\"",
  letter = "!!little_b"
))
my_plan
make(my_plan)
readd(letter)

## ----testquasiquoplan----------------------------------------------------
my_variable <- 5

drake_plan(
  a = !!my_variable,
  b = !!my_variable + 1,
  list = c(d = "!!my_variable")
)

drake_plan(
  a = !!my_variable,
  b = !!my_variable + 1,
  list = c(d = "!!my_variable"),
  tidy_evaluation = FALSE
)

## ----diagnosecaution-----------------------------------------------------
# Targets with available diagnostic metadata, incluing errors, warnings, etc.
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

error <- diagnose(target)$error # See also warnings and messages.

error$message

error$call

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

## ----lazyloadfuture, eval = FALSE----------------------------------------
#  library(future)
#  future::plan(multisession)
#  load_basic_example() # Get the code with drake_example("basic").
#  make(my_plan, lazy_load = TRUE, parallelism = "future_lapply")

## ----r6change------------------------------------------------------------
library(digest)
library(R6)
example_class <- R6Class(
  "example_class",
  private = list(data = list()),
  public = list(
    initialize = function(data = list()) {
      private$data = data
    }
  )
)
digest(example_class)
example_object <- example_class$new(data = 1234)
digest(example_class) # example_class changed

## ----r6rebuild, eval = FALSE---------------------------------------------
#  plan <- drake_plan(example_target = example_class$new(1234))
#  make(plan) # `example_class` changes because it is referenced.
#  make(plan) # Builds `example_target` again because `example_class` changed.

## ----depsdot-------------------------------------------------------------
deps("sqrt(x + y + .)")
deps("dplyr::filter(complete.cases(.))")

## ----helpfuncitons, eval = FALSE-----------------------------------------
#  ?deps
#  ?tracked
#  ?vis_drake_graph

## ----cautiondeps---------------------------------------------------------
f <- function(){
  b <- get("x", envir = globalenv()) # x is incorrectly ignored
  digest::digest(file_dependency)
}

deps(f)

command <- "x <- digest::digest(file_in(\"input_file.rds\")); assign(\"x\", 1); x" # nolint
deps(command)

## ----fileimportsfunctions------------------------------------------------
# toally_fine() will depend on the imported data.csv file.
# But make sure data.csv is an imported file and not a file target.
totally_okay <- function(x, y, z){
  read.csv(file_in("data.csv"))
}

# file_out() is for file targets, so `drake` will ignore it.
avoid_this <- function(x, y, z){
  read.csv(file_out("data.csv"))
}

# knitr_in() is for knitr files with dependencies
# in their active code chunks (explicitly referenced with loadd() and readd().
# Drake just treats knitr_in() as an ordinary file input in this case.
# You should really be using file_in() instead.
avoid_this <- function(x, y, z){
  read.csv(knitr_in("report.Rmd"))
}

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

