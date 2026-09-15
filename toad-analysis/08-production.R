# CHAPTER 8 — what it looks like organised
#
# Nothing new is computed. What changed is that a stranger could open this file
# and know what the analysis does and which file in R/ to read next.
#
# toad-analysis/
#   README.md        what it is, why, how to run it
#   _targets.R       this file, and nothing else
#   packages.R       every library() call, in one place
#   conflicts.R      sourced by the last line of packages.R
#   R/               one concern per file
#   data/            inputs
#   output/          everything the pipeline writes

library(targets)
library(tarchetypes)

source("packages.R")
tar_source("R/")

tar_assign({
  # ---- inputs ----------------------------------------------------------
  toad_path <- "data/cane-toad-all.parquet" |> tar_file()
  front_km_per_degree <- 107 |> tar_target()
  thinning_km <- 10 |> tar_target()

  # ---- the invasion front ---------------------------------------------
  occurrences_raw <- read_occurrences(toad_path) |> tar_target()
  occurrences_clean <- clean_occurrences(occurrences_raw) |> tar_target()
  toad_front <- front_by_decade(occurrences_clean) |> tar_target()
  front_model <- fit_front(toad_front) |> tar_target()
  toad_speed <- front_speed(front_model, front_km_per_degree) |> tar_target()

  # ---- where they could go --------------------------------------------
  occurrences_thinned <- thin_records(occurrences_clean, thinning_km) |>
    tar_target()
  toad_points <- as_spatvector(occurrences_thinned) |> tar_terra_vect()
  bioclim_now <- get_bioclim_australia() |> tar_terra_rast()
  sdm <- fit_sdm(extract_covariates(toad_points, bioclim_now)) |> tar_target()
  suitability <- predict_sdm(sdm, bioclim_now) |> tar_terra_rast()

  # ---- outputs ---------------------------------------------------------
  checks <- stop_if_invalid(toad_front) |> tar_target(deployment = "main")
  report <- tar_quarto(path = "toad-report.qmd")
})

# Notice what moved into the pipeline: the 107 and the 10. Both were magic
# numbers inside functions in chapter 2. As targets they show up in the graph,
# tar_read() works on them, and changing one invalidates exactly what used it.
#
# That is the argument for parameters-as-targets, and it lands better here than
# it would have in chapter 4.
