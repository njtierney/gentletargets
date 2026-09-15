#' Find the western edge of the invasion, by decade
#'
#' The cane toad invasion moved west across northern Australia. This returns two
#' different things per decade, and the difference between them matters.
#'
#' `west_seen` is the westernmost record *in* that decade. It can go backwards,
#' because a decade with few records may simply not have caught the front.
#'
#' `west_reached` is the westernmost record *by* the end of that decade, from
#' `cummin()`, the running minimum. Once the toads have reached somewhere they
#' have reached it, so this cannot go backwards. It is the one to model.
#'
#' Records south of `north_of` are excluded. The toads also spread south into
#' New South Wales, and those records sit far to the east, so leaving them in
#' measures a different thing entirely.
#'
#' @param occurrences A cleaned data frame from [clean_occurrences()].
#' @param north_of Southern limit, in degrees latitude.
#'
#' @return A tibble with one row per decade: `decade`, `n`, `west_seen` and
#'   `west_reached`.
front_by_decade <- function(occurrences, north_of = -20) {
  occurrences |>
    filter(decimalLatitude > north_of) |>
    mutate(decade = floor(year / 10) * 10) |>
    group_by(decade) |>
    summarise(n = n(), west_seen = min(decimalLongitude)) |>
    ungroup() |>
    mutate(west_reached = cummin(west_seen))
}
