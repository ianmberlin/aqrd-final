/*
RA: Amber Flaharty
Economist: Dan Wilson
Date Modified: 9/19/2018
Description: Converts NBER tax data to Stata dateset. The tax data is then 
merged with Forbes data. Scatter plots are then created using this merged data for the years 1985,1995, and 2005.
*/

clear all
set more off
cap log close
version 14
pause on


cd "$root"

//Import and save as Stata Dataset
import excel using "data\raw_data\StateMaxTaxRates\state-sort2.xlsx",firstrow clear
drop if State=="federal"
save "data\stata_data\State_Max_Tax_Rates.dta", replace 

// Pull in statefips crosswalk
import excel using "data\raw_data\state_fips_crosswalk.xlsx", firstrow clear
tempfile state
save `state'

//Merge in population by state
use "data\stata_data\pop_merged_crosswalk.dta",clear
collapse (sum) pop, by(statefips year)

tempfile popcrosswalk
save `popcrosswalk'

//Merge into Forbes data
use "data\stata_data\Kaplan_and_Rauh_merged.dta", clear
merge m:1 year statefips using `popcrosswalk', nogen keep(master match)

//Merge in state name to Forbes data set
merge m:1 statefips using `state', nogen keep(master match) assert(match master using)

//Merge in state tax data to Forbes data set
rename year Year
merge m:1 State Year using "data\stata_data\State_Max_Tax_Rates.dta", nogen assert(match master using)
save "data\stata_data\Tax_Rate_Merged_2.dta", replace
