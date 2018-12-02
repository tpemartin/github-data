## 創造 100-102學屆匿名資料： transcript100_102.csv
library(dplyr); library(stringr); library(purrr); library(lubridate); library(readr)
load("/Users/martin/Desktop/GitHub/github-data/temp_data/transcript.Rda")
data1 %>% filter({學屆 %>% between(100,102)}) -> data2

data2 %>% 
  mutate(
    學系=str_sub(學號,5,6)
  ) %>%
  group_by(學系, 學屆, 學號) %>% 
  slice(1) %>% 
  ungroup %>%
  group_by(學系, 學屆) %>%
  sample_frac(0.6) -> sampledID # 每個學院、學屆抽3成的人

data2 %>% filter(學號 %in% sampledID$學號) -> transcript100_102
transcript100_102 %>%
  select(-班別) -> transcript100_102

transcript100_102 %>% write_csv("/Users/martin/Desktop/GitHub/github-data/transcript100_102.csv")
