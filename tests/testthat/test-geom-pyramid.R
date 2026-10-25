test_that("geom_pyramid() draws a pyramid", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid() +
    ggplot2::scale_x_continuous(labels = abs)

  vdiffr::expect_doppelganger("basic pyramid", p)
})

test_that("geom_pyramid() stacks subgroups with an explicit side", {
  df <- rbind(
    transform(pyramid_data(), group = "a"),
    transform(pyramid_data(), group = "b", n = n / 2)
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, fill = group, side = sex)) +
    geom_pyramid(colour = "white") +
    ggplot2::scale_x_continuous(labels = abs)

  vdiffr::expect_doppelganger("stacked subgroups", p)
})

test_that("geom_pyramid() passes other stats through", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid(stat = "identity")

  expect_no_warning(d <- ggplot2::layer_data(p))
  expect_equal(d$xmin[1:4], -c(220, 200, 160, 90))
})
