suppressPackageStartupMessages({
  library(drake) # drake needs to be installed anyway for this test to work.
  library(eply)
  library(testthat)
})

# need to uncache previous imports on initialize()
test_that("projects with Makefiles can be switched", {

debug_setup()
make(example_plan("debug"), verbose = F)
expect_false(is.numeric(readd(f)))
rm(f)
make(example_plan("small"), verbose = F, makefile = T, 
  packages = character(0), command = "make", args = "-j2 -s")
expect_true(is.numeric(readd(f)))
debug_cleanup()

debug_setup()
make(example_plan("debug"), verbose = F)
expect_false(is.numeric(readd(f)))
rm(f)
make(example_plan("small"), verbose = F)
expect_true(is.numeric(readd(f)))
debug_cleanup()

})
