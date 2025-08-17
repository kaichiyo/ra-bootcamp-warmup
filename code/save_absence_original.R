library(pacman)
pacman::p_load(tidyverse, readxl)


# loading data ------------------------------------------------------------

df_students_num_raw <- read_xlsx("data/raw/生徒数/生徒数.xlsx")

folder_path_absence <- "data/raw/不登校生徒数"

file_path_absence <- list.files(folder_path_absence, full.names = T)

file_name_absence <- 
  list.files(folder_path_absence, full.names = F) %>% 
  str_remove("_不登校生徒数.xlsx")

list_of_df_absence_num_raw <-
  map(file_path_absence, \(path){
    
    read_xlsx(path)
    
  }) %>% 
  setNames(file_name_absence)


# rename vars -------------------------------------------------------------

list_of_df_absence_num_original <-
  list_of_df_absence_num_raw %>% 
  map(., \(df){
    
    df %>% 
      rename(
        prefecture = "都道府県",
        n_absence = "不登校生徒数"
      )
  })

df_students_num_original <-
  df_students_num_raw %>% 
  rename(
    prefecture = "都道府県",
    year = "年度",
    n_student = "生徒数"
  )
  )


# save rds ----------------------------------------------------------------

saveRDS(df_students_num_original,
        "data/original/df_students_num_original.rds")

saveRDS(list_of_df_absence_num_original,
        "data/original/list_of_df_absence_num_original.rds")
