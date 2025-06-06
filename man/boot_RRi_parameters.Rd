% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/boot_RRi_parameters.R
\name{boot_RRi_parameters}
\alias{boot_RRi_parameters}
\title{Bootstrap RRi Model Parameter Estimates}
\usage{
boot_RRi_parameters(
  fit = NULL,
  n_samples = nrow(fit$data),
  prop_of_samples = NULL,
  nboot = 100
)
}
\arguments{
\item{fit}{An object of class \code{"RRi_fit"} produced by \code{estimate_RRi_curve()}. This fitted
object must contain a \code{data} component with the original time and RRi values as well as the fitted
values.}

\item{n_samples}{A numeric value specifying the number of data points to sample for each bootstrap replicate.
The default is \code{nrow(fit$data)} (all data points). Must not exceed the total number of rows in the data.}

\item{prop_of_samples}{A numeric value (between 0 and 1) specifying the proportion of data to use in each
bootstrap sample. If specified, it overrides \code{n_samples} by computing the number as \code{floor(nrow(fit$data) * prop_of_samples)}.}

\item{nboot}{A numeric value indicating the number of bootstrap replicates to perform. The default is \code{100}.}
}
\value{
An object of class \code{"boot_RRi_fit"}, which is a data.table with one row per bootstrap replicate.
Each row contains the estimated parameters from that bootstrap sample.
}
\description{
This function performs a bootstrap procedure on a fitted RRi model (as produced by
\code{estimate_RRi_curve()}) to assess the uncertainty of the parameter estimates. It
resamples the original data (using either a specified number of samples or a proportion of
the available data) and re-estimates the dual-logistic model parameters for each bootstrap
sample. The approach leverages the speed and efficiency of the \pkg{data.table} package.
}
\details{
The bootstrap procedure returns a data.table with a row for each bootstrap replicate,
containing the estimated parameters. This enables users to construct confidence intervals
and assess the variability of the fitted model parameters.

The function first checks that the input \code{fit} object is not NULL and that \code{n_samples} and \code{nboot}
are numeric and valid. If \code{prop_of_samples} is provided, it is used to compute the number of samples
per replicate. The data from the \code{fit} object is converted to a data.table for efficient subsetting.

Bootstrap indices are generated by sampling with replacement, and for each bootstrap replicate, the function
re-estimates the model parameters using \code{estimate_RRi_curve()}. The output is a data.table where each row
corresponds to a bootstrap replicate.
}
\examples{
\donttest{
library(CardioCurveR)
library(data.table)

# Simulate an example RRi signal:
set.seed(123)
t <- seq(0, 20, by = 0.01)
true_params <- c(alpha = 800, beta = -350, c = 0.80,
                 lambda = -3, phi = -2, tau = 6, delta = 3)
RRi_true <- dual_logistic(t, true_params)
RRi_sim <- RRi_true + rnorm(n = length(t), sd = 30)

# Estimate the model parameters:
fit <- estimate_RRi_curve(time = t, RRi = RRi_sim)

# Bootstrap the parameter estimates using 50\% of the data per replicate and 100 replicates
boot_fit <- boot_RRi_parameters(fit = fit, prop_of_samples = 0.5, nboot = 100)

# View the bootstrap estimates
print(boot_fit)
}

}
