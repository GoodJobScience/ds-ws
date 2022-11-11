## code to prepare `DATASET` dataset goes here

if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,here,vroom)

train_data <- vroom(here::here("data-raw","train.csv"))
test_data <- vroom(here::here("data-raw","test.csv"))
odds_table <- vroom(here::here("data-raw","odds_table.csv"))
scores <- vroom(here::here("data-raw","scores.csv"))
shuffle <- read.table(here::here("data-raw","shuffle.txt"))
superundo <- read.table(here::here("data-raw","superundo.txt"))

usethis::use_data(train_data, overwrite = TRUE)
usethis::use_data(test_data, overwrite = TRUE)
usethis::use_data(odds_table, overwrite = TRUE)
usethis::use_data(scores, overwrite = TRUE)
usethis::use_data(shuffle, overwrite = TRUE)
usethis::use_data(superundo, overwrite = TRUE)