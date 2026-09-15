# The cane toad front line, for one decade
#
# EXTENSION MATERIAL, not chapter 1. See `dev/extensions.md`. `cummin()` in
# `01-flat-script.R` answers the same question in six lines.
#
# Everything up to 1990, done once, straight down the page. No functions and no
# map(), so you can run it a line at a time and look at what comes out.
#
# The idea: take the convex hull of the records, and then take one edge of it.
# Every edge of a convex hull is a tangent: the whole hull sits on one side of
# it. So the south-west facing edge is a line with every toad on one side, which
# is the front.
#
# chull() gives the hull. The rest is arithmetic.

library(arrow)
library(here)
library(janitor)
library(ozmaps)
library(sf)
library(tidyverse)
library(conflicted)
conflicts_prefer(dplyr::filter)

toads <- read_parquet(
  file = here("data/cane-toad-all.parquet")
) |>
  clean_names() |>
  mutate(year = year(event_date)) |>
  rename(lat = decimal_latitude, lon = decimal_longitude) |>
  filter(
    !is.na(year),
    year >= 1935,
    between(lon, 112, 154),
    between(lat, -44, -9)
  )

# Everything the toads had done by the end of 1990.
toads_1990 <- toads |>
  filter(year <= 1990)

nrow(toads_1990)

# ---- the hull ---------------------------------------------------------------
# chull() returns the row numbers of the points on the boundary, going
# clockwise. The direction matters below, so it gets checked rather than
# assumed.
corners <- chull(toads_1990$lon, toads_1990$lat)

corners

hull <- toads_1990 |>
  slice(corners) |>
  select(lon, lat)

hull

# ---- the edges --------------------------------------------------------------
# Each corner joined to the next one. lead() with a default wraps the last
# corner back round to the first, which closes the shape.
edges <- hull |>
  mutate(
    lon_end = lead(lon, default = first(lon)),
    lat_end = lead(lat, default = first(lat)),
    run = lon_end - lon,
    rise = lat_end - lat
  )

# Which way does each edge face?
#
# chull() traces the hull CLOCKWISE, which is worth checking rather than
# assuming. Take a square, run chull() on it, and work out the signed area: if
# it comes out negative the traversal is clockwise.
#
# For a clockwise hull the outward normal of an edge is (-rise, run). Getting
# that backwards points every normal inwards and you pick the edge on the far
# side of the country, which is what happened the first time.
#
# We want the edge facing south-west, so the one whose normal points most
# strongly towards smaller longitude and smaller latitude. That is the dot
# product with (-1, -1), scaled by edge length so a long edge does not win just
# for being long.
edges <- edges |>
  mutate(
    length = sqrt(run^2 + rise^2),
    faces_southwest = (rise - run) / length
  )

edges |>
  select(lon, lat, run, rise, faces_southwest) |>
  arrange(desc(faces_southwest))

# ---- the tangent ------------------------------------------------------------
tangent <- edges |>
  slice_max(faces_southwest, n = 1)

tangent

# Extend it to the top and bottom of the continent, so it reads as a front
# rather than as one edge of a polygon.
slope <- tangent$run / tangent$rise

front_1990 <- tibble(
  lat = c(-9.5, -39),
  lon = tangent$lon + slope * (lat - tangent$lat)
)

front_1990

# ---- the plot ---------------------------------------------------------------
australia <- ozmap_states |>
  filter(NAME != "Other Territories")

ggplot() +
  geom_sf(
    data = australia,
    fill = "grey96",
    colour = "grey85",
    linewidth = 0.25
  ) +
  geom_point(
    data = toads_1990,
    aes(x = lon, y = lat),
    colour = "grey70",
    size = 0.3,
    alpha = 0.4
  ) +
  geom_polygon(
    data = hull,
    aes(x = lon, y = lat),
    fill = NA,
    colour = "grey55",
    linetype = "dashed",
    linewidth = 0.4
  ) +
  geom_line(
    data = front_1990,
    aes(x = lon, y = lat),
    colour = "#D95F02",
    linewidth = 1
  ) +
  coord_sf(xlim = c(112, 154), ylim = c(-40, -9)) +
  labs(
    title = "The cane toad front in 1990",
    subtitle = "Dashed is the convex hull. Orange is its south-west edge, extended."
  ) +
  theme_void(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.01),
    plot.subtitle = element_text(colour = "grey40", hjust = 0.01),
    plot.margin = margin(12, 12, 12, 12)
  )

ggsave(
  here("output/toad-front-1990.png"),
  width = 8,
  height = 6,
  bg = "white"
)
