# library(testthat); library(drake)
context("sanitize")

test_that("Function sanitize works.", {
  clean(destroy=TRUE)
  a = data.frame(
    output = letters[1:6],
    code = c("b + c", "d + e", "d + f", "1 + 1", "2 + 2", "3 + 3"),
    stringsAsFactors = FALSE)
  b = data.frame(
    output = letters[1:6],
    code = c("b+c", "d+e", "d+f", "1+1", "2+2", "3+3"),
    stringsAsFactors = TRUE)
  expect_equal(a, sanitize(b))
  x = data.frame(output = c("x", "x"), code = c("1+1", "1+1"))
  expect_error(sanitize(x))
  x$output = c("x", "y")
  expect_silent(o <- sanitize(x))
  y = x
  colnames(y) = letters[1:ncol(y)]
  expect_error(sanitize(y))
  expect_error(sanitize())
  expect_error(sanitize(NULL))
  expect_error(sanitize(NA))
  expect_error(sanitize(letters[1:5]))
  x = data.frame(output = "\"x\"", code = "y")
  expect_error(sanitize(x))
  x = data.frame(output = c("_mystuff", "bla"), 
    code = c("123", "456"))
  expect_error(sanitize(x))
  a = "_UNDERSCOREblabla"
  x = data.frame(output = c(a, "bla"),
    code = c("123", "456"))
  expect_error(sanitize(x))
  p = plan(list = c(a = "b<-2; b", c = "1+1; 1+2"))
  s = sanitize(p)
  d = data.frame(output = c("a", "c"),
    code = c("b <- 2;\nb", "1 + 1;\n1 + 2"),
    stringsAsFactors = F)
  expect_equal(s, d)
  clean(destroy=TRUE)
})
