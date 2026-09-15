# Where were the cane toads, where are they now, and where are they going?
#
# This computes and saves. Nothing is printed and nothing is plotted, because
# neither of those is something you can pick up again later. `toad-report.qmd` reads
# what this writes and turns it into something you can send to someone.
#
# The boss has sent us the records up to 1999. When more arrives, change the
# filename. There are three:
#
#   cane-toad-to-1999.parquet
#   cane-toad-from-2000.parquet
#   cane-toad-all.parquet

toad_path <- "data/cane-toad-to-1999.parquet"

library(dplyr)
library(arrow)
library(readr)
library(fs)

lapply(dir_ls("R", glob = "*.R"), source)

dir_create("output")

occurrences_raw <- read_occurrences(toad_path)

occurrences_clean <- clean_occurrences(occurrences_raw)

toad_front <- front_by_decade(occurrences_clean)

front_model <- fit_front(toad_front)

toad_summary <- tibble(
  source = toad_path,
  records = nrow(occurrences_raw),
  records_clean = nrow(occurrences_clean),
  km_per_year = front_speed(front_model)
)

write_csv(toad_front, "output/toad-front.csv")
write_csv(toad_summary, "output/toad-summary.csv")
