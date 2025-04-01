#' Print method for RRi_fit objects
#'
#' Displays a concise summary of the RRi_fit object produced by
#' \code{estimate_RRi_curve()}. The printed output includes the optimization method,
#' estimated parameters, the final objective value, and the convergence code.
#'
#' @param x An object of class "RRi_fit".
#' @param ... Additional arguments passed to print.
#'
#' @export
print.RRi_fit <- function(x, ...) {
  cat("RRi_fit Object\n")
  cat("Optimization Method:", x$method, "\n")
  cat("Estimated Parameters:\n")
  print(x$parameters)
  cat("Objective Value (Huber loss):", x$objective_value, "\n")
  cat("Convergence Code:", x$convergence, "\n")
  invisible(x)
}

#' Summary method for RRi_fit objects
#'
#' Provides a detailed summary of the fitted dual-logistic model, including
#' measures of fit such as the residual sum of squares (RSS), total sum of squares (TSS),
#' and R-squared. The summary also includes basic information about the optimization.
#'
#' @param object An object of class "RRi_fit".
#' @param ... Additional arguments (unused).
#'
#' @returns A list with the following components:
#'   \item{method}{The optimization method used.}
#'   \item{parameters}{The estimated parameters from the model.}
#'   \item{objective_value}{The final value of the objective (Huber loss) function.}
#'   \item{convergence}{An integer code indicating convergence (0 indicates success).}
#'   \item{RSS}{Residual sum of squares.}
#'   \item{TSS}{Total sum of squares of the observed RRi values.}
#'   \item{R_squared}{Coefficient of determination.}
#'   \item{n}{The number of observations used.}
#'
#' @export
summary.RRi_fit <- function(object, ...) {
  res <- object
  residuals <- res$data$RRi - res$data$fitted
  rss <- sum(residuals^2)
  tss <- sum((res$data$RRi - mean(res$data$RRi))^2)
  summary_list <- list(
    method = res$method,
    parameters = res$parameters,
    objective_value = res$objective_value,
    convergence = res$convergence,
    RSS = rss,
    TSS = tss,
    R_squared = 1 - rss/tss,
    RMSE = sqrt(mean(residuals^2)),
    MAPE = mean(abs(residuals/res$data$RRi)),
    n = nrow(res$data)
  )
  class(summary_list) <- "summary.RRi_fit"
  return(summary_list)
}

#' Print summary of RRi_fit objects
#'
#' @param x An object of class "summary.RRi_fit".
#' @param ... Additional arguments.
#'
#' @export
print.summary.RRi_fit <- function(x, ...) {
  cat("Summary of RRi_fit Object\n")
  cat("Optimization Method:", x$method, "\n")
  cat("Estimated Parameters:\n")
  print(x$parameters)
  cat("\nObjective Value (Huber loss):", x$objective_value, "\n")
  cat("Residual Sum of Squares (RSS):", x$RSS, "\n")
  cat("Total Sum of Squares (TSS):", x$TSS, "\n")
  cat("R-squared:", round(x$R_squared, 4), "\n")
  cat("Root Mean Squared Error (RMSE):", round(x$RMSE, 1), " ms \n")
  cat("Mean Absolute Percentage Error (MAPE):", round(x$MAPE*100, 1), " % \n")
  cat("Number of observations:", x$n, "\n")
  cat("Convergence Code:", x$convergence, "\n")
  invisible(x)
}

#' Plot method for RRi_fit objects
#'
#' Produces a panel of diagnostic plots for the fitted dual-logistic model.
#' The output includes a plot of the observed RRi signal with the fitted curve overlay,
#' a residuals versus time plot, and a histogram of the residuals.
#'
#' @param x An object of class "RRi_fit".
#' @param ... Additional arguments (unused).
#'
#' @import ggplot2
#' @importFrom gridExtra grid.arrange
#'
#' @export
plot.RRi_fit <- function(x, ...) {
  ## Global variables used in NSE
  assign("time", NULL); assign("RRi", NULL)
  assign("fitted", NULL); assign("residuals", NULL)

  df <- x$data
  df$residuals <- df$RRi - df$fitted

  p1 <- ggplot2::ggplot(df, ggplot2::aes(x = time)) +
    ggplot2::geom_line(ggplot2::aes(y = RRi), color = "purple", linewidth = 1/2) +
    ggplot2::geom_line(ggplot2::aes(y = fitted), color = "blue", linewidth = 1) +
    ggplot2::labs(title = "Observed RRi and Fitted Dual-Logistic Model",
                  x = "Time", y = "RR Interval (ms)") +
    ggplot2::theme_minimal()

  p2 <- ggplot2::ggplot(df, ggplot2::aes(x = time, y = residuals)) +
    ggplot2::geom_line(color = "purple", linewidth = 1/2) +
    ggplot2::geom_hline(ggplot2::aes(yintercept = 0), linetype = "dashed") +
    ggplot2::labs(title = "Residuals vs. Time",
                  x = "Time", y = "Residuals (ms)") +
    ggplot2::theme_minimal()

  p3 <- ggplot2::ggplot(df, ggplot2::aes(x = residuals)) +
    ggplot2::geom_histogram(fill = "gray", color = "gray25", bins = 30) +
    ggplot2::labs(title = "Histogram of Residuals",
                  x = "Residuals (ms)", y = "Count") +
    ggplot2::theme_minimal()

  gridExtra::grid.arrange(p1, p2, p3, ncol = 1)

  invisible(x)
}
