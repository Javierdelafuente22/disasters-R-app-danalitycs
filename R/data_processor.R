library(here)

read_all_data <- function() {
  files <- list.files(here("data"), pattern = "\\.csv$", full.names = TRUE)
  
  data <- lapply(files, read.csv, stringsAsFactors = FALSE)
  
  names(data) <- tools::file_path_sans_ext(basename(files))
  data
}