test_that("scale_x_pyramid() labels absolute values", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid() +
    scale_x_pyramid(breaks = c(-200, 0, 200))
  x <- ggplot2::ggplot_build(p)$layout$panel_scales_x[[1]]

  expect_equal(x$get_labels(), c("200", "0", "200"))
  expect_equal(x$get_limits(), c(-220, 220))
})

test_that("scale_y_pyramid() takes label functions and formulas", {
  scale <- scale_y_pyramid(labels = ~ paste0(.x, "k"), symmetric = FALSE)
  scale$train(c(-3, 5))

  expect_equal(scale$get_labels(c(-2, 0, 4)), c("2k", "0k", "4k"))
  expect_equal(scale$get_limits(), c(-3, 5))
})

test_that("a labels vector is used as given", {
  scale <- scale_x_pyramid(breaks = c(-1, 1), labels = c("a", "b"))
  scale$train(c(-1, 1))

  expect_equal(scale$get_labels(), c("a", "b"))
})

test_that("scale_x_pyramid() checks its arguments", {
  expect_snapshot(scale_x_pyramid(labels = 1), error = TRUE)
  expect_snapshot(scale_x_pyramid(symmetric = "yes"), error = TRUE)
})
