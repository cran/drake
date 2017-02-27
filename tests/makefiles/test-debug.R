suppressPackageStartupMessages({
  library(drake) # drake needs to be installed anyway for this test to work.
  library(eply)
  library(testthat)
})
unlink("Makefile")
debug_cleanup()
expect_equal(cached(), character(0))
source("../testthat/utils.R")

test_that("Makefiles for debug example behave", {

debug_setup()

p = example_plan("debug")
p = rbind(p, data.frame(code = "sha1(b)", output = "sha"))
expect_error(dummy)
test = 0

cat(test<-test+1, "")
make(p, makefile=T, run = T, command = "make", args = c("--jobs=2", "-s"), verbose = F,
     packages = character(0),
     global = strings(library(digest), dummy <- 1))
expect_equal(dummy, 1)
expect_true(file.exists("Makefile"))
expect_true(all(file.exists(c("d", "e"))))
expect_true(all(c("'d'", "final", "sha") %in% cached()))
expect_equal(nrow(drake::status()), 17)
expect_equal(digest::sha1(readd(b)), readd(sha))

cat(test<-test+1, "")
clean(T)
expect_equal(cached(), character(0))
make(p, makefile=T, run = T, command = "make", args = c("-j2", "-s"), verbose = F,
     packages = "digest")
expect_true(file.exists("Makefile"))
expect_true(all(file.exists(c("d", "e"))))
expect_true(all(c("'d'", "final", "sha") %in% cached()))
expect_equal(nrow(drake::status()), 17)
expect_equal(digest::sha1(readd(b)), readd(sha))

cat(test<-test+1, "")
make(p, command = "make", args = "-s", packages = "digest", makefile=T, verbose = F)
expect_true(all(drake::status()$status == "imported"))

cat(test<-test+1, "")
clean(T)
expect_equal(cached(), character(0))
suppressPackageStartupMessages(library(digest))
suppressPackageStartupMessages(
  make(p, makefile=T, run = T, command = "make", args = c("-j2", "-s"), verbose = F))
expect_true(file.exists("Makefile"))
expect_true(all(file.exists(c("d", "e"))))
expect_true(all(c("'d'", "final", "sha") %in% cached()))
expect_equal(nrow(drake::status()), 17)
expect_equal(digest::sha1(readd(b)), readd(sha))

cat(test<-test+1, "")
make(p, packages = "digest", makefile=T, verbose = F,
     command = "make", args = c("-j2", "-s"))
expect_true(all(drake::status()$status == "imported"))

cat(test<-test+1, "")
unlink("e")
expect_false(file.exists("e"))
make(p, packages = "digest", makefile=T, verbose = F,
     command = "make", args = c("-j2", "-s"))
expect_true(file.exists("e"))

cat(test<-test+1, "")
make(p, packages = "digest", makefile=T, verbose = F,
     command = "make", args = c("-j2", "-s"))
expect_true(all(drake::status()$status == "imported"))

cat(test<-test+1, "")
final0 = readd(final)
g = function(x){
  h(x) + i(x) + 1
}
make(p, packages = "digest", makefile=T, verbose = F,
     command = "make", args = c("-j2", "-s"))
expect_false(identical(readd(final), final0))

cat(test<-test+1, "")
make(p, packages = "digest", makefile=T, verbose = F,
     command = "make", args = c("-j2", "-s"))
expect_true(all(drake::status()$status == "imported"))

cat(test<-test+1, "")
p$code[3] = "a+2"
make(p, makefile=T, verbose = F, packages = "digest",
     command = "make", args = c("-j2", "-s"))
expect_true(all(drake::status()$status == "imported"))

cat(test<-test+1, "")
final0 = readd(final)
p$code[2] = "a+2"
make(p, packages = "digest", makefile=T, verbose = F,
     command = "make", args = c("-j2", "-s"))
expect_false(identical(readd(final), final0))

cat("\n")
debug_cleanup()
unlink("Makefile")

})