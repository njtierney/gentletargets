#' Map the records on a slippy map
#'
#' An interactive map of every record you pass it. The map fits to the data, so
#' if a record sits in the Pacific Ocean the map zooms out far enough to show
#' you the Pacific Ocean. That is the intended behaviour.
#'
#' @param occurrences A data frame with `decimalLongitude` and `decimalLatitude`.
#'
#' @return A leaflet widget.
map_occurrences <- function(occurrences) {
  points <- occurrences |>
    filter(!is.na(decimalLongitude), !is.na(decimalLatitude))

  leaflet(points) |>
    addProviderTiles("CartoDB.Positron") |>
    addCircleMarkers(
      lng = ~decimalLongitude,
      lat = ~decimalLatitude,
      radius = 3,
      stroke = FALSE,
      fillColor = "#1B9E77",
      fillOpacity = 0.6,
      popup = ~ paste0("Year: ", year)
    )
}
