/*
RA: Amber Flaharty
Economist: Dan Wilson
Date Modified: 3/30/2020
Description: Program fixes inconsistent names by pulling in fixed names from fuzzy string match in Python.
*/

version 14
clear all
set more off
cap log close

cd "$root"

local d = c(current_date)
di "`d'"
log using "log/Inconsistent_Name_Check_`d'.log", replace

//Pull in name fix data
import excel using "data/raw_data/manual_name_check_v2.xlsx", sheet("to_input") firstrow clear

tempfile fix
save `fix'

//Pull in Forbes data
//use "data/stata_data/IndivAnalysisDataset.dta", clear
use "data/stata_data/EI_Tax_Merged.dta", clear

//Did one manual fix
replace Name = "Ann Clark Rockefeller Harris" if Name == "Arm Clark Rockefeller Harris"
replace firstname = "Ann" if Name == "Ann Clark Rockefeller Harris"

//Merge in fixes
drop _m
merge m:1 Name using `fix'

//Replace with correct values
replace Name = FixedName if _m == 3
replace firstname = first if _m == 3
replace midname = mid if _m == 3
replace lastname = last if _m == 3

//Drop additional variables
drop FixedName first mid last

//Save fixed dataset
//save "data/stata_data/IndivAnalysisDataset_Names_Fixed.dta", replace
save "data/stata_data/EI_Tax_Merged_v2.dta", replace 
