# Where were the cane toads, and how fast are they moving west?
#
# In 1935 about 2,400 cane toads were released near Gordonvale in far north
# Queensland, to eat a beetle that was damaging the sugar cane. They did not eat
# the beetle. They spread instead, west across the top of the country, and they
# are still going.
#
# The data is occurrence records from the Atlas of Living Australia. One row is
# one report of one species, at one place, on one date. It is not a survey and
# it is not a count. Nobody went out and measured how many toads there are.
# Someone saw a toad, wrote down where and when, and that became a row.
#
# The boss has sent Queensland's WildNet records up to 1999. WildNet is the
# Queensland government's wildlife database, and it holds the origin: the oldest
# cane toad records in the country.

library(arrow)
library(here)
library(janitor)
library(gganimate)
library(leaflet)
library(ozmaps)
library(sf)
library(tidyverse)
library(visdat)
library(conflicted)
conflicts_prefer(dplyr::filter)

toads_raw <- read_parquet(
  file = here("data/cane-toad-wildnet-to-1999.parquet")
) |>
  clean_names()

toads <- toads_raw |>
  mutate(
    year = year(event_date),
    month = month(event_date),
    day = mday(event_date),
    decade = floor(year / 10) * 10,
    period = floor(year / 5) * 5,
    .before = event_date
  ) |>
  rename(
    lat = decimal_latitude,
    lon = decimal_longitude,
    date = event_date
  )

toads

# ---- what have we got? ------------------------------------------------------
glimpse(toads)
vis_dat(toads)

# Who collected these?
toads |>
  count(data_resource_name, sort = TRUE)

# How were they recorded? A quarter are museum specimens or machine detections
# rather than someone seeing a live animal.
toads |>
  count(basis_of_record, sort = TRUE)

# How precise are the coordinates? Median 1.3 km, but the worst is 100 km.
summary(toads$coordinate_uncertainty_in_meters)

# how many years of data?
summary(toads$year)

# ---- how many toads, over time? ---------------------------------------------
# Records per year. Worth knowing before we read anything into a trend: this is
# how often somebody wrote a toad down, not how many toads there were.
toads |> count(year)

ggplot(toads, aes(x = year)) +
  geom_bar() +
  labs(
    x = "Year",
    y = "# Cane Toads Seen"
  ) +
  scale_x_continuous(
    breaks = scales::breaks_width(width = 5)
  )

# Per decade
toads |> count(decade)

ggplot(toads, aes(x = decade)) +
  geom_bar() +
  labs(
    x = "Decade",
    y = "# Cane Toads Seen"
  ) +
  scale_x_continuous(
    breaks = scales::breaks_width(width = 10)
  )

# ---- where are they? --------------------------------------------------------

geodata_oz <- ozmap_states |> filter(NAME != "Other Territories")
ggplot() +
  geom_sf(
    data = geodata_oz,
    fill = "grey95",
    colour = "grey70",
    linewidth = 0.3
  ) +
  geom_point(
    data = toads,
    aes(x = lon, y = lat),
    alpha = 0.3
  ) +
  coord_sf(xlim = c(112, 154), ylim = c(-44, -9))

# ---- how far west have they got? --------------------------------------------
# Longitude gets smaller as you go west, so the westernmost record is the
# smallest longitude.
min(toads$lon)

# Where is that? Worth looking at rather than trusting.
toads |>
  filter(lon == min(lon)) |>
  select(year, lat, lon, data_resource_name)

# The toads also spread south into New South Wales. Those records sit far to the
# east of the northern front, so including them measures something else.
toads |>
  mutate(northern = lat > -20) |>
  group_by(northern) |>
  summarise(n = n(), west = min(lon))

# So: northern records only, and the westernmost one in each decade.
toads |>
  filter(lat > -20) |>
  group_by(decade) |>
  summarise(n = n(), west_seen = min(lon))

# That can go backwards, because a decade with few records may simply not have
# caught the front. It does not mean the toads retreated.
#
# A running minimum fixes it. Once the toads have reached somewhere, they have
# reached it, so `west_reached` can only move west.
toad_front <- toads |>
  filter(lat > -20) |>
  group_by(decade) |>
  summarise(n = n(), west_seen = min(lon)) |>
  ungroup() |>
  mutate(west_reached = cummin(west_seen))

toad_front

# ---- how fast is the front moving? ------------------------------------------
ggplot(toad_front, aes(x = decade, y = west_reached)) +
  geom_line() +
  geom_point() +
  scale_y_reverse() +
  labs(x = NULL, y = "Westernmost record (°E)") +
  scale_x_continuous(
    breaks = scales::breaks_width(width = 5)
  )

# A straight line through those points. The slope is degrees of longitude per
# decade, and a degree is about 107 km at that latitude.
speed <- lm(west_reached ~ decade, data = toad_front)

km_per_year <- -coef(speed)[["decade"]] * 107

km_per_year

write_csv(toad_front, here("output/toad-front.csv"))

# ---- the march of the cane toads --------------------------------------------
# One frame per five-year period. Records stay on the map once they appear,
# greyed out, so what moves is the front rather than the dots.
#
# On the Queensland records this is a march across Queensland. Run it again when
# the rest of the data arrives and they cross the continent.
# ozmaps carries the state boundaries. "Other Territories" is Christmas Island
# and the Cocos Islands, which are a long way offshore and squash the map.
australia <- ozmap_states |>
  filter(NAME != "Other Territories")

