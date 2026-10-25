test_that("the first factor level is mirrored to the left", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, fill = sex)) +
    ggplot2::geom_col(position = position_pyramid())
  d <- layer_rows(p)

  male <- d$fill == unique(d$fill)[1]
  expect_equal(d$xmin[male], -c(220, 200, 160, 90))
  expect_equal(d$xmax[male], rep(0, 4))
  expect_equal(d$xmin[!male], rep(0, 4))
  expect_equal(d$xmax[!male], c(210, 205, 170, 120))
})

test_that("`left` chooses the mirrored side", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, side = sex)) +
    ggplot2::geom_col(position = position_pyramid(left = "Female"))
  d <- layer_rows(p)

  expect_equal(d$xmin[d$side == "Female"], -c(210, 205, 170, 120))
  expect_equal(d$xmax[d$side == "Male"], c(220, 200, 160, 90))
})

test_that("`left` in coord_pyramid() reaches every layer", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid() +
    geom_pyramid_text() +
    geom_pyramid_outline() +
    coord_pyramid(left = "Female")

  for (i in 1:3) {
    d <- ggplot2::layer_data(p, i)
    female <- d$fill == unique(d$fill[d$x < 0])
    expect_true(all(d$x[female] <= 0), label = paste("layer", i))
    expect_true(all(d$x[!female] >= 0), label = paste("layer", i))
    expect_equal(sort(d$x[female & d$x != 0]), sort(-c(210, 205, 170, 120)))
  }
})

test_that("`left` in position_pyramid() overrides coord_pyramid()", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, side = sex)) +
    ggplot2::geom_col(position = "pyramid") +
    ggplot2::geom_col(position = position_pyramid(left = "Male")) +
    coord_pyramid(left = "Female")

  d1 <- layer_rows(p, 1)
  d2 <- layer_rows(p, 2)
  expect_equal(d1$xmin[d1$side == "Female"], -c(210, 205, 170, 120))
  expect_equal(d2$xmin[d2$side == "Male"], -c(220, 200, 160, 90))
})

test_that("coord_pyramid() keeps layers on a subset on the same side", {
  df <- transform(pyramid_data(), sex = as.character(sex))
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, side = sex)) +
    ggplot2::geom_col(position = "pyramid") +
    ggplot2::geom_point(
      data = subset(df, sex == "Male"),
      position = "pyramid"
    ) +
    coord_pyramid(left = "Female")

  expect_true(all(ggplot2::layer_data(p, 2)$x > 0))
})

test_that("a character side mirrors its first value in sorted order", {
  df <- transform(pyramid_data(), sex = as.character(sex))
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, side = sex)) +
    ggplot2::geom_col(position = "pyramid")
  d <- layer_rows(p)

  expect_equal(unique(d$side[d$xmax <= 0]), "Female")
})

test_that("the side is kept when one category is missing from an age group", {
  df <- pyramid_data()[-4, ]
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, fill = sex)) +
    ggplot2::geom_col(position = "pyramid")
  d <- layer_rows(p)

  expect_equal(d$xmin[d$y == 4], 0)
  expect_equal(d$xmax[d$y == 4], 120)
})

test_that("subgroups stack within each side", {
  df <- rbind(
    transform(pyramid_data(), group = "a"),
    transform(pyramid_data(), group = "b")
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, fill = group, side = sex)) +
    ggplot2::geom_col(position = "pyramid")
  d <- layer_rows(p)
  d <- d[d$y == 1, ]

  expect_equal(sort(d$xmin), c(-440, -220, 0, 210))
  expect_equal(sort(d$xmax), c(-220, 0, 210, 420))
})

test_that("`stack = FALSE` overlaps rows on the same side", {
  df <- rbind(
    transform(pyramid_data(), group = "a"),
    transform(pyramid_data(), group = "b")
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, fill = group, side = sex)) +
    ggplot2::geom_col(position = position_pyramid(stack = FALSE))
  d <- layer_rows(p)

  expect_equal(sort(unique(d$xmin[d$y == 1])), c(-220, 0))
})

