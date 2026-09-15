#' Plot the western front over time
#'
#' Longitude is drawn descending, so west is up and the line rises as the toads
#' move across the continent. The straight line is the model from
#' [fit_front()], drawn so you can see what the speed is a slope of.
#'
#' @param front A tibble from [front_by_decade()].
#' @param show_fit Draw the fitted straight line.
#'
#' @return A ggplot object. Nothing is written to disk.
plot_front <- function(front, show_fit = TRUE) {
  p <- ggplot(front, aes(x = decade, y = west_reached))

  if (show_fit) {
    p <- p +
      geom_smooth(
        method = "lm",
        formula = y ~ x,
        se = FALSE,
        colour = "#D95F02",
        linewidth = 0.7
      )
  }

  p +
    geom_line(linewidth = 0.8, colour = "grey30") +
    geom_point(size = 2.4) +
    scale_y_reverse() +
    labs(
      x = NULL,
      y = "Westernmost record (°E)",
      title = "How far west had the toads reached?"
    ) +
    theme_minimal(base_size = 12)
}
