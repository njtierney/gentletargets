library(arrow)
library(janitor)

cane_toads_raw <- read_parquet("data-raw/parquet/cane-toad.parquet")

brolga_raw <- read_parquet("data-raw/parquet/brolga.parquet")

brolga_tidy <- brolga_raw |>
  mutate(
    year = year(eventDate),
    month = month(eventDate),
    month_day = mday(eventDate),
    weekday = wday(eventDate, label = TRUE),
    .after = eventDate
  )

brolga_year_month <- brolga_tidy |>
  summarise(n = n(), .by = c(year, month)) |>
  arrange(year, month)

brolga_year_month

write_csv(brolga_year_month, "data/brolga_year_month.csv")