test_that("a layer with one side is mirrored without stacking", {
  df <- pyramid_data()[1:4, ]
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, side = sex)) +
    ggplot2::geom_col(position = "pyramid")
  d <- layer_rows(p)

  expect_equal(d$xmin, -c(220, 200, 160, 90))
  expect_equal(as.vector(d$y), 1:4)
})

test_that("stacked labels sit at the same relative place on both sides", {
  df <- rbind(
    transform(pyramid_data(), group = "a"),
    transform(pyramid_data(), group = "b")
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, side = sex, group = group)) +
    ggplot2::geom_text(
      ggplot2::aes(label = n),
      position = position_pyramid(vjust = 0.5)
    )
  d <- layer_rows(p)
  d <- d[d$y == 1, ]

  expect_equal(sort(d$x), c(-330, -110, 105, 315))
})

test_that("mapped hjust is mirrored on the left", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, side = sex)) +
    ggplot2::geom_text(
      ggplot2::aes(label = n, hjust = -0.2),
      position = "pyramid"
    )
  d <- layer_rows(p)

  expect_equal(d$x, c(-220, -200, -160, -90, 210, 205, 170, 120))
  expect_equal(d$hjust, rep(c(1.2, -0.2), each = 4))
})

test_that("character justification is mirrored", {
  expect_equal(
    mirror_just(
      c("left", "right", "inward", "left"),
      c(TRUE, TRUE, TRUE, FALSE)
    ),
    c("right", "left", "inward", "left")
  )
})

test_that("the value axis is trained on both signs", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, fill = sex)) +
    ggplot2::geom_col(position = "pyramid")
  range <- ggplot2::get_panel_scales(p)$x$get_limits()

  expect_equal(range, c(-220, 210))
})

test_that("a vertical pyramid mirrors the y axis", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(age, n, fill = sex)) +
    ggplot2::geom_col(position = "pyramid")
  d <- layer_rows(p, age = "x")

  expect_equal(d$ymin[1:4], -c(220, 200, 160, 90))
  expect_equal(d$xmin[1:4], d$xmin[5:8])
})

test_that("two continuous axes give a horizontal pyramid", {
  df <- transform(pyramid_data(), age = as.integer(age))
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, side = sex)) +
    ggplot2::geom_point(position = "pyramid")
  d <- layer_rows(p)

  expect_equal(d$x, c(-220, -200, -160, -90, 210, 205, 170, 120))
  expect_equal(d$y, df$age)
})

test_that("the side aesthetic is accepted without a warning", {
  p <- ggplot2::ggplot(pyramid_data()) +
    ggplot2::geom_col(
      ggplot2::aes(n, age, side = sex),
      position = position_pyramid()
    )

  expect_no_warning(ggplot2::ggplot_build(p))
})

test_that("a layer without a side variable fails", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age)) +
    ggplot2::geom_col(position = "pyramid")

  expect_snapshot(ggplot2::ggplot_build(p), error = TRUE)
})

test_that("a side variable with more than two values fails", {
  df <- transform(pyramid_data(), sex = rep(c("a", "b", "c", "d"), 2))
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, side = sex)) +
    ggplot2::geom_col(position = "pyramid")

  expect_snapshot(ggplot2::ggplot_build(p), error = TRUE)
})

test_that("an unknown `left` value warns", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, side = sex)) +
    ggplot2::geom_col(position = position_pyramid(left = "female"))

  expect_snapshot(d <- ggplot2::layer_data(p))
  expect_true(all(d$xmin >= 0))
})

test_that("arguments are checked", {
  expect_snapshot(position_pyramid(left = c("Male", "Female")), error = TRUE)
  expect_snapshot(position_pyramid(stack = "yes"), error = TRUE)
  expect_snapshot(coord_pyramid(left = NA), error = TRUE)
})

test_that("a zero on the left side stays on the left side", {
  df <- pyramid_data()
  df$n[4] <- 0
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, fill = sex)) +
    ggplot2::geom_col(position = "pyramid", width = 1)
  d <- layer_rows(p)

  expect_equal(1 / c(d$xmin[4], d$xmax[4]), c(-Inf, -Inf))
  expect_equal(d$xmin[8], 0)
})
