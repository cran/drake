## ----setup, include = FALSE----------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
suppressMessages(suppressWarnings(library(cranlogs)))
suppressMessages(suppressWarnings(library(ggplot2)))
suppressMessages(suppressWarnings(library(knitr)))
suppressMessages(suppressWarnings(library(magrittr)))
suppressMessages(suppressWarnings(library(plyr)))
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))
knitr::opts_chunk$set(
  collapse = TRUE,
  error = TRUE,
  warning = TRUE
)
reportfile <- file.path("examples", "packages", "report.Rmd") %>%
  system.file(package = "drake", mustWork = TRUE)
file.copy(reportfile, getwd())

## ----cranlogsintroreport-------------------------------------------------
library(cranlogs)
cran_downloads(packages = "dplyr", when = "last-week")

## ----pkgspkgs------------------------------------------------------------
library(drake)
library(cranlogs)
library(ggplot2)
library(knitr)
library(plyr)

## ----packagelist---------------------------------------------------------
package_list <- c(
  "knitr",
  "Rcpp",
  "ggplot2"
)

## ----datadataplan--------------------------------------------------------
data_plan <- drake_plan(
  recent = cran_downloads(packages = package_list, when = "last-month"),
  older = cran_downloads(
    packages = package_list,
    from = "2016-11-01",
    to = "2016-12-01"
  ),
  strings_in_dots = "literals"
)

data_plan

## ----outputtypespackages-------------------------------------------------
output_types <- drake_plan(
  averages = make_my_table(dataset__),
  plot = make_my_plot(dataset__)
)

output_types

## ----summplotdatapackages------------------------------------------------
make_my_table <- function(downloads){
  ddply(downloads, "package", function(package_downloads){
    data.frame(mean_downloads = mean(package_downloads$count))
  })
}

make_my_plot <- function(downloads){
  ggplot(downloads) +
    geom_line(aes(x = date, y = count, group = package, color = package))
}

## ----outputplanpackages--------------------------------------------------
output_plan <- plan_analyses(
  plan = output_types,
  datasets = data_plan
)

output_plan

## ----reportplanpackages--------------------------------------------------
report_plan <- drake_plan(
  report.md = knit("report.Rmd", quiet = TRUE),
  file_targets = TRUE
)

report_plan

## ----packageswhole_plan--------------------------------------------------
whole_plan <- rbind(
  data_plan,
  output_plan,
  report_plan
)

whole_plan

## ----packagestriggers----------------------------------------------------
whole_plan$trigger <- "any" # default trigger
whole_plan$trigger[whole_plan$target == "recent"] <- "always"

whole_plan

## ----firstmakepackages, fig.width = 7, fig.height = 4--------------------
make(whole_plan)

readd(averages_recent)

readd(averages_older)

readd(plot_recent)

readd(plot_older)

## ----packagessecondmake--------------------------------------------------
make(whole_plan)

## ----plotpackagesgraph, eval = FALSE-------------------------------------
#  config <- drake_config(whole_plan)
#  vis_drake_graph(config)

## ----rmfiles_main, echo = FALSE------------------------------------------
clean(destroy = TRUE, verbose = FALSE)
unlink(
  c("Makefile", "report.Rmd", "figure", "shell.sh", "STDIN.o*", "Thumbs.db"))

