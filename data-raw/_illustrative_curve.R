.t <- seq(0, 20, by = 0.01)

# Define the true model parameters from Castillo-Aguilar et al. (2025)
.tp <- list(alpha = 800, beta = -300, c = 0.85,
            lambda = -2, phi = -1,
            tau = 6, delta = 4)

# Compute the theoretical RRi curve using dual_logistic()
.rri <- CardioCurveR::dual_logistic(.t, .tp)

library(ggplot2)

p <- ggplot() +
  ## Intervalo de inicio de ejercicio
  annotate("segment", y = .rri[.t == .tp$tau], yend = -Inf, x = 6,
           col = "gray", linetype = 2, linewidth = 1/2) +
  ## Intervalo de termino de ejercicio
  annotate("segment", y = .rri[.t == (.tp$tau + .tp$delta)], yend = -Inf,
           x = .tp$tau + .tp$delta,
           col = "gray", linetype = 2, linewidth = 1/2) +
  ## Intervalo de ejercicio
  annotate("segment", y = 490, x = .tp$tau + 0.2, xend = (.tp$tau + .tp$delta - 0.2),
           col = "gray", linewidth = 1/2,
           arrow = arrow(ends = "both", length = unit(0.15, "cm"))) +
  ## Flecha de caida
  annotate("segment", y = 790, x = 3.5, yend = .rri[.t == (7.5)],
           col = "gray", arrow = arrow(length = unit(0.15, "cm"))) +
  ## Flecha de recuperación
  annotate("segment", y = .rri[.t == 7.5], x = 14, yend = 735,
           col = "gray", arrow = arrow(length = unit(0.15, "cm"))) +
  ## Rate de lambda
  annotate("segment", xend = 4.4, x = 5.5, y = 790,
           col = "gray85") +
  annotate("segment", yend = .rri[.t == 5.3], x = 5.5, y = 790,
           col = "gray50", arrow = arrow(length = unit(0.15, "cm"))) +
  ## Rate de phi
  annotate("segment", xend = 12.6, x = 11.3, y = 738,
           col = "gray85") +
  annotate("segment", y = .rri[.t == 11.3], x = 11.3, yend = 738,
           col = "gray50", arrow = arrow(length = unit(0.15, "cm"))) +
  ## Curva RRi
  geom_line(aes(.t, .rri), arrow = arrow(length = unit(0.15, "cm"))) +
  annotate("text", x = 2.5, y = (.tp$alpha + 20),
           size = 6, label = "alpha", parse = TRUE) +
  annotate("text", x = 3-0.25, y = 650,
           size = 6, label = "beta", parse = TRUE, col = "#900") +
  annotate("text", x = 15+0.5, y = 650,
           size = 6, label = "-c%.%beta", parse = TRUE, col = "#059") +
  annotate("text", x = .tp$tau + 0.2, y = 770,
           size = 6, label = "lambda", parse = TRUE, col = "#550") +
  annotate("text", x = 10.6, y = 720,
           size = 6, label = "phi", parse = TRUE, col = "#055") +
  annotate("text", x = 6-0.7, y = 490,
           size = 6, label = "tau", parse = TRUE, col = "#595") +
  annotate("text", x = 8, y = 505,
           size = 6, label = "delta", parse = TRUE, col = "#955") +
  labs(x = "Time (min)", y = "RRi (ms)",
       title = "Model Parameters",
       subtitle = "And Their Role In Overall RRi Dynamics",
       caption = "Model according to Castillo-Aguilar et al. (2025)") +
  theme_classic(12) +
  theme(plot.caption = element_text(vjust = 1),
        axis.line = element_line(colour = "gray"),
        axis.ticks = element_line(colour = "gray"),
        plot.background = element_rect(fill = "#fff", colour = "#fff"))

ggsave(filename = "man/figures/illustrative_curve.svg",
       plot = p, device = "svg",
       width = 6, height = 5)
