context("make")

test_that("envir is insulated from calling env", {
  clean(destroy=TRUE)
  expect_error(a)
  expect_error(b)
  p = plan(list = c(a = "b<-2; b", c = "1+1; 1+2"))
  make(p, verbose = F)
  expect_equal(readd(a), 2)
  expect_equal(readd(c), 3)
  expect_error(readd(b))
  expect_error(a)
  expect_error(b)
  clean(destroy=TRUE)
  p = plan(x = y)
  y = 1
  e = new.env()
  e$y = 2
  make(p, envir = e, verbose = F)
  expect_equal(y, 1)
  expect_equal(readd(y), 2)
  clean(destroy=TRUE)
  rm(y)
  expect_error(y)
  clean(destroy=TRUE)
  expect_error(make(p, verbose = F))
  expect_silent(make(p, envir = e, verbose = F))
  expect_error(y)
  expect_equal(readd(y), 2)
})

test_that("really long target names are truncated", {
  clean(destroy=TRUE)
  targ = paste(rep("a", 100), collapse = "")
  p = data.frame(output = targ, code = 1)
  o = capture.output(make(p))
  expect_true(all(grepl("\\.\\.\\.$", o)))
  expect_true(all(nchar(o) < 90))
  expect_true(targ %in% cached())
  targ = "abc"
  p = data.frame(output = targ, code = 1)
  o = capture.output(make(p))
  expect_false(any(grepl("\\.\\.\\.$", o)))
  expect_true(targ %in% cached())
  clean(destroy=TRUE)
})

test_that("make() fails correctly on bad input", {
  clean(destroy=TRUE)
  x = example_plan("small")
  y = data.frame(code = character(0), output = character(0))
  expect_error(make(y))
  expect_error(make(x, output = NULL))
  expect_error(make(x, output = "bla"))
  expect_error(make(x, envir = "bla"))
  expect_true(!file.exists(cache_path))
  unlink("input")
  x = example_plan("debug")
  expect_error(make(x))
  clean(destroy=TRUE)
  x = data.frame(output = c("z", "z"), code = c("1", "1"),
    stringsAsFactors = F)
  expect_error(make(x))
  x = plan(list = c(out = "readRDS('input')"))
  expect_error(make(x))
  clean(destroy=TRUE)
  expect_true(!file.exists(cache_path))
  expect_true(!file.exists("input"))
})

test_that("verbosity works", {
  clean(destroy=TRUE)
  p = example_plan("small")
  expect_output(make(p))
  expect_silent(make(p, verbose = F))
  clean(destroy=TRUE)
})

test_that("make() fails correctly when there's a cycle", {
  clean(destroy=TRUE)
  p = plan(a = b, b = a)
  expect_error(make(p))
  p = plan(a = b, b = c, c = a)
  expect_error(make(p))
  unlink(cache_path, recursive = T)
  expect_false(file.exists(cache_path))
})

test_that("row order doesn't matter", {
  clean(destroy=TRUE)
  p = example_plan("small")
  make(p, verbose = F)
  expect_equal(readd("a"), 14)
  clean(destroy=TRUE)
  expect_equal(cached(), character(0))
  p = p[c(3, 6, 4, 1, 5, 2),]
  make(p, verbose = F)
  expect_equal(readd("a"), 14)
  clean(destroy=TRUE)
})

test_that("output conflicts are caught and reported", {
  p = example_plan("small")
  e = 1000
  expect_error(make(p, verbose = F))
  rm(e)
  expect_silent(make(p, verbose = F))
  b = function(){stop("Gotcha!")}
  expect_error(make(p, verbose = F))
  rm(b)
  expect_silent(make(p, verbose = F))
  d = plan("'file'" = saveRDS(mtcars, "file"))
  d = rbind(d, d)
  expect_error(make(d, verbose = F))
  d$output = eply::unquote(d$output)
  d$code = 1:2
  expect_error(make(d, verbose = F))
  unlink(cache_path, recursive = T)
})

test_that("individual groups of targets can be made", {
  p = example_plan("small")
  make(p, c("c", "e"), verbose = F)
  expect_equal(letters[3:6], cached())
  unlink(cache_path, recursive = T)
})

test_that("loaded packages are used", {
  expect_equal(cached(), character(0)) 
  plan = rbind(example_plan("small"), 
    data.frame(output = "final", code = "sha1(a) %>% as.character"))
  library(digest)
  library(magrittr)
  expect_silent(make(plan, verbose = F))
  expect_equal(readd("final"), digest::sha1(readd("a")))
  l = c(letters[1:6], "final")
  expect_true(all(l %in% cached()))
  expect_false(any(l %in% ls()))
  unlink(cache_path, recursive = TRUE)
})

test_that("long chain of deps is okay", {
  plan = data.frame(
    code = letters[1:25],
    output = letters[2:26])
  expect_error(make(p, verbose = F))
  a = 1
  expect_silent(make(plan, "y", verbose = F))
  expect_equal(cached(), letters[1:25])
  expect_silent(make(plan, verbose = F))
  expect_equal(cached(), letters[1:26])
  unlink(cache_path, recursive = TRUE)
})

test_that("self$envir contains only the necessary data", {
  unlink(c("d", "e", "input"))
  unlink(cache_path, recursive = T)
  p = example_plan("debug")
  debug_setup()
  x = Make$new(p, envir = environment(), output = "d")
  loads = c("f", "g", "global", "h", "i", "j", "y")
  expect_true(all(loads %in% ls(x$envir)))
  expect_output(x$make())
  ls(x$envir)
  loads = c(loads, "b", "c")
  expect_true(all(loads %in% ls(x$envir)))
  exclude = c("a", "d", "e", "final")
  expect_false(any(exclude %in% ls(x$envir)))
  expect_false(any(c(letters[1:5], "final") %in% ls()))
  expect_error(o <- x$deps("bla"))
  expect_silent(o <- x$deps("a"))
  unlink(c("d", "e", "input"))
  unlink(cache_path, recursive = T)
})

test_that("'global' var is necessary", {
  unlink(c("d", "e", "input"))
  unlink(cache_path, recursive = T)
  p = example_plan("debug")
  debug_setup()
  rm(global)
  expect_error(make(p, verbose = F))
  global = 10
  expect_silent(make(p, verbose = F))
  unlink(c("d", "e", "input"))
  unlink(cache_path, recursive = T)
})
