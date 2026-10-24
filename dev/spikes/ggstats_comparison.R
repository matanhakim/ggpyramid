# Throwaway comparison from the design research (24.10.2026), not package code.
# Needs ggstats (>= 0.14.0) and patchwork, which the package does not depend on.

suppressMessages({library(ggplot2); library(ggstats); library(patchwork)})
set.seed(1)
ages <- c(paste0(seq(0, 80, 5), "-", seq(4, 84, 5)), "85+")
pop <- expand.grid(age = factor(ages, levels = ages), sex = factor(c("Male", "Female"), levels = c("Male", "Female")))
pop$n <- round(1000 * exp(-as.integer(pop$age) / 9) * runif(nrow(pop), .9, 1.1))
th <- theme_minimal(base_size = 9) + theme(legend.position = "none", plot.title = element_text(size = 9, face = "bold"))

# 1. defaults: what values, which labels
p1 <- ggplot(pop, aes(y = age, fill = sex, weight = n)) + geom_pyramid() + th + ggtitle("1. ggstats defaults")
b1 <- ggplot_build(p1); cat("1 x range:", b1$layout$panel_params[[1]]$x.range, " sum|x|:", sum(abs(b1$data[[1]]$xmax - b1$data[[1]]$xmin)), "\n")

# 2. one category missing at one age (no males aged 85+)
pop2 <- pop[!(pop$age == "85+" & pop$sex == "Male"), ]
p2 <- ggplot(pop2, aes(y = age, fill = sex, weight = n)) + geom_pyramid() +
  scale_x_continuous(labels = label_percent_abs()) + th + ggtitle("2. no males 85+ (default complete)")
b2 <- ggplot_build(p2); d <- b2$data[[1]]; print(d[d$y == 18, c("y", "xmin", "xmax", "fill")])

# 3. subgroups within each sex (e.g. population group)
pop3 <- merge(pop, data.frame(grp = c("A", "B")))
pop3$n <- round(pop3$n * ifelse(pop3$grp == "A", .7, .3))
p3 <- ggplot(pop3, aes(y = age, fill = interaction(grp, sex), weight = n)) + geom_pyramid() +
  scale_x_continuous(labels = label_percent_abs()) + th + ggtitle("3. 4 fill categories (grp x sex)")
b3 <- ggplot_build(p3); d <- b3$data[[1]]; print(d[d$y == 1, c("xmin", "xmax", "fill")])
# 3b. stacking by grp with sex as side is not expressible: fill = grp only
p3b <- ggplot(pop3, aes(y = age, fill = grp, weight = n)) + geom_pyramid() + th + ggtitle("3b. fill = grp")
b3b <- ggplot_build(p3b); d <- b3b$data[[1]]; print(d[d$y == 1, c("xmin", "xmax", "fill")])

# 4. side order: can Female go left without re-levelling?
cat("4. args of geom_pyramid:", paste(names(formals(geom_pyramid)), collapse = ", "), "\n")
cat("   args of position_diverging:", paste(names(formals(position_diverging)), collapse = ", "), "\n")

# 5. adding a comparison outline with position = "diverging"
ggsave("ggstats_cases.png", (p1 | p2) / (p3 | p3b), width = 9, height = 7, dpi = 100, device = ragg::agg_png)
