#' Fit a straight line to the western front
#'
#' A linear model of how far west the invasion had reached, against decade. The
#' slope is what we are after, and [front_speed()] pulls it out.
#'
#' Splitting the fitting from the extracting means you can look at the model
#' itself, which is where you find out whether a straight line was a reasonable
#' thing to ask for.
#'
#' @param front A tibble from [front_by_decade()].
#'
#' @return An `lm` object.
fit_front <- function(front) {
  lm(west_reached ~ decade, data = front)
}
