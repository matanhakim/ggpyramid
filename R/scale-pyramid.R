#' Position scales for the value axis of a pyramid
#'
#' `scale_x_pyramid()` and `scale_y_pyramid()` are continuous position scales
#' that label the value axis of a pyramid without the minus sign and extend it
#' equally far on both sides of zero. [coord_pyramid()] does the same for a
#' horizontal pyramid, along with placing the age axis; these scales serve a
#' vertical pyramid, or a plot that needs another coordinate system.
#'
#' @inheritParams ggplot2::scale_x_continuous
#' @param labels Labels for the breaks, applied to their absolute values. One
#'   of:
#'   * a function that takes the breaks and returns labels, such as
#'     `scales::label_comma()`, or a formula such as `~ .x / 1000`;
#'   * the default, `waiver()`, for the usual number format;
#'   * a character vector of labels, used as given;
#'   * `NULL` for no labels.
#' @param symmetric If `TRUE`, the limits extend equally far on both sides of
#'   zero. Ignored when `limits` is set.
#' @param ... Other arguments passed on to [ggplot2::scale_x_continuous()] or
#'   [ggplot2::scale_y_continuous()], such as `breaks`, `expand` or `position`.
#'
#' @returns A ggplot2 scale.
#' @seealso [coord_pyramid()], which labels and limits the value axis of a
#'   horizontal pyramid.
#' @export
#' @examples
#' library(ggplot2)
#'
#' france <- subset(europe_pop, country == "France" & year == 2024)
#'
#' # A vertical pyramid, with age on x
#' ggplot(france, aes(x = age, y = population, fill = sex)) +
#'   geom_pyramid() +
#'   scale_y_pyramid(labels = scales::label_comma()) +
#'   theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
scale_x_pyramid <- function(
  ...,
  labels = waiver(),
  limits = NULL,
  symmetric = TRUE
) {
  ggplot2::scale_x_continuous(
    ...,
    labels = absolute_labels(labels),
    limits = pyramid_limits(limits, symmetric)
  )
}

#' @rdname scale_x_pyramid
#' @export
scale_y_pyramid <- function(
  ...,
  labels = waiver(),
  limits = NULL,
  symmetric = TRUE
) {
  ggplot2::scale_y_continuous(
    ...,
    labels = absolute_labels(labels),
    limits = pyramid_limits(limits, symmetric)
  )
}

absolute_labels <- function(labels, call = rlang::caller_env()) {
  if (is.null(labels) || is.character(labels) || is.expression(labels)) {
    return(labels)
  }
  if (ggplot2::is_waiver(labels)) {
    return(\(x) scales::transform_identity()$format(magnitude(x)))
  }
  if (!is.function(labels) && !rlang::is_formula(labels)) {
    cli::cli_abort(
      "{.arg labels} must be a function, a character vector, {.code NULL} or
       {.code waiver()}.",
      call = call
    )
  }
  labels <- rlang::as_function(labels)
  \(x) labels(magnitude(x))
}

pyramid_limits <- function(limits, symmetric, call = rlang::caller_env()) {
  if (!rlang::is_bool(symmetric)) {
    cli::cli_abort(
      "{.arg symmetric} must be {.code TRUE} or {.code FALSE}.",
      call = call
    )
  }
  if (!is.null(limits) || !symmetric) {
    return(limits)
  }
  \(range) c(-1, 1) * max(abs(range))
}
