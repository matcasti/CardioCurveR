#' Simulated RR Interval (RRi) Data with Ectopic Beats
#'
#' A data frame containing a simulated RR interval (RRi) signal generated using the dual-logistic model as
#' described by Castillo-Aguilar et al. (2025). The data are produced by first computing a theoretical RRi curve
#' based on specified model parameters, then adding Gaussian noise to mimic natural variability, and finally
#' introducing ectopic beats by modifying 5% of the data points (multiplying by a factor of 0.3 or 1.7). This
#' simulated dataset is intended for demonstrating and testing the preprocessing and modeling functions provided
#' in the CardioCurveR package.
#'
#' The dual-logistic model is defined as:
#'
#' \deqn{
#' RRi(t) = \alpha + \frac{\beta}{1 + \exp\{\lambda (t - \tau)\}} + \frac{-c \cdot \beta}{1 + \exp\{\phi (t - \tau - \delta)\}},
#' }
#'
#' where \eqn{\alpha} is the baseline RRi level, \eqn{\beta} controls the amplitude of the drop,
#' \eqn{\lambda} and \eqn{\tau} define the drop phase, and \eqn{c}, \eqn{\phi}, and \eqn{\delta} govern the recovery.
#'
#' @format A data frame with \code{n} rows and 2 variables:
#' \describe{
#'   \item{time}{A numeric vector of time points (in seconds).}
#'   \item{RRi_simulated}{A numeric vector of simulated RR interval values (in milliseconds), including added
#'   noise and simulated ectopic beats.}
#' }
#'
#' @source Simulated data generated using the dual-logistic model and random noise.
#'
#' @references Castillo-Aguilar, et al. (2025). *Enhancing Cardiovascular Monitoring: A Non-linear Model for Characterizing RR Interval Fluctuations in Exercise and Recovery*. Scientific Reports, 15(1), 8628.
#'
#' @examples
#'
#' data(sim_RRi)
#'
#' head(sim_RRi)
#'
#' # Plot tha data
#' library(ggplot2)
#'
#' ggplot(sim_RRi, aes(time, RRi_simulated)) +
#' geom_line(linewidth = 1/4, col = "purple") +
#' labs(x = "Time (s)", y = "RRi (ms)",
#'      title = "Simulated RRi Signal with Ectopic Beats") +
#' theme_minimal()
#'
"sim_RRi"
