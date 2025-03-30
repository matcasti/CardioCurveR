dummy_RRi_fit <- function() {
  # Generate a small dummy dataset
  set.seed(42)
  time_vec <- seq(0, 10, length.out = 100)
  RRi <- rnorm(100, mean = 800, sd = 50)
  # For testing purposes, let's define fitted values as a simple linear function:
  fitted <- 800 + 2 * time_vec
  data <- data.frame(time = time_vec, RRi = RRi, fitted = fitted)

  fit_obj <- list(
    data = data,
    method = "L-BFGS-B",
    parameters = c(alpha = 800, beta = -380, c = 0.85, lambda = -3, phi = -2, tau = 6, delta = 3),
    objective_value = 12345,
    convergence = 0
  )
  class(fit_obj) <- "RRi_fit"
  fit_obj
}

dummy_fit <- dummy_RRi_fit()

test_that("print.RRi_fit outputs expected text", {
  # Capture the printed output
  printed <- capture.output(print(dummy_fit))

  expect_true(any(grepl("RRi_fit Object", printed)))
  expect_true(any(grepl("Optimization Method: L-BFGS-B", printed)))
  expect_true(any(grepl("Estimated Parameters:", printed)))
  expect_true(any(grepl("Objective Value \\(Huber loss\\): 12345", printed)))
  expect_true(any(grepl("Convergence Code: 0", printed)))
})

test_that("summary.RRi_fit returns a list with correct components", {
  sum_fit <- summary(dummy_fit)

  expect_type(sum_fit, "list")
  expect_true("method" %in% names(sum_fit))
  expect_true("parameters" %in% names(sum_fit))
  expect_true("objective_value" %in% names(sum_fit))
  expect_true("convergence" %in% names(sum_fit))
  expect_true("RSS" %in% names(sum_fit))
  expect_true("TSS" %in% names(sum_fit))
  expect_true("R_squared" %in% names(sum_fit))
  expect_true("RMSE" %in% names(sum_fit))
  expect_true("MAPE" %in% names(sum_fit))
  expect_true("n" %in% names(sum_fit))

  # Check that n is correct
  expect_equal(sum_fit$n, nrow(dummy_fit$data))

  # Check that R_squared is computed correctly:
  residuals <- dummy_fit$data$RRi - dummy_fit$data$fitted
  rss <- sum(residuals^2)
  tss <- sum((dummy_fit$data$RRi - mean(dummy_fit$data$RRi))^2)
  r_squared <- 1 - rss/tss
  expect_equal(sum_fit$R_squared, r_squared)

  # Check RMSE and MAPE (they are numeric)
  expect_type(sum_fit$RMSE, "double")
  expect_type(sum_fit$MAPE, "double")
})

test_that("print.summary.RRi_fit outputs expected text", {
  sum_fit <- summary(dummy_fit)
  printed <- capture.output(print(sum_fit))

  expect_true(any(grepl("Summary of RRi_fit Object", printed)))
  expect_true(any(grepl("Optimization Method: L-BFGS-B", printed)))
  expect_true(any(grepl("Objective Value \\(Huber loss\\):", printed)))
  expect_true(any(grepl("Residual Sum of Squares \\(RSS\\):", printed)))
  expect_true(any(grepl("Total Sum of Squares \\(TSS\\):", printed)))
  expect_true(any(grepl("R-squared:", printed)))
  expect_true(any(grepl("Root Mean Squared Error \\(RMSE\\):", printed)))
  expect_true(any(grepl("Mean Absolute Percentage Error \\(MAPE\\):", printed)))
  expect_true(any(grepl("Number of observations:", printed)))
  expect_true(any(grepl("Convergence Code: 0", printed)))
})

test_that("plot.RRi_fit produces a panel of diagnostic plots", {
  # Check that plot.RRi_fit does not produce errors and returns invisibly the input object.
  expect_silent({
    res <- plot(dummy_fit)
  })

  # In addition, we can check that ggplot objects are created by temporarily overriding grid.arrange
  # (if desired; here we simply check that the plot function runs without error).
})

