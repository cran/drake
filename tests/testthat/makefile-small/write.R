devtools::load_all()
library(eply)
p = example_plan("small")
makefile(p, run = F)
system("rm -rf .drake")

