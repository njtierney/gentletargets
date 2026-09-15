# CHAPTER 4 — _targets.R
#
# Compare this against 02-functions.R. The names are the same, the calls are the
# same, and the order is the same. Every line gained `|> tar_target()`.
#
# That is the whole reveal: working with targets is working with functions, with
# one extra step. `x |> tar_target()` IS `tar_target(x)`, because the native pipe
# is a parse-time rewrite.

library(targets)
library(tarchetypes)

tar_option_set(packages = c("dplyr", "ggplot2", "arrow", "readr"))
tar_source("R/")

tar_assign({
  toad_path <- "data/cane-toad-to-1999.parquet" |> tar_file()

  occurrences_raw <- read_occurrences(toad_path) |> tar_target()

  occurrences_clean <- clean_occurrences(occurrences_raw) |> tar_target()

  toad_front <- front_by_decade(occurrences_clean) |> tar_target()

  front_model <- fit_front(toad_front) |> tar_target()

  toad_speed <- front_speed(front_model) |> tar_target()
})

# Then:
#   tar_make()          build it
#   tar_visnetwork()    the graph they failed to draw in chapter 1
#   tar_read(toad_front)
#
# Change clean_occurrences() and run tar_outdated() BEFORE tar_make().
# Predict first, then look. That is the exercise this course is built on.
