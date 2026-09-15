# The march of the cane toads, as a faceted plot
#
# EXTENSION MATERIAL, not chapter 1. See `dev/extensions.md`. Chapter 1 keeps
# the plain `facet_wrap(~decade)` in `01-flat-script.R`, because the join below
# is a new idea that has nothing to do with pipelines.
#
# One panel per decade. In each panel, the toads recorded in that decade are
# green, and everything recorded earlier is grey. So each panel is the whole
# invasion so far, and the green is what is new.
#
# The trick is the join. Every record needs to appear in its own panel and in
# every panel after it, which is a join on an inequality: `decade <= panel`.

library(arrow)
library(here)
library(janitor)
library(ozmaps)
library(sf)
library(tidyverse)
library(conflicted)
conflicts_prefer(dplyr::filter)

toads_raw <- read_parquet(
  file = here("data/cane-toad-wildnet-to-1999.parquet")
) |>
  clean_names()

toads <- toads_raw |>
  mutate(
    year = year(event_date),
    decade = floor(year / 10) * 10,
    .before = event_date
  ) |>
  rename(
    lat = decimal_latitude,
    lon = decimal_longitude,
    date = event_date
  )

# ---- one row per record per panel -------------------------------------------
decades <- tibble(panel = sort(unique(toads$decade)))

decades

# A record from 1965 gets a copy in the 1960 panel, the 1970 panel, and every
# panel after that. `seen` says whether this copy is the new one.
toads_cumulative <- toads |>
  select(lon, lat, decade) |>
  inner_join(decades, by = join_by(decade <= panel)) |>
  mutate(seen = if_else(decade == panel, "this decade", "earlier"))

count(toads_cumulative, panel, seen)

# ---- the plot ---------------------------------------------------------------
australia <- ozmap_states |>
  filter(NAME != "Other Territories")

# Two layers rather than one, so the grey is drawn first and the green sits on
# top of it. A single layer with colour mapped to `seen` would draw them in
# whatever order the rows happen to be in.
earlier <- toads_cumulative |>
  filter(seen == "earlier")

this_decade <- toads_cumulative |>
  filter(seen == "this decade")

# The extent is the whole country, not just the part with toads in it. The 1930s
# panel is mostly empty Australia on purpose: when the rest of the data arrives
# the green crosses the Territory into Western Australia in this same frame.
march_facet <- ggplot() +
  geom_sf(
    data = australia,
    fill = "grey96",
    colour = "grey85",
    linewidth = 0.2
  ) +
  geom_point(
    data = earlier,
    aes(x = lon, y = lat),
    colour = "grey70",
    size = 0.25,
    alpha = 0.5
  ) +
  geom_point(
    data = this_decade,
    aes(x = lon, y = lat),
    colour = "#1B9E77",
    size = 0.3,
    alpha = 0.7
  ) +
  coord_sf(xlim = c(112, 154), ylim = c(-44, -9)) +
  facet_wrap(
    ~panel,
    nrow = 2,
    labeller = labeller(panel = \(x) paste0(x, "s"))
  ) +
  labs(
    title = "The march of the cane toads",
    subtitle = "Green is new that decade, grey is everywhere they had already been",
    x = NULL,
    y = NULL
  ) +
  theme_void(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.01),
    plot.subtitle = element_text(colour = "grey40", hjust = 0.01),
    strip.text = element_text(face = "bold", colour = "grey30"),
    plot.margin = margin(12, 12, 12, 12)
  )

march_facet

ggsave(
  here("output/toad-march-facet.png"),
  plot = march_facet,
  width = 11,
  height = 5,
  bg = "white"
)

# ---- the other way round ----------------------------------------------------
# Every record in grey in every panel, and only that decade's records in green.
# So the grey is the whole invasion, past and future, and the green moves
# through it.
#
# No join this time. A layer whose data has no `decade` column is drawn in full
# in every panel, which is what puts the same grey behind all seven.
all_records <- toads |>
  select(lon, lat)

march_ghost <- ggplot() +
  geom_sf(
    data = australia,
    fill = "grey96",
    colour = "grey85",
    linewidth = 0.2
  ) +
  geom_point(
    data = all_records,
    aes(x = lon, y = lat),
    colour = "grey70",
    size = 0.25,
    alpha = 0.5
  ) +
  geom_point(
    data = toads,
    aes(x = lon, y = lat),
    colour = "#1B9E77",
    size = 0.3,
    alpha = 0.7
  ) +
  coord_sf(xlim = c(112, 154), ylim = c(-44, -9)) +
  facet_wrap(
    ~decade,
    nrow = 2,
    labeller = labeller(decade = \(x) paste0(x, "s"))
  ) +
  labs(
    title = "The march of the cane toads",
    subtitle = "Green is that decade, grey is every record we have",
    x = NULL,
    y = NULL
  ) +
  theme_void(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.01),
    plot.subtitle = element_text(colour = "grey40", hjust = 0.01),
    strip.text = element_text(face = "bold", colour = "grey30"),
    plot.margin = margin(12, 12, 12, 12)
  )

march_ghost

ggsave(
  here("output/toad-march-facet-ghost.png"),
  plot = march_ghost,
  width = 11,
  height = 5,
  bg = "white"
)
