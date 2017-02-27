context("rebuild")
source("utils.R")

test_that("rebuild after no change skips everything", {
  clean(destroy=TRUE)
  p = example_plan("debug")
  debug_setup()
  make(p, verbose = F)
  fin = readd("final")
  expect_true(all(updated() == status()$output))
  make(p, verbose = F)
  expect_equal(fin, readd("final"))
  expect_equal(intersect(updated(), p$output), character(0))
  debug_cleanup()
})

test_that("updates pick up where they last left off", {
  clean(destroy=TRUE)
  p = example_plan("debug")
  debug_setup()
  make(p, verbose = F)
  d0 = readd("d")
  e0 = readRDS("e")
  final0 = readd(final)
  all_obj = sort(c(imported_(), p$output))
  expect_equal(cached(), all_obj)
  p$code[2] = "a + 10"
  make(p, output = "e", verbose = F)
  expect_equal(readd(final), final0)
  expect_true(any(readd("d") != d0))
  expect_equal(cached(), all_obj)
  expect_equal(built_(), c("b", "d", "e"))
  expect_equal(skipped(), c("a", "c"))
  make(p, verbose = F)
  expect_false(any(readd(final) == final0))
  expect_equal(built_(), c("'d'", "'e'", "final"))
  expect_equal(cached(), all_obj)
  expect_false(any(e0 == readRDS("e")))
  e0 = readRDS("e")
  f0 = readd("final")
  h = function(x){
    x+6
    stop()
  }
  expect_error(make(p, verbose = F))
  expect_equal(cached(), all_obj)
  expect_equal(readd(final), f0)
  h = function(x){x+6}
  expect_silent(make(p, verbose = F))
  expect_equal(cached(), all_obj)
  expect_equal(built_(), c("'d'", "'e'", "d", "e", "final"))
  expect_true(any(readd("final") != f0))
  expect_true(any(readRDS("e") != e0))
  debug_cleanup()
})

test_that("global non-function objects are tracked", {
  clean(destroy=TRUE)
  p = plan(a = b, b = C, C = d)
  expect_error(make(p, verbose = F))
  d = 1
  expect_silent(make(p, verbose = F))
  expect_equal(readd("d"), 1)
  expect_equal(readd("a"), 1)
  d = 2
  expect_equal(readd("d"), 1)
  make(p, verbose = F)
  expect_equal(readd("d"), 2)
  expect_equal(readd("a"), 2)
  clean(destroy=TRUE)
  expect_equal(d, 2)
})

test_that("nested function/object imports/changes are handled well", {
  clean(destroy=TRUE)
  p = plan(x = f(2), y = x + 2)
  f = function(x) g(x) + 1
  g = function(x) h(x) + 2
  h = function(x) x^2
  make(p, verbose = F)
  expect_equal(updated(), c("f", "g", "h", "x", "y"))
  expect_equal(readd("y"), 9)
  h = function(x) {x^2 + 1}
  make(p, verbose = F)
  expect_equal(updated(), c("f", "g", "h", "x", "y"))
  expect_equal(readd("y"), 10)
  h = function(x) {x^2 + 2 - 1}
  make(p, verbose = F)
  expect_equal(built_(), "x")
  expect_equal(readd("y"), 10)
  h = function(x) {
   x^2 + 2-1 # bla bla bla
  }
  make(p, verbose = F)
  expect_equal(built_(), character(0))
  expect_equal(readd("y"), 10)
  h = function(x) {x^2 + global}
  global = 1
  make(p, verbose = F)
  expect_equal(readd("y"), 10)
  expect_equal(updated(), c("f", "g", "global", "h", "x"))
  global = 2
  make(p, verbose = F)
  expect_equal(readd("y"), 11)
  expect_equal(updated(), c("f", "g", "global", "h", "x", "y"))
  clean(destroy=TRUE)
})
