#' Remove records that cannot be right
#'
#' Occurrence records arrive with dates and coordinates that are impossible
#' rather than merely uncertain. This drops three kinds.
#'
#' **Missing dates or coordinates.** A record with no location cannot tell you
#' where anything was.
#'
#' **Coordinates outside Australia.** The cane toad file contains records at
#' longitude -170 and -80, which are the mid-Pacific and South America. These
#' are usually a sign or a decimal place lost somewhere upstream.
#'
#' **Dates before the species was here.** Cane toads were released at Gordonvale
#' in 1935. Records dated earlier are wrong, and there are 44 of them in the
#' file, 41 dated 1770. Left in, they anchor any trend through time to a point
#' 165 years before the species existed in Australia, and the answer changes by
#' a factor of seven.
#'
#' @param occurrences A data frame from [read_occurrences()].
#' @param first_year The earliest year a record could be real. For the cane toad
#'   this is 1935, the year they were released.
#'
#' @return `occurrences`, with impossible rows removed.
clean_occurrences <- function(occurrences, first_year = 1935) {
  occurrences |>
    filter(
      !is.na(eventDate),
      !is.na(decimalLongitude),
      !is.na(decimalLatitude),
      between(decimalLongitude, 112, 154),
      between(decimalLatitude, -44, -9),
      year >= first_year
    )
}
