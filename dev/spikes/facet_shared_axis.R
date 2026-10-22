# Throwaway feasibility prototype from the design research (22.10.2026), not package code.
# Run from dev/spikes/. Figures are in dev/fig/.

# Needs ggh4x (>= 0.3.1), which the package does not depend on.
suppressMessages({library(ggplot2); library(ggh4x)})
df <- data.frame(age=factor(rep(1:5,2)), sex=rep(c("F","M"),each=5), n=c(10,20,30,40,50, 5,15,25,35,45))
base <- ggplot(df, aes(n, age, fill=sex)) + geom_col(show.legend=FALSE)
# A: core ggplot2 only: two facets, left x reversed not possible per panel in core -> use negative data
df$n2 <- ifelse(df$sex=="F", -df$n, df$n)
pA <- ggplot(df, aes(n2, age, fill=sex)) + geom_col(show.legend=FALSE) + scale_x_continuous(labels=abs) +
  facet_wrap(~sex, scales="free_x", axes="all_y", axis.labels="all_y") + theme(panel.spacing.x = unit(0, "pt"))
# B: ggh4x per-panel scales: left panel reversed x and y-axis on the right; right panel no y labels
pB <- base + facet_wrap(~sex, scales="free") +
  facetted_pos_scales(x = list(scale_x_reverse(), scale_x_continuous()),
                      y = list(scale_y_discrete(position="right"), scale_y_discrete(labels=NULL))) +
  theme(panel.spacing.x = unit(0, "pt"), axis.ticks.length.y = unit(0,"pt"))
for (nm in c("A","B")) { p <- get(paste0("p", nm)); r <- tryCatch({png(sprintf("out/shared_%s.png", nm), 600, 380); print(p); dev.off(); "OK"}, error=function(e){try(dev.off(),silent=TRUE); conditionMessage(e)}); cat(nm, r, "\n") }
