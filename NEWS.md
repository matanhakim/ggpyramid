# ggpyramid 0.1.0

* Initial CRAN submission.
* `coord_pyramid()` is a coordinate system for horizontal pyramids. It labels the value axis without the minus sign on the left side, makes it symmetric around zero, and places the age axis on the left, on the right, on both sides or in a gap in the centre. Its `left` argument chooses the side drawn on the left for every layer of the plot.
* `europe_pop` holds the population of France, Ireland, Italy and Poland in 2004 and 2024 by age group and sex, from Eurostat, for examples.
* `geom_pyramid()` and `stat_pyramid()` draw the bars of a population pyramid. They count individual records or sum a mapped value, and `denominator` shows the bars as proportions of the panel or of each side.
* `geom_pyramid_outline()` draws a pyramid as a stepped outline, to compare a second population with the bars.
* `geom_pyramid_text()` labels the end of each bar, outside or inside it, on both sides.
* `position_pyramid()` mirrors one side of the pyramid and stacks subgroups within each side, for any layer. The side comes from the new `side` aesthetic, or from `fill` when `side` is not mapped.
* `scale_x_pyramid()` and `scale_y_pyramid()` label the value axis with absolute values and make it symmetric, for vertical pyramids and other coordinate systems.
* `theme_pyramid()` is a minimal theme for pyramids, with the legend on top.
