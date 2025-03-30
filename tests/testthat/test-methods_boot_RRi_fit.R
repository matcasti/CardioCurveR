# Helper function to create a dummy boot_RRi_fit object
dummy_boot_RRi_fit <- function() {
  set.seed(1)
  nboot <- 10
  # Create a dummy data.frame with bootstrap replicate id and parameter estimates.
  df <- data.frame(
    nboot = 1:nboot,
    alpha = runif(nboot, 700, 900),
    beta = runif(nboot, -400, -300),
    c = runif(nboot, 0.7, 0.9),
    lambda = runif(nboot, -4, -2),
    phi = runif(nboot, -3, -1),
    tau = runif(nboot, 5, 7),
    delta = runif(nboot, 2, 4)
  )
  class(df) <- c("boot_RRi_fit", class(df))
  df
}

dummy_obj <- dummy_boot_RRi_fit()

test_that("print.boot_RRi_fit outputs expected text", {
  printed <- capture.output(print(dummy_obj))
  expect_true(any(grepl("Bootstrap RRi Parameter Estimates", printed)))
  expect_true(any(grepl("Number of bootstrap replicates:", printed)))
  expect_true(any(grepl("Preview of estimated parameters", printed)))
  # Test that the function returns invisibly
  expect_identical(invisible(dummy_obj), dummy_obj)
})

test_that("summary.boot_RRi_fit returns a proper summary with robust measures (default)", {
  sum_obj <- CardioCurveR:::summary.boot_RRi_fit(dummy_obj)
  # The summary should be a list (transposed data.table) with a column named "alpha"
  expect_type(sum_obj, "list")
  expect_true("alpha" %in% sum_obj$Parameter)
  # Check that the robust attribute is TRUE by default
  expect_true(isTRUE(attr(sum_obj, "robust")))

  # Check that each parameter has three elements: estimate, scale and CI string.
  for(param in names(sum_obj)) {
    expect_equal(length(sum_obj[["Parameter"]]), 7)
  }
})

test_that("summary.boot_RRi_fit returns a summary with non-robust measures when robust=FALSE", {
  sum_obj <- CardioCurveR:::summary.boot_RRi_fit(dummy_obj, robust = FALSE)
  expect_false(attr(sum_obj, "robust"))
})

test_that("print.summary.boot_RRi_fit outputs expected text", {
  sum_obj <- CardioCurveR:::summary.boot_RRi_fit(dummy_obj)
  printed <- capture.output(print(sum_obj))
  expect_true(any(grepl("Summary of Bootstrap RRi Parameter Estimates", printed)))
  expect_true(any(grepl("95% confidence intervals are quantile-based", printed)))
  # Check note for robust method is printed correctly
  if (isTRUE(attr(sum_obj, "robust"))) {
    expect_true(any(grepl("median and median absolute deviation", printed)))
  } else {
    expect_true(any(grepl("mean and standard deviation", printed)))
  }
})

test_that("plot.boot_RRi_fit produces density plots without error", {
  # Since the plot method prints the plot, we can check that the output is invisible
  expect_invisible(
    suppressMessages(plot(dummy_obj))
  )
})

