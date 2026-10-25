#' @param denominator `NULL` (the default) shows counts. `"total"` shows each
#'   bar as a proportion of all rows in the panel, and `"side"` as a
#'   proportion of the rows on its side.
#' @param geom The geometric object used to display the data.
#' @rdname geom_pyramid
#' @export
stat_pyramid <- function(
  mapping = NULL,
  data = NULL,
  geom = "bar",
  position = "pyramid",
  ...,
  denominator = NULL,
  na.rm = FALSE,
  orientation = NA,
  show.legend = NA,
  inherit.aes = TRUE
) {
  layer(
    data = data,
    mapping = mapping,
    stat = pyramid_stat(denominator),
    geom = geom,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = rlang::list2(
      denominator = denominator,
      na.rm = na.rm,
      orientation = orientation,
      ...
    )
  )
}

# The stat writes the counts or proportions straight into the value axis, so
# that every layer using it agrees with the `denominator` it was given. This
# child only adds a default mapping that names the axis after what it shows.
pyramid_stat <- function(denominator = NULL, call = rlang::caller_env()) {
  if (is.null(denominator)) {
    return(ggproto(
      NULL,
      StatPyramid,
      default_aes = aes(
        x = after_stat(count),
        y = after_stat(count),
        weight = 1
      )
    ))
  }
  rlang::arg_match0(denominator, c("total", "side"), error_call = call)
  ggproto(
    NULL,
    StatPyramid,
    default_aes = aes(
      x = after_stat(prop),
      y = after_stat(prop),
      weight = 1
    )
  )
}

#' @rdname ggpyramid-ggproto
#' @format NULL
#' @usage NULL
#' @export
StatPyramid <- ggproto(
  "StatPyramid",
  Stat,
  required_aes = "x|y",
  default_aes = aes(weight = 1),
  dropped_aes = "weight",

  setup_params = function(self, data, params) {
    params$flipped_aes <- has_flipped_aes(
      data,
      params,
      main_is_orthogonal = FALSE,
      default = TRUE
    )
    if (is.null(params$width)) {
      age <- if (params$flipped_aes) "y" else "x"
      params$width <- resolution(data[[age]], discrete = TRUE) * 0.9
    }
    params
  },

  compute_panel = function(
    self,
    data,
    scales,
    width = NULL,
    denominator = NULL,
    flipped_aes = FALSE
  ) {
    bars <- ggproto_parent(Stat, self)$compute_panel(
      data,
      scales,
      width = width,
      flipped_aes = flipped_aes
    )
    total <- if (identical(denominator, "side")) {
      ave(bars$count, as.character(pyramid_side(bars)), FUN = sum)
    } else {
      sum(bars$count)
    }
    bars$prop <- bars$count / total
    if (!is.null(denominator)) {
      bars[[if (flipped_aes) "x" else "y"]] <- bars$prop
    }
    bars
  },

  compute_group = function(
    self,
    data,
    scales,
    width = NULL,
    flipped_aes = FALSE
  ) {
    data <- flip_data(data, flipped_aes)
    weight <- data$weight %||% rep(1, nrow(data))
    if (!is.null(data$y)) {
      weight <- weight * data$y
    }
    count <- as.vector(rowsum(weight, data$x, na.rm = TRUE))
    bars <- data.frame(count = count)
    bars$x <- sort(unique(data$x))
    bars$y <- count
    bars$width <- width
    bars$flipped_aes <- flipped_aes
    flip_data(bars, flipped_aes)
  }
)
