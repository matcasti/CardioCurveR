test_that("clean_outlier returns a numeric vector with proper dimensions", {
  set.seed(123)
  n <- 200
  time_vec <- seq(0, 20, length.out = n)
  # Create a simulated RRi signal with dynamic behavior
  signal <- 1000 - 400 / (1 + exp(-3 * (time_vec - 6))) +
    300 / (1 + exp(-2 * (time_vec - 10))) + rnorm(n, sd = 50)

  # Introduce some ectopic beats (simulate ~5% outliers)
  noise_idx <- sample.int(n, size = floor(n * 0.05))
  signal[noise_idx] <- signal[noise_idx] * runif(length(noise_idx), 0.25, 2.00)

  signal_clean <- clean_outlier(signal = signal)

  expect_type(signal_clean, "double")
  expect_equal(length(signal_clean), length(time_vec))
})

test_that("clean_outlier handles missing values correctly", {
  set.seed(123)
  n <- 100
  time_vec <- seq(0, 20, length.out = n)
  signal <- rnorm(n, mean = 1000, sd = 50)

  # Introduce NAs in both time and signal
  time_vec[c(10, 20)] <- NA
  signal[c(10, 20)] <- NA

  df <- clean_outlier(signal = signal)

  # The output signal should have length = n minus the NA cases.
  expect_equal(length(df), n - 2)
  expect_true(all(!is.na(df)))
})

test_that("clean_outlier applies Gaussian replacement correctly", {
  set.seed(123)
  n <- 150
  time_vec <- seq(0, 20, length.out = n)
  # Create a signal that follows a linear trend plus noise
  signal <- 1000 + 0.5 * time_vec + rnorm(n, sd = 20)

  # Force some outliers by adding large noise at random indices
  out_idx <- sample(seq_along(signal), size = 10)
  signal[out_idx] <- signal[out_idx] + 300

  df <- clean_outlier(signal = signal,
                      loess_span = 0.3, threshold = 2,
                      replace = "gaussian", seed = 123)

  # For indices where replacement occurred, the cleaned value should be near the loess prediction.
  fit <- loess(signal ~ time_vec, span = 0.3)
  predicted <- predict(fit, newdata = data.frame(time_vec = time_vec))
  residuals <- signal - predicted
  mad_val <- mad(residuals)
  cutoff <- mad_val * 2
  ectopic <- abs(residuals) > cutoff

  # Check that, for at least one ectopic index, the replaced value differs from the original.
  if (any(ectopic)) {
    expect_false(all(signal[ectopic] == df[ectopic]))
    # Check that replaced values are generated from a normal distribution with mean equal to prediction.
    expect_true(all(abs(df[ectopic] - predicted[ectopic]) <= 4 * mad_val))
  }
})

test_that("clean_outlier applies Uniform replacement correctly", {
  set.seed(123)
  n <- 150
  time_vec <- seq(0, 20, length.out = n)
  signal <- 1000 + 0.5 * time_vec + rnorm(n, sd = 20)
  out_idx <- sample(seq_along(signal), size = 10)
  signal[out_idx] <- signal[out_idx] + 300

  df <- clean_outlier(signal = signal,
                      loess_span = 0.3, threshold = 2,
                      replace = "uniform", seed = 123)

  fit <- loess(signal ~ time_vec, span = 0.3)
  predicted <- predict(fit, newdata = data.frame(time_vec = time_vec))
  residuals <- signal - predicted
  mad_val <- mad(residuals)
  cutoff <- mad_val * 2
  ectopic <- abs(residuals) > cutoff

  # Check that uniform replacements fall between predicted ± mad_val.
  if (any(ectopic)) {
    expect_true(all(df[ectopic] >= predicted[ectopic] - mad_val))
    expect_true(all(df[ectopic] <= predicted[ectopic] + mad_val))
  }
})

test_that("clean_outlier applies LOESS replacement correctly", {
  set.seed(123)
  n <- 150
  time_vec <- seq(0, 20, length.out = n)
  signal <- 1000 + 0.5 * time_vec + rnorm(n, sd = 20)
  out_idx <- sample(seq_along(signal), size = 10)
  signal[out_idx] <- signal[out_idx] + 300

  df <- clean_outlier(signal = signal,
                      loess_span = 0.3, threshold = 2,
                      replace = "loess", seed = 123)

  fit <- loess(signal ~ time_vec, span = 0.3)
  predicted <- predict(fit, newdata = data.frame(time_vec = time_vec))
  residuals <- signal - predicted
  mad_val <- mad(residuals)
  cutoff <- mad_val * 2
  ectopic <- abs(residuals) > cutoff

  # For loess replacement, cleaned values should equal the predicted values at ectopic points.
  if (any(ectopic)) {
    expect_equal(df[ectopic], unname(predicted[ectopic]))
  }
})

test_that("clean_outlier errors on non-numeric inputs", {
  expect_error(clean_outlier(signal = "not numeric"), regexp = "\`signal\` must be numeric")
})
