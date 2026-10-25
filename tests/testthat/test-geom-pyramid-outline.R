steps_of <- function(x, y) {
  outline_steps(data.frame(
    x = x,
    y = y,
    PANEL = factor(1),
    colour = "black",
    linewidth = 0.5,
    linetype = 1,
    alpha = NA
  ))
}

test_that("the outline steps along each age group and back to zero", {
  s <- steps_of(c(1, 2), c(3, 5))

  expect_equal(s$x, c(0.5, 0.5, 1.5, 1.5, 2.5, 2.5))
  expect_equal(s$y, c(0, 3, 3, 5, 5, 0))
  expect_equal(unique(s$group), 1)
})

test_that("the outline drops to zero across a missing age group", {
  s <- steps_of(c(1, 2, 4), c(3, 5, 2))

  expect_equal(s$x, c(0.5, 0.5, 1.5, 1.5, 2.5, 2.5, 3.5, 3.5, 4.5, 4.5))
  expect_equal(s$y, c(0, 3, 3, 5, 5, 0, 0, 2, 2, 0))
})

test_that("each side gets its own line, with zeros of its sign", {
  s <- steps_of(c(1, 1), c(-3, 4))

  expect_length(unique(s$group), 2)
  left <- s[s$group == s$group[s$y < 0][1], ]
  expect_equal(1 / left$y[c(1, nrow(left))], c(-Inf, -Inf))
})

test_that("geom_pyramid_outline() compares two populations", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid() +
    geom_pyramid_outline(
      data = transform(pyramid_data(), n = n * c(1.2, 0.9))
    ) +
    coord_pyramid(gap = 0.1)

  vdiffr::expect_doppelganger("outline over bars", p)
})
