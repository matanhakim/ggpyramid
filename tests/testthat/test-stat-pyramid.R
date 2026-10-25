test_that("aggregated values are summed within each age group", {
  df <- rbind(pyramid_data(), pyramid_data())
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid()
  d <- layer_rows(p)

  expect_equal(d$count, 2 * pyramid_data()$n)
  expect_equal(d$xmin[1:4], -2 * c(220, 200, 160, 90))
})

test_that("individual records are counted", {
  df <- pyramid_data()
  people <- df[rep(seq_len(nrow(df)), df$n), c("age", "sex")]
  p <- ggplot2::ggplot(people, ggplot2::aes(y = age, fill = sex)) +
    geom_pyramid()
  d <- layer_rows(p)

  expect_equal(d$count, df$n)
  expect_equal(d$xmax[5:8], df$n[5:8])
})

test_that("weight multiplies the counted rows", {
  p <- ggplot2::ggplot(
    pyramid_data(),
    ggplot2::aes(y = age, fill = sex, weight = n)
  ) +
    geom_pyramid()

  expect_equal(layer_rows(p)$count, pyramid_data()$n)
})

test_that("prop is a share of the panel total by default", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid()
  d <- layer_rows(p)

  expect_equal(d$prop, pyramid_data()$n / 1375)
  expect_equal(d$xmax[5:8], pyramid_data()$n[5:8])
})

test_that("`denominator` makes the bars show proportions", {
  df <- pyramid_data()
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid(denominator = "side")
  d <- layer_rows(p)

  expect_equal(d$prop, df$n / rep(c(670, 705), each = 4))
  expect_equal(d$xmin[1:4], -d$prop[1:4])
  expect_equal(d$xmax[5:8], d$prop[5:8])

  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid(denominator = "total")
  expect_equal(layer_rows(p)$xmax[5:8], df$n[5:8] / 1375)
})

test_that("each facet panel has its own denominator", {
  df <- rbind(
    transform(pyramid_data(), year = 2000),
    transform(pyramid_data(), year = 2020, n = 2 * n)
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid(denominator = "total") +
    ggplot2::facet_wrap(ggplot2::vars(year))
  d <- layer_rows(p)

  expect_equal(d$prop[d$PANEL == 1], d$prop[d$PANEL == 2])
  expect_equal(sum(d$prop[d$PANEL == 1]), 1)
})

test_that("the value axis is named after what the bars show", {
  df <- pyramid_data()
  people <- df[rep(seq_len(nrow(df)), df$n), c("age", "sex")]
  label_x <- function(layer) {
    p <- ggplot2::ggplot(people, ggplot2::aes(y = age, fill = sex)) + layer
    as.vector(ggplot2::ggplot_build(p)$plot@labels$x)
  }

  expect_equal(label_x(geom_pyramid()), "count")
  expect_equal(label_x(geom_pyramid(denominator = "side")), "prop")
  expect_equal(label_x(stat_pyramid()), "count")
})

test_that("other layers can use the stat", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid(denominator = "side") +
    ggplot2::geom_text(
      ggplot2::aes(label = after_stat(prop)),
      stat = "pyramid",
      position = "pyramid",
      denominator = "side"
    )
  bars <- ggplot2::layer_data(p, 1)
  labels <- ggplot2::layer_data(p, 2)

  expect_equal(labels$x, bars$xmin + bars$xmax)
})

test_that("a numeric age gives a horizontal pyramid", {
  df <- transform(pyramid_data(), age = as.integer(age))
  p <- ggplot2::ggplot(df, ggplot2::aes(n, age, fill = sex)) +
    geom_pyramid()
  d <- layer_rows(p)

  expect_true(all(d$flipped_aes))
  expect_equal(sort(unique(d$y)), 1:4)
  expect_equal(d$xmin[1:4], -c(220, 200, 160, 90))
})

test_that("a vertical pyramid counts along x", {
  p <- ggplot2::ggplot(pyramid_data(), ggplot2::aes(age, n, fill = sex)) +
    geom_pyramid()
  d <- layer_rows(p, age = "x")

  expect_false(any(d$flipped_aes))
  expect_equal(d$ymin[1:4], -c(220, 200, 160, 90))
})

test_that("an unknown denominator fails", {
  expect_snapshot(geom_pyramid(denominator = "sex"), error = TRUE)
  expect_snapshot(stat_pyramid(denominator = "sex"), error = TRUE)
})
