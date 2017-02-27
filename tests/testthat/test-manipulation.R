context("manipulation")

example_datasets = function(){
  out = plan(data1 = df1(n = 10), data2 = df2(n = 20))
  out$check = c(T, F)
  out
}

example_analyses = function(){
  plan(analysis1 = analyze1(..dataset..), analysis2 = analyze2(..dataset..))
}

test_that("Function unique_random_string() is correct.", {
  for(i in c(23, 37, 5)) expect_equal(nchar(unique_random_string(n = i)), i)
  exclude = c(1:9, letters, LETTERS)
  for(i in 1:10) expect_equal("0", unique_random_string(exclude, n = 1))
  exclude = c(0:9, letters[-5], LETTERS)
  for(i in 1:10) expect_equal("e", unique_random_string(exclude, n = 1))
})

test_that("Function expand() is correct.", {
  expect_silent(check(expand(example_datasets())))
  expect_equal(expand(example_datasets()), example_datasets())
  o = expand(example_datasets(), values = c("rep1", "rep2", "rep3"))
  expect_silent(check(o))
  expect_equal(o, data.frame(
    output = c("data1_rep1", "data1_rep2", "data1_rep3", 
               "data2_rep1", "data2_rep2", "data2_rep3"),
    code = c("df1(n = 10)", "df1(n = 10)", "df1(n = 10)", 
                "df2(n = 20)", "df2(n = 20)", "df2(n = 20)"),
    check = c(T, T, T, F, F, F),
    stringsAsFactors = F))
})

test_that("Function gather() is correct.", {
  expect_silent(check(gather(example_analyses())))
  expect_equal(gather(example_analyses()), data.frame(
    output = "output",
    code = "list(analysis1 = analysis1, analysis2 = analysis2)",
    stringsAsFactors = F))
  o = gather(example_analyses(), output = "hi", gather = "cbind")
  expect_silent(check(o))
  expect_equal(o, data.frame(
    output = "hi",
    code = "cbind(analysis1 = analysis1, analysis2 = analysis2)",
    stringsAsFactors = F))
  clean(destroy=TRUE)
})
