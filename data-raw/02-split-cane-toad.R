# Split the cane toad records into the files the course works through.
#
# The story is that more data keeps arriving, in two different ways.
#
# First more years, from the same source. WildNet is the Queensland government's
# wildlife database and it holds the origin, so that is where we start:
#
#   cane-toad-wildnet-to-1999.parquet  4,538   what you are given
#   cane-toad-wildnet-to-2010.parquet  6,018   a decade later
#   cane-toad-wildnet.parquet          7,641   all of it
#
# Adding years does not help, and that is worth sitting with. WildNet is
# Queensland, and the toads left Queensland, so the front stops moving in this
# source. Cleaned, the answer goes 15.7, then 11.5, then 9.8 km/yr. More data,
# worse answer.
#
# Then more sources, which do follow the toads west:
#
#   cane-toad-fauna-atlas-nt.parquet  16,756   the Territory, the middle passage
#   cane-toad-awc.parquet             19,949   the front, and the only one in WA
#   cane-toad-nsw-bionet.parquet       4,669   the southern tail
#   cane-toad-inaturalist.parquet      1,611   citizen science, for contrast
#   cane-toad-museums.parquet          1,220   OZCAM, where the oddities are
#   cane-toad-all.parquet             54,055   everything
#
# Cleaned and cumulative, those give 9.8, then 23.3, then 27.6 km/yr. Adding
# sources fixed what adding years could not.
#
# Nothing here is cleaned. WildNet carries 41 records dated 1770, and the museum
# records carry 124 coordinates outside Australia. Finding those is the work.

library(arrow)
library(dplyr)
library(fs)

toads <- read_parquet("data-raw/parquet/cane-toad.parquet")

dir_create("toad-analysis/data")

write_split <- function(records, name) {
  path <- path("toad-analysis/data", name, ext = "parquet")
  write_parquet(records, path, compression = "zstd")
  message(name, ": ", format(nrow(records), big.mark = ","), " records")
}

# ---- WildNet, in three time windows -----------------------------------------
# The first two windows start in 1930, so they hold nothing older than the
# toads. The third is all of WildNet, and that is where the 41 records dated
# 1770 turn up. The bug arrives with the data rather than being there from the
# start, so the first two answers are believable and the third is not.
wildnet <- toads |>
  filter(dataResourceName == "WildNet - Queensland Wildlife Data") |>
  mutate(year = as.integer(format(eventDate, "%Y")))

write_split(
  filter(wildnet, !is.na(year), year >= 1930, year <= 1999),
  "cane-toad-wildnet-to-1999"
)
write_split(
  filter(wildnet, !is.na(year), year >= 1930, year <= 2010),
  "cane-toad-wildnet-to-2010"
)
write_split(wildnet, "cane-toad-wildnet")

# ---- then the other sources -------------------------------------------------
providers <- tribble(
  ~file            , ~match                              ,
  "fauna-atlas-nt" , "Fauna Atlas N.T."                  ,
  "awc"            , "AWC Ecological Monitoring Surveys" ,
  "nsw-bionet"     , "NSW BioNet Atlas"                  ,
  "inaturalist"    , "iNaturalist Australia"
)

for (i in seq_len(nrow(providers))) {
  write_split(
    filter(toads, dataResourceName == providers$match[i]),
    paste0("cane-toad-", providers$file[i])
  )
}

# The museums travel together. Individually they are a few hundred records each,
# and they share a provenance: specimens in a drawer, registered later.
write_split(
  filter(toads, grepl("OZCAM", dataResourceName)),
  "cane-toad-museums"
)

write_split(toads, "cane-toad-all")
