# geom_pyramid_text() checks its arguments

    Code
      geom_pyramid_text(place = "middle")
    Condition
      Error in `geom_pyramid_text()`:
      ! `place` must be one of "outside" or "inside", not "middle".

---

    Code
      geom_pyramid_text(padding = "1mm")
    Condition
      Error in `geom_pyramid_text()`:
      ! `padding` must be a single number.

# `labels` must be a function or a formula

    Code
      geom_pyramid_text(labels = "a")
    Condition
      Error in `geom_pyramid_text()`:
      ! `labels` must be a function, a formula or `NULL`.

