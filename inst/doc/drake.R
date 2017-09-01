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

## ----rmfile, echo = FALSE------------------------------------------------
clean(destroy = TRUE)
unlink(c("report.Rmd", "Thumbs.db"))

