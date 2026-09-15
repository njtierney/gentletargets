#' The march of the cane toads
#'
#' An animated map, one frame per year, with earlier records left behind in grey
#' so you can see the front move rather than just watch dots flicker.
#'
#' The animation gets better as more data arrives. On the Queensland records
#' alone the toads spread across Queensland. On everything, they cross the top
#' of the continent and end up in the Kimberley.
#'
#' @param occurrences A cleaned data frame with `lon`, `lat` and `year`.
#' @param from,to Year range to animate.
#'
#' State boundaries come from `ozmaps`, minus the offshore territories, which
#' sit a long way out and squash the map.
#'
#' @return A `gganim` object. Render it with [gganimate::animate()].
gg_march <- function(occurrences, from = 1935, to = 2025) {
  australia <- ozmaps::ozmap_states |>
    filter(NAME != "Other Territories")

  in_range <- occurrences |>
    filter(!is.na(year), year >= from, year <= to)

  ggplot() +
    geom_sf(
      data = australia,
      fill = "grey95",
      colour = "grey70",
      linewidth = 0.3
    ) +
    geom_point(
      data = in_range,
      aes(x = lon, y = lat),
      colour = "#1B9E77",
      alpha = 0.55,
      size = 1.1
    ) +
    coord_sf(xlim = c(112, 154), ylim = c(-44, -9)) +
    labs(
      title = "The march of the cane toads",
      subtitle = "{floor(frame_along)}",
      x = NULL,
      y = NULL
    ) +
    theme_void(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.02),
      plot.subtitle = element_text(
        hjust = 0.02,
        size = 18,
        colour = "#D95F02",
        face = "bold"
      )
    ) +
    gganimate::transition_reveal(year) +
    gganimate::shadow_mark(colour = "grey72", size = 0.7, alpha = 0.5)
}
