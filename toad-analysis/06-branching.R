# CHAPTER 6 — twelve species
#
# The other eleven arrive, and branching finally has a reason to exist. One
# function per species, run twelve times, without writing it twelve times.
#
# crew goes on at the end, because it is only worth it once there is something
# to parallelise.

library(targets)
library(tarchetypes)
library(crew)

tar_option_set(
  packages = c("dplyr", "ggplot2", "arrow", "readr"),
  controller = crew_controller_local(workers = 4),
  # one species failing should not kill the other eleven
  error = "trim"
)
tar_source("R/")

tar_assign({
  species_files <- dir_species_files("data") |> tar_files()

  # dynamic branching: one branch per file, no names needed up front
  occurrences <- read_occurrences(species_files) |>
    tar_target(pattern = map(species_files))

  cleaned <- clean_occurrences(occurrences) |>
    tar_target(pattern = map(occurrences))

  fronts <- front_by_decade(cleaned) |>
    tar_target(pattern = map(cleaned))

  speeds <- front_speed(fit_front(fronts)) |>
    tar_target(pattern = map(fronts))

  # one row per species, for the comparison
  speed_table <- bind_speeds(speeds, species_files) |> tar_target()
})

# Worth showing: tar_make() with a controller, then again without, and the
# wall clock difference. Also that total CPU time goes UP while wall clock
# goes down, which surprises people.
