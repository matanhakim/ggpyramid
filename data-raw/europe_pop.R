# Builds data/europe_pop.rda from the Eurostat dataset demo_pjangroup,
# "Population on 1 January by age group and sex". Eurostat data are reused
# under CC BY 4.0: https://ec.europa.eu/eurostat/about-us/policies/copyright

countries <- c(FR = "France", IE = "Ireland", IT = "Italy", PL = "Poland")
years <- c(2004L, 2024L)
ages <- c(paste0(seq(0, 80, 5), "-", seq(4, 84, 5)), "85+")
age_codes <- c("Y_LT5", paste0("Y", seq(5, 80, 5), "-", seq(9, 84, 5)), "Y_GE85")

url <- paste0(
  "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/",
  "demo_pjangroup?format=JSON&lang=EN&unit=NR&sex=M&sex=F",
  paste0("&geo=", names(countries), collapse = ""),
  paste0("&time=", years, collapse = ""),
  paste0("&age=", age_codes, collapse = "")
)
raw <- jsonlite::fromJSON(url)

# JSON-stat stores the cube as a flat vector indexed in row-major order over
# the dimensions in `raw$id`.
dims <- lapply(raw$id, \(d) names(sort(unlist(raw$dimension[[d]]$category$index))))
names(dims) <- raw$id
cube <- expand.grid(rev(dims), stringsAsFactors = FALSE)[rev(raw$id)]
cube$value <- NA_real_
cube$value[as.integer(names(raw$value)) + 1] <- unlist(raw$value)
stopifnot(!anyNA(cube$value))

europe_pop <- data.frame(
  country = factor(countries[cube$geo], unname(countries)),
  year = as.integer(cube$time),
  age = factor(ages[match(cube$age, age_codes)], ages),
  sex = factor(c(M = "Male", F = "Female")[cube$sex], c("Male", "Female")),
  population = as.integer(cube$value)
)
europe_pop <- europe_pop[
  order(europe_pop$country, europe_pop$year, europe_pop$sex, europe_pop$age),
]
rownames(europe_pop) <- NULL
stopifnot(nrow(europe_pop) == length(countries) * length(years) * 2 * 18)

usethis::use_data(europe_pop, overwrite = TRUE)
