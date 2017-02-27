context("code")
source("utils.R")

test_that("output objects respond appropriately to code changes", {
  debug_cleanup()
  debug_setup()
  p = example_plan("debug")
  make(p, verbose = F)
  final0 = readd("final")
  p$code[3] = "a+3"
  make(p, verbose = F)
  expect_equal(built_(), c("'d'", "'e'", "c", "d", "e", "final"))
  expect_false(any(readd(final) == final0))
  p$code[3] = "a + 3 # bla bla COMMENT bla"
  final0 = readd(final)
  make(p, verbose = F)
  expect_equal(built_(), character(0))
  expect_equal(final0, readd(final))
  p$code[3] = "a+1+2"
  make(p, verbose = F)
  expect_equal(built_(), "c")
  expect_equal(final0, readd(final))
  debug_cleanup()
})

test_that("output files respond appropriately to code changes", {
  debug_cleanup()
  debug_setup()
  p = example_plan("debug")
  make(p, verbose = F)
  final0 = readd("final")
  p$code[7] = "saveRDS(e + 1, \"e\")"
  make(p, verbose = F)
  expect_equal(built_(), c("'e'", "final"))
  expect_false(any(readd(final) == final0))
  p$code[7] = "saveRDS(e+1,\"e\") # bla bla COMMENT bla"
  final0 = readd(final)
  make(p, verbose = F)
  expect_equal(built_(), character(0))
  expect_equal(final0, readd(final))
  p$code[7] = "saveRDS(e + 2 - 1,\"e\")"
  make(p, verbose = F)
  expect_equal(built_(), "'e'")
  expect_equal(final0, readd(final))
  debug_cleanup()
})
