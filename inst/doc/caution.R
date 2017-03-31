## ---- echo = F-----------------------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
clean(destroy = TRUE)

## ------------------------------------------------------------------------
plan(target1 = 1 + 1 - sqrt(sqrt(3)), 
     target2 = my_function(web_scraped_data) %>% my_tidy)

## ---- echo = FALSE-------------------------------------------------------
library(drake)

## ------------------------------------------------------------------------
plan(list = c(a = "x <- 1; return(x)"))

