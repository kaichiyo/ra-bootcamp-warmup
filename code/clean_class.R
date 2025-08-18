library(pacman)
pacman::p_load(tidyverse, readxl)


# loading data ------------------------------------------------------------

list_of_df_class_num_original <- readRDS("data/original/list_of_df_class_num_original.rds")


# cleaning data -----------------------------------------------------------

new_names <- 
  list_of_df_class_num_original %>% 
  map_chr(\(df){
    
    nendo <- df[[1, 1]]
    
    gengo <- str_extract(nendo, "平成|令和")
    
    gengo_year <- as.numeric(str_extract(nendo, "\\d+"))
    
    year <- case_when(
        gengo == "平成" ~ gengo_year + 1988,
        gengo == "令和" ~ gengo_year + 2018
      ) %>% 
      as.character()
    
  })

df_class_num_cleaned <-
  list_of_df_class_num_original %>% 
  setNames(new_names) %>% 
  map(\(df){
    
    new_colnames <- df[1,] %>% 
      str_remove_all("学級")
    
    needs_rename <- grepl("61", new_colnames)
    
    new_colnames[needs_rename] <- "61以上" 
    
    colnames(df) <- c("prefecture", new_colnames[-1])
    
    needs_rename <- grepl("61", colnames(df))
    
    df <- df[-1,] %>% 
      select(!計) %>% 
      mutate(prefecture_index = row_number()) %>% 
      mutate(across(-prefecture, as.numeric)) %>% 
      relocate(prefecture, prefecture_index)
    
  }) %>% 
  bind_rows(.id = "year") %>% 
  arrange(prefecture_index, year) %>% 
  mutate(
    prefecture = case_when(
      str_detect(prefecture, "県") ~ str_remove(prefecture, "県"),
      prefecture %in% c("大阪府", "京都府") ~ str_remove(prefecture, "府"),
      prefecture == "東京都" ~ str_remove(prefecture, "都"),
      TRUE ~ prefecture
    )
  ) %>% 
  relocate(year, prefecture, prefecture_index) %>% 
  pivot_longer(
    cols = `0`:`61以上`,
    names_to = "n_class",
    values_to = "n_school"
  ) %>% 
  mutate(
    n_class = case_when(
      n_class == "25～30" ~ "27.5",
      n_class == "31～36" ~ "33.5",
      n_class == "37～42" ~ "39.5",
      n_class == "43～48" ~ "45.5",
      n_class == "49～54" ~ "51.5",
      n_class == "55～60" ~ "57.5",
      n_class == "61以上" ~ "63.5",
      TRUE ~ n_class
    )
  ) %>% 
  mutate(
    n_class = as.numeric(n_class),
    total_class_num = n_class*n_school
  ) %>% 
  group_by(prefecture, prefecture_index, year) %>% 
  summarise(total_class_num = sum(total_class_num, na.rm = TRUE)) %>% 
  ungroup() %>% 
  arrange(prefecture_index) %>% 
  select(!prefecture_index)


# saving rds --------------------------------------------------------------

saveRDS(df_class_num_cleaned,
        "data/cleaned/df_class_num_cleaned.rds")
