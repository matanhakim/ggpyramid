# Changelog

## ggpyramid (development version)

- [`geom_pyramid()`](https://matanhakim.github.io/ggpyramid/reference/geom_pyramid.md)
  and
  [`stat_pyramid()`](https://matanhakim.github.io/ggpyramid/reference/geom_pyramid.md)
  draw the bars of a population pyramid. They count individual records
  or sum a mapped value, and `denominator` shows the bars as proportions
  of the panel or of each side.
- [`position_pyramid()`](https://matanhakim.github.io/ggpyramid/reference/position_pyramid.md)
  mirrors one side of the pyramid and stacks subgroups within each side,
  for any layer. The side comes from the new `side` aesthetic, or from
  `fill` when `side` is not mapped.
