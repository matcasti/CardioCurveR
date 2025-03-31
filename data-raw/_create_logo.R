# Create logo

# install.packages("hexSticker")
library(hexSticker)
library(ggplot2)
library(CardioCurveR)

params <- list(alpha = 900, beta = -300, c = 0.80,
               lambda = -3, phi = -2,
               tau = 6, delta = 3)

# Simulate a time vector
t <- seq(0, 20, by = 0.05)

set.seed(1234)

# Compute the dual-logistic model values
RRi_model <- dual_logistic(t, params) +
  rnorm(n = length(t), 0, 30)

theme_set(new = theme_void() +
            theme_transparent())

p <- ggplot() +
  geom_line(aes(t, RRi_model),
            linewidth = 1/4, col = "purple") +
  geom_line(aes(t, dual_logistic(t, params)),
            linewidth = 1/2, col = "gray90") +
  geom_line(aes(t, dual_logistic(t, params) + 30),
            linewidth = 1/4, col = "gray90",
            linetype = 2) +
  geom_line(aes(t, dual_logistic(t, params) - 30),
            linewidth = 1/4, col = "gray90",
            linetype = 2)

sticker(p, package = "CardioCurveR",
        h_fill = "#003", h_color = "#006", h_size = 1,
        s_width = 1.85, s_height = 1.4, dpi = 600,
        s_x = 1, s_y = .8,
        p_x = 1.2, p_y = 1.4, p_size = 24,
        url = "matcasti.github.io/CardioCurveR/",
        u_color = "#AAAAAA", u_size = 8,
        )

use_logo(img = "CardioCurveR.png")
