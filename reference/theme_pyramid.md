# A theme for population pyramids

`theme_pyramid()` is
[`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
adjusted for pyramids. It removes the grid lines that run along the
bars, which the age axis already marks, keeps the major grid lines
across the value axis, and puts the legend above the plot, where it
reads as a heading for the two sides.

## Usage

``` r
theme_pyramid(..., flipped = FALSE)
```

## Arguments

- ...:

  Arguments passed on to
  [`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html),
  such as `base_size` or `base_family`.

- flipped:

  If `FALSE` (the default), the pyramid is horizontal, with age on the y
  axis. Set it to `TRUE` for a vertical pyramid, with age on x.

## Value

A ggplot2 theme.

## Examples

``` r
library(ggplot2)

france <- subset(europe_pop, country == "France" & year == 2024)
ggplot(france, aes(x = population, y = age, fill = sex)) +
  geom_pyramid() +
  coord_pyramid() +
  theme_pyramid()
```
