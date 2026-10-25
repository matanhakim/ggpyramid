# ggpyramid (development version)

* `geom_pyramid()` and `stat_pyramid()` draw the bars of a population pyramid. They count individual records or sum a mapped value, and `denominator` shows the bars as proportions of the panel or of each side.
* `position_pyramid()` mirrors one side of the pyramid and stacks subgroups within each side, for any layer. The side comes from the new `side` aesthetic, or from `fill` when `side` is not mapped.
