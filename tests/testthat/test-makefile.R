context("makefile")

test_that("make(makefile = T) initializes and build() works", {
  clean(destroy=TRUE)
  p = plan(x = some_global)
  some_global = 5
  make(p, makefile = T, run = F, verbose = F)
  expect_false("p" %in% cached())
  expect_true("some_global" %in% cached())
  debug_cleanup()
  p = example_plan("small")
  make(p, makefile = T, run = FALSE)
  expect_false("e" %in% cached())
  build("e", F, F)
  expect_true("e" %in% cached())
  unlink("Makefile")
})

test_that("makefile fails correctly on bad input", {
  expect_error(make(NULL, makefile = T, run = F))
  expect_error(make(1:5, makefile = T, run = F))
  p = example_plan("small")
  expect_error(make(p, makefile = T, run = F, verbose = 1))
  expect_error(make(p, makefile = T, run = F, verbose = NA))
  expect_error(make(p, makefile = T, run = F, verbose = NULL))
  expect_error(make(p, makefile = T, run = F, verbose = 1))
  expect_error(make(p, makefile = T, run = F, verbose = c(T, F)))
  p = plan(a = b, b = all)
  expect_silent(make(p, makefile = T, run = F))
  p = plan(a = b, b = all, all = 22)
})

test_that("makefile 'prepend' argument works", {
  p = example_plan("small")
  x = "# hello world"
  make(p, makefile = T, run = F, prepend = x)
  m = readLines("Makefile")
  expect_true(grepl(m[1], x))
  unlink("Makefile")
  clean(destroy=TRUE)
})

test_that("correct Makefiles are written for main examples", {
  p = example_plan("small")  
  expect_silent(make(p, makefile = T, run = F, envir = new.env()))
  d = "makefile-small"
  f = "Makefile"
  x1 = readLines(f)
  x2 = readLines(file.path(d, f))
  unlink("Makefile")
  p = example_plan("debug")
  p = rbind(p, plan(sha = sha1(1)))
  rm(d)
  debug_setup()
  make(p, makefile = T, run = F, verbose = F)
  d = "makefile-debug"
  f = "Makefile"
  x1 = readLines(f)
  x2 = readLines(file.path(d, f))
  expect_equal(x1, x2)
  unlink("Makefile")
  debug_cleanup()
})
