# Mirror one side of a population pyramid

`position_pyramid()` draws the rows of one side in the negative
direction, so that the two sides of a pyramid extend away from a shared
age axis, and stacks subgroups within each side. It works with any
layer, so bars, labels, points and lines all land on the same side.

## Usage

``` r
position_pyramid(left = NULL, stack = TRUE, vjust = 1, reverse = FALSE)
```

## Arguments

- left:

  The value of the side variable drawn on the left in this layer.
  Overrides the `left` of
  [`coord_pyramid()`](https://matanhakim.github.io/ggpyramid/reference/coord_pyramid.md),
  which sets the side for every layer at once. Without either, the first
  level is drawn on the left when the side variable is a factor, and the
  first value in sorted order otherwise.

- stack:

  If `TRUE`, rows that share an age group and a side are stacked away
  from the centre, as in
  [`ggplot2::position_stack()`](https://ggplot2.tidyverse.org/reference/position_stack.html).
  If `FALSE`, they overlap, which suits a comparison layer drawn over
  the bars. Ranges that do not start at zero, such as error bars, are
  never stacked.

- vjust, reverse:

  Passed on to the stacking. See
  [`ggplot2::position_stack()`](https://ggplot2.tidyverse.org/reference/position_stack.html).

## Value

A ggproto object of class `PositionPyramid`.

## Aesthetics

`position_pyramid()` understands the `side` aesthetic, which assigns
each row to one of the two sides. When `side` is not mapped, the side
comes from `fill`, and failing that from `colour`. Map `side` explicitly
when `fill` shows subgroups, for example
`aes(fill = region, side = sex)`. Rows with a missing side are drawn on
the right.

## Signed values

The data you supply stays positive. Inside the plot, values on the left
side are negative, so a manual reference line or limit on that side
carries a minus sign: `geom_vline(xintercept = -100)` or
`scale_x_continuous(limits = c(-500, 500))`.
[`coord_pyramid()`](https://matanhakim.github.io/ggpyramid/reference/coord_pyramid.md)
shows the axis labels without the sign; with another coordinate system
or in a vertical pyramid, use
[`scale_x_pyramid()`](https://matanhakim.github.io/ggpyramid/reference/scale_x_pyramid.md)
or
[`scale_y_pyramid()`](https://matanhakim.github.io/ggpyramid/reference/scale_x_pyramid.md).

## Orientation

The axis that does not hold age is the one that gets mirrored. Age is
the discrete axis when only one of them is discrete, and the y axis when
both are continuous, so a pyramid is horizontal unless age is mapped to
`x`. A mapped `hjust` (or `vjust` in a vertical pyramid) is mirrored as
well, so text justified away from the bar end on the right does the same
on the left. A fixed `hjust` set outside
[`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html) is
not mirrored.

## See also

[`geom_pyramid()`](https://matanhakim.github.io/ggpyramid/reference/geom_pyramid.md)
for the bars of a pyramid, and
[`coord_pyramid()`](https://matanhakim.github.io/ggpyramid/reference/coord_pyramid.md)
for its axes.

## Examples

``` r
library(ggplot2)

pop <- data.frame(
  age = factor(rep(c("0-19", "20-39", "40-59", "60+"), 2)),
  sex = factor(rep(c("Male", "Female"), each = 4), c("Male", "Female")),
  n = c(220, 200, 160, 90, 210, 205, 170, 120)
)

# Any geom can be mirrored
ggplot(pop, aes(x = n, y = age, fill = sex)) +
  geom_col(position = position_pyramid()) +
  geom_text(aes(label = n, hjust = -0.2), position = "pyramid") +
  scale_x_continuous(expand = expansion(mult = 0.15)) +
  coord_pyramid()


# Subgroups stack within each side
pop2 <- rbind(transform(pop, group = "A"), transform(pop, group = "B"))
ggplot(pop2, aes(x = n, y = age, fill = group, side = sex)) +
  geom_col(position = "pyramid") +
  coord_pyramid(left = "Female")
```
