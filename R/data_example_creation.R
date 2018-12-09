# 創造 100-102學屆匿名成績資料 ------------------------------------------------------

## 創造 100-102學屆匿名成績資料： transcript100_102.csv
library(dplyr); library(stringr); library(purrr); library(lubridate); library(readr)

source("/Users/martin/Desktop/GitHub/My-functions/DataScienceTeaching/R/anonymousData.R")

data0 <- read_csv("~/Dropbox/IR-Data/大學部100-106學年度入學學生歷年成績資料.csv",
                  col_types = cols(
                    學期成績="n"
                  ))
# 學期成績必需為 numeric因師培中心成績到小數第1位


# 取100-102入學 --------------------------------------------------------------

data0 %>%
  mutate(
    學屆=str_sub(學號,2,4)
  ) -> data0
data0 %>% 
  filter(學屆 %in% c("100","101","102")) -> data1


# 科目名稱匿名化 -----------------------------------------------------------------

# 科目名稱匿名化: anonymousFactor()
data1$科目名稱 %>% anonymousFactor -> 科目名稱indexTable
科目名稱indexTable$var -> data1$科目名稱


# 學號匿名化 -------------------------------------------------------------------

# 學號匿名化: anonymousID2()
data1 %>%
  mutate(
    學號9碼=str_pad(學號,9,side="left",pad="0"),
    系號=str_sub(學號9碼,5,6)
  ) -> data1
data1 %>%
  group_by(學號) %>%
  slice(1) -> tempdata

tempdata$學號9碼 %>% anonymousIDdata2(digitRangeFixedLevels = c(5,6)) ->
  學號indexTable

data1 %>%
  left_join(
    學號indexTable$indexTable,
    by=c("學號9碼"="oldId")
  ) -> data1

data1 %>%
  mutate(學號=newId) %>%
  select(-newId,-學號9碼,-系號) -> data1


#  學系抽3成 ------------------------------------------------------------------

data1 %>% 
  mutate(
    學系=str_sub(學號,5,6)
  ) %>%
  group_by(學系, 學屆, 學號) %>% 
  slice(1) %>% 
  ungroup %>%
  group_by(學系, 學屆) %>%
  sample_frac(0.6) -> sampledID # 每個學院、學屆抽3成的人

data1 %>% filter(學號 %in% sampledID$學號) -> transcript100_102
transcript100_102 %>%
  select(學號,學屆,學年,學期,科目名稱,學期成績,學分數,`必選修類別（必∕選∕通）`,上課時間及教室) -> transcript100_102

transcript100_102 %>% write_csv("/Users/martin/Desktop/GitHub/github-data/transcript100_102.csv")


# 創造 100-102學屆匿名借書資料 ------------------------------------------------------


## 創造 100-102學屆匿名借書資料： library100_102.Rda
source("/Users/martin/Desktop/GitHub/My-functions/DataScienceTeaching/R/anonymousData.R")
load("/Users/martin/Desktop/GitHub/Research/Social-media-and-student-learning/library.Rda")
bookNoRenew$入學年 %>% table
bookNoRenew %>%
  filter({入學年 %>% between(100,102)}) -> data0

data0 %>%
  group_by(學號) %>%
  slice(1) -> data1
data1$學號 %>% 
  str_pad(9,side="left",pad="0") %>% #補足學號均9位數
  anonymousIDdata2(digitRangeFixedLevels = c(5,6)) -> # 產生匿名學號
  學號indexTable

data0 %>%
  left_join(
    學號indexTable$indexTable,
    by=c("學號"="oldId")
  ) -> data1

data1 %>%
  mutate(
    學號=newId
  ) %>%
  select(-姓名,-入學系級) -> data2

data2$讀者身分 %>% table
data2$書籍名稱 %>% str_sub(1,3) %>%
  str_pad(8,side="right",pad="○") -> data2$書籍名稱

data2 %>% 
  select(
    -c(讀者系級,讀者身分,圖書登錄號,執行動作,借閱日期,
       書籍作者 ,書籍索書號,書籍ISBN,書籍出版者,
       `書籍標題(subject)`,學號長度,入學系,借閱月份,
       newId
       )
  ) -> data3
  
data3 %>% write_csv("/Users/martin/Desktop/GitHub/github-data/library100_102.csv")
