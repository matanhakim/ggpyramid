text_plot <- function(...) {
  ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid_text(...)
}

test_that("labels show the counts at the outer end of each bar", {
  d <- layer_rows(text_plot())

  expect_equal(d$label, d$count)
  expect_equal(d$x, c(-220, -200, -160, -90, 210, 205, 170, 120))
})

test_that("labels follow `denominator` and `labels`", {
  d <- layer_rows(text_plot(denominator = "side"))
  expect_equal(d$label, d$prop)

  grob <- ggplot2::layer_grob(text_plot(labels = ~ paste0(.x, "!")))[[1]]
  expect_true(all(endsWith(grob$label, "!")))
})

test_that("labels are justified away from the centre on both sides", {
  outside <- ggplot2::layer_grob(text_plot())[[1]]
  left <- ggplot2::layer_data(text_plot())$x < 0
  expect_equal(outside$hjust[left], rep(1, 4))
  expect_equal(outside$hjust[!left], rep(0, 4))

  inside <- ggplot2::layer_grob(text_plot(place = "inside"))[[1]]
  expect_equal(inside$hjust, 1 - outside$hjust)
})

test_that("rotated labels in a vertical pyramid are justified with the text", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(age, n, fill = sex)) +
    geom_pyramid_text(angle = 90)
  grob <- ggplot2::layer_grob(p)[[1]]

  expect_setequal(grob$hjust, c(0, 1))
  expect_equal(unique(grob$vjust), 0.5)
})

test_that("geom_pyramid_text() draws labels on a pyramid", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid() +
    geom_pyramid_text() +
    geom_pyramid_text(place = "inside", colour = "white") +
    coord_pyramid(age_axis = "centre")

  expect_doppelganger("labels outside and inside", p)
})

test_that("geom_pyramid_text() checks its arguments", {
  expect_snapshot(geom_pyramid_text(place = "middle"), error = TRUE)
  expect_snapshot(geom_pyramid_text(padding = "1mm"), error = TRUE)
})

test_that("`labels` must be a function or a formula", {
  expect_snapshot(geom_pyramid_text(labels = "a"), error = TRUE)
})
