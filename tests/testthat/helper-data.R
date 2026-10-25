pyramid_data <- function() {
  data.frame(
    age = factor(rep(c("0-19", "20-39", "40-59", "60+"), 2)),
    sex = factor(rep(c("Male", "Female"), each = 4), c("Male", "Female")),
    n = c(220, 200, 160, 90, 210, 205, 170, 120)
  )
}

# Layer data in a stable order: by side in order of appearance (the first
# factor level first), then along the age axis.
layer_rows <- function(p, i = 1, age = "y") {
  d <- ggplot2::layer_data(p, i)
  side <- if (is.null(d$side)) d$fill else d$side
  d <- d[order(d$PANEL, match(side, unique(side)), d[[age]]), ]
  rownames(d) <- NULL
  d
}
