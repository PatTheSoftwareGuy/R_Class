# examples/hello_plot.R
# Quick smoke test for the dev container:
#   1. Confirms console output works.
#   2. Confirms ggplot2 graphics open in the VS Code Plot Viewer (via httpgd).
#
# How to run:
#   - Open this file, place cursor on a line, press Ctrl+Enter to send to the R terminal.
#   - Or run the whole file: from the R terminal, source("examples/hello_plot.R")

library(tidyverse)

# --- Console output ---------------------------------------------------------
cat("R version:", R.version.string, "\n")
cat("Loaded packages:", paste(.packages(), collapse = ", "), "\n\n")

mtcars |>
  group_by(cyl) |>
  summarise(
    n        = n(),
    avg_mpg  = mean(mpg),
    avg_hp   = mean(hp),
    .groups  = "drop"
  ) |>
  print()

# --- Plotted output ---------------------------------------------------------
p <- ggplot(mtcars, aes(x = wt, y = mpg, color = factor(cyl))) +
  geom_point(size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title    = "Fuel economy vs. weight",
    subtitle = "mtcars sample dataset",
    x        = "Weight (1000 lbs)",
    y        = "Miles per gallon",
    color    = "Cylinders"
  ) +
  theme_minimal(base_size = 13)

print(p)   # opens in the VS Code Plot Viewer
