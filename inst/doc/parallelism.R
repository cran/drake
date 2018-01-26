## ----suppression, echo = F-----------------------------------------------
suppressMessages(suppressWarnings(library(future)))
suppressMessages(suppressWarnings(library(drake)))
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))
knitr::opts_chunk$set(
  collapse = TRUE,
  error = TRUE,
  warning = TRUE
)

## ----hiddenhpcpreplotgraph, eval = TRUE, echo = FALSE, message = FALSE----
clean()
load_basic_example() # Get the code with drake_example("basic").
config <- make(my_plan, jobs = 2, verbose = FALSE) # Parallelize over 2 jobs.
# Change a dependency.
reg2 <- function(d) {
  d$x3 <- d$x ^ 3
  lm(y ~ x3, data = d)
}

## ----hpcplotgraph, eval = FALSE------------------------------------------
#  clean()
#  load_basic_example()
#  config <- make(my_plan, jobs = 2, verbose = FALSE) # Parallelize over 2 jobs.
#  # Change a dependency.
#  reg2 <- function(d) {
#    d$x3 <- d$x ^ 3
#    lm(y ~ x3, data = d)
#  }
#  # Hover, click, drag, zoom, and pan.
#  vis_drake_graph(config, width = "100%", height = "500px")

## ----parallelstages------------------------------------------------------
parallel_stages(config)

## ----hpcquick, eval = FALSE----------------------------------------------
#  library(drake)
#  load_basic_example()
#  config <- drake_config(my_plan)
#  vis_drake_graph(config) # Set targets_only to TRUE for smaller graphs.
#  max_useful_jobs(config) # 8
#  max_useful_jobs(config, imports = "files") # 8
#  max_useful_jobs(config, imports = "all") # 8
#  max_useful_jobs(config, imports = "none") # 8
#  config <- make(my_plan, jobs = 4)
#  vis_drake_graph(config)
#  # Ignore the targets already built.
#  max_useful_jobs(config) # 1
#  max_useful_jobs(config, imports = "files") # 1
#  max_useful_jobs(config, imports = "all") # 8
#  max_useful_jobs(config, imports = "none") # 0
#  # Change a function so some targets are now out of date.
#  reg2 <- function(d){
#    d$x3 <- d$x ^ 3
#    lm(y ~ x3, data = d)
#  }
#  vis_drake_graph(config)
#  max_useful_jobs(config) # 4
#  max_useful_jobs(config, from_scratch = TRUE) # 8
#  max_useful_jobs(config, imports = "files") # 4
#  max_useful_jobs(config, imports = "all") # 8
#  max_useful_jobs(config, imports = "none") # 4

## ----hpcchoices, eval = TRUE---------------------------------------------
parallelism_choices()

parallelism_choices(distributed_only = TRUE)

## ----hpcmoredocs, eval = TRUE--------------------------------------------
?parallelism_choices  # Read an explanation of each backend.
default_parallelism() # "parLapply" on Windows, "mclapply" everywhere else

## ----hpcmclapply, eval = FALSE-------------------------------------------
#  make(.., parallelism = "mclapply", jobs = 2)

## ----hpcparLapply, eval = FALSE------------------------------------------
#  make(.., parallelism = "parLapply", jobs = 2)
#  default_parallelism() # "parLapply" on Windows, "mclapply" everywhere else

## ----sequential, eval = TRUE---------------------------------------------
library(future)
future::plan()

future::plan(multicore)
future::plan()

## ----usebackend, eval = FALSE--------------------------------------------
#  make(my_plan, parallelism = "future_lapply")

## ----futuremultisession, eval = FALSE------------------------------------
#  future::plan(multisession(workers = 4)) # Use a max of 4 parallel jobs at a time. # nolint
#  make(my_plan, parallelism = "future_lapply")

## ----owncluster, eval = FALSE--------------------------------------------
#  cl <- future::makeClusterPSOCK(2L, dryrun = TRUE)
#  future::plan(cluster, workers = cl)
#  make(my_plan, parallelism = "future_lapply")

