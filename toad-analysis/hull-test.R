# The invasion as a grid, after the map on the Wikipedia cane toad page
#
# First attempt at this was convex hulls per five-year period. That does not
# work, for two reasons worth remembering.
#
# A convex hull is the smallest convex shape containing the points, and the
# north coast of Australia is emphatically not convex, so the hull bridges the
# Gulf of Carpentaria and puts toads in open water. And cumulative hulls are
# nearly identical to each other, so they stack into one blob rather than
# nesting into readable bands.
#
# A grid fixes both. Bin the records into cells, and colour each cell by the
# first year a toad was recorded in it. A cell with no records stays empty, so
# nothing is invented, and the bands fall out of the data rather than being
# imposed on it.

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
    year <= 2025,
    between(lon, 112, 154),
    between(lat, -44, -9)
  )

# Half a degree is about 50 km, which is roughly one year of movement at the
# rates the literature reports. Bigger cells smooth the front away, smaller ones
# leave holes where nobody happened to look.
cell_size <- 0.5

invasion <- toads |>
  mutate(
    cell_lon = floor(lon / cell_size) * cell_size,
    cell_lat = floor(lat / cell_size) * cell_size
  ) |>
  summarise(
    first_seen = min(year),
    n = n(),
    .by = c(cell_lon, cell_lat)
  ) |>
  mutate(period = floor(first_seen / 5) * 5)

australia <- ozmap_states |>
  filter(NAME != "Other Territories")

ggplot() +
  geom_sf(
    data = australia,
    fill = "grey10",
    colour = "grey25",
    linewidth = 0.3
  ) +
  geom_tile(
    data = invasion,
    aes(
      x = cell_lon + cell_size / 2,
      y = cell_lat + cell_size / 2,
      fill = period
    ),
    width = cell_size,
    height = cell_size
  ) +
  scale_fill_gradient(
    low = "grey95",
    high = "grey35",
    name = "First recorded",
    breaks = seq(1940, 2020, 20)
  ) +
  coord_sf(xlim = c(112, 154), ylim = c(-30, -9)) +
  labs(
    title = "The cane toad invasion, in five-year steps",
    subtitle = "Each cell is half a degree, shaded by when a toad first turned up in it"
  ) +
  theme_void(base_size = 14) +
  theme(
    plot.background = element_rect(fill = "black", colour = NA),
    plot.title = element_text(colour = "grey95", face = "bold", hjust = 0.02),
    plot.subtitle = element_text(colour = "grey60", hjust = 0.02),
    legend.title = element_text(colour = "grey80"),
    legend.text = element_text(colour = "grey70"),
    plot.margin = margin(12, 12, 12, 12)
  )

ggsave(
  here("output/toad-invasion-grid.png"),
  width = 9,
  height = 5,
  bg = "black"
)
