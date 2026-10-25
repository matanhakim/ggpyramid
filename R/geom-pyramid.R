#' Bars of a population pyramid
#'
#' `geom_pyramid()` draws the bars of a population pyramid: one bar per age
#' group on each side, extending away from a shared age axis. It counts rows,
#' so it accepts individual records (`aes(y = age, fill = sex)`), and it sums a
#' value when one is mapped, so it also accepts aggregated data
#' (`aes(x = n, y = age, fill = sex)`). The bars are mirrored and stacked by
#' [position_pyramid()], and every other part of the plot (scales, facets,
#' themes and further layers) comes from ggplot2 as usual.
#'
#' @inheritParams ggplot2::geom_bar
#' @param stat The statistical transformation to use on the data for this
#'   layer. The default, `"pyramid"`, is [stat_pyramid()].
#' @param position A position adjustment. The default, `"pyramid"`, is
#'   [position_pyramid()]; call it to set its arguments, for example
#'   `position = position_pyramid(reverse = TRUE)`. To choose the side drawn on
#'   the left for every layer, use `coord_pyramid(left = "Female")`.
#' @param ... Other arguments passed on to [ggplot2::layer()], such as the bar
#'   `width` or fixed aesthetics like `colour = "white"`.
#'
#' @section Aesthetics:
#' Age goes on `y`, or on `x` for a vertical pyramid. The value axis is
#' optional: when it is mapped, its values are summed within each age group,
#' and when it is not, rows are counted. `weight` multiplies either. The side
#' of each bar comes from `side`, or from `fill` when `side` is not mapped; see
#' [position_pyramid()].
#'
#' @section Computed variables:
#' These can be used with [ggplot2::after_stat()]:
#' * `after_stat(count)`: the number of rows, or the sum of the value, in each
#'   age group. This is what the bars show by default.
#' * `after_stat(prop)`: `count` as a proportion of all rows in the panel, or
#'   of the rows on the same side with `denominator = "side"`. Each facet
#'   panel has its own denominator. The bars show `prop` whenever
#'   `denominator` is set.
#'
#' @returns A ggplot2 layer.
#' @seealso [position_pyramid()] to mirror other layers, and [coord_pyramid()]
#'   for the axes of a pyramid.
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
#' # Aggregated data: the value is summed
#' ggplot(pop, aes(x = n, y = age, fill = sex)) +
#'   geom_pyramid() +
#'   coord_pyramid()
#'
#' # Individual records: rows are counted
#' people <- pop[rep(seq_len(nrow(pop)), pop$n), c("age", "sex")]
#' ggplot(people, aes(y = age, fill = sex)) +
#'   geom_pyramid()
#'
#' # Percentages of each side
#' ggplot(pop, aes(x = n, y = age, fill = sex)) +
#'   geom_pyramid(denominator = "side") +
#'   scale_x_continuous(labels = scales::label_percent()) +
#'   coord_pyramid() +
#'   labs(x = "Share of each sex")
geom_pyramid <- function(
  mapping = NULL,
  data = NULL,
  stat = "pyramid",
  position = "pyramid",
  ...,
  denominator = NULL,
  just = 0.5,
  na.rm = FALSE,
  orientation = NA,
  show.legend = NA,
  inherit.aes = TRUE
) {
  if (identical(stat, "pyramid")) {
    stat <- pyramid_stat(denominator)
  }
  params <- rlang::list2(
    just = just,
    na.rm = na.rm,
    orientation = orientation,
    ...
  )
  # Only stat_pyramid() knows `denominator`, so leave it out when unset.
  params$denominator <- denominator
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomBar,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = params
  )
}
