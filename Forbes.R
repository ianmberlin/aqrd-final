library(tidyverse) 
library(haven)
library(modelsummary)
library(summarytools)
library(vtable)
library(fixest)
library(gt)
library(readxl)
library(fuzzyjoin)
library(usethis)

forbes <- read_dta("data/brookings_forbes_2022.dta")
states <- read.csv("data/Popular vote backend - Sheet1.csv") |>
  pop(1:4)
analysis <- read_dta("ReplicationPackage/data/stata_data/StateyearAnalysisDataset.dta")
analysis2 <- read_dta("ReplicationPackage/data/stata_data/StateyearAgeAnalysisDataset.dta")
person_year <- read_dta("ReplicationPackage/data/stata_data/IndivAnalysisDataset.dta") |>
  rename(name = Name)

dynastic <- read_excel("data/Forbes 400 Aggregate with Dynasty Members.xlsx")

dynasty_test <- dynastic |> 
  slice(1:330)

dynasty_long <- dynasty_test |>
  filter(dynasty_binary != "") |> 
  mutate(dynasty_binary = as.character(dynasty_binary)) |> 
  select(!"Grand Total") |>
  pivot_longer(cols = !c("name", "dynasty_binary"),
               names_to = "year",
               values_to = "NetWorth") |>
  filter(NetWorth != "") |>
  mutate(NetWorthMill = NetWorth/1000000)

dynasty_long |>
  fuzzy_inner_join(
    person_year,
    by = c("year", "name", "NetWorthMill"),
    match_fun = stringdist_inner_join,
    distance_col = "distance"
  )


## Replication attempt ----

analysis <- analysis |>
  mutate(post_year = if_else(year > 2001, 1, 0)) |>
  mutate(PIT = avg*100) 

analysis <- analysis |>
  group_by(year) |>
  mutate(pop_90to97_natl = sum(pop_90to97)) |>
  mutate(topshr_90to97 = (pop_90to97/pop_90to97_natl)*100) |>
  mutate(total_wealth = sum(wealth)) |>
  mutate(wealth_share = (wealth/total_wealth)*100)

mod1 <- feols(stock ~ EI*post_year + EI  | State + year, analysis)
mod2 <- feols(stock ~ EI*post_year + EI + PIT*post_year + PIT | State + year, analysis)
mod3 <- feols(stock ~ EI*post_year + EI + topshr_90to97  | State + year, analysis)
mod6 <- feols(wealth_share ~ EI*post_year + EI  | State + year, analysis)

#create dataset without 2002-2004
analysis_drop <- analysis|>
  filter(year != "2002",
         year != "2003",
         year != "2004")

mod8 <- feols(stock ~ EI*post_year + EI  | State + year, analysis_drop)


modelsummary(list(mod1, mod2, mod3, mod6, mod8), gof_map = c("nobs", "FE: State", "FE: year"))

forbes |>
  group_by(year) |>
  count(marital) |>
  ggplot(aes(x = year, y = n, color = marital)) +
  geom_line()


# Summary Statistics ----

summary_table <- forbes |>
  mutate(gender2 = if_else(gender == "M", 1, 0),
         marital2 = if_else(marital == "Married", 1, 0),
         race2 = if_else(race == "white", 1, 0)) |>
  select("networth", "gender2", "marital2", "race2", "age", "numberofchildren",
         "Change") |>
  sumtable(labels = c("Net Worth (billions)", "Gender (M = 1)", 
                      "Marital Status (Married = 1)", "Race (white = 1)", 
                      "Age", "Number of Children", "% Change from Previous Year"),
           digits = 4)


# Everything else ----
  
  summarize_all(list(mean = mean, sd = sd), na.rm = TRUE)

pivot_wider(forbes, names_from = fullname, values_from = networth)


ivys <- c("Harvard", "Princeton", "Yale", "Dartmouth", "Brown", "Columbia", "Cornell")

forbes <- forbes |>
  filter(year >= 2001) |>
  mutate(ivy = ifelse(any(str_detect(education, ivys)), 1, 0)) |>
  count(ivy)

forbes |>
  mutate(selfmade = tolower(selfmade),
         selfmade = ifelse("self-made", 1, 0)) |>
  group_by(year) |>
  count(selfmade) |>
  ggplot(aes(x = year, y = n, color = selfmade)) +
  geom_point()

filtered <- forbes |>
  filter(year >= 2014) |>
  mutate(self_score = SelfMadeScoreBeginning2014)

mod <- lm(networth ~ state_current, data = filtered)

summary(mod)

states <- forbes |>
  group_by(state, year) |>
  count(state)

forbes |>
  ggplot(aes(x = year, y = sum, color = self)) +
  geom_line()

wyoming <- forbes |>
  filter(year == 2009)

forbes |>
  group_by(year) |>
  summarize(ratio = max(networth)/min(networth)) |>
  ggplot(aes(x = year, y = ratio)) +
  geom_line()

test <- forbes[forbes$lastname == "Gates",]

forbes <- forbes |>
  mutate(selfmade2 = if_else(selfmade == "self-made", 1, 0))

mod <- lm(networth ~ race , data = forbes)
summary(mod)

model1 <- feols(Change ~ networth | URL_name + year, forbes)

summary(model1)

forbes |>
  group_by(year, race) |>
  summarize(mean = mean(networth)) |>
  pivot_wider(names_from = "race", values_from = "mean") |>
  mutate(ratio = white/black) |>
  ggplot(aes(x = year, y = ratio)) +
  geom_line()
  

gt() |>
  cols_label(c("year", "asian", "black", "hispanic", "white"))
