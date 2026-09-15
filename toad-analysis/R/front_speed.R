#' How fast is the front moving?
#'
#' Pulls the slope out of a model from [fit_front()] and turns it into
#' kilometres per year.
#'
#' The sign is flipped because longitude gets smaller as you go west, so a front
#' that is advancing has a negative slope and a positive speed.
#'
#' @param model An `lm` from [fit_front()].
#' @param km_per_degree Width of a degree of longitude, in kilometres. About 107
#'   across northern Australia. It shrinks as you move away from the equator, so
#'   this is an approximation, and a different study area wants a different
#'   number.
#'
#' @return A single number: kilometres per year.
front_speed <- function(model, km_per_degree = 107) {
  slope <- broom::tidy(model) |>
    filter(term == "decade") |>
    pull(estimate)

  -slope * km_per_degree
}
