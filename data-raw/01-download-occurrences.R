# Download species occurrence records from the Atlas of Living Australia and
# cache them as parquet in data-raw/.
#
# Occurrence records: one row is one report of one species, at one place, at one
# time. Not a count, not a survey, not a time series. They are presence-only,
# nothing here says "we looked and found none", and they mix systematic
# government surveys, citizen science and museum specimens together.
#
# Two things about galah that will bite you if you forget them:
#
# 1. `identify()` is SILENTLY DROPPED unless the query also has a `filter()`. An
#    unfiltered call asks ALA for all 184 million records, comes back with no
#    order id, and `collect()` then polls a ticket that does not exist. So every
#    query here filters on the taxon concept instead.
#
# 2. You ask for `license` and ALA returns a column called `dcterms:license`.
#    galah warns, but `d$license` silently returns NULL, so it is renamed below.
#
# Records under a CC-BY-NC licence cannot be redistributed in a paid course, so
# they are dropped here rather than at the point of use.
#
# Takes about ten minutes on a good connection. Run it once.

library(galah)
library(arrow)
library(dplyr)
library(fs)

galah_config(
  email = "nicholas.tierney@gmail.com",
  atlas = "Australia",
  verbose = FALSE
)

dir_create("data-raw/parquet")

# The bettong and the kookaburra are genera with several members. These are the
# largest of each: the woylie, and the laughing kookaburra.
species <- tribble(
  ~common                    , ~scientific                ,
  "galah"                    , "Eolophus roseicapilla"    ,
  "laughing-kookaburra"      , "Dacelo novaeguineae"      ,
  "koala"                    , "Phascolarctos cinereus"   ,
  "eastern-grey-kangaroo"    , "Macropus giganteus"       ,
  "echidna"                  , "Tachyglossus aculeatus"   ,
  "brolga"                   , "Antigone rubicunda"       ,
  "saltwater-crocodile"      , "Crocodylus porosus"       ,
  "cane-toad"                , "Rhinella marina"          ,
  "woylie"                   , "Bettongia penicillata"    ,
  "platypus"                 , "Ornithorhynchus anatinus" ,
  "northern-quoll"           , "Dasyurus hallucatus"      ,
  "eastern-barred-bandicoot" , "Perameles gunnii"
)

sizes <- vector("list", nrow(species))

for (i in seq_len(nrow(species))) {
  common <- species$common[i]
  scientific <- species$scientific[i]

  taxon_id <- search_taxa(scientific)$taxon_concept_id[1]

  records <- galah_call() |>
    filter(taxonConceptID == taxon_id) |>
    select(
      scientificName,
      decimalLatitude,
      decimalLongitude,
      eventDate,
      coordinateUncertaintyInMeters,
      dataResourceName,
      basisOfRecord,
      license
    ) |>
    collect()

  names(records)[names(records) == "dcterms:license"] <- "license"

  open <- records |>
    filter(!grepl("NC", license, ignore.case = TRUE))

  path <- path("data-raw/parquet", common, ext = "parquet")
  write_parquet(open, path, compression = "zstd")

  sizes[[i]] <- tibble(
    common = common,
    downloaded = nrow(records),
    kept = nrow(open),
    mb = round(as.numeric(file_size(path)) / 1e6, 1)
  )

  message(
    common,
    ": ",
    nrow(open),
    " of ",
    nrow(records),
    " records kept, ",
    round(as.numeric(file_size(path)) / 1e6, 1),
    " MB"
  )
}

sizes <- bind_rows(sizes)
write.csv(sizes, "data-raw/parquet-sizes.csv", row.names = FALSE)

sizes
