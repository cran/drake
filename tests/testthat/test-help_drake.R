# library(testthat); library(drake)
context("help_drake")

test_that("Function help_drake() runs correctly", {
  expect_output(help_drake())
})
