library(tidyverse) 
library(haven)
library(modelsummary)
library(vtable)
library(fixest)
library(gt)
library(readxl)
library(fuzzyjoin)
library(usethis)
library(panelView)
library(patchwork)
library(zoomerjoin)

install.packages(
  'zoomerjoin',
  repos = c('https://beniaminogreen.r-universe.dev', getOption("repos"))
)

# Load Files
state_year<- read_dta("ReplicationPackage/data/stata_data/StateyearAnalysisDataset.dta")
state_year_age <- read_dta("ReplicationPackage/data/stata_data/StateyearAgeAnalysisDataset.dta")
person_year_orig <- read_dta("ReplicationPackage/data/stata_data/IndivAnalysisDataset.dta") 

person_year <- person_year_orig |>
  rename(name = Name) |>
  filter(!year %in% c("1982", "1984")) |>
  mutate(across(where(is.character), str_trim))

dynastic <- read_excel("data/Forbes 400 Aggregate with Dynasty Members.xlsx") |>
  mutate(across(where(is.character), str_trim))

## Fuzzy Matching ----
dynasty_clean <- dynastic |>
  filter(dynasty_binary != "") |>
  mutate(dynasty_binary = as.character(dynasty_binary)) |> 
  select(!"Grand Total") |>
  mutate(name = gsub("(Child|Spouse).*", "", name)) |>
  pivot_longer(cols = !c("name", "dynasty_binary"),
               names_to = "year",
               values_to = "NetWorth") |>
  filter(NetWorth != "",
         !year %in% c("2002", "2018", "2019", "2020")) |>
  pivot_wider(id_cols = c("name", "dynasty_binary"),
              names_from = year,
              values_from = NetWorth,
              names_sort = TRUE) |>
  select(c("name", "dynasty_binary"))

moretti_names <- person_year |>
  arrange(lastname) |>
  select(name) |>
  unique()

dynasty_clean <- dynasty_clean |>
  mutate(name_lower = tolower(name))

moretti_names <- moretti_names |>
  mutate(name_lower = tolower(name))

join <- jaccard_inner_join(moretti_names, dynasty_clean,
                   by = c("name_lower" = "name_lower"), # THE TWO COLUMN NAMES # but make both lowercase first
                   n_gram_width = 2,
                   band_width = 5, 
                   n_bands = 100, 
                   threshold = .7,
                   similarity_column = "dist") |>
  arrange(name.x) |>
  mutate(moretti_is_na = ifelse(is.na(name.y), 1, 0))

?jaccard_inner_join

join <- stringdist_join(moretti_names, dynasty_clean,
                by='name',
                method = "lv",
                mode = "inner",
                max_dist = 1,
                distance_col = 'dist') |>
  select(c("name.x", "name.y", "dynasty_binary", "dist"))
  

dynasty_long <- dynastic |>
  filter(dynasty_binary != "") |>
  mutate(dynasty_binary = as.character(dynasty_binary)) |> 
  select(!"Grand Total") |>
  mutate(name = gsub("(Child|Spouse).*", "", name)) |>
  pivot_longer(cols = !c("name", "dynasty_binary"),
               names_to = "year",
               values_to = "NetWorth") |>
  filter(NetWorth != "",
         !year %in% c("2002", "2018", "2019", "2020")) |>
  mutate(NetWorthMill = NetWorth/1000000)

distance_join(person_year, dynasty_long,
              by = join_by(name, year, NetWorthMill),
              mode = "inner",
              max_dist = 1,
              distance_col = "dist")


#test for git 

# Panel View

state_year |>
  panelview(stock ~ EI,
            index = c("State", "year"),
            axis.lab.gap = c(1,0),
            xlab = "",
            ylab = "",
            main = "Estate Tax",
            leave.gap = TRUE)

?panelview

test <- state_year |>
  group_by(year) |>
  count()

## Replication attempt ----

# Figure 5.

person_year_orig <- person_year_orig |> 
  group_by(State) |>
  mutate(EI2001 = if_else(any(year == 2001 & EI == 1), 1, 0)) |>
  ungroup() |>
  mutate(prepost = case_when(year < 2001 ~ 0,
                             year > 2001 ~ 1))

mean <- person_year_orig |>
  group_by(prepost) |>
  summarize(mean = mean(EI2001)*100)

person_year_orig |>
  group_by(year) |>
  summarize(share = mean(EI2001)*100) |>
  ggplot(aes(x = year, y = share)) +
  geom_line() +
  geom_segment(aes(x = 1983, y = 21.4, xend = 2001, yend = 21.4), 
               linetype = "dashed", color = "red") +
  geom_segment(aes(x = 2002, y = 17.4, xend = 2017, yend = 17.4), 
               linetype = "dashed", color = "red") +
  geom_vline(xintercept = 2001) +
  annotate("rect",xmin = 2001, xmax = 2004, ymin = -Inf, ymax = Inf, alpha = .5) +
  scale_y_continuous(limits =c(0,30),
                     breaks = seq(0, 30, by = 5)) +
  labs(x = "Year",
       y = "Percentage")

# Figure 6

trend_pre <- person_year_orig |> 
  filter(Age_num > 40,
         Age_num <= 85,
         year <= 2001) |>
  group_by(Age_num) |>
  summarize(share = mean(EI)) |>
  ggplot(aes(x = Age_num, y = share)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", se = F, color = "darkred") +
  scale_y_continuous(limits = c(0, .5))

trend_post <- person_year_orig |> 
  filter(Age_num > 40,
         Age_num <= 85,
         year > 2001) |>
  group_by(Age_num) |>
  summarize(share = mean(EI)) |>
  ggplot(aes(x = Age_num, y = share)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", se = F, color = "darkred") +
  scale_y_continuous(limits = c(0, .5))

# combine graphs
trend_pre + trend_post

# Table 2
state_year <- state_year |>
  mutate(post_year = if_else(year > 2001, 1, 0)) |>
  mutate(PIT = avg*100) 

mean_2017 <- state_year |>
  filter(year == 2017) |>
  summarize(mean = mean(wealth))

state_year <- state_year |>
  group_by(year) |>
  mutate(pop_90to97_natl = sum(pop_90to97)) |>
  mutate(topshr_90to97 = (pop_90to97/pop_90to97_natl)*100) |>
  mutate(total_wealth = sum(wealth)) |>
  mutate(wealth_share = (wealth/total_wealth)*100) |>
  mutate(stockpc = (stock/pop)*1000) |>
  mutate(inheritance_estate = if_else(EI == 1 | Ionly == 1, 1, 0)) |>
  mutate(wealth_deflated = if_else(year>2001, wealth/52.1, wealth))

wealth


mod1 <- feols(stock ~  EI*post_year | State + year, state_year)
mod2 <- feols(stock ~ EI*post_year  + PIT*post_year + PIT | State + year, state_year)
mod3 <- feols(stock ~ EI*post_year + topshr_90to97  | State + year, state_year)
mod5 <- feols(stockpc ~ EI*post_year | State + year, state_year)
mod6 <- feols(wealth_deflated ~ EI*post_year | State + year, state_year)
mod7 <- feols(stock ~ inheritance_estate*post_year + inheritance_estate | State + year, state_year)

#create dataset without 2002-2004
state_year_drop <- state_year|>
  filter(!year %in% c("2002", "2003", "2004"))

mod8 <- feols(stock ~ EI*post_year + EI  | State + year, state_year_drop)

modelsummary(list(mod1, mod2, mod3, mod5, mod6, mod8),
             gof_map = c("nobs", "FE: State", "FE: year"))
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


