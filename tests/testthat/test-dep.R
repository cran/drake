# library(testthat); library(drake)
context("dep")

test_that("Function dep works.", {
  expect_equal(dep(), character(0))
  expect_equal(dep(NA), character(0))
  x = "f(x, 1, g(), h(i())) #champ!"
  expect_equal(dep(x), c("f", "x", "g", "h", "i"))
  ops = c("+", "-", "*", "/", "^", "&", "&&", "|", "||", "%%", "%*%", "%>%")
  for(op in ops)
    expect_equal(dep(paste("x", op, "y + z")), c("x", "y", "z"))
  expect_equal(dep(x), c("f", "x", "g", "h", "i"))
  expect_equal(dep("f(g(x < 6))"), c("f", "g", "x"))
  x = "myfun(return(1), myfun2('a', \"b\", 1, 2, f))"
  y = c("myfun", "return", "myfun2", "'a'", "f")
  expect_equal(dep(x), y)
  x = c("f1('x', \"bla\", y, 'z', \"z.csv\")", "f1('x', y, 'z', \"z.csv\", 'w.xyz')")
  y = c("f1", "'x'", "y", "'z'","'w.xyz'")
  expect_equal(length(x), 2)
  expect_equal(dep(x), y)
})

test_that("dep() utilities work.", {
  expect_equal(is_quoted(), list())
  x = c("x", "'x", "'x'", "\"x\"", '"x"')
  y = c(F, F, T, T, T)
  names(y) = x
  expect_equal(is_quoted(x), y)
  x = c(x, "c.csv", "'my/folder/a.csv'")
  expect_equal(is_file(), logical(0))
  expect_equal(is_file(x), c(F, F, T, F, F, F, T))
})
