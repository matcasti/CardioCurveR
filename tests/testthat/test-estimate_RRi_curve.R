test_that("estimate_RRi_curve runs correctly on simulated data", {
  set.seed(123)
  time_vec <- seq(0, 20, by = 0.1)
  true_params <- c(alpha = 800, beta = -380, c = 0.85,
                   lambda = -3, phi = -2, tau = 6, delta = 3)

  RRi_simulated <- dual_logistic(time_vec, true_params) +
    rnorm(length(time_vec), sd = 30)

  fit <- estimate_RRi_curve(time = time_vec, RRi = RRi_simulated)

  expect_type(fit, "list")
  expect_named(fit, c("method", "parameters", "objective_value", "convergence"))
  expect_length(fit$parameters, length(true_params))
  expect_true(fit$convergence == 0)  # Check if optimization converged
})

test_that("estimate_RRi_curve handles missing values correctly", {
  set.seed(123)
  time_vec <- seq(0, 20, by = 0.1)
  RRi_simulated <- rnorm(length(time_vec), mean = 800, sd = 30)

  # Introduce NAs
  RRi_simulated[c(10, 50, 100)] <- NA
  time_vec[c(10, 50, 100)] <- NA

  fit <- estimate_RRi_curve(time = time_vec, RRi = RRi_simulated)

  expect_type(fit, "list")
  expect_true(fit$convergence == 0)
})

test_that("estimate_RRi_curve errors on invalid inputs", {
  time_vec <- seq(0, 20, by = 0.1)
  RRi_simulated <- rnorm(length(time_vec), mean = 800, sd = 30)

  expect_error(estimate_RRi_curve(time = "not numeric", RRi = RRi_simulated),
               "Both 'time' and 'RRi' must be numeric vectors.")
  expect_error(estimate_RRi_curve(time = time_vec, RRi = "not numeric"),
               "Both 'time' and 'RRi' must be numeric vectors.")
  expect_error(estimate_RRi_curve(time = time_vec[-1], RRi = RRi_simulated),
               "'time' and 'RRi' must be the same length.")
})

test_that("estimate_RRi_curve allows custom optimization methods", {
  set.seed(123)
  time_vec <- seq(0, 20, by = 0.1)
  true_params <- c(alpha = 800, beta = -380, c = 0.85,
                   lambda = -3, phi = -2, tau = 6, delta = 3)

  RRi_simulated <- dual_logistic(time_vec, true_params) +
    rnorm(length(time_vec), sd = 30)

  fit_nelder_mead <- estimate_RRi_curve(time = time_vec, RRi = RRi_simulated, method = "Nelder-Mead")

  expect_type(fit_nelder_mead, "list")
  expect_true(fit_nelder_mead$convergence == 0)
})

test_that("estimate_RRi_curve works with boundary conditions", {
  time_vec <- seq(0, 20, by = 0.1)
  RRi_constant <- rep(800, length(time_vec))  # No variation in RRi

  fit <- estimate_RRi_curve(time = time_vec, RRi = RRi_constant)

  expect_type(fit, "list")
  expect_true(fit$convergence == 0)
  expect_true(all(abs(fit$parameters - c(800, -380, 0.85, -3, -2, 6, 3)) < 100))  # Rough check
})
