pyramid_plot <- function(data = pyramid_data()) {
  ggplot2::ggplot(data, ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid()
}

panel_params <- function(p) {
  ggplot2::ggplot_build(p)$layout$panel_params[[1]]
}

# Layer data in panel coordinates, as the geom draws it.
drawn_rows <- function(p, i = 1) {
  b <- ggplot2::ggplot_build(p)
  b$layout$coord$transform(b$data[[i]], b$layout$panel_params[[1]])
}

test_that("the value axis is labelled with absolute values", {
  p <- pyramid_plot() +
    ggplot2::scale_x_continuous(breaks = c(-200, -100, 0, 100, 200)) +
    coord_pyramid()

  expect_equal(
    panel_params(p)$x$get_labels(),
    c("200", "100", "0", "100", "200")
  )
})

test_that("the value axis is symmetric unless asked otherwise", {
  symmetric <- panel_params(pyramid_plot() + coord_pyramid())
  expect_equal(symmetric$x$dimension(), c(-1, 1) * 220 * 1.1)

  asymmetric <- panel_params(pyramid_plot() + coord_pyramid(symmetric = FALSE))
  expect_equal(asymmetric$x$dimension(), c(-220, 210) + c(-1, 1) * 430 * 0.05)

  limited <- panel_params(
    pyramid_plot() + coord_pyramid(xlim = c(-500, 300), expand = FALSE)
  )
  expect_equal(limited$x$dimension(), c(-500, 300))
})

test_that("a gap separates the two sides at equal scale", {
  d <- drawn_rows(pyramid_plot() + coord_pyramid(gap = 0.2))
  left <- d$xmin < 0.5

  expect_equal(d$xmax[left], rep(0.4, 4))
  expect_equal(d$xmin[!left], rep(0.6, 4))
  expect_equal((0.4 - min(d$xmin)) / (max(d$xmax) - 0.6), 220 / 210)
})

test_that("a zero on the left side stays on the left of the gap", {
  df <- pyramid_data()
  df$n[4] <- 0
  p <- pyramid_plot(df) +
    ggplot2::geom_text(ggplot2::aes(label = n), position = "pyramid") +
    coord_pyramid(gap = 0.2)
  bars <- drawn_rows(p, 1)
  labels <- drawn_rows(p, 2)

  expect_equal(bars$xmin[bars$xmin == bars$xmax], 0.4)
  expect_equal(labels$x[labels$label == 0], 0.4)
})

test_that("a gap draws a break at zero on both inner edges", {
  p <- pyramid_plot() +
    ggplot2::scale_x_continuous(
      breaks = c(-200, 0, 200),
      labels = c("a", "b", "c")
    )

  closed <- panel_params(p + coord_pyramid())
  expect_equal(closed$x$get_labels(), c("a", "b", "c"))

  open <- panel_params(p + coord_pyramid(gap = 0.2))
  expect_equal(1 / open$x$get_breaks(), 1 / c(-200, -0, 0, 200))
  expect_equal(open$x$get_labels(), c("a", "b", "b", "c"))
})

test_that("`age_axis` moves the age scale", {
  build <- function(age_axis) {
    ggplot2::ggplot_build(pyramid_plot() + coord_pyramid(age_axis = age_axis))
  }

  expect_equal(build("right")$layout$panel_scales_y[[1]]$position, "right")
  expect_s3_class(
    build("both")$layout$panel_scales_y[[1]]$secondary.axis,
    "AxisSecondary"
  )
})

test_that("coord_pyramid() places the age axis", {
  p <- pyramid_plot() + ggplot2::labs(y = NULL)

  vdiffr::expect_doppelganger(
    "age axis in the centre",
    p + coord_pyramid(age_axis = "centre")
  )
  vdiffr::expect_doppelganger(
    "age axis on both sides",
    p + coord_pyramid(age_axis = "both", gap = 0.05)
  )
  vdiffr::expect_doppelganger(
    "age axis on the right",
    p + coord_pyramid(age_axis = "right")
  )
})

test_that("`age_axis = \"centre\"` opens a gap by default", {
  expect_equal(coord_pyramid(age_axis = "center")$age_axis, "centre")
  expect_equal(coord_pyramid(age_axis = "centre")$gap, 0.12)
  expect_equal(coord_pyramid()$gap, 0)
})

test_that("coord_pyramid() checks its arguments", {
  expect_snapshot(coord_pyramid(age_axis = "top"), error = TRUE)
  expect_snapshot(coord_pyramid(gap = 1), error = TRUE)
  expect_snapshot(coord_pyramid(symmetric = NA), error = TRUE)
})

test_that("coord_pyramid() needs the values on the x axis", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(age, n, fill = sex)) +
    geom_pyramid() +
    coord_pyramid()

  expect_snapshot(error = TRUE, ggplot2::ggplot_build(p))
})

test_that("labels are the same on both sides despite rounding noise", {
  df <- transform(pyramid_data(), n = n / 4400)
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid() +
    ggplot2::scale_x_continuous(
      breaks = c(-0.05 * (1 + 4 * .Machine$double.eps), 0, 0.05),
      labels = scales::label_percent()
    ) +
    coord_pyramid()

  expect_equal(panel_params(p)$x$get_labels(), c("5%", "0%", "5%"))
})
