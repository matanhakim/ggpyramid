#' Value labels on a population pyramid
#'
#' `geom_pyramid_text()` writes a label at the end of each bar of a pyramid.
#' It aggregates the data in the same way as [geom_pyramid()], so the labels
#' show the counts, or the proportions when `denominator` is set, without
#' further mapping. Labels on the left side are justified towards the left,
#' so they sit outside (or inside) the bar on both sides.
#'
#' @inheritParams geom_pyramid
#' @inheritParams ggplot2::geom_text
#' @param position A position adjustment. The default, `"pyramid"`, is
#'   [position_pyramid()], which places each label at the outer end of its
#'   bar. Labels follow the side set by `coord_pyramid(left = ...)`; a
#'   position given to the bars should be given to the labels as well.
#' @param place Where to draw the labels: `"outside"` the end of the bar, or
#'   `"inside"` it.
#' @param padding The distance between the label and the end of the bar, in
#'   millimetres.
#' @param labels A function that formats the labels, such as
#'   `scales::label_comma()` or `scales::label_percent()`, or `NULL` to show
#'   them as they are. A formula such as `~ round(.x)` is converted with
#'   [rlang::as_function()].
#' @param ... Other arguments passed on to [ggplot2::layer()], such as fixed
#'   aesthetics like `size = 3` or `colour = "grey30"`.
#'
#' @section Aesthetics:
#' `label` defaults to the value the bars show, `after_stat(count)` or
#' `after_stat(prop)`, and can be mapped to anything else. The horizontal and
#' vertical justification are set by `place` and the text `angle`, so a mapped
#' or fixed `hjust` or `vjust` is replaced. The other aesthetics are those of
#' [ggplot2::geom_text()].
#'
#' @returns A ggplot2 layer.
#' @seealso [geom_pyramid()] for the bars.
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
#'   coord_pyramid()
#'
#' p +
#'   geom_pyramid() +
#'   geom_pyramid_text() +
#'   scale_x_continuous(expand = expansion(mult = 0.15))
#'
#' # Percentages inside the bars
#' p +
#'   geom_pyramid(denominator = "total") +
#'   geom_pyramid_text(
#'     denominator = "total",
#'     place = "inside",
#'     labels = scales::label_percent(accuracy = 1),
#'     colour = "white"
#'   )
geom_pyramid_text <- function(
  mapping = NULL,
  data = NULL,
  stat = "pyramid",
  position = "pyramid",
  ...,
  denominator = NULL,
  place = c("outside", "inside"),
  padding = 1,
  labels = NULL,
  parse = FALSE,
  check_overlap = FALSE,
  size.unit = "mm",
  na.rm = FALSE,
  orientation = NA,
  show.legend = NA,
  inherit.aes = TRUE
) {
  place <- rlang::arg_match(place)
  if (!is.numeric(padding) || length(padding) != 1 || is.na(padding)) {
    cli::cli_abort("{.arg padding} must be a single number.")
  }
  if (!is.null(labels)) {
    labels <- rlang::as_function(labels)
  }
  if (identical(stat, "pyramid")) {
    stat <- pyramid_stat(denominator, label = TRUE)
  }
  params <- rlang::list2(
    place = place,
    padding = padding,
    labels = labels,
    parse = parse,
    check_overlap = check_overlap,
    size.unit = size.unit,
    na.rm = na.rm,
    orientation = orientation,
    ...
  )
  params$denominator <- denominator
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomPyramidText,
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
GeomPyramidText <- ggproto(
  "GeomPyramidText",
  GeomText,
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
    place = "outside",
    padding = 1,
    labels = NULL,
    parse = FALSE,
    na.rm = FALSE,
    check_overlap = FALSE,
    size.unit = "mm",
    flipped_aes = TRUE
  ) {
    if (nrow(data) == 0) {
      return(ggplot2::zeroGrob())
    }
    if (!is.null(labels)) {
      data$label <- labels(data$label)
    }
    value <- if (flipped_aes) "x" else "y"
    left <- is_left_value(data[[value]])
    # Away from the centre: +1 on the right, -1 on the left.
    outward <- ifelse(left, -1, 1)
    if (place == "inside") {
      outward <- -outward
    }
    # Justify along whichever text direction lies closer to the value axis:
    # `hjust` runs with the text and `vjust` across it.
    angle <- (data$angle %||% 0) * pi / 180
    with_text <- if (flipped_aes) cos(angle) else sin(angle)
    across_text <- if (flipped_aes) -sin(angle) else cos(angle)
    by_hjust <- abs(with_text) >= abs(across_text)
    towards <- outward * sign(ifelse(by_hjust, with_text, across_text))
    just <- (1 - towards) / 2
    data$hjust <- ifelse(by_hjust, just, 0.5)
    data$vjust <- ifelse(by_hjust, 0.5, just)

    grob <- ggproto_parent(GeomText, self)$draw_panel(
      data,
      panel_params,
      coord,
      parse = parse,
      na.rm = na.rm,
      check_overlap = check_overlap,
      size.unit = size.unit
    )
    shift <- grid::unit(outward * padding, "mm")
    if (flipped_aes) {
      grob$x <- grob$x + shift
    } else {
      grob$y <- grob$y + shift
    }
    grob
  }
)

# Whether a layer is horizontal, with age on y. The pyramid stat records this
# in `flipped_aes`; other stats leave it to the same rule as the position.
pyramid_flipped <- function(data, params) {
  if (!is.null(data$flipped_aes)) {
    return(isTRUE(data$flipped_aes[1]))
  }
  has_flipped_aes(data, params, default = TRUE)
}

# Values drawn on the left side: negative ones, and the negative zeros that
# position_pyramid() writes for zeros on the left.
is_left_value <- function(x) {
  !is.na(x) & (x < 0 | (x == 0 & 1 / x < 0))
}
