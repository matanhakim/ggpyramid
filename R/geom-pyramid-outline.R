#' A stepped outline of a population pyramid
#'
#' `geom_pyramid_outline()` traces the outer edge of a pyramid as a stepped
#' line, without filling the bars. Drawn over [geom_pyramid()], it compares two
#' populations, such as two census years or a region and the whole country.
#' It aggregates the data in the same way as [geom_pyramid()], so it accepts
#' individual records and aggregated data alike.
#'
#' Each side gets one line, and so does each subgroup that `fill`, `colour`,
#' `linetype`, `linewidth` or `alpha` sets apart. The line starts at zero below
#' the youngest age group, follows the value of each group across its whole
#' band, and returns to zero above the oldest. It drops to zero across an age
#' group with no data.
#'
#' @inheritParams geom_pyramid
#' @inheritParams ggplot2::geom_path
#' @param position A position adjustment. The default mirrors the left side
#'   without stacking, as `position_pyramid(stack = FALSE)`, so that one line
#'   per side follows the total. Use `position_pyramid(left = ...)` to match
#'   the bars when they set `left`.
#' @param ... Other arguments passed on to [ggplot2::layer()], such as fixed
#'   aesthetics like `colour = "black"` or `linewidth = 0.8`.
#'
#' @section Aesthetics:
#' The age and value axes are as in [geom_pyramid()], and the side of each line
#' comes from `side`, `fill` or `colour`, as described in
#' [position_pyramid()]. The line is styled by `colour`, `linewidth`,
#' `linetype` and `alpha`.
#'
#' @returns A ggplot2 layer.
#' @seealso [geom_pyramid()] for the bars.
#' @export
#' @examples
#' library(ggplot2)
#'
#' france <- subset(europe_pop, country == "France")
#'
#' # 2024 as bars, 2004 as an outline
#' ggplot(france, aes(x = population, y = age, fill = sex)) +
#'   geom_pyramid(data = subset(france, year == 2024)) +
#'   geom_pyramid_outline(data = subset(france, year == 2004)) +
#'   coord_pyramid(age_axis = "centre")
geom_pyramid_outline <- function(
  mapping = NULL,
  data = NULL,
  stat = "pyramid",
  position = position_pyramid(stack = FALSE),
  ...,
  denominator = NULL,
  lineend = "butt",
  linejoin = "mitre",
  linemitre = 10,
  na.rm = FALSE,
  orientation = NA,
  show.legend = NA,
  inherit.aes = TRUE
) {
  if (identical(stat, "pyramid")) {
    stat <- pyramid_stat(denominator)
  }
  params <- rlang::list2(
    lineend = lineend,
    linejoin = linejoin,
    linemitre = linemitre,
    na.rm = na.rm,
    orientation = orientation,
    ...
  )
  params$denominator <- denominator
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomPyramidOutline,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = params
  )
}

#' @rdname ggpyramid-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomPyramidOutline <- ggproto(
  "GeomPyramidOutline",
  GeomPath,
  extra_params = c("na.rm", "orientation"),

  setup_params = function(data, params) {
    params$flipped_aes <- pyramid_flipped(data, params)
    params
  },

  draw_panel = function(
    self,
    data,
    panel_params,
    coord,
    lineend = "butt",
    linejoin = "mitre",
    linemitre = 10,
    na.rm = FALSE,
    flipped_aes = TRUE
  ) {
    if (nrow(data) == 0) {
      return(ggplot2::zeroGrob())
    }
    steps <- outline_steps(flip_data(data, flipped_aes))
    ggproto_parent(GeomPath, self)$draw_panel(
      flip_data(steps, flipped_aes),
      panel_params,
      coord,
      lineend = lineend,
      linejoin = linejoin,
      linemitre = linemitre,
      na.rm = na.rm
    )
  }
)

# The vertices of one stepped line per side and style, with age on x and the
# value on y. Each age group spans the full width between its neighbours.
outline_steps <- function(data) {
  half <- resolution(data$x, zero = FALSE, discrete = TRUE) / 2
  style <- intersect(c("colour", "linewidth", "linetype", "alpha"), names(data))
  separate <- intersect(c("side", "fill", style), names(data))
  key <- data[c("PANEL", separate)]
  key$left <- is_left_value(data$y)
  lines <- lapply(split(data, vec_group_id(key)), function(line) {
    line <- line[order(line$x), , drop = FALSE]
    # A zero with the sign of the side, so that a centre gap keeps it there.
    base <- 0 * line$y[1]
    lo <- line$x - half
    hi <- line$x + half
    n <- nrow(line)
    # A group starts a new step from zero unless it touches the one before.
    breaks <- c(TRUE, lo[-1] > hi[-n] + half * 1e-6)
    x <- y <- numeric(0)
    for (i in seq_len(n)) {
      if (breaks[i]) {
        if (i > 1) {
          x <- c(x, hi[i - 1])
          y <- c(y, base)
        }
        x <- c(x, lo[i])
        y <- c(y, base)
      }
      x <- c(x, lo[i], hi[i])
      y <- c(y, line$y[i], line$y[i])
    }
    vertices <- line[rep(1, length(x) + 1), style, drop = FALSE]
    vertices$x <- c(x, hi[n])
    vertices$y <- c(y, base)
    vertices$PANEL <- line$PANEL[1]
    vertices
  })
  steps <- vec_rbind(!!!lines)
  steps$group <- rep(seq_along(lines), vapply(lines, nrow, integer(1)))
  steps
}
