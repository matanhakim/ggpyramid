#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom ggplot2 aes after_stat CoordCartesian flip_data GeomBar ggplot
#' @importFrom ggplot2 ggproto ggproto_parent has_flipped_aes layer
#' @importFrom ggplot2 PositionStack resolution Stat transform_position
#' @importFrom rlang %||%
#' @importFrom stats ave
#' @importFrom utils globalVariables
#' @importFrom vctrs vec_rbind vec_slice
## usethis namespace: end
NULL

# Computed variables named in after_stat() mappings.
globalVariables(c("count", "prop"))
