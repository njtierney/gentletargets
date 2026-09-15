# A cumulative convex hull for each decade
#
# EXTENSION MATERIAL, not chapter 1. See `dev/extensions.md`.
#
# The simplest thing that works. For each decade, take every record up to and
# including it, and draw the hull around them. The hulls nest, because once the
# toads have reached somewhere they have reached it.
#
# The cumulative part comes from a join with an inequality: every record joins
# to every decade at or after its own. Then it is one group_by() and one
# slice(chull()).

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
  mutate(
    year = year(event_date),
    decade = floor(year / 10) * 10
  ) |>
  rename(lat = decimal_latitude, lon = decimal_longitude) |>
  filter(
    !is.na(year),
    year >= 1935,
    between(lon, 112, 154),
    between(lat, -44, -9)
  )

decades <- tibble(panel = sort(unique(toads$decade)))

# Every record, repeated once for each decade it belongs to or precedes. A
# record from 1960 appears in the 1960 panel, the 1970 panel, and so on.
cumulative <- toads |>
  select(lon, lat, decade) |>
  inner_join(decades, by = join_by(decade <= panel))

count(cumulative, panel)

# The hull of each panel. slice() takes the rows chull() names, and inside
# group_by() it does that separately for every decade.
hulls <- cumulative |>
  group_by(panel) |>
  slice(chull(lon, lat)) |>
  ungroup()

count(hulls, panel)

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
    data = toads,
    aes(x = lon, y = lat),
    colour = "grey80",
    size = 0.25,
    alpha = 0.3
  ) +
  geom_polygon(
    data = hulls,
    aes(x = lon, y = lat, group = panel, colour = panel),
    fill = NA,
    linewidth = 0.8
  ) +
  scale_colour_viridis_c(name = "By the end of", breaks = seq(1940, 2020, 20)) +
  coord_sf(xlim = c(112, 154), ylim = c(-40, -9)) +
  labs(
    title = "The cane toad front, decade by decade",
    subtitle = "A convex hull around every record up to the end of each decade"
  ) +
  theme_void(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.01),
    plot.subtitle = element_text(colour = "grey40", hjust = 0.01),
    plot.margin = margin(12, 12, 12, 12)
  )

ggsave(
  here("output/toad-front-lines.png"),
  width = 8,
  height = 6,
  bg = "white"
)
