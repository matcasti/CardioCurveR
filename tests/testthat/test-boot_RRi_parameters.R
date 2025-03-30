# Helper function to create a dummy RRi_fit object
dummy_RRi_fit <- function() {
  # Create a simple dummy dataset
  time <- seq(0, 20, length.out = 50)
  RRi <- 800 + rnorm(50, sd = 20)
  fitted <- 800 + 2 * time  + rnorm(50, sd = 5)  # Dummy fitted values
  data <- data.frame(time = time, RRi = RRi, fitted = fitted)

  # Create a dummy fit object with required components
  fit_obj <- list(
    data = data,
    method = "L-BFGS-B",
    parameters = c(alpha = 800, beta = -380, c = 0.85,
                   lambda = -3, phi = -2, tau = 6, delta = 3),
    objective_value = 12345,
    convergence = 0
  )
  class(fit_obj) <- "RRi_fit"
  return(fit_obj)
}

dummy_fit <- dummy_RRi_fit()

test_that("boot_RRi_parameters errors on NULL fit", {
  expect_error(boot_RRi_parameters(fit = NULL),
               "`fit` can't be NULL")
})

test_that("boot_RRi_parameters errors when n_samples is not numeric", {
  expect_error(boot_RRi_parameters(fit = dummy_fit, n_samples = "not numeric"),
               "`n_samples` must be a numeric.")
})

test_that("boot_RRi_parameters errors when n_samples exceeds available rows", {
  # nrow(dummy_fit$data) is 50; try n_samples = 60
  expect_error(boot_RRi_parameters(fit = dummy_fit, n_samples = 60),
               "`n_samples` can't be greater than the number")
})

test_that("boot_RRi_parameters errors when prop_of_samples is not numeric", {
  expect_error(boot_RRi_parameters(fit = dummy_fit, prop_of_samples = "bad"),
               "`prop_of_samples` must be a numeric.")
})

test_that("boot_RRi_parameters errors when nboot is NULL", {
  expect_error(boot_RRi_parameters(fit = dummy_fit, nboot = NULL),
               "`nboot` can't be NULL")
})

test_that("boot_RRi_parameters errors when nboot is not numeric", {
  expect_error(boot_RRi_parameters(fit = dummy_fit, nboot = "bad"),
               "`nboot` must be a numeric.")
})

test_that("boot_RRi_parameters uses prop_of_samples to override n_samples", {
  # Using prop_of_samples = 0.5, n_samples should become floor(50*0.5)=25
  boot_res <- boot_RRi_parameters(fit = dummy_fit, prop_of_samples = 0.5, nboot = 10)
  # Expect 10 rows (one per bootstrap replicate)
  expect_equal(nrow(boot_res), 10)
})

test_that("boot_RRi_parameters runs successfully with default n_samples", {
  boot_res <- boot_RRi_parameters(fit = dummy_fit, nboot = 5)
  expect_s3_class(boot_res, "boot_RRi_fit")
  # Check that each row has columns corresponding to the parameters plus nboot
  expected_cols <- c("nboot", names(dummy_fit$parameters))
  expect_true(all(expected_cols %in% names(boot_res)))
  # Check that nboot column is as expected
  expect_equal(unique(boot_res$nboot), seq_len(5))
})

test_that("boot_RRi_parameters returns a data.table converted to data.frame", {
  boot_res <- boot_RRi_parameters(fit = dummy_fit, nboot = 3)
  # Check that the output is a data.frame with class "boot_RRi_fit"
  expect_true(is.data.frame(boot_res))
  expect_true("boot_RRi_fit" %in% class(boot_res))
})
