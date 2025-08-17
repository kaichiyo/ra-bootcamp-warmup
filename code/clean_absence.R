library(pacman)
pacman::p_load(tidyverse, readxl)


# loading data ------------------------------------------------------------

df_students_num_original <- readRDS("data/original/df_students_num_original.rds")

list_of_df_absence_num_original <- readRDS("data/original/list_of_df_absence_num_original.rds")


# cleaning data -----------------------------------------------------------

df_absence_num_cleaned <-
  list_of_df_absence_num_original %>% 
  map(\(df){
    
    df %>% 
      select(!blank) %>% 
      mutate(
        n_absence = as.numeric(n_absence),
        prefecture_index = row_number()
      )
    
  }) %>% 
  bind_rows(.id = "year") %>% 
  relocate(prefecture) %>% 
  mutate(year = as.numeric(str_remove(year, "年度"))) %>% 
  arrange(prefecture_index, year) %>% 
  select(!prefecture_index)


# merging data ------------------------------------------------------------

df_absence_num <- 
  df_students_num_original %>% 
  left_join(df_absence_num_cleaned,
            by = c("prefecture", "year"))


# creating vars -----------------------------------------------------------

df_absence_num <- 
  df_absence_num %>% 
  mutate(absence_rate = n_absence / n_student)


# saving data -------------------------------------------------------------

saveRDS(df_absence_num,
        "data/cleaned/df_absence_num.rds")
