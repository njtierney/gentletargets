# CHAPTER 5 — living in the pipeline
#
# New here: a value and its file are two targets, a writer that returns a path,
# a validation target that fails, and a report that depends on all of it.

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

  # a value and its file are two targets, never fused
  front_plot <- gg_front(toad_front) |> tar_target()
  front_plot_path <- ggsave_return_path(front_plot, "output/toad-front.png") |>
    tar_file()

  # a check that stops, on main so its message reaches the console
  checks <- stop_if_toads_move_backwards(toad_front) |>
    tar_target(deployment = "main")

  report <- tar_quarto(path = "toad-report.qmd")
})

# The exercise: change the year cutoff in clean_occurrences(), then predict
# which of these go stale before running tar_outdated(). Most people get
# toad_speed right and forget the report.
