## ---- echo = F-----------------------------------------------------------
suppressPackageStartupMessages(library(drake))
suppressPackageStartupMessages(library(Ecdat))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(knitr))
unlink(".drake", recursive = TRUE)
clean(destroy = TRUE, verbose = FALSE)
unlink(c("Makefile", "report.Rmd", "shell.sh", "STDIN.o*", "Thumbs.db"))
knitr::opts_chunk$set(collapse = TRUE)

## ----masterdata2---------------------------------------------------------
library(Ecdat)
data(Produc)
head(Produc)

## ----masterpkgs----------------------------------------------------------
library(drake)
library(Ecdat) # econometrics datasets
library(knitr)
library(ggplot2)

## ----mastermodels--------------------------------------------------------
predictors <- setdiff(colnames(Produc), "gsp")
combos <- t(combn(predictors, 3))
head(combos)
targets <- apply(combos, 1, paste, collapse = "_")
commands <- apply(combos, 1, function(row){
  covariates <- paste(row, collapse = " + ")
  formula <- paste0("as.formula(\"gsp ~ ", covariates, "\")")
  command <- paste0("lm(", formula, ", data = Produc)")
})
model_plan <- data.frame(target = targets, command = commands)

head(model_plan)

## ----masterrmspe_plan----------------------------------------------------
commands <- paste0("get_rmspe(", targets, ", data = Produc)")
targets <- paste0("rmspe_", targets)
rmspe_plan <- data.frame(target = targets, command = commands)

head(rmspe_plan)

## ----masterget_rmspe-----------------------------------------------------
get_rmspe <- function(lm_fit, data){
  y <- data$gsp
  yhat <- predict(lm_fit, data = data)
  terms <- attr(summary(lm_fit)$terms, "term.labels")
  data.frame(
    rmspe = sqrt(mean((y - yhat)^2)), # nolint
    X1 = terms[1],
    X2 = terms[2],
    X3 = terms[3]
  )
}

## ----masterrbindplan-----------------------------------------------------
rmspe_results_plan <- gather_plan(
  plan = rmspe_plan,
  target = "rmspe",
  gather = "rbind"
)

## ----masterknitrreport---------------------------------------------------
output_plan <- drake_plan(
  rmspe.pdf = ggsave(filename = "rmspe.pdf", plot = plot_rmspe(rmspe)),
  report.md = knit("report.Rmd", quiet = TRUE),
  file_targets = TRUE,
  strings_in_dots = "literals"
)

head(output_plan)

## ----wholeplan-----------------------------------------------------------
whole_plan <- rbind(model_plan, rmspe_plan, rmspe_results_plan, output_plan)

## ----defineplotrmspe-----------------------------------------------------
plot_rmspe <- function(rmspe){
  ggplot(rmspe) +
    geom_histogram(aes(x = rmspe), bins = 30)
}

## ----copyreport----------------------------------------------------------
local <- file.path("examples", "gsp", "report.Rmd")
path <- system.file(path = local, package = "drake", mustWork = TRUE)
file.copy(from = path, to = "report.Rmd", overwrite = TRUE)

## ----appmake-------------------------------------------------------------
make(whole_plan, verbose = FALSE)

## ----masterrmspeplot-----------------------------------------------------
results <- readd(rmspe)

loadd(plot_rmspe)

library(ggplot2)
plot_rmspe(rmspe = results)

## ----masterbestmodels----------------------------------------------------
head(results[order(results$rmspe, decreasing = FALSE), ])

## ----rmfiles_main, echo = FALSE------------------------------------------
clean(destroy = TRUE, verbose = FALSE)
unlink(
  c("Makefile", "report.Rmd", "figure", "shell.sh", "STDIN.o*", "Thumbs.db"))

