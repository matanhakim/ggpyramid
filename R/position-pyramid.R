#' Mirror one side of a population pyramid
#'
#' `position_pyramid()` draws the rows of one side in the negative direction,
#' so that the two sides of a pyramid extend away from a shared age axis, and
#' stacks subgroups within each side. It works with any layer, so bars, labels,
#' points and lines all land on the same side.
#'
#' @param left The value of the side variable drawn on the left. Defaults to
#'   the first level when the side variable is a factor, and to the first value
#'   in sorted order otherwise.
#' @param stack If `TRUE`, rows that share an age group and a side are stacked
#'   away from the centre, as in [ggplot2::position_stack()]. If `FALSE`, they
#'   overlap, which suits a comparison layer drawn over the bars.
#' @param vjust,reverse Passed on to the stacking. See
#'   [ggplot2::position_stack()].
#'
#' @section Aesthetics:
#' `position_pyramid()` understands the `side` aesthetic, which assigns each
#' row to one of the two sides. When `side` is not mapped, the side comes from
#' `fill`, and failing that from `colour`. Map `side` explicitly when `fill`
#' shows subgroups, for example `aes(fill = region, side = sex)`. Rows with a
#' missing side are drawn on the right.
#'
#' @section Signed values:
#' The data you supply stays positive. Inside the plot, values on the left side
#' are negative, so a manual reference line or limit on that side carries a
#' minus sign: `geom_vline(xintercept = -100)` or
#' `scale_x_continuous(limits = c(-500, 500))`. [coord_pyramid()] shows the
#' axis labels without the sign; with another coordinate system or in a
#' vertical pyramid, use [scale_x_pyramid()] or [scale_y_pyramid()].
#'
#' @section Orientation:
#' The axis that does not hold age is the one that gets mirrored. Age is the
#' discrete axis when only one of them is discrete, and the y axis when both
#' are continuous, so a pyramid is horizontal unless age is mapped to `x`. A
#' mapped `hjust` (or `vjust` in a vertical pyramid) is mirrored as well, so
#' text justified away from the bar end on the right does the same on the
#' left. A fixed `hjust` set outside [ggplot2::aes()] is not mirrored.
#'
#' @returns A ggproto object of class `PositionPyramid`.
#' @seealso [geom_pyramid()] for the bars of a pyramid, and [coord_pyramid()]
#'   for its axes.
#' @export
#' @examples
#' library(ggplot2)
#'
#' pop <- data.frame(
#'   age = factor(rep(c("0-19", "20-39", "40-59", "60+"), 2)),
#'   sex = factor(rep(c("Male", "Female"), each = 4), c("Male", "Female")),
#'   n = c(220, 200, 160, 90, 210, 205, 170, 120)
#' )
#'
#' # Any geom can be mirrored
#' ggplot(pop, aes(x = n, y = age, fill = sex)) +
#'   geom_col(position = position_pyramid()) +
#'   geom_text(aes(label = n, hjust = -0.2), position = "pyramid") +
#'   scale_x_continuous(expand = expansion(mult = 0.15)) +
#'   coord_pyramid()
#'
#' # Subgroups stack within each side
#' pop2 <- rbind(transform(pop, group = "A"), transform(pop, group = "B"))
#' ggplot(pop2, aes(x = n, y = age, fill = group, side = sex)) +
#'   geom_col(position = position_pyramid(left = "Female"))
position_pyramid <- function(
  left = NULL,
  stack = TRUE,
  vjust = 1,
  reverse = FALSE
) {
  if (!is.null(left) && (!rlang::is_scalar_atomic(left) || is.na(left))) {
    cli::cli_abort("{.arg left} must be a single value of the side variable.")
  }
  if (!rlang::is_bool(stack)) {
    cli::cli_abort("{.arg stack} must be {.code TRUE} or {.code FALSE}.")
  }
  ggproto(
    NULL,
    PositionPyramid,
    left = left,
    stack = stack,
    vjust = vjust,
    reverse = reverse
  )
}

