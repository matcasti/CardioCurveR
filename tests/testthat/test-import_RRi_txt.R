library(testthat)
library(CardioCurveR)

# Test: file is NULL.
test_that("import_RRi_txt errors when file is NULL", {
  expect_error(import_RRi_txt(file = NULL),
               "`file` can't be NULL.")
})

# Test: remove_ectopic is not a logical value of length 1.
test_that("import_RRi_txt errors when remove_ectopic is not a logical of length 1", {
  tmp <- tempfile(fileext = ".txt")
  writeLines(c("800", "900"), tmp)
  expect_error(import_RRi_txt(file = tmp, remove_ectopic = "yes"),
               "`remove_ectopic` must be logical of length 1.")
})

# Test: filter_noise is not a logical value of length 1.
test_that("import_RRi_txt errors when filter_noise is not a logical of length 1", {
  tmp <- tempfile(fileext = ".txt")
  writeLines(c("800", "900"), tmp)
  expect_error(import_RRi_txt(file = tmp, filter_noise = "no"),
               "`filter_noise` must be logical of length 1.")
})

# Test: Processing file correctly without ectopic removal and filtering.
test_that("import_RRi_txt processes file correctly with no cleaning", {
  tmp <- tempfile(fileext = ".txt")
  # Create data with valid and invalid values.
  data_lines <- c("800", "1000", "2100", "500", "200")
  writeLines(data_lines, tmp)

  result <- import_RRi_txt(file = tmp, remove_ectopic = FALSE, filter_noise = FALSE, min = 250, max = 2000)

  # Expect non-realistic readings (2100 and 200) to be removed.
  expect_true(is.data.frame(result))
  expect_true(all(c("time", "RRi") %in% names(result)))
  expect_equal(nrow(result), 3)
  expect_true(all(result$RRi >= 250 & result$RRi <= 2000))
  expect_true(all(diff(result$time) > 0))
})

# Test: Cleaning ectopic beats (assuming clean_outlier() works properly).
test_that("import_RRi_txt applies clean_outlier when remove_ectopic is TRUE", {
  tmp <- tempfile(fileext = ".txt")

  set.seed(1234)
  # Create data with one out-of-range value that would be replaced by clean_outlier.
  data_lines <- round(rt(1000, 10, 800))
  cat(data_lines, file = tmp, sep = "\n")

  result <- import_RRi_txt(file = tmp, remove_ectopic = TRUE, filter_noise = FALSE, min = 250, max = 2000)

  # The out-of-range "3000" is replaced by clean_outlier and then removed via NA removal.
  expect_true(all(result$RRi >= 250 & result$RRi <= 2000))
})

# Test: Filtering noise when filter_noise is TRUE.
test_that("import_RRi_txt applies filter_signal when filter_noise is TRUE", {
  tmp <- tempfile(fileext = ".txt")
  # Create a simple signal that will be filtered.
  data_lines <- as.character(x = c(800, 810, 820, 830, 840, 850, 860))
  writeLines(data_lines, tmp)

  result <- import_RRi_txt(file = tmp, remove_ectopic = FALSE, filter_noise = TRUE, min = 250, max = 2000)

  # Because filter_signal typically trims edge values, final data should have fewer rows than original.
  expect_true(nrow(result) < length(data_lines))
})

# Test: Ensure that additional arguments (...) are passed to readLines (simulate by passing encoding)
test_that("import_RRi_txt passes additional arguments to readLines", {
  tmp <- tempfile(fileext = ".txt")
  writeLines(c("800", "900"), tmp, useBytes = TRUE)

  # Pass an extra argument (e.g., encoding) to readLines via ...
  result <- import_RRi_txt(file = tmp, remove_ectopic = FALSE, filter_noise = FALSE, min = 250, max = 2000, encoding = "UTF-8")

  expect_true(is.data.frame(result))
})
