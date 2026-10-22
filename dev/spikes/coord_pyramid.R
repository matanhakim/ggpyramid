# Throwaway feasibility prototype from the design research (22.10.2026), not package code.
# Run from dev/spikes/. Figures are in dev/fig/.

library(ggplot2)
source_lines <- readLines("position_pyramid.R"); eval(parse(text = source_lines[1:30]))  # data + PositionPyramid
PositionPyramid$required_aes <- "side"

# Candidate: a Coord that opens a central gap (npc) and draws the vertical-axis labels inside it.
CoordPyramid <- ggproto("CoordPyramid", CoordCartesian,
  gap = 0.12, axis = "center",
  transform = function(self, data, panel_params) {
    data <- ggproto_parent(CoordCartesian, self)$transform(data, panel_params)
    z <- panel_params$x$rescale(0); g <- self$gap
    xs <- intersect(c("x", "xmin", "xmax", "xend"), names(data))
    # side of each row from its centre, so a bar edge sitting exactly on 0 follows its bar
    right <- rowMeans(as.matrix(data[xs])) > z
    f <- function(x) ifelse(right, (z + g / 2) + (x - z) * (1 - z - g / 2) / (1 - z), x * (z - g / 2) / z)
    for (v in xs) data[[v]] <- f(data[[v]])
    data
  },
  render_axis_v = function(self, panel_params, theme) {
    axes <- ggproto_parent(CoordCartesian, self)$render_axis_v(panel_params, theme)
    if (self$axis == "center") axes$left <- zeroGrob()
    axes
  },
  render_fg = function(self, panel_params, theme) {
    border <- ggproto_parent(CoordCartesian, self)$render_fg(panel_params, theme)
    if (self$axis != "center") return(border)
    y <- panel_params$y
    pos <- y$rescale(y$get_breaks())
    lab <- y$get_labels()
    el <- calc_element("axis.text.y", theme)
    txt <- grid::textGrob(lab, x = grid::unit(panel_params$x$rescale(0), "npc"), y = grid::unit(pos, "npc"),
                          gp = grid::gpar(col = el$colour, fontsize = el$size, fontfamily = el$family))
    grid::grobTree(border, txt)
  }
)
coord_pyramid <- function(gap = 0.12, axis = "center") ggproto(NULL, CoordPyramid, gap = gap, axis = axis,
  limits = list(x = NULL, y = NULL), expand = TRUE, default = FALSE, clip = "on", reverse = "none")

p <- ggplot(subset(pop, year == 2020), aes(n, age, fill = sex, side = sex)) +
  geom_col(position = position_pyramid(), width = 0.9) +
  geom_text(aes(label = n, hjust = -0.15), position = position_pyramid(), size = 3) +
  scale_x_continuous(labels = \(x) scales::comma(abs(x)), limits = \(l) c(-1, 1) * max(abs(l)),
                     expand = expansion(mult = .12)) +
  coord_pyramid() + labs(y = NULL) + theme_minimal() + theme(panel.grid.major.y = element_blank())
ggsave("spike2_coord_center.png", p, width = 7, height = 5, dpi = 110, device = ragg::agg_png)
p2 <- p + facet_wrap(~"Region A") + theme(legend.position = "top")
ggsave("spike2_coord_facet.png", p2, width = 7, height = 5, dpi = 110, device = ragg::agg_png)
