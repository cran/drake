## ---- echo = F-----------------------------------------------------------
suppressMessages(suppressWarnings(library(drake)))
clean(T)

## ------------------------------------------------------------------------
library(drake)
x = example_plan("small")
x

## ------------------------------------------------------------------------
check(x) # check for errors first 
make(x)
readd(a) # see also loadd() and cached()

## ------------------------------------------------------------------------
make(x, output = c("c", "f"))

## ------------------------------------------------------------------------
x$code[3] = "sqrt(d) + 2*f + 1" # new code for variable c
make(x)
readd(a)
make(x)
x$code[5] = "2*2*1" # variable e: previously 2 + 2, so the output value doesn't change
make(x)
readd(a)
x$code[5] = "7/2" # new code for variable e
make(x)
readd(a)
x$code[5] = "7 /2 # changes to comments and whitespace are ignored"
make(x)

## ------------------------------------------------------------------------
cached()
x = x[1:5,]
prune(x)
cached()

## ------------------------------------------------------------------------
clean() # removes the cached objects but keeps the hidden ".drake/" folder
cached()
clean(destroy = TRUE) # removes ".drake/"

## ------------------------------------------------------------------------
x = data.frame(output = c("out", "my_input"), code = c("my_input - 1", "f(2)"))
f = function(x) g(x) + 1
g = function(x) h(x) + 2
h = function(x) x^2 + my_var
# make(x) # quits in error because "my_var" is undefined
my_var = 1
make(x)
readd(out)
make(x)
my_var = 2 # drake knows you changed "my_var"
make(x)
readd(out)

## ------------------------------------------------------------------------
h = function(x){ x - 10 + my_var}
make(x)
readd(out)

## ------------------------------------------------------------------------
h = function(x){
  x-10+my_var
}
make(x)
readd(out)

## ------------------------------------------------------------------------
global = 10000
run = function(x) make(x)
run(x)
readd(out)

## ------------------------------------------------------------------------
save.image()
drake:::.onLoad()
unlink('.RData')

## ---- echo = F-----------------------------------------------------------
clean()
rm(list = ls())

## ------------------------------------------------------------------------
saveRDS("imported data", file = "imported_file")
x = data.frame(
  output = c("'first'", "message", "'second'", "contents_of_imported_file"),
  code = c(
    "saveRDS(\"hello world\", \"first\")",
    "readRDS('first')",
    "saveRDS(message, \"second\")",
    "readRDS('imported_file')"))
x

## ------------------------------------------------------------------------
check(x)
make(x, output = "'second'") # Use single quotes here too.
make(x)
readRDS("second")
readd(contents_of_imported_file)
readd("'second'") # Only the fingerprints of external files are cached.

## ------------------------------------------------------------------------
make(x)
cached()
list.files()

## ------------------------------------------------------------------------
clean()
cached()
list.files()
unlink("imported_file")

## ------------------------------------------------------------------------
file_plan = plan(list = c(
  "'a'" = "saveRDS(17, \"a\")",
  "'b'" = "saveRDS(1 + readRDS('a'), \"b\")",
  "c" = "readRDS('b')"))
file_plan
make(file_plan, verbose = FALSE) # first runthrough
readRDS('b')
saveRDS(5, 'b') # damage the file 'b'
make(file_plan)
readRDS('b')
clean()

## ------------------------------------------------------------------------
example_plans()
example_plan("small")
example_plan("debug")

## ------------------------------------------------------------------------
plan(x = a, y = readRDS(2, 'input.rds'))
plan(x = a, y = readRDS(2, 'input.rds'), 
     strings_in_dots = "file_deps") # default
plan(x = a, y = readRDS(2, 'input.rds'), 
     strings_in_dots = "not_deps")
plan(x = a, y = readRDS(2, "input.rds"))
plan(x = a, y = readRDS(2, "input.rds"), 
     strings_in_dots = "not_deps")
plan(list = c(x = "a", y = "readRDS(\"some_string\", 'input.rds')"))
plan('a' = 1)
plan("'a'" = 1)
plan("'a'" = 1, strings_in_dots = "not_deps") # does not affect output names
# plan('"a"' = 1) # error: output names can't be double-quoted

## ------------------------------------------------------------------------
p = plan(x = saveRDS(1, "x"), y = saveRDS(2, "y"), file_outputs = TRUE)
p
# check(p) # quits in error
# make(p)  # quits in error
p = plan(x = saveRDS(1, "x"), y = saveRDS(2, "y"), 
         file_outputs = TRUE, strings_in_dots = "not_deps")
p
check(p)

## ------------------------------------------------------------------------
as_file(letters[1:4])
a = 4
plan(list = c(x = a, "'file'" = "readRDS(2, 'input.rds')"))
library(eply) # for quotes(), strings(), and unquote()
quotes(1:5, single = TRUE)
unquote("'not_a_file'")
strings(these, are, strings)

## ------------------------------------------------------------------------
data = plan(large = my_large(), small = my_small())

## ------------------------------------------------------------------------
methods = plan(reg = regression(..dataset..), 
rf = random_forest(..dataset..))

## ------------------------------------------------------------------------
myanalyses = analyses(methods, data)
myanalyses

## ------------------------------------------------------------------------
summary_types = plan(
  stats = summary_statistics(..analysis..),
  error = mean_squared_error(..analysis.., ..dataset..))
mysummaries = summaries(summary_types, analyses= myanalyses, datasets = data)
mysummaries[3:10,]

## ------------------------------------------------------------------------
mysummaries[1:2,]

## ------------------------------------------------------------------------
out = plan(my_table.csv = save_summaries(stats),
           my_plot.pdf = plot_errors(error), file_outputs = TRUE)

## ------------------------------------------------------------------------
report_depends = plan(deps = c(stats, error))

reports = plan(
  my_report.md = my_knit('my_report.Rmd', deps),
  my_report.html = my_render('my_report.md', deps),
  file_outputs = TRUE)
reports

## ------------------------------------------------------------------------
my_knit = function(file, ...) knitr::knit(file)
my_render = function(file, ...) rmarkdown::render(file)

## ------------------------------------------------------------------------
my_plan = rbind(data, myanalyses, mysummaries, out, 
  report_depends, reports)
tmp = file.create("my_report.Rmd") # You would write this by hand.
check(my_plan)
# make(my_plan)
tmp = file.remove("my_report.Rmd")

## ------------------------------------------------------------------------
df = plan(data = simulate(center = MU, scale = SIGMA))
df
df = expand(df, values = c("rep1", "rep2"))
df
evaluate(df, wildcard = "MU", values = 1:2)
evaluate(df, wildcard = "MU", values = 1:2, expand = FALSE)
evaluate(df, rules = list(MU = 1:2, SIGMA = c(0.1, 1)), expand = FALSE)
evaluate(df, rules = list(MU = 1:2, SIGMA = c(0.1, 1, 10)))
gather(df)
gather(df, output = "my_summaries", gather = "rbind")

## ----echo=F--------------------------------------------------------------
clean(destroy = TRUE)

