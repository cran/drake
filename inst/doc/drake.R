## ---- echo = F-----------------------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
clean(destroy = TRUE)

## ----basicgraph----------------------------------------------------------
library(drake)
load_basic_example()
make(my_plan, jobs = 2, verbose = FALSE) # Parallelize over 2 jobs.
reg2 = function(d){ # Change a dependency.
  d$x3 = d$x^3
  lm(y ~ x3, data = d)
}

# Skip the file argument to just plot.
# Hover, click, drag, zoom, pan.
plot_graph(my_plan, width = "100%", height = "500px", 
  file = "drake_graph.html") 

## ----rmfile, echo = FALSE------------------------------------------------
clean(destroy = TRUE)
unlink(c("report.Rmd", "Thumbs.db"))