## ----ownclusterdocker, eval = FALSE--------------------------------------
#  ## Setup of Docker worker running rocker and r-base # nolint
#  ## (requires installation of future package)
#  cl <- future::makeClusterPSOCK(
#    "localhost",
#    ## Launch Rscript inside Docker container
#    rscript = c(
#      "docker", "run", "--net=host", "rocker/r-base",
#      "Rscript"
#    ),
#    ## Install drake
#    rscript_args = c(
#      "-e", shQuote("install.packages('drake')")
#    )
#  )
#  future::plan(cluster, workers = cl)
#  make(my_plan, parallelism = "future_lapply")

## ----futurebatchtools, eval = FALSE--------------------------------------
#  library(future.batchtools)
#  drake_batchtools_tmpl_file("slurm") # Write batchtools.slurm.tmpl.
#  future::plan(
#    batchtools_slurm,
#    template = "batchtools.slurm.tmpl",
#    workers = 16
#  )
#  make(my_plan, parallelism = "future_lapply")

## ----hybridparallelism, eval = FALSE-------------------------------------
#  drake_batchtools_tmpl_file("sge") # Write sge-simple.tmpl.
#  future::plan(
#    list(
#      tweak(batchtools_sge, template = "sge-simple.tmpl"),
#      multiprocess
#    )
#  )
#  make(my_plan, parallelism = "future_lapply")

## ----writexamples, eval = FALSE------------------------------------------
#  drake_example("sge")   # Sun/Univa Grid Engine workflow and supporting files
#  drake_example("slurm") # SLURM workflow and supporting files

## ----writexampletmpl, eval = FALSE---------------------------------------
#  drake_batchtools_tmpl_file("sge")   # Writes sge-simple.tmpl
#  drake_batchtools_tmpl_file("slurm") # Writes batchtools.slurm.tmpl

## ----Makefilehpc, eval = FALSE-------------------------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 2)

## ----hpcargs, eval = FALSE-----------------------------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 4, args = "--jobs=6 --silent")

## ----touchsilent, eval = FALSE-------------------------------------------
#  make(my_plan, parallelism = "Makefile", args = c("--touch", "--silent"))

## ----hpclsmake, eval = FALSE---------------------------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 4, command = "lsmake")

## ----defaultmakecommandfunction------------------------------------------
default_Makefile_command()

## ----defaultrecipecommandfunction----------------------------------------
default_recipe_command()

r_recipe_wildcard()

## ----hpcrqe, eval = FALSE------------------------------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 4,
#    recipe_command = "R -e 'R_RECIPE' -q")

## ----makefilerecipefunction----------------------------------------------
Makefile_recipe()

Makefile_recipe(
  recipe_command = "R -e 'R_RECIPE' -q",
  target = "this_target",
  cache_path = "custom_cache"
)

## ----reappendrrecipe-----------------------------------------------------
Makefile_recipe(recipe_command = "R -q -e")

## ----examplerecipes, eval = FALSE----------------------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 4)
#  make(my_plan, parallelism = "Makefile", jobs = 4,
#    recipe_command = "Rscript -e")
#  make(my_plan, parallelism = "Makefile", jobs = 4,
#    recipe_command = "Rscript -e 'R_RECIPE'")

## ----examplerecipesfailwindows, eval = FALSE-----------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 4,
#    recipe_command = "R -e 'R_RECIPE' -q")
#  make(my_plan, parallelism = "Makefile", jobs = 4,
#    recipe_command = "R -q -e 'R_RECIPE'")
#  make(my_plan, parallelism = "Makefile", jobs = 4,
#    recipe_command = "R -q -e")

## ----hpcprepend, eval = FALSE--------------------------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 2, prepend = "SHELL=./shell.sh")

## ----cluster, eval = FALSE-----------------------------------------------
#  make(
#    my_plan,
#    parallelism = "Makefile",
#    jobs = 2,
#    prepend = c(
#      "SHELL=srun",
#      ".SHELLFLAGS=-N1 -n1 bash -c"
#    )
#  )

## ----cluster2, eval = FALSE----------------------------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 4,
#    recipe_command = "tell_cluster_to_submit Rscript -e")

## ----triggerparallel, eval = FALSE---------------------------------------
#  load_basic_example()
#  make(my_plan, trigger = "missing") # Also consider "always".

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

## ----endofline_quickstart, echo = F--------------------------------------
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

