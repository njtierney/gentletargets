#' Plot records per decade
#'
#' A bar per decade. The shape of this plot is the thing worth arguing about:
#' almost every species has more records recently than it used to, and that is
#' mostly a fact about smartphones rather than about animals.
#'
#' @param by_decade A data frame with `decade` and `n` columns, as returned by
#'   counting thinned records by decade.
#'
#' @return A ggplot object. Nothing is written to disk.
plot_decade <- function(by_decade) {
  ggplot(by_decade, aes(x = decade, y = n)) +
    geom_col(fill = "grey20") +
    scale_x_continuous(breaks = by_decade$decade) +
    labs(
      x = NULL,
      y = "Records",
      title = "Records per decade"
    ) +
    theme_minimal(base_size = 12)
}
