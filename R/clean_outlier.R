#' Clean RR-Interval Signal Using Local Smoothing and Adaptive Outlier Replacement
#'
#' This function cleans an RR-interval (RRi) signal by identifying ectopic or noisy beats using
#' a robust, locally adaptive approach. In the context of cardiovascular monitoring (such as
#' for applying the Castillo-Aguilar et al. (2025) non-linear model), the function first fits a
#' local regression (LOESS) to the RRi signal as a function of time, computes the residuals, and then
#' identifies ectopic beats as those with residuals exceeding a multiple of the median absolute deviation.
#'
#' The function offers several replacement strategies for these outliers:
#' \describe{
#'   \item{\code{"gaussian"}}{Replace ectopic values with random draws from a normal distribution,
#'         centered at the LOESS-predicted value with a standard deviation equal to the robust MAD.}
#'   \item{\code{"uniform"}}{Replace ectopic values with random draws from a uniform distribution,
#'         bounded by the LOESS-predicted value \emph{±} the MAD.}
#'   \item{\code{"loess"}}{Simply replace ectopic values with the LOESS-predicted values.}
#' }
#'
#' This adaptive approach ensures that dynamic changes in the RRi signal, such as those observed during
#' exercise, are preserved, while ectopic or spurious beats are corrected without "chopping" the data.
#'
#' @param time A numeric vector of time points corresponding to the RRi recordings.
#' @param signal A numeric vector of RR interval (RRi) values.
#' @param loess_span A numeric value controlling the span for the LOESS fit (default is 0.25). Smaller
#'   values yield a more local fit.
#' @param threshold A numeric multiplier (default is 2) for the median absolute deviation (MAD)
#'   to determine the cutoff for flagging ectopic beats.
#' @param replace A character string specifying the replacement method for ectopic beats. Must be one of
#'   \code{"gaussian"}, \code{"uniform"}, or \code{"loess"} (default is \code{"gaussian"}).
#' @param seed An integer to set the random seed for reproducibility of the replacement process (default is 123).
#'
#' @return A \code{data.frame} containing the original time values and the cleaned RRi signal.
#'
#' @examples
#' \dontrun{
#' # Simulate an RRi signal with dynamic behavior and ectopic beats:
#' set.seed(123)
#' n <- 1000
#' time_vec <- seq(0, 20, length.out = n)
#' signal <- 1000 -
#' 400 / (1 + exp(-3 * (time_vec - 6))) +
#' 300 / (1 + exp(-2 * (time_vec - 10))) + rnorm(n, sd = 50)
#' # Introduce ectopic beats (5% of total signal)
#' noise_points <- sample.int(n, floor(n*0.05))
#' signal[noise_points] <- signal[noise_points] * runif(25, 0.25, 2.00)
#'
#' # Clean the signal using the default Gaussian replacement strategy
#' clean_df <- clean_outlier(time = time_vec, signal = signal,
#'                          loess_span = 0.25, threshold = 2,
#'                          replace = "gaussian", seed = 123)
#'
#' plot(time_vec, signal, main = "Original vs Cleaned R-R interval Signal",
#'      xlab = "Time (min)", ylab = "RRi (ms)", type = "l", axes = FALSE)
#' axis(1); axis(2)
#' lines(clean_df, col = "red2")
#' }
#'
#' @importFrom stats complete.cases loess predict mad rnorm runif
#' @export
clean_outlier <- function(time, signal,
                         loess_span = 0.25, threshold = 2,
                         replace = c("gaussian", "uniform", "loess"),
                         seed = 123) {

  if (!is.numeric(time) || !is.numeric(signal)) {
    stop("\`time\` and \`signal\` must be both numeric")
  }
  if (length(time) != length(signal)) {
    stop("\`time\` and \`signal\` must be of the same length")
  }

  # Ensure that time and signal have complete cases
  ind <- stats::complete.cases(time, signal)
  time <- time[ind]
  signal <- signal[ind]

  # Fit a local regression model to capture dynamic trends
  fit <- stats::loess(signal ~ time, span = loess_span)
  predicted <- stats::predict(fit)

  # Compute residuals and determine adaptive threshold based on MAD
  residual_values <- signal - predicted
  mad_value <- stats::mad(residual_values)
  cutoff_mad <- mad_value * threshold

  # Flag ectopic (noisy) beats based on the adaptive threshold
  ectopic_values <- abs(residual_values) > cutoff_mad

  # Set seed for reproducibility
  set.seed(seed)

  # Validate the replacement method
  replace <- match.arg(replace)

  # Replace ectopic values based on the chosen method
  if (replace == "gaussian") {
    signal[ectopic_values] <- stats::rnorm(n = sum(ectopic_values),
                                    mean = predicted[ectopic_values],
                                    sd = mad_value)
  } else if (replace == "uniform") {
    signal[ectopic_values] <- stats::runif(n = sum(ectopic_values),
                                    min = predicted[ectopic_values] - mad_value,
                                    max = predicted[ectopic_values] + mad_value)
  } else if (replace == "loess") {
    signal[ectopic_values] <- predicted[ectopic_values]
  }

  # Return the cleaned signal along with time
  data.frame(time = time, signal = signal)
}
