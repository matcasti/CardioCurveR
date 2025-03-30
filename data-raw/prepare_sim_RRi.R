# Simulate a time vector and a theoretical RRi signal using the dual-logistic model.
time <- seq(0, 20, by = 0.01)

# Define the true model parameters
true_params <- list(alpha = 800, beta = -400, c = 0.75,
                    lambda = -3, phi = -2,
                    tau = 6, delta = 3)

# Compute the theoretical RRi curve using dual_logistic()
RRi_theoretical <- dual_logistic(time, true_params)

set.seed(123) # Seed for reproducibility

# Simulate a noisy RRi signal by adding Gaussian noise
RRi_simulated <- RRi_theoretical + rnorm(length(time), sd = 50)

## Total number of RRi records or points
n_samples <- length(RRi_simulated)

## We'll select random points (5% of whole signal)
ectopics <- sample.int(n = n_samples, size = floor(n_samples * 0.05))

## We'll add a doubled or half value to selected ectopic data points
RRi_simulated[ectopics] <- RRi_simulated[ectopics] * c(0.3, 1.7)

## We'll save this as a data.frame
sim_RRi <- data.frame(time, RRi_simulated)

usethis::use_data(sim_RRi, overwrite = TRUE)
