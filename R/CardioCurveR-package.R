#' CardioCurveR: Nonlinear Modeling and Preprocessing of R-R Interval Dynamics
#'
#' CardioCurveR provides an automated and robust framework for analyzing R-R interval (RRi)
#' signals using advanced nonlinear modeling and preprocessing techniques. The package implements a
#' dual-logistic model to capture both the rapid drop in RRi during exercise and the subsequent recovery
#' phase, following the methodology described by Castillo-Aguilar et al. (2025):
#'
#' \deqn{
#' RRi(t) = \alpha + \frac{\beta}{1 + e^{\lambda (t-\tau)}} + \frac{-c \cdot \beta}{1 + e^{\phi (t-\tau-\delta)}}
#' }
#'
#' In this model, \eqn{\alpha} denotes the baseline RRi, \eqn{\beta} controls the amplitude of the drop,
#' \eqn{\lambda} and \eqn{\tau} modulate the drop phase, and \eqn{c}, \eqn{\phi}, and \eqn{\delta} govern the recovery
#' dynamics.
#'
#' In addition to parameter estimation, CardioCurveR offers state-of-the-art signal preprocessing tools:
#'
#' CardioCurveR cleans RRi signals by applying zero-phase Butterworth low-pass filtering to remove high-frequency
#' noise while preserving the signal phase. It further employs adaptive outlier replacement, using local regression
#' (LOESS) and robust statistics, to identify and correct ectopic beats without "chopping" dynamic signal features.
#'
#' These methods ensure that the intrinsic dynamics of RRi signals are maintained, supporting accurate cardiovascular
#' monitoring and facilitating clinical research.
#'
#' @name CardioCurveR
NULL

#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
