test_that("theme_pyramid() removes the grid lines along the bars", {
  horizontal <- theme_pyramid()
  expect_s3_class(horizontal$panel.grid.major.y, "ggplot2::element_blank")
  expect_null(horizontal$panel.grid.major.x)
  expect_equal(horizontal$legend.position, "top")

  vertical <- theme_pyramid(flipped = TRUE)
  expect_s3_class(vertical$panel.grid.major.x, "ggplot2::element_blank")
})

test_that("theme_pyramid() passes arguments to theme_minimal()", {
  expect_equal(theme_pyramid(base_size = 20)$text$size, 20)
})
