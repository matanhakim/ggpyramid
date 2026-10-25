# a layer without a side variable fails

    Code
      ggplot2::ggplot_build(p)
    Condition
      Error in `ggplot2::geom_col()`:
      ! Problem while computing position.
      i Error occurred in the 1st layer.
      Caused by error:
      ! Can't tell which side of the pyramid each row belongs to.
      i Map the side aesthetic, for example `aes(side = sex)`.

# a side variable with more than two values fails

    Code
      ggplot2::ggplot_build(p)
    Condition
      Error in `ggplot2::geom_col()`:
      ! Problem while computing position.
      i Error occurred in the 1st layer.
      Caused by error:
      ! A pyramid has two sides, but the side variable has 4 values: "a", "b", "c", and "d".
      i Map side to a variable with two values and use fill for subgroups within each side.

# an unknown `left` value warns

    Code
      d <- ggplot2::layer_data(p)
    Condition
      Warning:
      `left` is "female", which is not a value of the side variable ("Male" and "Female").
      i All rows are drawn on the right side.

# arguments are checked

    Code
      position_pyramid(left = c("Male", "Female"))
    Condition
      Error in `position_pyramid()`:
      ! `left` must be a single value of the side variable.

---

    Code
      position_pyramid(stack = "yes")
    Condition
      Error in `position_pyramid()`:
      ! `stack` must be `TRUE` or `FALSE`.

