/*
RA: Amber Flaharty
Economist: Dan Wilson
Date Modified: 9/10/2018
Description: Merges in, and creates, collapsed population data by CA.

*/

clear all
set more off
cap log close
version 14
pause on

cd "$root/data"

*set haverdir "M:/Haver/DLX/DATA"

/// First get the haver concordence from county names to fips codes
import excel using ./raw_data/fips_haver_county_codes.xls, clear firstrow case(lower)
destring fips, replace
drop c
replace haver=lower(haver)
levelsof haver, local(havercodes)
save stata_data/HaverCountyNameToFipsMapping.dta, replace

/// Import population data
clear
foreach county in `havercodes' {
	cap import haver (`county'RBT)@USPOP, tvar(year) fin(1970,2017) clear
	if _rc==0 {
		gen haver="`county'"
		rename `county'rbt_uspop pop
		tempfile `county'
		qui save "``county''"
	}
	else {
		clear
	}
}
clear
foreach county in `havercodes' {
  cap append using "``county''"
}
merge m:1 haver using stata_data/HaverCountyNameToFipsMapping.dta, nogen keep(3)
drop haver
order year fips
save stata_data/population.dta, replace


// Merge population data with crosswalk, collapsing by CA
use "stata_data/temp_crosswalk_for_CDPv4.dta", clear
rename county fips
// Attempting to pull just one instance of the county from the crosswalk
egen first = tag(fips)
drop if first == 0
drop first
merge 1:m fips using "stata_data/population.dta", nogen keep(master match)
rename csa10 CSA //Recycling code from clean_forbes_cities_with_CDP_gazetter_and_crosswalk4 to make naming consistent
rename cbsa10 CBSA
rename csaname10 CSAname
rename cbsaname10 CBSAname
gen CA = CSA if CSA~=999
replace CA = CBSA if CSA==999
replace CA = placefp if CSA==999 & CBSA==99999

gen CAname = CSAname if CSA~=999
replace CAname = CBSAname if CSA==999

keep fips statefips cntyname year pop CA 
save "pop_merged_crosswalk.dta", replace
