#' Read cached occurrence records
#'
#' Reads one species' parquet file and adds a `year` column. No cleaning happens
#' here, deliberately, so that you can see what you were given before anything
#' is thrown away.
#'
#' @param path Path to a parquet file written by `data-raw/01-download-occurrences.R`.
#'
#' @return A tibble with a `year` column added.
read_occurrences <- function(path) {
  read_parquet(path) |>
    mutate(year = as.integer(format(eventDate, "%Y")))
}
