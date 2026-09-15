# CHAPTER 2 — the same work, as named calls
#
# Written top-down: these calls were sketched before any of the bodies existed.
# Verbs live in R/, nouns live here.
#
# R/
#   read_occurrences.R   clean_occurrences.R   front_by_decade.R
#   fit_front.R          front_speed.R         plot_front.R

library(dplyr)
library(ggplot2)
library(arrow)
library(readr)
library(fs)

lapply(dir_ls("R", glob = "*.R"), source)

toad_path <- "data/cane-toad-to-1999.parquet"

occurrences_raw <- read_occurrences(toad_path)

occurrences_clean <- clean_occurrences(occurrences_raw)

toad_front <- front_by_decade(occurrences_clean)

front_model <- fit_front(toad_front)

toad_speed <- front_speed(front_model)

write_csv(toad_front, "output/toad-front.csv")
