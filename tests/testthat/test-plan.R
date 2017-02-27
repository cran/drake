# library(testthat); library(drake);
context("plan")

test_that("Function plan() calls sanitize() at the end", {
  clean(destroy=TRUE)
  p = plan(x = bla+1)
  expect_equal(p$code, "bla + 1")
  clean(destroy=TRUE)
})

test_that("Function plan() is correct.", {
  expect_equal(plan(), 
    data.frame(output = character(0), code = character(0)))
  o = data.frame(output = c("x", "y"), 
    code = c("1", "f(2)"), stringsAsFactors = F)
  expect_equal(o, plan(x = 1, y = f(2)))
  expect_equal(o, plan(list = c(x = 1, y = "f(2)")))
  expect_equal(o, plan(x = 1, list = c(y = "f(2)")))
  o$output = quotes(o$output, single = T)
  expect_equal(o, plan(x = 1, y = f(2), file_outputs = T))
  osingle = data.frame(output = c("x", "y"),
    code = c("readRDS('file_1')", "readRDS('this_file')"),
    stringsAsFactors = F)
  isingle = plan(x = readRDS('file_1'), y = readRDS('this_file'))
  expect_equal(osingle, isingle)
  o = plan(list = c(x = "readRDS('file_1')", 
    y = "readRDS(\"this_file\")"))
  o2 = data.frame(output = c("x", "y"),
    code = c("readRDS('file_1')", "readRDS(\"this_file\")"),
    stringsAsFactors = F)
  expect_equal(o, o2)
  o = plan(x = readRDS('file_1'), list = c(y = "readRDS(\"this_file\")"))
  expect_equal(o, o2)
  o = plan(x = readRDS("file_1"), list = c(y = "readRDS('this_file')"))
  expect_equal(o, osingle)
  o = plan(x = saveRDS(1,"x" ), y = saveRDS(2,"y"), file_outputs = TRUE)
  o2 = data.frame(output = c("'x'", "'y'"), 
    code = c("saveRDS(1, 'x')", "saveRDS(2, 'y')"), stringsAsFactors = F)
  expect_equal(o, o2)
})

test_that("Argument strings_in_dots works", {
  expect_error(o <- plan(a = 1, strings_in_dots = "bla"))
  o = plan(x = readRDS('y'), 
    list = c(y = "I(\"str\")", z = "readRDS('file')"))
  k = plan(x = readRDS('y'),
    list = c(y = "I(\"str\")", z = "readRDS('file')"),
    strings_in_dots = "file_deps")
  expect_equal(o, k)
  o2 = data.frame(output = c("x", "y", "z"), 
    code = c("readRDS('y')", 'I("str")', "readRDS('file')"),
    stringsAsFactors = F)
  expect_equal(o, o2)
  o3 = o2
  o3$output = quotes(o3$output, single = T)
  o = plan(x = readRDS('y'),
    list = c(y = "I(\"str\")", z = "readRDS('file')"),
    file_outputs = T)
  k2 = plan(x = readRDS('y'),
    list = c(y = "I(\"str\")", z = "readRDS('file')"),
    strings_in_dots = "file_deps", file_outputs = T)
  expect_equal(o, k2)
  expect_equal(o3, o)

  o = plan(x = readRDS('y'),
    list = c(y = "I(\"str\")", z = "readRDS('file')"),
    strings_in_dots = "not_deps")
  o2 = data.frame(output = c("x", "y", "z"),
    code = c("readRDS(\"y\")", 'I("str")', "readRDS('file')"),
    stringsAsFactors = F)
  expect_equal(o, o2)
  o3 = o2
  o3$output = quotes(o3$output, single = T)
  o = plan(x = readRDS('y'),
    list = c(y = "I(\"str\")", z = "readRDS('file')"),
    file_outputs = T, strings_in_dots = "not_deps")
  expect_equal(o3, o)

  o = plan(x = readRDS('y'),
    list = c(y = "I(\"str\")", z = "readRDS('file')"),
    strings_in_dots = "not_deps")
  o2 = plan(x = readRDS("y"),
    list = c(y = "I(\"str\")", z = "readRDS('file')"),
    strings_in_dots = "not_deps")
  expect_equal(o, o2)

  o = plan(x = readRDS('y'),
    list = c(y = "I(\"str\")", z = "readRDS('file')"),
    strings_in_dots = "file_deps")
  o2 = plan(x = readRDS("y"),
    list = c(y = "I(\"str\")", z = "readRDS('file')"),
    strings_in_dots = "file_deps")
  expect_equal(o, o2)
})
