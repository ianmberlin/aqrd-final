******************************
* Description: File reads in locations and names from the Forbes 400. Merges
* with state populations, median earnings in each state, and state gpd from Haver.
*
* Date modified: May 15, 2018
* RA(s): Nathaniel Barlow and Annemarie Schweinert
* Economist(s): Daniel J. Wilson and Enrico Moretti
*****************************


clear all
set more off
cap log close
version 14
pause on

cd "$root"

*Fips codes w/ abbrevations
import excel "./data/raw_data/fips_codes.xlsx", sheet("fips") firstrow clear
keep StateAbbreviation StateFIPSCode
duplicates drop
rename StateAbbreviation stateabbv
rename StateFIPS statefips

*Creates local of all state abbrevations for Haver loop
*(Need to remove Puerto Rico)
levelsof stateabbv, local(for_haver2)
local nos "PR "
local for_haver: list for_haver2 - nos
tempfile all
save "`all'"
g test = 1
tempfile all2
save "`all2'"

foreach var of local for_haver{

*Import State populations, median income, and state gdp
import haver `var'RBT@USPOP `var'HMY@USPOP `var'TOH@GSP, tvar(time) clear
*freduse `var'POP, clear
*State abbrevation for later merge
g stateabbv = "`var'"
*synchronize variables, need to lower case for rename
local s = lower("`var'")
g pop = `s'rbt_uspop
g median_hh_income = `s'hmy_uspop
g gdp = `s'toh_gsp

*Drop extra variables
drop `s'rbt_uspop `s'hmy_uspop `s'toh_gsp

cap append using "`all2'"

cap save "`all2'", replace
}
*Drop blank series w/o haver
drop if test==1
drop test statefips

*Merge with abbrevations for statefips number
merge m:1 stateabbv using "`all'", nogen
g year = time
drop if year<1980

*Need to loop through three times for those with three locations listed
destring statefips, replace

*Merge together the Forbes 400 lists and the tax rates from Dan and Enrico's paper
tostring year, replace
keep year stateabbv pop statefips median_hh_income gdp
rename pop pop1
rename median_hh_income median_hh_income
rename gdp gdp
rename stateabbv stbv

merge 1:m year statefips using "./data/stata_data/Forbes_400_locality_data_CDP.dta", nogen keep(2 3)
rename stbv state
destring year, replace

merge m:1 year state using "./data/stata_data/taxrates_p50_p95_p99_p999.dta", nogen keep(1 3)
tostring year, replace
rename state stbv

save "./data/stata_data/forbes400_DW_EM_pop.dta", replace
