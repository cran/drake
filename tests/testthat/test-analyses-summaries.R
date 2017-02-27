# library(testthat); library(drake);
context("analyses-summaries")

test_that("Functions analyses() and summaries() are correct.", {
  debug_cleanup()
  clean(destroy=TRUE)

  d1 = plan(
    normal16 = normal_dataset(n = 16),
    poisson32 = poisson_dataset(n = 32),
    poisson64 = poisson_dataset(n = 64)
  )

  d2 = plan(
    out = ls(),
    normal16 = normal_dataset(n = 16),
    poisson32 = poisson_dataset(n = 32),
    poisson64 = poisson_dataset(n = 64)
  )

  a1 = analyses(
    plan = plan(
      linear = linear_analysis(..dataset..),
      quadratic = quadratic_analysis(..dataset..)),
    datasets = d1)

  a2 = analyses(
    plan = plan(
      linear = linear_analysis(..dataset..),
      quadratic = quadratic_analysis(..dataset..)),
    datasets = d2)

  s1 = summaries(
    plan = plan(
      mse = mse_summary(..dataset.., ..analysis..),
      coef = coefficients_summary(..analysis..)),
    analyses = a1, datasets = d1)

  s2 = summaries(
    plan = plan(
      mse = mse_summary(..dataset.., ..analysis..),
      coef = coefficients_summary(..analysis..)),
    analyses = a2, datasets = d2, gather = strings(c, rbind))

  s3 = summaries(
    plan = plan(
      mse = mse_summary(..dataset.., ..analysis..),
      coef = coefficients_summary(..analysis..)),
    analyses = a2, datasets = d2, gather = NULL)

  for(x in strings(a1, a2, s1, s2, s3)){
    a = get(x)
    b = read.table(file.path("analyses-summaries",
        paste0(x, ".txt")),
        stringsAsFactors = F, head = T)
    expect_equal(sanitize(a), sanitize(b))
    expect_silent(check(a))
    expect_silent(check(b))
  }
  clean(destroy=TRUE)
})
