library(tidyverse) 
library(haven)
library(modelsummary)
library(vtable)
library(fixest)
library(gt)
library(readxl)
library(usethis)
library(panelView)
library(patchwork)
library(zoomerjoin)
library(broom)

## Load Files
state_year<- read_dta("ReplicationPackage/data/stata_data/StateyearAnalysisDataset.dta")
person_year_orig <- read_dta("ReplicationPackage/data/stata_data/IndivAnalysisDataset.dta") 

person_year <- person_year_orig |>
  rename(name = Name) |>
  filter(!year %in% c("1982", "1984"))

dynastic <- read_excel("data/Forbes 400 Aggregate with Dynasty Members.xlsx") |>
  mutate(across(where(is.character), str_trim))

## Fuzzy Matching ----

# clean data and prepare for matching
dynasty_long <- dynastic |>
  filter(dynasty_binary != "") |>
  mutate(dynasty_binary = as.character(dynasty_binary)) |> 
  select(!"Grand Total") |>
  mutate(name = gsub("(Child|Spouse|spouse).*", "", name)) |>
  pivot_longer(cols = !c("name", "dynasty_binary"),
               names_to = "year",
               values_to = "NetWorth") |>
  filter(NetWorth != "",
         !year %in% c("2002", "2018", "2019", "2020")) |>
  mutate(NetWorthMill = NetWorth/1000000,
         name_lower = tolower(name))

# convert to lower to minimize false negatives
person_year <- person_year |>
  mutate(name_lower = tolower(name))

# fuzzy match 
join_wide <- jaccard_left_join(person_year, dynasty_long,
                          by = c("name_lower" = "name_lower"),
                          block_by = c("year" = "year"),
                          n_gram_width = 3,
                          band_width = 3, 
                          n_bands = 100, 
                          threshold = .6,
                          similarity_column = "dist") |>
  select("year.x", "year.y", "name.x", "name.y", "dynasty_binary", "NetWorthMill.x", "NetWorthMill.y", "dist") |>
  mutate(NetWorthMill.x = round(NetWorthMill.x,0),
         match = if_else(NetWorthMill.x == NetWorthMill.y, 1, 0)) |>
  arrange(match, dist)

# export to csv
write.csv(join_wide, "data/fuzzy_match_wide_partial.csv")

## Additional cleaning in Excel to hand match names that did not fuzzy match

# Read in cleaned CSV
cleaned <- read.csv("data/fuzzy_match_wide.csv") |>
  select(c("year.x", "name.x", "dynasty_binary"))

# merge with Moretti data
merged <- left_join(person_year, cleaned,
                    by = c("name" = "name.x", "year" = "year.x")) |>
  rename("dynasty" = "dynasty_binary") |>
  mutate(State = as.factor(State),
         year = as.factor(year),
         dynasty = as.factor(dynasty),
         our_wealthy = as.factor(our_wealthy),
         dynasty_either = as.factor(if_else(dynasty == 1 | our_wealthy == 1, 1, 0)),
  dynasty_both = as.factor(if_else(dynasty == 1 & our_wealthy == 1, 1, 0)))


counts_fernholz <- merged |>
  group_by(State, year, dynasty, .drop = FALSE) |>
  summarize(stock_fernholz = n(),
            NetWorth_fernholz = sum(NetWorthMill, na.rm = TRUE))

counts_moretti <- merged |>
  group_by(State, year, our_wealthy, .drop = FALSE) |>
  summarize(stock_moretti = n(),
            NetWorth_moretti = sum(NetWorthMill, na.rm = TRUE))

counts_either <- merged |>
  group_by(State, year, dynasty_either, .drop = FALSE) |>
  summarize(stock_either = n(),
            NetWorth_either = sum(NetWorthMill, na.rm = TRUE))

counts_both <- merged |>
  group_by(State, year, dynasty_both, .drop = FALSE) |>
  summarize(stock_both = n(),
            NetWorth_both = sum(NetWorthMill, na.rm = TRUE))

counts <- counts_fernholz |>
  left_join(counts_moretti, by = c("State" = "State", 
                                   "year" = "year", 
                                   "dynasty" = "our_wealthy")) |>
  left_join(counts_either, by = c("State" = "State", 
                                    "year" = "year", 
                                    "dynasty" = "dynasty_either")) |>
  left_join(counts_both, by = c("State" = "State", 
                                     "year" = "year", 
                                     "dynasty" = "dynasty_both"))

# create combined dataset for triple-difference analysis
state_year_dynasty <- state_year |>
  filter(!year %in% c("1982", "1984")) |>
  slice(rep(1:n(), each = 2)) |>
  select(- c("stock", "wealth", "NetWorthMill")) |>
  mutate(State = as.factor(State),
         year = as.factor(year))|>
  add_column(dynasty = as.factor(rep(c(0, 1), length.out = 2*(nrow(state_year)-100))),
             .after = "abbr") |>
  left_join(counts, by = c("State" = "State", "year" = "year", "dynasty" = "dynasty"))

