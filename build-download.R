# Build the downloadable copy of the analysis.
#
# Run by Quarto before every render, so the zip on the site cannot drift away
# from the analysis in the repo. `output/` is left out: that is what running the
# analysis produces, and having it arrive pre-filled would rather spoil it.

library(fs)

dir_create("download")

analysis_files <- c(
  dir_ls("toad-analysis", glob = "*.R"),
  dir_ls("toad-analysis", glob = "*.qmd"),
  dir_ls("toad-analysis/R", glob = "*.R"),
  dir_ls("toad-analysis/data", glob = "*.parquet")
)

zip_path <- "download/toad-analysis.zip"
if (file_exists(zip_path)) {
  file_delete(zip_path)
}

zip(zip_path, files = analysis_files, flags = "-qr9X")

message("built ", zip_path, " (", round(file_size(zip_path) / 1e3), " KB)")
