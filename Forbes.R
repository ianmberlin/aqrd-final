library(tidyverse) 
library(haven)
library(modelsummary)
library(vtable)
library(fixest)
library(gt)
library(readxl)
library(fuzzyjoin)
library(usethis)

forbes <- read_dta("data/brookings_forbes_2022.dta")
state_year<- read_dta("ReplicationPackage/data/stata_data/StateyearAnalysisDataset.dta")
state_year_age <- read_dta("ReplicationPackage/data/stata_data/StateyearAgeAnalysisDataset.dta")
person_year <- read_dta("ReplicationPackage/data/stata_data/IndivAnalysisDataset.dta") |>
  rename(name = Name) |>
  filter(year != "1982")

dynastic <- read_excel("data/Forbes 400 Aggregate with Dynasty Members, 2017 end.xlsx")

dynasty_clean <- dynastic |>
  filter(dynasty_binary != "") |>
  mutate(dynasty_binary = as.character(dynasty_binary)) |> 
  select(!"Grand Total") |>
  mutate(name = gsub("(Child|Spouse).*", "", name))

moretti_names <- person_year |>
  select(name) |>
  unique()


dynasty_long <- dynastic |>
  filter(dynasty_binary != "") |> 
  mutate(dynasty_binary = as.character(dynasty_binary)) |> 
  select(!"Grand Total") |> 
  pivot_longer(cols = !c("name", "dynasty_binary"),
               names_to = "year",
               values_to = "NetWorth") |>
  filter(NetWorth != "",
         !year %in% c("2018", "2019", "2020")) |>
  mutate(NetWorthMill = NetWorth/1000000) 



join <- stringdist_inner_join(dynasty_clean, moretti_names, 
                by='name',
                max_dist = 3) |>
  select(c("name.x", "name.y", "dynasty_binary"))
  
  
  #match based on tea) |>

?stringdist_inner_join
#test for git 


## Replication attempt ----

state_year <- state_year |>
  mutate(post_year = if_else(year > 2001, 1, 0)) |>
  mutate(PIT = avg*100) 

state_year <- state_year |>
  group_by(year) |>
  mutate(pop_90to97_natl = sum(pop_90to97)) |>
  mutate(topshr_90to97 = (pop_90to97/pop_90to97_natl)*100) |>
  mutate(total_wealth = sum(wealth)) |>
  mutate(wealth_share = (wealth/total_wealth)*100) |>
  mutate(stockpc = (stock/pop)*1000) |>
  mutate(inheritance_estate = if_else(EI == 1 | Ionly == 1, 1, 0))

state_year$Ionly

mod1 <- feols(stock ~ EI*post_year + EI  | State + year, state_year)
mod2 <- feols(stock ~ EI*post_year + EI + PIT*post_year + PIT | State + year, state_year)
mod3 <- feols(stock ~ EI*post_year + EI + topshr_90to97  | State + year, state_year)
mod5 <- feols(stockpc ~ EI*post_year + EI  | State + year, state_year)
mod6 <- feols(wealth ~ EI*post_year + EI  | State + year, state_year)
mod7 <- feols(stock ~ inheritance_estate*post_year + inheritance_estate | State + year, state_year)

summary(mod7)
#create dataset without 2002-2004
state_year_drop <- state_year|>
  filter(year != "2002",
         year != "2003",
         year != "2004")

mod8 <- feols(stock ~ EI*post_year + EI  | State + year, state_year_drop)


modelsummary(list(mod1, mod2, mod3, mod5, mod6, mod7, mod8), gof_map = c("nobs", "FE: State", "FE: year"))


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


