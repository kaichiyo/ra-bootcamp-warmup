library(pacman)
pacman::p_load(tidyverse, readxl)


# loading data ------------------------------------------------------------

folder_path_class <- "data/raw/学級数"

file_path_class <- list.files(folder_path_class, full.names = T)

file_name_class <- 
  list.files(folder_path_class, full.names = F) %>% 
  str_remove(".xlsx")

list_of_df_class_num_original <-
  map(file_path_class, \(path){
    
    read_xlsx(path)
    
  }) %>% 
  setNames(file_name_class)


# saving rds --------------------------------------------------------------

saveRDS(list_of_df_class_num_original,
        "data/original/list_of_df_class_num_original.rds")
