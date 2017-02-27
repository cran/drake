suppressPackageStartupMessages({
  library(drake) # drake needs to be installed anyway for this test to work.
  library(eply)
  library(testthat)
})

context("outputs")

test_that("outputs can be specified", {

debug_cleanup()
p = example_plan("small")
make(p, verbose = F, makefile = T, command = "make", args = "-s", output = "c",
  packages = character(0))
expect_true(is.numeric(readd(c)))
expect_error(readd(a))
make(p, makefile = T, verbose = F, command = "make", args = "-s",
  packages = character(0))
expect_true(is.numeric(readd(a)))
debug_cleanup()

})
