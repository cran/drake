## ---- echo = F-----------------------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
clean(destroy = TRUE)

## ----envir---------------------------------------------------------------
library(drake)
envir = new.env(parent = globalenv())
eval(expression({
  f = function(x){
    g(x) + 1
  }
  g = function(x){
    x + 1
  }
}), envir = envir)
myplan = plan(out = f(1:3))
make(myplan, envir = envir)
ls() # Check that your workspace did not change.
ls(envir) # Check your evaluation environment.
envir$out
readd(out)

## ------------------------------------------------------------------------
plan(target1 = 1 + 1 - sqrt(sqrt(3)), 
     target2 = my_function(web_scraped_data) %>% my_tidy)

## ----cautionlibdrake, echo = FALSE---------------------------------------
library(drake)

## ----depscheck-----------------------------------------------------------
my_plan = plan(list = c(a = "x <- 1; return(x)"))
my_plan
deps(my_plan$command[1])

## ----previewmyplan-------------------------------------------------------
load_basic_example()
my_plan

## ----plotgraph-----------------------------------------------------------
# Skip the file argument to just plot.
# Click, drag, and zoom to explore.
plot_graph(my_plan, width = "100%", height = "500px",
  file = "caution_graph.html") 

## ----checkdeps-----------------------------------------------------------
deps(reg2)
deps(my_plan$command[1]) # report.Rmd is single-quoted because it is a file dependency.
deps(my_plan$command[16])

## ----tracked-------------------------------------------------------------
tracked(my_plan, targets = "small")
tracked(my_plan)

## ----cautiondeps---------------------------------------------------------
f <- function(){
  b = get("x", envir = globalenv()) # x is incorrectly ignored
  file_dependency = readRDS('input_file.rds') # 'input_file.rds' is incorrectly ignored
  digest::digest(file_dependency)
}
deps(f)
command = "x <- digest::digest('input_file.rds'); assign(\"x\", 1); x"
deps(command)

## ----clean, echo = FALSE-------------------------------------------------
clean(destroy = TRUE)
unlink(c("report.Rmd", "Thumbs.db"))