#' @rdname ggpyramid-ggproto
#' @format NULL
#' @usage NULL
#' @export
PositionPyramid <- ggproto(
  "PositionPyramid",
  PositionStack,
  default_aes = aes(side = NULL),
  left = NULL,
  stack = TRUE,

  setup_params = function(self, data) {
    # Default to a horizontal pyramid when both axes are continuous, so that
    # labels with a numeric age agree with the bars from stat_pyramid().
    if (nrow(data) > 0) {
      data$flipped_aes <- has_flipped_aes(data, default = TRUE)
    }
    params <- ggproto_parent(PositionStack, self)$setup_params(data)
    if (!isTRUE(self$stack)) {
      params["var"] <- list(NULL)
    }
    params$left <- pyramid_left(pyramid_side(data), self$left)
    params
  },

  # Without stacking, PositionStack$setup_data() and $compute_panel() each
  # return flipped data and cancel out. Mirroring runs in between, so skip
  # both instead.
  setup_data = function(self, data, params) {
    if (is.null(params$var)) {
      return(data)
    }
    ggproto_parent(PositionStack, self)$setup_data(data, params)
  },

  # position_stack() splits rows into a negative and a positive pile by sign,
  # which would put a zero on the left side into the right side's pile. Stack
  # each side on its own instead, and keep the original row order.
  compute_panel = function(self, data, params, scales) {
    if (nrow(data) == 0) {
      return(data)
    }
    on_left <- on_left_side(data, params$left)
    parent <- ggproto_parent(PositionStack, self)
    sides <- lapply(
      list(data[on_left, , drop = FALSE], data[!on_left, , drop = FALSE]),
      \(side) if (nrow(side) > 0) parent$compute_panel(side, params, scales)
    )
    stacked <- vec_rbind(!!!sides)
    vec_slice(stacked, order(c(which(on_left), which(!on_left))))
  },

  compute_layer = function(self, data, params, layout) {
    on_left <- on_left_side(data, params$left)
    negate <- function(x) ifelse(on_left, -x, x)
    data <- if (params$flipped_aes) {
      transform_position(data, trans_x = negate)
    } else {
      transform_position(data, trans_y = negate)
    }
    if (!is.null(params$var)) {
      data <- ggproto_parent(PositionStack, self)$compute_layer(
        data,
        params,
        layout
      )
    }

    # Stacking can reorder rows by panel, so find the left side again.
    on_left <- on_left_side(data, params$left)
    axis <- if (params$flipped_aes) "x" else "y"
    lo <- paste0(axis, "min")
    hi <- paste0(axis, "max")
    if (!is.null(data[[lo]]) && !is.null(data[[hi]])) {
      bounds <- list(pmin(data[[lo]], data[[hi]]), pmax(data[[lo]], data[[hi]]))
      data[[lo]] <- bounds[[1]]
      data[[hi]] <- bounds[[2]]
      # position_stack() measures `vjust` from the end nearer zero on the
      # negative side; measure it from the centre on both sides instead.
      if (!is.null(params$var)) {
        v <- params$vjust
        far <- v * bounds[[1]] + (1 - v) * bounds[[2]]
        data[[axis]] <- ifelse(on_left, far, data[[axis]])
      }
    }
    just <- if (params$flipped_aes) "hjust" else "vjust"
    if (!is.null(data[[just]])) {
      data[[just]] <- mirror_just(data[[just]], on_left)
    }

    # A zero on the left side becomes a negative zero, so that coord_pyramid()
    # can put it on the left edge of a centre gap. It is computed, because the
    # byte compiler turns a literal -0 into 0.
    signed_zero <- function(x) {
      zero <- on_left & !is.na(x) & x == 0
      if (any(zero)) {
        x <- as.double(x)
        x[zero] <- -abs(x[zero])
      }
      x
    }
    if (params$flipped_aes) {
      transform_position(data, trans_x = signed_zero)
    } else {
      transform_position(data, trans_y = signed_zero)
    }
  }
)

mirror_just <- function(just, on_left) {
  if (is.numeric(just)) {
    return(ifelse(on_left, 1 - just, just))
  }
  swap <- c(left = "right", right = "left", bottom = "top", top = "bottom")
  flip <- on_left & just %in% names(swap)
  just[flip] <- swap[just[flip]]
  unname(just)
}
