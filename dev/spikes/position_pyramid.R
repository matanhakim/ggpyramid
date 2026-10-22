# Throwaway feasibility prototype from the design research (22.10.2026), not package code.
# Run from dev/spikes/. Figures are in dev/fig/.

library(ggplot2)
set.seed(1)
ages <- factor(c(paste0(seq(0, 80, 5), "-", seq(4, 84, 5)), "85+"), levels = c(paste0(seq(0, 80, 5), "-", seq(4, 84, 5)), "85+"))
pop <- expand.grid(age = ages, sex = c("Male", "Female"), year = c(2000, 2020))
pop$n <- round(1000 * exp(-as.integer(pop$age) / 9) * runif(nrow(pop), .9, 1.1) * ifelse(pop$year == 2020, 1.2, 1))

# Candidate: a Position that mirrors one side. Runs after stat, before position-scale retraining.
PositionPyramid <- ggproto("PositionPyramid", Position,
  side = NULL,
  setup_params = function(self, data) {
    levs <- if (is.factor(data$side)) levels(data$side) else sort(unique(data$side))
    list(left = self$side %||% levs[1])
  },
  compute_layer = function(self, data, params, layout) {
    left <- data$side == params$left
    for (v in intersect(c("x", "xmin", "xmax", "xend", "xintercept"), names(data))) data[[v]][left] <- -data[[v]][left]
    # swap xmin/xmax so they stay ordered
    if (all(c("xmin", "xmax") %in% names(data))) {
      lo <- pmin(data$xmin, data$xmax); hi <- pmax(data$xmin, data$xmax); data$xmin <- lo; data$xmax <- hi
    }
    if ("hjust" %in% names(data)) data$hjust[left] <- 1 - data$hjust[left]
    data
  }
)
position_pyramid <- function(side = NULL) ggproto(NULL, PositionPyramid, side = side)

d20 <- subset(pop, year == 2020)
d00 <- subset(pop, year == 2000)
p <- ggplot(d20, aes(n, age, fill = sex, side = sex)) +
  geom_col(position = position_pyramid(), width = 1, colour = "white") +
  geom_step(data = d00, aes(n, as.integer(age) - 0.5, group = sex, side = sex), inherit.aes = FALSE,
            position = position_pyramid(), direction = "vh") +
  geom_text(aes(label = n, hjust = -0.1), position = position_pyramid(), size = 3) +
  scale_x_continuous(labels = \(x) scales::comma(abs(x)), limits = \(l) c(-1, 1) * max(abs(l)),
                     expand = expansion(mult = .1)) +
  theme_minimal()
b <- ggplot_build(p)
print(b$layout$panel_params[[1]]$x$continuous_range)
print(head(b$data[[1]][, c("x", "xmin", "xmax", "y", "fill")], 3))
ggsave("spike1_position.png", p, width = 7, height = 5, dpi = 110, device = ragg::agg_png)