march <- ggplot() +
  geom_sf(
    data = australia,
    fill = "grey95",
    colour = "grey70",
    linewidth = 0.3
  ) +
  geom_point(
    data = toads,
    aes(x = lon, y = lat),
    colour = "#1B9E77",
    alpha = 0.25
  ) +
  labs(
    x = NULL,
    y = NULL
  ) +
  theme_void(base_size = 14)

march

# the static version, one panel per decade
march +
  facet_wrap(~decade, nrow = 1)

# and the animated one, one state per five years.
#
# A frame per year flickers, because most years add a handful of records and
# there is nothing to see between them. Five-year steps give each state enough
# new points to read as movement. `period` is the five-year version of `decade`.
#
# `transition_states()` with `transition_length = 0` means records appear where
# they are and stay put. The default tweens between frames, which makes the
# points slide around the map looking for their next position.
#
# `shadow_mark(past = TRUE)` is what leaves the grey trail behind: it redraws
# everything from earlier frames with these aesthetics.
march_animated <- march +
  labs(
    title = "The march of the cane toads",
    subtitle = "{closest_state}"
  ) +
  theme_sub_plot(
    title = element_text(face = "bold", hjust = 0.02),
    subtitle = element_text(
      hjust = 0.02,
      size = 18,
      colour = "#D95F02",
      face = "bold"
    )
  ) +
  transition_states(
    period,
    transition_length = 0,
    state_length = 1
  ) +
  shadow_mark(
    past = TRUE,
    colour = "grey70",
    size = 0.8,
    alpha = 0.55
  )

# `animate()` wants two of `nframes`, `fps` and `duration`, and silently drops
# the third, so give it frames and a frame rate and leave `duration` out.
#
# How long each period sits on screen is set by `nframes`, not by `state_length`.
# `state_length` is a ratio against `transition_length`, and that is 0 here, so
# changing it does nothing. Four frames per period at four frames a second is
# about a second each.
#
# About a second, not exactly. gganimate trims frames to fit the transition, and
# the gif renderer merges any that come out identical, keeping the time by
# lengthening the delay instead. So the frame count in the finished gif is lower
# than the number asked for while the running time is not: thirteen periods here
# come out as a thirteen second gif. Ask for about what you want and watch it.
march_animation <- animate(
  march_animated,
  nframes = n_distinct(toads$period) * 4,
  fps = 4,
  end_pause = 4,
  width = 700,
  height = 620,
  renderer = gifski_renderer()
)

march_animation

anim_save(
  animation = march_animation,
  filename = here("output/toad-march.gif")
)

# ---- more years arrive ------------------------------------------------------
# The boss sends the records up to 2010, and then all of them. Change the
# filename and run the whole thing again. Twice.
#
#   cane-toad-wildnet-to-2010.parquet
#   cane-toad-wildnet.parquet
#
# Cleaned, the answer goes 15.7, then 11.5, then 9.8 km a year.
#
# More data, and the answer got worse. That is worth stopping on. WildNet is
# Queensland, and the toads left Queensland in the 1980s, so recent Queensland
# records cannot move the western edge. The limit was never how many years we
# had. It was which state the database covers.

# ---- so where else is there data? -------------------------------------------
toads_all <- read_parquet(
  file = here("data/cane-toad-all.parquet")
) |>
  clean_names()

toads_all |>
  count(data_resource_name, sort = TRUE) |>
  head(8)

# Five more, and each is a different part of the invasion.
#
#   cane-toad-fauna-atlas-nt.parquet  the Territory, the middle passage
#   cane-toad-awc.parquet             the front, and the only one reaching WA
#   cane-toad-nsw-bionet.parquet      the southern tail
#   cane-toad-inaturalist.parquet     citizen science, for contrast
#   cane-toad-museums.parquet         OZCAM specimens, where the oddities are

# So: do the whole thing again for the Northern Territory.
nt_raw <- read_parquet(
  file = here("data/cane-toad-fauna-atlas-nt.parquet")
) |>
  clean_names()

nt <- nt_raw |>
  mutate(
    year = year(event_date),
    month = month(event_date),
    day = mday(event_date),
    decade = floor(year / 10) * 10,
    .before = event_date
  ) |>
  rename(
    lat = decimal_latitude,
    lon = decimal_longitude,
    date = event_date
  )

glimpse(nt)

nt |>
  count(year) |>
  ggplot(aes(x = year, y = n)) +
  geom_col() +
  labs(x = NULL, y = "Records", title = "Fauna Atlas N.T. records per year")

nt_front <- nt |>
  filter(lat > -20) |>
  group_by(decade) |>
  summarise(n = n(), west_seen = min(lon)) |>
  ungroup() |>
  mutate(west_reached = cummin(west_seen))

nt_front

nt_speed <- lm(west_reached ~ decade, data = nt_front)

-coef(nt_speed)[["decade"]] * 107

# And now four more times, for AWC, NSW BioNet, iNaturalist and the museums.
#
# By this point you have run the same eight steps eight times: three time
# windows and five sources. Every one of them was a filename change and a
# re-run, and the only thing telling you which results came from which file is
# your memory.
#
# That is what functions are for, and it is what the next session does.
