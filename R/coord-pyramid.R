#' Cartesian coordinates for a population pyramid
#'
#' `coord_pyramid()` is a Cartesian coordinate system for horizontal pyramids
#' drawn with [position_pyramid()]. It labels the value axis without the minus
#' sign on the left side, extends the value axis equally far on both sides of
#' zero, and places the age axis on the left, on the right, on both sides or in
#' the centre of the pyramid, optionally in a gap between the two sides.
#'
#' @param age_axis Where to draw the age axis: `"left"`, `"right"`, `"both"`,
#'   `"centre"` (between the two sides, see Age axis below) or `"none"`.
#'   `"center"` is accepted as well.
#' @param gap The width of an empty strip between the two sides, as a
#'   proportion of the panel width. Defaults to `0.12` when `age_axis` is
#'   `"centre"`, which leaves room for the age labels, and to `0` otherwise.
#' @param symmetric If `TRUE`, the value axis extends equally far on both sides
#'   of zero, so the two sides share one scale. Ignored when `xlim` is set.
#' @inheritParams ggplot2::coord_cartesian
#'
#' @section Value axis:
#' Only the labels lose their sign. The data and the scale keep the signed
#' values that [position_pyramid()] produces, so breaks, limits and reference
#' lines on the left side are still given as negative numbers. Any `labels`
#' given to [ggplot2::scale_x_continuous()] apply to the absolute values, for
#' example `labels = scales::label_percent()`. With a gap, a break at zero is
#' drawn on both inner edges, so a gap narrower than two zero labels makes them
#' overlap.
#'
#' @section Age axis:
#' `"left"` and `"right"` move the age scale to that side together with its
#' title, and `"both"` duplicates it on the right, as
#' `scale_y_discrete(sec.axis = dup_axis())` would. `"centre"` draws the age
#' labels inside the panel, above the layers and in the middle of the gap,
#' styled by the `axis.text.y.left` theme element. If the labels are wider
#' than the gap, increase `gap`.
#'
#' @returns A ggproto object of class `CoordPyramid`.
#' @seealso [position_pyramid()], which mirrors the left side.
#' @export
#' @examples
#' library(ggplot2)
#'
#' pop <- data.frame(
#'   age = factor(rep(c("0-19", "20-39", "40-59", "60+"), 2)),
#'   sex = factor(rep(c("Male", "Female"), each = 4), c("Male", "Female")),
#'   n = c(220, 200, 160, 90, 210, 205, 170, 120)
#' )
#' p <- ggplot(pop, aes(x = n, y = age, fill = sex)) +
#'   geom_pyramid()
#'
#' p + coord_pyramid()
#'
#' # Age labels in a gap between the two sides
#' p + coord_pyramid(age_axis = "centre")
#'
#' # Age labels on both sides, with a narrow gap
#' p + coord_pyramid(age_axis = "both", gap = 0.08)
coord_pyramid <- function(
  age_axis = c("left", "right", "both", "centre", "none"),
  gap = NULL,
  symmetric = TRUE,
  xlim = NULL,
  ylim = NULL,
  expand = TRUE,
  clip = "on"
) {
  if (identical(age_axis, "center")) {
    age_axis <- "centre"
  }
  age_axis <- rlang::arg_match(age_axis)
  gap <- gap %||% if (age_axis == "centre") 0.12 else 0
  if (
    !is.numeric(gap) || length(gap) != 1 || is.na(gap) || gap < 0 || gap >= 1
  ) {
    cli::cli_abort("{.arg gap} must be a single number from 0 up to 1.")
  }
  if (!rlang::is_bool(symmetric)) {
    cli::cli_abort("{.arg symmetric} must be {.code TRUE} or {.code FALSE}.")
  }
  ggproto(
    NULL,
    CoordPyramid,
    limits = list(x = xlim, y = ylim),
    age_axis = age_axis,
    gap = gap,
    symmetric = symmetric,
    expand = expand,
    clip = clip,
    reverse = "none",
    default = FALSE
  )
}

