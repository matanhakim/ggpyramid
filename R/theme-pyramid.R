#' A theme for population pyramids
#'
#' `theme_pyramid()` is [ggplot2::theme_minimal()] adjusted for pyramids. It
#' removes the grid lines that run along the bars, which the age axis already
#' marks, keeps the major grid lines across the value axis, and puts the legend
#' above the plot, where it reads as a heading for the two sides.
#'
#' @param ... Arguments passed on to [ggplot2::theme_minimal()], such as
#'   `base_size` or `base_family`.
#' @param flipped If `FALSE` (the default), the pyramid is horizontal, with age
#'   on the y axis. Set it to `TRUE` for a vertical pyramid, with age on x.
#'
#' @returns A ggplot2 theme.
#' @export
#' @examples
#' library(ggplot2)
#'
#' france <- subset(europe_pop, country == "France" & year == 2024)
#' ggplot(france, aes(x = population, y = age, fill = sex)) +
#'   geom_pyramid() +
#'   coord_pyramid() +
#'   theme_pyramid()
theme_pyramid <- function(..., flipped = FALSE) {
  if (!rlang::is_bool(flipped)) {
    cli::cli_abort("{.arg flipped} must be {.code TRUE} or {.code FALSE}.")
  }
  along_bars <- if (flipped) "panel.grid.major.x" else "panel.grid.major.y"
  ggplot2::theme_minimal(...) +
    do.call(
      ggplot2::theme,
      stats::setNames(
        list(ggplot2::element_blank()),
        along_bars
      )
    ) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "top"
    )
}
