# Position scales for the value axis of a pyramid

`scale_x_pyramid()` and `scale_y_pyramid()` are continuous position
scales that label the value axis of a pyramid without the minus sign and
extend it equally far on both sides of zero.
[`coord_pyramid()`](https://matanhakim.github.io/ggpyramid/reference/coord_pyramid.md)
does the same for a horizontal pyramid, along with placing the age axis;
these scales serve a vertical pyramid, or a plot that needs another
coordinate system.

## Usage

``` r
scale_x_pyramid(..., labels = waiver(), limits = NULL, symmetric = TRUE)

scale_y_pyramid(..., labels = waiver(), limits = NULL, symmetric = TRUE)
```

## Arguments

- ...:

  Other arguments passed on to
  [`ggplot2::scale_x_continuous()`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)
  or
  [`ggplot2::scale_y_continuous()`](https://ggplot2.tidyverse.org/reference/scale_continuous.html),
  such as `breaks`, `expand` or `position`.

- labels:

  Labels for the breaks, applied to their absolute values. One of:

  - a function that takes the breaks and returns labels, such as
    [`scales::label_comma()`](https://scales.r-lib.org/reference/label_number.html),
    or a formula such as `~ .x / 1000`;

  - the default,
    [`waiver()`](https://ggplot2.tidyverse.org/reference/waiver.html),
    for the usual number format;

  - a character vector of labels, used as given;

  - `NULL` for no labels.

- limits:

  One of:

  - `NULL` to use the default scale range

  - A numeric vector of length two providing limits of the scale. Use
    `NA` to refer to the existing minimum or maximum

  - A function that accepts the existing (automatic) limits and returns
    new limits. Also accepts rlang
    [lambda](https://rlang.r-lib.org/reference/as_function.html)
    function notation. Note that setting limits on positional scales
    will **remove** data outside of the limits. If the purpose is to
    zoom, use the limit argument in the coordinate system (see
    [`coord_cartesian()`](https://ggplot2.tidyverse.org/reference/coord_cartesian.html)).

- symmetric:

  If `TRUE`, the limits extend equally far on both sides of zero.
  Ignored when `limits` is set.

## Value

A ggplot2 scale.

## See also

[`coord_pyramid()`](https://matanhakim.github.io/ggpyramid/reference/coord_pyramid.md),
which labels and limits the value axis of a horizontal pyramid.

## Examples

``` r
library(ggplot2)

france <- subset(europe_pop, country == "France" & year == 2024)

# A vertical pyramid, with age on x
ggplot(france, aes(x = age, y = population, fill = sex)) +
  geom_pyramid() +
  scale_y_pyramid(labels = scales::label_comma()) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
```
