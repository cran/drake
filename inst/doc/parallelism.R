## ----suppression, echo = F-----------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
clean(destroy = TRUE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

## ----hpcplotgraph, eval = FALSE------------------------------------------
#  clean()
#  load_basic_example()
#  make(my_plan, jobs = 2, verbose = FALSE) # Parallelize over 2 jobs.
#  # Change a dependency.
#  reg2 <- function(d) {
#    d$x3 <- d$x ^ 3
#    lm(y ~ x3, data = d)
#  }
#  # Hover, click, drag, zoom, and pan.
#  plot_graph(my_plan, width = "100%", height = "500px")

## ----hpcquick, eval = FALSE----------------------------------------------
#  library(drake)
#  load_basic_example()
#  plot_graph(my_plan) # Set targets_only to TRUE for smaller graphs.
#  max_useful_jobs(my_plan) # 8
#  max_useful_jobs(my_plan, imports = "files") # 8
#  max_useful_jobs(my_plan, imports = "all") # 8
#  max_useful_jobs(my_plan, imports = "none") # 8
#  make(my_plan, jobs = 4)
#  plot_graph(my_plan)
#  # Ignore the targets already built.
#  max_useful_jobs(my_plan) # 1
#  max_useful_jobs(my_plan, imports = "files") # 1
#  max_useful_jobs(my_plan, imports = "all") # 8
#  max_useful_jobs(my_plan, imports = "none") # 0
#  # Change a function so some targets are now out of date.
#  reg2 <- function(d){
#    d$x3 <- d$x ^ 3
#    lm(y ~ x3, data = d)
#  }
#  plot_graph(my_plan)
#  max_useful_jobs(my_plan) # 4
#  max_useful_jobs(my_plan, from_scratch = TRUE) # 8
#  max_useful_jobs(my_plan, imports = "files") # 4
#  max_useful_jobs(my_plan, imports = "all") # 8
#  max_useful_jobs(my_plan, imports = "none") # 4

## ----hpcchoices, eval = FALSE--------------------------------------------
#  parallelism_choices() # List the parallel backends.
#  ?parallelism_choices  # Read an explanation of each backend.
#  default_parallelism() # "parLapply" on Windows, "mclapply" everywhere else

## ----hpcmclapply, eval = FALSE-------------------------------------------
#  make(.., parallelism = "mclapply", jobs = 2)

## ----hpcparLapply, eval = FALSE------------------------------------------
#  make(.., parallelism = "parLapply", jobs = 2)
#  default_parallelism() # "parLapply" on Windows, "mclapply" everywhere else

## ----Makefilehpc, eval = FALSE-------------------------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 2)

## ----hpcargs, eval = FALSE-----------------------------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 4, args = "--jobs=6 --silent")

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
#  make(my_plan, parallelism = "Makefile", jobs = 4,
#    prepend = "SHELL=srun")

## ----cluster2, eval = FALSE----------------------------------------------
#  make(my_plan, parallelism = "Makefile", jobs = 4,
#    recipe_command = "tell_cluster_to_submit Rscript -e")

## ----endofline_quickstart, echo = F--------------------------------------
clean(destroy = TRUE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))

