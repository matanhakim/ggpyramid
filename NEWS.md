# ggpyramid (development version)

* `coord_pyramid()` is a coordinate system for pyramids. It labels the value axis without the minus sign on the left side, makes it symmetric around zero, and places the age axis on the left, on the right, on both sides or in a gap in the centre.
* `geom_pyramid()` and `stat_pyramid()` draw the bars of a population pyramid. They count individual records or sum a mapped value, and `denominator` shows the bars as proportions of the panel or of each side.
* `position_pyramid()` mirrors one side of the pyramid and stacks subgroups within each side, for any layer. The side comes from the new `side` aesthetic, or from `fill` when `side` is not mapped.
