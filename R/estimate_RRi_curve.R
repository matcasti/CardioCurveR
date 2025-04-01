#' Estimate RRi Curve Using a Dual-Logistic Model for RR Interval Dynamics (Castillo-Aguilar et al.)
#'
#' This function estimates parameters for a dual-logistic model applied to RR interval (RRi)
#' signals. The model is designed to capture both the rapid drop and subsequent recovery of RRi values
#' during exercise and recovery periods, as described in Castillo-Aguilar et al. (2025). A robust Huber loss
#' function (with a default \eqn{\delta} of 50 ms) is used to downweight the influence of outliers, ensuring
#' that the optimization process is robust even in the presence of noisy or ectopic beats.
#'
#' The dual-logistic model, as described in Castillo-Aguilar et al. (2025), is defined as:
#'
#' \deqn{
#' RRi(t) = \alpha + \frac{\beta}{1 + e^{\lambda (t - \tau)}} + \frac{-c \cdot \beta}{1 + e^{\phi (t - \tau - \delta)}}
#' }
#'
#' where:
#'
#' \describe{
#'   \item{\eqn{\alpha}}{is the baseline RRi level.}
#'   \item{\eqn{\beta}}{controls the amplitude of the drop.}
#'   \item{\eqn{\lambda}}{modulates the steepness of the drop phase.}
#'   \item{\eqn{\tau}}{represents the time at which the drop is centered.}
#'   \item{\eqn{c}}{scales the amplitude of the recovery relative to \eqn{\beta}.}
#'   \item{\eqn{\phi}}{controls the steepness of the recovery phase.}
#'   \item{\eqn{\delta}}{shifts the recovery phase in time relative to \eqn{\tau}.}
#' }
#'
#' @param time A numeric vector of time points.
#' @param RRi A numeric vector of RR interval values.
#' @param start_params A named numeric vector or list of initial parameter estimates. Default is
#'   \code{c(alpha = 800, beta = -380, c = 0.85, lambda = -3, phi = -2, tau = 6, delta = 3)}.
#' @param lower_lim A named numeric vector specifying the lower bound for each parameter.
#'   Default is \code{c(alpha = 300, beta = -750, c = 0.1, lambda = -10, phi = -10, tau = min(time), delta = min(time))}.
#' @param upper_lim A named numeric vector specifying the upper bound for each parameter.
#'   Default is \code{c(alpha = 2000, beta = -10, c = 2.0, lambda = -0.1, phi = -0.1, tau = max(time), delta = max(time))}.
#' @param method A character string specifying the optimization method to use with \code{optim()}. The default is
#'   \code{"L-BFGS-B"}, which allows for parameter constraints.
#'
#' @returns A list containing:
#'   \describe{
#'     \item{data}{A data frame with columns for time, the original RRi values, and the fitted values obtained from the dual-logistic model.}
#'     \item{method}{The optimization method used.}
#'     \item{parameters}{The estimated parameters from the model.}
#'     \item{objective_value}{The final value of the objective (Huber loss) function.}
#'     \item{convergence}{An integer code indicating convergence (0 indicates success).}
#'   }
#'
#' @details
#' The function first removes any missing cases from the input data and then defines the dual-logistic model,
#' which represents the dynamic behavior of RR intervals during exercise and recovery. The objective function
#' is based on the Huber loss (with a default threshold of 50 ms), which provides robustness against outliers by
#' penalizing large deviations less harshly than the standard squared error. This objective function quantifies
#' the discrepancy between the observed RRi values and those predicted by the model.
#'
#' Parameter optimization is performed using \code{optim()} with box constraints when the \code{"L-BFGS-B"} method is
#' used. These constraints ensure that the parameters remain within physiologically plausible ranges. For other optimization
#' methods, the bounds are ignored by setting the lower limit to \code{-Inf} and the upper limit to \code{Inf}.
#'
#' It is important to note that the default starting parameters and bounds provided in the function are general
#' guidelines and may not be optimal for every dataset or experimental scenario. Users are encouraged to customize the
#' starting parameters (\code{start_params}) and, if necessary, the lower and upper bounds (\code{lower_lim} and \code{upper_lim})
#' based on the specific characteristics of their RRi signal. This customization is crucial for achieving robust convergence
#' and accurate parameter estimates in diverse applications.
#'
#' @references
#' Castillo-Aguilar, et al. (2025). *Enhancing Cardiovascular Monitoring: A Non-linear Model for Characterizing RR Interval Fluctuations in Exercise and Recovery*. **Scientific Reports**, 15(1), 8628.
#'
#' @examples
#' true_params <- c(alpha = 800, beta = -300, c = 0.80,
#'                  lambda = -3, phi = -1, tau = 6, delta = 3)
#'
#' time_vec <- seq(0, 20, by = 0.01)
#'
#' set.seed(1234)
#'
#' # Simulate an example RRi signal:
#' RRi_simulated <- dual_logistic(time_vec, true_params) +
#'                   rnorm(length(time_vec), sd = 30)
#'
#' # Estimate the model parameters:
#' fit <- estimate_RRi_curve(time = time_vec, RRi = RRi_simulated)
#'
#' # Print method
#' print(fit)
#'
#' # Summary method
#' summary(fit)
#'
#' # Plot method
#' plot(fit)
#'
#' @importFrom stats complete.cases optim
#' @export
estimate_RRi_curve <- function(time, RRi,
                               start_params = c(alpha = 800, beta = -380, c = 0.85,
                                                lambda = -3, phi = -2,
                                                tau = 6, delta = 3),
                               lower_lim = c(alpha = 300, beta = -750, c = 0.1,
                                              lambda = -10, phi = -10,
                                              tau = min(time), delta = min(time)),
                               upper_lim = c(alpha = 2000, beta = -10, c = 2.0,
                                              lambda = -0.1, phi = -0.1,
                                              tau = max(time), delta = max(time)),
                               method = "L-BFGS-B") {
  # Input checks:
  if (!is.numeric(time) || !is.numeric(RRi))
    stop("Both 'time' and 'RRi' must be numeric vectors.")
  if (length(time) != length(RRi))
    stop("'time' and 'RRi' must be the same length.")
  ind <- stats::complete.cases(time, RRi)
  time <- time[ind]
  RRi <- RRi[ind]

  # Define the objective function: Huber loss function with huber_delta = 50 ms:
  objective <- function(params, huber_delta = 50) {
    predicted <- dual_logistic(time, params)
    errors <- RRi - predicted
    loss <- ifelse(abs(errors) <= huber_delta,
                   0.5 * errors^2,
                   huber_delta * (abs(errors) - 0.5 * huber_delta))
    sum(loss)
  }

  # Ignore constraints in cases other than "L-BFGS-B" method
  if (method != "L-BFGS-B") {
    lower_lim <- -Inf;
    upper_lim <- Inf;
  }

  # Use optim() with box constraints:
  fit <- stats::optim(par = start_params, fn = objective,
               lower = lower_lim, upper = upper_lim,
               method = method, control = list(maxit = 10000))

  # Return the fit details:
  output <- list(
    data = data.frame(time, RRi,
                      fitted = dual_logistic(time, fit$par)),
    method = method,
    parameters = fit$par,
    objective_value = fit$value,
    convergence = fit$convergence
  )

  class(output) <- "RRi_fit"
  return(output)
}