# Panel View
state_year |>
  panelview(stock ~ EI,
            index = c("State", "year"),
            axis.lab.gap = c(1,0),
            xlab = "",
            ylab = "",
            main = "Estate Tax",
            leave.gap = TRUE)

ggsave("template/figures/panelview.png", height = 6, width = 6)


## Replication ----

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
  geom_line(linewidth = 1) +
  geom_segment(aes(x = 1983, y = 21.4, xend = 2001, yend = 21.4), 
               linetype = "dashed", color = "red") +
  geom_segment(aes(x = 2002, y = 17.4, xend = 2017, yend = 17.4), 
               linetype = "dashed", color = "red") +
  geom_vline(xintercept = 2001) +
  annotate("rect",xmin = 2001, xmax = 2004, ymin = -Inf, ymax = Inf, alpha = .5) +
  scale_y_continuous(limits =c(0,30),
                     breaks = seq(0, 30, by = 5)) +
  scale_x_continuous(breaks = seq(1985, 2015, by = 10)) +
  labs(x = "Year",
       y = "Percentage",
       caption = "Notes: Year 2002 is missing. Dashed horizontal lines are the mean before 2001 and after 2001.")

ggsave("template/figures/figure5.png", height = 4, width = 6)

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
  scale_y_continuous(limits = c(0, .5)) +
  labs(x = "Age",
       y = "Fraction of age group living\n in state with estate tax",
       title = "Panel A. 1982–2001")

trend_post <- person_year_orig |> 
  filter(Age_num > 40,
         Age_num <= 85,
         year > 2001) |>
  group_by(Age_num) |>
  summarize(share = mean(EI)) |>
  ggplot(aes(x = Age_num, y = share)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", se = F, color = "darkred") +
  scale_y_continuous(limits = c(0, .5)) +
  labs(x = "Age",
       y = "Fraction of age group living\n in state with estate tax",
       title = "Panel B. 2003–2017")

# combine graphs
trend_pre + trend_post

ggsave("template/figures/figure_6.png", width = 8, height = 4)

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

models_1 <- list("(1)" = mod1, 
               "(2)" = mod2, 
               "(3)" = mod3,
               "Per Capita (5)" = mod5,
               "Drop 2002-2004 
               (8)" = mod8
               )

reg1 <- modelsummary(models_1,
             gof_map = c("nobs", "FE: State", "FE: year"),
             coef_map = c("EI:post_year" = "ET-state × post-2001",
                          "EI" = "ET-State",
                          "post_year:PIT" = "PIT × post-2001",
                          "PIT" = "PIT",
                          "topshr_90to97" = "High earners share"),
             output = "gt") |>
  tab_options(
    table.font.size = px(12),
    table.width = px(400),
    data_row.padding = px(1.5)) |>
  opt_table_font(stack = "transitional")

gtsave(reg1, "template/tables/reg1.png")
  

# Triple Differences

state_year_dynasty <- state_year_dynasty |>
  mutate(year = as.character(year),
         post_year = if_else(year > 2001, 1, 0),
         PIT = avg*100) |>
  group_by(year) |>
  mutate(pop_90to97_natl = sum(pop_90to97),
         topshr_90to97 = (pop_90to97/pop_90to97_natl)*100,
         stockpc = (stock_fernholz/pop)*1000)

mod2_1 <- feols(stock_fernholz ~ EI*post_year*dynasty + EI*dynasty + EI*post_year + dynasty*post_year | State + year, state_year_dynasty)

mod2_2 <- feols(stock_fernholz ~ EI*post_year*dynasty + EI*dynasty + EI*post_year + dynasty*post_year + PIT*post_year*dynasty + PIT*dynasty + PIT*post_year | State + year, state_year_dynasty)

mod2_3 <- feols(stock_fernholz ~ EI*post_year*dynasty + EI*dynasty + EI*post_year + dynasty*post_year + EI + dynasty + topshr_90to97| State + year, state_year_dynasty)

mod2_4 <- feols(stockpc ~ EI*post_year*dynasty + EI*dynasty + EI*post_year + dynasty*post_year | State + year, state_year_dynasty)

summary(mod2_4)

mod_moretti <- feols(stock_moretti ~ EI*post_year*dynasty + EI*dynasty + EI*post_year + dynasty*post_year | State + year, state_year_dynasty)

mod_either <- feols(stock_either ~ EI*post_year*dynasty + EI*dynasty + EI*post_year + dynasty*post_year | State + year, state_year_dynasty)

mod_both <- feols(stock_both ~ EI*post_year*dynasty + EI*dynasty + EI*post_year + dynasty*post_year | State + year, state_year_dynasty)

# drop 2002-2004
state_year_dynasty_drop <- state_year_dynasty |>
  filter(!year %in% c("2002", "2003", "2004"))

mod_drop <- feols(stock_fernholz ~ EI*post_year*dynasty + EI*dynasty + EI*post_year + dynasty*post_year | State + year, state_year_dynasty_drop)

models_2 <- list(mod2_1, mod2_2, mod2_3, "Per Capita" = mod2_4, "Moretti Codings" = mod_moretti, "Either" = mod_either, "Both" = mod_both, "Drop 2002-2004" = mod_drop)

reg2 <- modelsummary(models_2,
             gof_map = c("nobs", "FE: State", "FE: year"),
             coef_map = c("EI:post_year:dynasty1" = "ET-state × post-2001 x dynasty",
                          "EI:dynasty1" = "ET-state × dynasty",
                          "EI:post_year" = "ET-state × post-2001",
                          "post_year:dynasty1" = "Dynasty x post-2001",
                          "EI" = "ET-State",
                          "dynasty1" = "Dynasty",
                          "post_year:dynasty1:PIT" = "PIT × post-2001 x dynasty",
                          "dymasty1:PIT" = "PIT × dynasty",
                          "post_year:PIT" = "PIT × post-2001",
                          "PIT" = "PIT",
                          "topshr_90to97" = "High earners share"),
             stars = TRUE,
             output = "gt") |>
  tab_options(
    table.font.size = px(14),
    table.width = px(500),
    data_row.padding = px(1.5)) |>
  opt_table_font(stack = "transitional")

gtsave(reg2, "template/tables/reg2.png")

# Summary Statistics ----

summary <- merged |>
  select(NetWorthMill, Age_num, EI, dynasty, our_wealthy) |> 
  mutate(dynasty = as.double(dynasty)-1,
         our_wealthy = as.double(our_wealthy)-1) |>
  pivot_longer(cols = everything()) |>
  group_by(name) |>
  summarize(
    mean = mean(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE),
    n = sum(!is.na(value))
  ) |>
  ## rename variable descriptions
  mutate(name = recode_factor(
    name,
    Age_num = "Age",
    EI = "Estate Tax State (0 or 1)",
    NetWorthMill = "Net Worth (USD millions)",
    dynasty = "Fernholz and Hagler Dynasty Indicator (0 or 1)",
    our_wealthy = "Moretti and Wilson Dynasty Indicator (0 or 1)")) |>
  arrange(name) |>
  gt() |>
  cols_align("left", 1) |>
  cols_label(name = "", mean = "Mean", sd = "Sd", n = "N") |>
  fmt_number(columns = c(mean, sd), decimals = 2) |>
  ## add commas to integers
  fmt_integer(columns = n) |>
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_row_groups()
  )

