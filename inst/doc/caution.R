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

## ---- echo = FALSE-------------------------------------------------------
library(drake)

## ------------------------------------------------------------------------
plan(list = c(a = "x <- 1; return(x)"))

## ----clean, echo = FALSE-------------------------------------------------
clean(destroy = TRUE)