#' @rdname ggpyramid-ggproto
#' @format NULL
#' @usage NULL
#' @export
CoordPyramid <- ggproto(
  "CoordPyramid",
  CoordCartesian,
  age_axis = "left",
  gap = 0,
  symmetric = TRUE,

  # The panel scales are copies made for this plot, so changing them here
  # moves the axis title along with the axis.
  modify_scales = function(self, scales_x, scales_y) {
    if (any(vapply(scales_x, \(scale) scale$is_discrete(), logical(1)))) {
      cli::cli_abort(
        c(
          "{.fn coord_pyramid} draws horizontal pyramids, with the values on
           the x axis.",
          i = "Map age to {.field y}."
        ),
        call = NULL
      )
    }
    for (scale in scales_y) {
      scale$position <- if (self$age_axis == "right") "right" else "left"
      no_secondary <- is.null(scale$secondary.axis) ||
        ggplot2::is_waiver(scale$secondary.axis)
      if (self$age_axis == "both" && no_secondary) {
        scale$secondary.axis <- ggplot2::dup_axis()
      }
    }
    invisible()
  },

  setup_panel_params = function(self, scale_x, scale_y, params = list()) {
    coord <- self
    if (self$symmetric && is.null(self$limits$x)) {
      reach <- suppressWarnings(max(abs(scale_x$get_limits()), na.rm = TRUE))
      if (is.finite(reach) && reach > 0) {
        coord <- ggproto(
          NULL,
          self,
          limits = list(x = c(-reach, reach), y = self$limits$y)
        )
      }
    }
    panel_params <- ggproto_parent(CoordCartesian, coord)$setup_panel_params(
      scale_x,
      scale_y,
      params
    )
    panel_params$x <- pyramid_view_scale(panel_params$x, self$gap > 0)
    panel_params
  },

  transform = function(self, data, panel_params) {
    left <- on_left_half(data)
    data <- ggproto_parent(CoordCartesian, self)$transform(data, panel_params)
    open_gap(data, left, panel_params, self$gap)
  },

  render_axis_v = function(self, panel_params, theme) {
    axes <- ggproto_parent(CoordCartesian, self)$render_axis_v(
      panel_params,
      theme
    )
    if (self$age_axis %in% c("centre", "none")) {
      axes$left <- ggplot2::zeroGrob()
    }
    axes
  },

  render_fg = function(self, panel_params, theme) {
    border <- ggproto_parent(CoordCartesian, self)$render_fg(
      panel_params,
      theme
    )
    if (self$age_axis != "centre") {
      return(border)
    }
    age <- panel_params$y
    centre <- panel_params$x$rescale(0) * (1 - self$gap) + self$gap / 2
    labels <- ggplot2::element_grob(
      ggplot2::calc_element("axis.text.y.left", theme),
      label = age$get_labels(),
      x = grid::unit(centre, "npc"),
      y = grid::unit(age$break_positions(), "npc"),
      hjust = 0.5,
      margin_x = FALSE,
      margin_y = FALSE
    )
    grid::grobTree(labels, border)
  }
)

# The view scale of the value axis, labelled with absolute values. With a gap,
# a break at zero is doubled into a negative and a positive zero, one for each
# inner edge.
pyramid_view_scale <- function(view, split_zero) {
  ggproto(
    NULL,
    view,
    get_breaks = function(self) {
      breaks <- view$get_breaks()
      zero <- zero_break(breaks)
      if (!split_zero || is.na(zero)) {
        return(breaks)
      }
      append(breaks, -abs(breaks[zero]), after = zero - 1)
    },
    # Labels come from the scale's own breaks, so that a `labels` vector given
    # to the scale keeps the length of its `breaks`.
    get_labels = function(self, breaks = self$get_breaks()) {
      if (!split_zero) {
        return(view$scale$get_labels(magnitude(breaks)))
      }
      own <- view$get_breaks()
      labels <- view$scale$get_labels(magnitude(own))
      zero <- zero_break(own)
      if (is.na(zero)) {
        return(labels)
      }
      append(labels, labels[zero], after = zero - 1)
    }
  )
}

zero_break <- function(breaks) {
  which(!is.na(breaks) & breaks == 0)[1]
}

# The x-like position aesthetics, as listed by ggplot2.
x_aesthetics <- c(
  "x",
  "xmin",
  "xmax",
  "xend",
  "xintercept",
  "xmin_final",
  "xmax_final",
  "xlower",
  "xmiddle",
  "xupper",
  "x0"
)

# For each x-like column, which values belong to the left half. Negative values
# do, and a zero follows the other values in its row, so the inner end of a
# bar stays with its bar. A zero with nothing else to follow is on the left
# only when it is a negative zero, as position_pyramid() writes it.
on_left_half <- function(data) {
  columns <- data[intersect(x_aesthetics, names(data))]
  if (length(columns) == 0) {
    return(list())
  }
  direction <- Reduce(`+`, lapply(columns, \(x) ifelse(is.na(x), 0, sign(x))))
  negative_zero <- Reduce(
    `|`,
    lapply(columns, \(x) !is.na(x) & x == 0 & 1 / x < 0)
  )
  row_left <- direction < 0 | (direction == 0 & negative_zero)
  lapply(columns, \(x) x < 0 | (x == 0 & row_left))
}

# Squeezes both halves of the panel by the same factor and opens `gap` between
# them, so that equal values still have equal lengths on both sides.
open_gap <- function(data, left, panel_params, gap) {
  zero <- panel_params$x$rescale(0)
  if (gap <= 0 || length(left) == 0 || !is.finite(zero)) {
    return(data)
  }
  if (zero <= 0 || zero >= 1) {
    return(data)
  }
  for (column in names(left)) {
    data[[column]] <- data[[column]] * (1 - gap) + gap * !left[[column]]
  }
  data
}

# Absolute values for labelling. Breaks computed around zero can differ in the
# last bits between the two sides, enough for a label function that picks its
# own precision to round 0.025 up on one side and down on the other.
magnitude <- function(x) {
  signif(abs(x), 12)
}
