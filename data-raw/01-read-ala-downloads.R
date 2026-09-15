# Read the ALA download zips into inst/extdata/.
#
# ALA occurrence downloads are asynchronous: you place a request, the ALA
# builds a zip, and emails you a link. galah is meant to do that waiting for
# you but currently fails on the collect step, so we download from
# biocache.ala.org.au directly and read the zips here.
#
# Occurrence records: one row is one report of one species, at one place, at
# one time. Not a count, not a survey, not a time series. Presence-only —
# nothing here says "we looked and found none" — and they mix systematic
# government surveys, citizen science and museum specimens together.
#
#   Rhinella marina       cane toad, released at Gordonvale QLD in 1935
#   Dasyurus hallucatus   northern quoll, which eats them and dies
#
# Put the downloaded zips in data-raw/ and name them below, then source this.

library(readr)

dir.create("inst/extdata", recursive = TRUE, showWarnings = FALSE)

read_ala_zip <- function(zip_path) {
  records_file <- grep(
    "records.*\\.csv$",
    unzip(zip_path, list = TRUE)$Name,
    value = TRUE
  )[1]
  read_csv(unz(zip_path, records_file), show_col_types = FALSE)
}

toads <- read_ala_zip("data-raw/cane-toad-ala.zip")
write_csv(toads, "inst/extdata/cane-toad-raw.csv")

quolls <- read_ala_zip("data-raw/northern-quoll-ala.zip")
write_csv(quolls, "inst/extdata/northern-quoll-raw.csv")
