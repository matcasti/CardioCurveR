test_that("filter_signal returns a vector of same length and trims edges (default parameters)", {
  # Create a simple test signal: a linear sequence.
  x <- seq(1, 100, length.out = 100)
  y <- filter_signal(x)  # default n = 3, W = 0.5, abs = 5

  # Check that the output has the same length as input
  expect_length(y, length(x))

  # Check that the first and last 'abs' samples are set to NA
  expect_true(all(is.na(y[1:5])))
  expect_true(all(is.na(y[(length(y)-5+1):length(y)])))

  # Check that the remaining middle values are not NA
  expect_true(all(!is.na(y[6:(length(y)-5)])))
})

test_that("filter_signal works with custom parameters", {
  # Create a noisy sine signal
  set.seed(123)
  x <- 1000 + sin(seq(0, 2*pi, length.out = 150)) * 50 + rnorm(150, sd = 10)

  # Use custom filter order, cutoff frequency, and trim length.
  y <- filter_signal(x, n = 4, W = 0.3, abs = 10)

  expect_length(y, length(x))
  expect_true(all(is.na(y[1:10])))
  expect_true(all(is.na(y[(length(y)-10+1):length(y)])))
  expect_true(all(!is.na(y[11:(length(y)-10)])))
})

test_that("filter_signal returns expected values for constant signal", {
  # Constant signal should be unchanged by a low-pass filter,
  # aside from edge trimming.
  x <- rep(1000, 500)
  y <- filter_signal(x, abs = 5)

  expect_length(y, length(x))
  expect_true(all(is.na(y[1:5])))
  expect_true(all(is.na(y[(length(y)-5+1):length(y)])))

  # The middle values should remain constant (within numerical precision)
  middle <- y[200:300]
  expect_true(all(abs(middle - 1000) < 1e-6))
})

test_that("filter_signal handles vector of zeros", {
  # Test with a signal of zeros
  x <- rep(0, 100)
  y <- filter_signal(x, abs = 5)

  expect_length(y, length(x))
  expect_true(all(is.na(y[1:5])))
  expect_true(all(is.na(y[(length(y)-5+1):length(y)])))

  # Middle values should be (approximately) zero
  middle <- y[6:(length(y)-5)]
  expect_true(all(abs(middle) < 1e-6))
})

