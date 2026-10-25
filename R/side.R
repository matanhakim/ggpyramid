# The variable that puts each row on a side: `side` when mapped, otherwise
# `fill`, otherwise `colour`. Stats and positions run before non-position
# aesthetics are scaled, so these still hold the user's original values.
pyramid_side <- function(data, call = NULL) {
  for (aesthetic in c("side", "fill", "colour")) {
    if (!is.null(data[[aesthetic]])) {
      return(data[[aesthetic]])
    }
  }
  cli::cli_abort(
    c(
      "Can't tell which side of the pyramid each row belongs to.",
      i = "Map the {.field side} aesthetic, for example
           {.code aes(side = sex)}."
    ),
    call = call
  )
}

# The side value drawn in the negative direction: `left` when given, otherwise
# the first factor level or the first value in sorted order.
pyramid_left <- function(side, left = NULL, call = NULL) {
  present <- unique(as.character(side[!is.na(side)]))
  if (length(present) > 2) {
    cli::cli_abort(
      c(
        "A pyramid has two sides, but the side variable has
         {length(present)} values: {.val {present}}.",
        i = "Map {.field side} to a variable with two values and use
             {.field fill} for subgroups within each side."
      ),
      call = call
    )
  }
  if (is.null(left)) {
    candidates <- if (is.factor(side)) levels(side) else sort(present)
    return(candidates[1])
  }
  left <- as.character(left)
  if (length(present) == 2 && !left %in% present) {
    cli::cli_warn(
      c(
        "{.arg left} is {.val {left}}, which is not a value of the side
         variable ({.val {present}}).",
        i = "All rows are drawn on the right side."
      ),
      call = call
    )
  }
  left
}

# `left` from the layer's position, else from coord_pyramid(), so that one
# setting on the coordinate system reaches every layer of the plot.
layer_left <- function(left, coord) {
  if (is.null(left) && inherits(coord, "CoordPyramid")) coord$left else left
}

check_left <- function(left, call = rlang::caller_env()) {
  if (!is.null(left) && (!rlang::is_scalar_atomic(left) || is.na(left))) {
    cli::cli_abort(
      "{.arg left} must be a single value of the side variable.",
      call = call
    )
  }
}

on_left_side <- function(data, left) {
  side <- as.character(pyramid_side(data))
  !is.na(side) & side == left
}
