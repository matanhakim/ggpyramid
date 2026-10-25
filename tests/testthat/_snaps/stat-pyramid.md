# an unknown denominator fails

    Code
      geom_pyramid(denominator = "sex")
    Condition
      Error in `geom_pyramid()`:
      ! `denominator` must be one of "total" or "side", not "sex".

---

    Code
      stat_pyramid(denominator = "sex")
    Condition
      Error in `stat_pyramid()`:
      ! `denominator` must be one of "total" or "side", not "sex".

