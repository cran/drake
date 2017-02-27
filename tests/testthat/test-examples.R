# library(drake); library(testthat); 
context("examples")

test_that("Functions for example plans runs as expected.", {
  clean(destroy=TRUE)
  expect_true(is.character(example_plans()))
  expect_true(is.data.frame(example_plan()))
  for(e in example_plans())
    expect_true(is.data.frame(example_plan(e)))
  rm(list = ls())
  expect_silent(debug_setup())
  funs = strings(f, i, g, h, j, y)
  expect_true(all(funs %in% ls()))
  e = environment()
  for(fun in funs){
    expect_true(is.function(e[[fun]]))
    expect_identical(environment(e[[fun]]), e)
  }
  rm(e)
  p = example_plan("debug")
  expect_true(file.exists("input"))
  expect_false(any(file.exists(".drake", "d", "e")))
  make(p, verbose = F)
  expect_true(all(file.exists("input", ".drake", "d", "e")))
  debug_cleanup()
  expect_false(any(file.exists("input", ".drake", "d", "e")))
})