gtsave(summary, "template/tables/summarystats.tex")

# Table 1
mean_wealth <- state_year |> 
  filter(year == 2017) |>
  group_by(State) |>
  mutate(pbwealth = NetWorthMill/stock) |>
  summarize(mean = mean(pbwealth))  |>
  select(mean)
  

tab1_df <- state_year |>
  filter(year %in% c("1982", "2000", "2017")) |>
  mutate(pbwealth = NetWorthMill/stock) |>
  select(stock, year, State) |>
  pivot_wider(names_from = year,
              values_from = stock) |>
  mutate(stock_delta82_17 = `2017` - `1982`,
         stock_delta82_00 = `2000` - `1982`,
         stock_delta00_17 = `2017` - `2000`) |>
  arrange(State) |>
  add_column(mean_wealth,
             .after = "2017") |>
  select(State, `2017`, mean, stock_delta82_17, stock_delta82_00, stock_delta00_17)



tab1 <- gt(tab1_df) |>
  cols_label(State = "State", `2017` = "Forbes population in 2017", 
                           mean = "Per capita mean wealth in 2017 (mil)",
                           stock_delta82_17 = "1982–2017 Change in Forbes population",
                           stock_delta82_00 = "1982–2000 Change in Forbes population",
                        stock_delta00_17 = "2000–2017 Change in Forbes population") |>
  sub_missing(
    columns = everything(),
    missing_text = "") |>
  fmt_number(columns = c(mean), decimals = 0) |>
  opt_table_font(stack = "transitional") |>
  tab_options(
    table.font.size = px(15),
    table.width = px(800),
    data_row.padding = px(1)
  ) |>
  tab_style(
    style = list(
      cell_borders(
        sides = "bottom",
        style = "hidden"
      )
    ),
    locations = cells_body()
  ) |>
  cols_width(
    everything() ~ px(100)
  )

gtsave(tab1, "template/tables/table1.tex")

