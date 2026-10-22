# Throwaway feasibility prototype from the design research (22.10.2026), not package code.
# Run from dev/spikes/. Figures are in dev/fig/.

library(ggplot2)
eval(parse(text = readLines("coord_pyramid.R")[1:46]))   # data, position, CoordPyramid with gap + centre labels
PositionPyramid$default_aes <- aes(side = NULL)
CoordPyramid$setup_panel_params <- function(self, scale_x, scale_y, params = list()) {
  m <- max(abs(scale_x$get_limits()))
  sym <- ggproto(NULL, self, limits = list(x = c(-m, m), y = self$limits$y))
  pp <- ggproto_parent(CoordCartesian, sym)$setup_panel_params(scale_x, scale_y, params)
  vx <- pp$x
  pp$x <- ggproto(NULL, vx, get_labels = function(self, breaks = self$get_breaks()) vx$scale$get_labels(abs(breaks)))
  pp
}
d <- subset(pop, year == 2020); d$p <- d$n / sum(d$n)
p <- ggplot(d, aes(p, age, fill = sex, side = sex)) +
  geom_col(position = position_pyramid(), width = 0.9) +
  scale_x_continuous(labels = scales::label_percent(accuracy = 1)) +   # an ordinary scale, no abs()
  coord_pyramid(gap = 0.1) + labs(x = "Share of total population", y = NULL, fill = NULL) +
  theme_minimal() + theme(panel.grid.major.y = element_blank(), legend.position = "top")
ggsave("spike5_coord_abs.png", p, width = 7, height = 5, dpi = 110, device = ragg::agg_png)
