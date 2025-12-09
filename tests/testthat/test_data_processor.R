library(testthat)
library(here)

source(here("R/data_processor.R"))

test_that("All datasets load correctly", {
  all_data <- read_all_data()
  
  # Check that the list is not empty
  expect_true(length(all_data) > 0)
  
  # Check each dataset
  for (name in names(all_data)) {
    df <- all_data[[name]]
    expect_true(is.data.frame(df), info = paste(name, "is not a data frame"))
    expect_true(nrow(df) > 0, info = paste(name, "has no rows"))
    expect_true(ncol(df) > 0, info = paste(name, "has no columns"))
  }
})
