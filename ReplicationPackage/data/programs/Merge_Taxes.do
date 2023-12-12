/*
RA: Amber Flaharty
Economist: Dan Wilson
Date Modified: 1/31/2019
Description: Converts NBER tax data to Stata dateset. The tax data is then 
merged with Forbes data. Scatter plots are then created using this merged data for the years 1985,1995, and 2005.
*/

clear all
set more off
cap log close
version 14
pause on

cd "$root/data"

//Import and save as Stata Dataset
import excel using "raw_data\CITrates110618.xlsx", sheet("Data") firstrow clear
save "stata_data\CIT_Rates.dta", replace 

// Merge in CIT rates
use "stata_data/Tax_Rate_Merged_2.dta", clear
merge m:1 State Year using "stata_data\CIT_Rates.dta", nogen assert(match master using)
save "stata_data/CIT_Rate_Merged.dta", replace

// Merge in E&I and Total Tax Revenues
import excel using "raw_data\EstateTaxes\STC_Historical_DB (2017).xls", firstrow clear

//Clean up data before merging in
keep Year Name C105 T50
drop if Year == .
rename C105 Total_Taxes
rename T50 EI_Tax
replace Name = substr(Name,1,2) 
drop if Name == "US"
rename Name abbr
replace EI_Tax = "" if EI_Tax == "X"
replace EI_Tax = subinstr(EI_Tax, ",", "",.)
destring EI_Tax, replace

save "stata_data\EI_Tax.dta", replace

//Merge
use "stata_data/CIT_Rate_Merged.dta", clear
merge m:1 abbr Year using "stata_data/EI_Tax.dta", nogen assert(match master using) 
save "stata_data/EI_Tax_Merged.dta", replace
