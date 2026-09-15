#' Map the records one panel per decade
#'
#' The invasion, drawn as small multiples. Each panel keeps the records from
#' every earlier decade in grey behind it, so you are looking at the front
#' moving rather than at ten unrelated maps.
#'
#' @param occurrences A cleaned data frame from [clean_occurrences()].
#'
#' @return A ggplot object. Nothing is written to disk.
plot_decades <- function(occurrences) {
  by_decade <- occurrences |>
    mutate(decade = floor(year / 10) * 10)

  ggplot(by_decade, aes(decimalLongitude, decimalLatitude)) +
    geom_point(
      data = select(by_decade, -decade),
      colour = "grey88",
      size = 0.35
    ) +
    geom_point(colour = "#1B9E77", size = 0.5) +
    facet_wrap(~decade) +
    coord_quickmap() +
    labs(
      x = NULL,
      y = NULL,
      title = "Cane toad records by decade",
      subtitle = "Grey shows every record in the dataset, green shows that decade"
    ) +
    theme_minimal(base_size = 11) +
    theme(
      axis.text = element_blank(),
      panel.grid = element_blank()
    )
}
