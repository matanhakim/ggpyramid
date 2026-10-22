# Throwaway feasibility prototype from the design research (22.10.2026), not package code.
# Run from dev/spikes/. Figures are in dev/fig/.

library(ggplot2)
cat("transform_position exported:", "transform_position" %in% getNamespaceExports("ggplot2"), "\n")
print(ggplot2:::transform_position)
PositionMirrorStack <- ggproto("PositionMirrorStack", PositionStack,
  default_aes = aes(side = NULL),
  left = NULL,
  setup_params = function(self, data) {
    params <- ggproto_parent(PositionStack, self)$setup_params(data)
    params$left <- self$left %||% sort(unique(as.character(data$side)))[1]
    params
  },
  compute_layer = function(self, data, params, layout) {
    flip <- as.character(data$side) == params$left
    neg <- function(v) ifelse(flip, -v, v)
    data <- transform_position(data, trans_x = if (isTRUE(params$flipped_aes)) neg else NULL, trans_y = if (isTRUE(params$flipped_aes)) NULL else neg)
    ggproto_parent(PositionStack, self)$compute_layer(data, params, layout)
  })
position_mirror_stack <- function(left = NULL, reverse = FALSE) ggproto(NULL, PositionMirrorStack, left = left, reverse = reverse)
df <- expand.grid(age = factor(1:4), sex = c("F","M"), status = c("a","b"))
df$n <- c(10,20,30,40, 8,18,28,38, 5,5,5,5, 4,4,4,4)
p <- ggplot(df, aes(n, age, fill = status, side = sex)) + geom_col(position = position_mirror_stack())
b <- ggplot_build(p)
print(head(b$data[[1]][order(b$data[[1]]$y), c("y","xmin","xmax","side","fill")], 8))
cat("x.range:", b$layout$panel_params[[1]]$x.range, "\n")
png("out/mirror_stack.png", 600, 400); print(p + scale_x_continuous(labels = abs)); dev.off()
