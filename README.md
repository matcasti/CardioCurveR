CardioCurveR: Nonlinear Modeling of R-R Interval Dynamics
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/CardioCurveR)](https://CRAN.R-project.org/package=CardioCurveR)
[![R-CMD-check](https://github.com/matcasti/CardioCurveR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/matcasti/CardioCurveR/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/matcasti/CardioCurveR/graph/badge.svg)](https://app.codecov.io/gh/matcasti/CardioCurveR)

CardioCurveR provides an automated and robust framework for modeling RR
interval (RRi) signals. The package is built around a dual-logistic
model, as described by Castillo-Aguilar et al. (2025), which captures
both the rapid drop in RRi during exercise and the subsequent recovery
phase. In our formulation, the model is defined by the following
equation:

$$
RRi(t) = \alpha + \frac{\beta}{1 + e^{\lambda\ (t-\tau)}} - 
         \frac{c\,\beta}{1 + e^{\phi\ (t-\tau-\delta)}},
$$

where $\alpha$ represents the baseline RRi level, $\beta$ controls the
amplitude of the drop, $\lambda$ modulates the steepness of the drop
phase, $\tau$ is the time center of the drop, $c$ scales the recovery
amplitude relative to $\beta$, $\phi$ controls the steepness of the
recovery phase, and $\delta$ shifts the recovery phase in time relative
to the drop.

CardioCurveR also incorporates advanced signal filtering techniques
using a zero-phase Butterworth filter to preprocess the RRi data and
remove edge artifacts. This ensures that the dynamic fluctuations are
preserved for subsequent non-linear modeling.

## Installation

To install the development version of CardioCurveR, run the following
commands in R. Make sure that you have the **devtools** package
installed:

``` r
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

devtools::install_github("matcasti/CardioCurveR")
```

## Core Functions

The package provides several key functions:

### Dual-Logistic Model: `dual_logistic()`

This function implements the dual-logistic model from Castillo-Aguilar
et al. (2025):

$$
RRi(t) = \alpha + \frac{\beta}{1 + e^{\lambda (t-\tau)}} - \frac{c\,\beta}{1 + e^{\phi (t-\tau-\delta)}}
$$

It takes a vector of time points and a named vector (or list) of
parameters, returning the modeled RRi values.

### Parameter Estimation: `estimate_RRi_curve()`

This function optimizes the dual-logistic model parameters using a
robust Huber loss function. The optimization is performed via the
`optim()` function with box constraints (default method `"L-BFGS-B"`).
It is designed to yield reliable parameter estimates even in the
presence of noisy data.

### Signal Filtering: `filter_signal()`

This function applies a Butterworth low-pass filter using zero-phase
filtering (with `filtfilt()`) to clean the RRi signal. To mitigate edge
effects from filtering, it trims a specified number of samples from the
beginning and end of the filtered signal.

### Adaptive Outlier Cleaning: `clean_outlier()`

The `clean_outlier()` function removes ectopic or noisy beats from an
RRi signal. It fits a LOESS model to capture local trends, calculates
residuals, and flags outliers based on a robust threshold (multiples of
the median absolute deviation). Outliers are then replaced by one of
three methods: drawing from a Gaussian or uniform distribution, or
simply replacing with the LOESS-predicted values.

## Example Workflow

Below is an extended example that demonstrates the full workflow of
simulating, filtering, visualizing, and fitting an RRi signal model.

``` r
library(CardioCurveR)

# Simulate a time vector and a theoretical RRi signal using the dual-logistic model.
set.seed(123)
time_vec <- seq(0, 20, by = 0.05)

# Define the true model parameters from Castillo-Aguilar et al. (2025)
true_params <- list(alpha = 800, beta = -375, c = 0.85, 
                    lambda = -3, phi = -2, 
                    tau = 6, delta = 3)

# Compute the theoretical RRi curve using dual_logistic()
RRi_theoretical <- dual_logistic(time_vec, true_params)

# Visualize the theoretical model
plot(time_vec, RRi_theoretical, type = "l", col = "blue", lwd = 2,
     main = "Theoretical Dual-Logistic RRi Model",
     xlab = "Time (s)", ylab = "RR Interval (ms)", axes = FALSE)
axis(1);axis(2)
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

``` r

# Simulate a noisy RRi signal by adding Gaussian noise
RRi_simulated <- RRi_theoretical + rnorm(length(time_vec), sd = 35)

# Apply the Butterworth low-pass filter to the noisy RRi signal
RRi_filtered <- filter_signal(RRi_simulated)

# Plot the simulated signal and its filtered version
plot(time_vec, RRi_simulated, type = "l", col = "red", lwd = 1,
     main = "Simulated (Red) vs. Filtered (Blue) RRi Signal",
     xlab = "Time (s)", ylab = "RR Interval (ms)", axes = FALSE)
axis(1);axis(2)
lines(time_vec, RRi_filtered, col = "blue", lwd = 2)
```

<img src="man/figures/README-unnamed-chunk-2-2.png" width="100%" />

``` r

# Estimate the dual-logistic model parameters from the noisy RRi signal
fit_summary <- estimate_RRi_curve(time = time_vec, RRi = RRi_simulated)

## Lets print the results of the estimation of our model parameters
print(fit_summary)
#> RRi_fit Object
#> Optimization Method: L-BFGS-B 
#> Estimated Parameters:
#>        alpha         beta            c       lambda          phi          tau 
#>  803.1184916 -397.5127654    0.8542077   -2.7167717   -1.7694993    5.9969601 
#>        delta 
#>    2.9302810 
#> Objective Value (Huber loss): 217118.3 
#> Convergence Code: 0

## Now lets see a summary with model fit statistics
summary(fit_summary)
#> Summary of RRi_fit Object
#> Optimization Method: L-BFGS-B 
#> Estimated Parameters:
#>        alpha         beta            c       lambda          phi          tau 
#>  803.1184916 -397.5127654    0.8542077   -2.7167717   -1.7694993    5.9969601 
#>        delta 
#>    2.9302810 
#> 
#> Objective Value (Huber loss): 217118.3 
#> Residual Sum of Squares (RSS): 455980.6 
#> Total Sum of Squares (TSS): 4702302 
#> R-squared: 0.903 
#> Root Mean Squared Error (RMSE): 33.7  ms 
#> Mean Absolute Percentage Error (MAPE): 3.9  % 
#> Number of observations: 401 
#> Convergence Code: 0

## Finally, lets see a plot with diagnostics statistics
plot(fit_summary)
```

<img src="man/figures/README-unnamed-chunk-2-3.png" width="100%" />

The above example demonstrates multiple steps. First, a theoretical RRi
signal is computed from the dual-logistic model. Next, a noisy version
of the signal is simulated and then cleaned using a Butterworth low-pass
filter. The noisy signal is used to estimate the dual-logistic model
parameters through a robust optimization procedure. Visualizations are
provided for the theoretical curve, the noisy versus filtered signals,
the fitted model overlay, and the residuals of the fit, offering
comprehensive insight into each stage of the process.

Enjoy exploring your RR interval dynamics and modeling them robustly
with CardioCurveR!
