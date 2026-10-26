# coord_pyramid() checks its arguments

    Code
      coord_pyramid(age_axis = "top")
    Condition
      Error in `coord_pyramid()`:
      ! `age_axis` must be one of "left", "right", "both", "centre", or "none", not "top".

---

    Code
      coord_pyramid(gap = 1)
    Condition
      Error in `coord_pyramid()`:
      ! `gap` must be a single number from 0 up to 1.

---

    Code
      coord_pyramid(symmetric = NA)
    Condition
      Error in `coord_pyramid()`:
      ! `symmetric` must be `TRUE` or `FALSE`.

# coord_pyramid() needs the values on the x axis

    Code
      ggplot2::ggplot_build(p)
    Condition
      Error:
      ! `coord_pyramid()` draws horizontal pyramids, with the values on the x axis.
      i Map age to y.

# a transformed value axis is refused

    Code
      ggplot2::ggplot_build(p)
    Condition
      Error:
      ! `coord_pyramid()` needs a linear value axis, not a "reverse" transformation.
      i Use `left` in `coord_pyramid()` to swap the sides.

