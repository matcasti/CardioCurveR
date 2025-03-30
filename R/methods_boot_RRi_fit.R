#' Print method for boot_RRi_fit objects
#'
#' Displays a concise summary of the bootstrap RRi model parameter estimates.
#' The printed output shows the number of bootstrap replicates and a preview
#' of the parameter estimates from the first few replicates.
#'
#' @param x An object of class "boot_RRi_fit".
#' @param ... Additional arguments passed to \code{print}.
#'
#' @importFrom utils head
#' @export
print.boot_RRi_fit <- function(x, ...) {
  cat("Bootstrap RRi Parameter Estimates\n")
  cat("Number of bootstrap replicates:", nrow(x), "\n")
  cat("Preview of estimated parameters (first 6 replicates):\n")
  print.data.frame(utils::head(x, 6))
  invisible(x)
}

#' Summary method for boot_RRi_fit objects
#'
#' Computes summary statistics for each estimated parameter across the bootstrap replicates.
#' For each parameter, the summary includes the mean, standard deviation, and the 2.5\%, 50\%, and 97.5\% quantiles.
#'
#' @param object An object of class "boot_RRi_fit".
#' @param robust Logical. If TRUE (default) then uses median and MAD as centrality and dispersion
#' measures. If FALSE then uses mean and standard deviation instead.
#' @param ... Additional arguments (unused).
#'
#' @return A list with summary statistics for each parameter.
#'
#' @importFrom data.table as.data.table transpose `:=` .SD
#' @importFrom stats median IQR quantile sd
#' @export
summary.boot_RRi_fit <- function(object, robust = TRUE, ...) {
  dt <- data.table::as.data.table(object)
  # Exclude the replicate identifier "nboot" from the parameters
  summary_list <- dt[, lapply(.SD, function(x) {
    if (isTRUE(robust)) {
    estimate <- round(stats::median(x), 2)
    scale <- round(stats::mad(x), 2)
    } else {
    estimate <- round(mean(x), 2)
    scale <- round(stats::sd(x), 2)
    }
    Q2.5 <-  round(stats::quantile(x, probs = 0.025), 2)
    Q97.5 <- round(stats::quantile(x, probs = 0.975), 2)
    c(
      estimate,
      scale,
      paste0("[", Q2.5, ", ", Q97.5, "]")
    )
  }), .SDcols = -c("nboot")]

  summary_list[, `:=`(
    Parameter = c("Estimate", "SE", "95% CI")
  )]

  summary_list <- data.table::transpose(summary_list,
                        keep.names = "Parameter",
                        make.names = "Parameter")

  class(summary_list) <- c("summary.boot_RRi_fit", class(summary_list))
  attr(summary_list, which = "robust") <- robust
  return(summary_list)
}

#' Print summary of boot_RRi_fit objects
#'
#' Prints a human-readable summary of the bootstrap RRi model parameter estimates,
#' including the mean, standard deviation, and selected quantiles for each parameter.
#'
#' @param x An object of class "summary.boot_RRi_fit".
#' @param ... Additional arguments.
#'
#' @export
print.summary.boot_RRi_fit <- function(x, ...) {
  cat("Summary of Bootstrap RRi Parameter Estimates\n\n")
  print.data.frame(x)
  cat("\nNote: Estimates and SE correspond to ")
  if(isTRUE(attr(x, "robust"))) {
  cat("median and median absolute deviation\n")
  } else {
  cat("mean and standard deviation\n")
  }
  cat("95% confidence intervals are quantile-based\n")
  invisible(x)
}

#' Plot method for boot_RRi_fit objects
#'
#' Generates a panel of density plots to visualize the bootstrap distributions of the RRi model parameters.
#' The method converts the bootstrap results to long format and creates one density plot per parameter.
#'
#' @param x An object of class "boot_RRi_fit".
#' @param ... Additional arguments (unused).
#'
#' @import ggplot2
#' @importFrom data.table melt
#'
#' @export
plot.boot_RRi_fit <- function(x, ...) {
  # Global variables
  assign("estimate", NULL); assign("density", NULL)

  dt <- as.data.table(x)
  # Melt the data.table to long format (excluding the replicate index)
  dt_long <- data.table::melt(dt, id.vars = "nboot",
                            variable.name = "parameter",
                            value.name = "estimate")

  p <- ggplot2::ggplot(dt_long, ggplot2::aes(x = estimate)) +
    ggplot2::geom_density(fill = "purple", alpha = 0.5) +
    ggplot2::geom_histogram(ggplot2::aes(y = ggplot2::after_stat(density)/2), fill = "purple4", alpha = 0.7) +
    ggplot2::facet_wrap(~ parameter, scales = "free", ncol = 2,
                        labeller = ggplot2::label_parsed) +
    ggplot2::labs(title = "Bootstrap Distribution of RRi Model Parameters",
                  x = "Parameter Estimate", y = "Density") +
    ggplot2::theme_minimal()

  print(p)
  invisible(p)
}
