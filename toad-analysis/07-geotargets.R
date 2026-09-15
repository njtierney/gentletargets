# CHAPTER 7 — rasters
#
# Occurrence points become a SpatVector, climate rasters arrive, and the answer
# stops being a table and becomes a surface.
#
# The join between the two halves of the course is one function: terra::extract().

library(targets)
library(tarchetypes)
library(geotargets)

tar_option_set(packages = c("dplyr", "terra", "sf", "arrow"))
tar_source("R/")

# GDAL options worth setting, measured on mousecast: ZSTD with PREDICTOR=3
# was 35-45% smaller than the LZW default at no measurable write cost.
raster_gdal <- c("COMPRESS=ZSTD", "PREDICTOR=3", "ZSTD_LEVEL=9")

tar_assign({
  toad_path <- "data/cane-toad-all.parquet" |> tar_file()
  occurrences <- read_occurrences(toad_path) |> tar_target()
  cleaned <- clean_occurrences(occurrences) |> tar_target()

  # tabular becomes vector
  toad_points <- as_spatvector(cleaned) |> tar_terra_vect()

  # the raster the whole geospatial half rests on
  bioclim_now <- get_bioclim_australia() |>
    tar_terra_rast(gdal = raster_gdal)

  # raster becomes tabular again. this is the hinge
  background <- sample_background(bioclim_now, n = 10000) |> tar_target()
  model_data <- extract_covariates(toad_points, background, bioclim_now) |>
    tar_target()

  # deliberately simple, and obviously swappable. your model goes here
  sdm <- fit_sdm(model_data) |> tar_target()

  # tabular becomes raster
  suitability <- predict_sdm(sdm, bioclim_now) |>
    tar_terra_rast(gdal = raster_gdal)
})

# The optional extension, if there is time: branch suitability over two future
# climate scenarios and put the maps side by side.
