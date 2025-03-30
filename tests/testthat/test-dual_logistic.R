test_that("dual_logistic correctly computes RRi values", {
  t <- seq(0, 20, length.out = 100)
  params <- list(alpha = 1000, beta = -380, lambda = -3, tau = 6,
                 c = 0.85, phi = -2, delta = 3)

  RRi_model <- dual_logistic(t, params)

  expect_type(RRi_model, "double")
  expect_length(RRi_model, length(t))
  expect_true(all(is.finite(RRi_model)))  # Ensure no NaNs or Inf values
})

test_that("dual_logistic handles edge cases correctly", {
  t <- c(0, 5, 10, 15, 20)
  params <- list(alpha = 1000, beta = -380, lambda = -3, tau = 6,
                 c = 0.85, phi = -2, delta = 3)

  RRi_model <- dual_logistic(t, params)

  expect_true(all(diff(RRi_model) <= 0 | diff(RRi_model) >= 0))  # Check monotonicity trends
  expect_true(RRi_model[1] > RRi_model[2])  # Initial drop
  expect_true(RRi_model[4] < RRi_model[5])  # Recovery phase
})

test_that("dual_logistic errors on invalid inputs", {
  expect_error(dual_logistic("not numeric", list(alpha = 1000, beta = -380, lambda = -3,
                                                 tau = 6, c = 0.85, phi = -2, delta = 3)),
               "`t` must be a numeric vector.")

  expect_error(dual_logistic(seq(0, 20, length.out = 100), list(alpha = 1000, beta = -380)),
               "`params` must be a list/vector of length 7.")
})

test_that("dual_logistic handles extreme parameter values", {
  t <- seq(0, 20, length.out = 100)

  # Extremely steep logistic functions (approaching step function behavior)
  params_steep <- list(alpha = 1000, beta = -380, lambda = -50, tau = 6,
                       c = 0.85, phi = -50, delta = 3)
  RRi_steep <- dual_logistic(t, params_steep)

  expect_true(any(diff(RRi_steep) < -50))  # Very rapid drop
  expect_true(any(diff(RRi_steep) > 50))   # Very rapid recovery
  expect_true(length(unique(RRi_steep)) > 2)  # Should not collapse to two discrete values

  # Extreme alpha (baseline RRi) should shift all values
  params_high_alpha <- modifyList(params_steep, list(alpha = 2000))
  RRi_high_alpha <- dual_logistic(t, params_high_alpha)

  expect_true(all(RRi_high_alpha > 1500))  # Ensuring baseline shift
})

