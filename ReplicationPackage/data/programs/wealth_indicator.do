clear all
set more off
cap log close
version 14
pause on

cd "$root/data"

// Pull in Kaplan/Rauh data and save as Stata file
import excel using "./raw_data/KaplanRauh.xlsx", firstrow sheet("KaplanRauh") clear
save "stata_data/KaplanRauh.dta", replace

keep if year == 2001 
g id = _n
tempfile relevantyears
save `relevantyears'

use "stata_data/Forbes_400_net_worth_and_rank_cleaned2.dta", clear

// Creating wealth variable replication: inheritance
g our_wealthy = 0
gen Age_num = real(Age)			//eventually pull out numbers within this string so they don't get set to missing

egen MaxAgeByFamily = max(Age_num), by(lastname year Source)
replace MaxAgeByFamily = . if Source==""
gen kid = ( (Age_num <= MaxAgeByFamily - 21) & MaxAgeByFamily~=. & Age_num~=. )
egen kid_ever = max(kid), by(Name)
replace our_wealthy = 2 if kid_ever>0 

g inh_included = regexm(Source, "inh")
replace inh_included = regexm(Source, "Inh")
egen inh_number = total(inh_included), by(Name)
replace our_wealthy = 2 if inh_number > 0

/// Fix our_wealthy for erroneous cases we've discovered
replace our_wealthy = 0 if Name=="Samuel Moore Walton"
replace our_wealthy = 2 if lastname=="Walton" & inlist(firstname,"Helen","Helena")
replace our_wealthy = 2 if family==1 & inlist(firstname,"","De","Du")

drop inh_*
save "stata_data/master_031119.dta", replace

//Merge Kaplan/Rauh data for 2001 and 2011(the other two years are lacking rankings)
destring year, replace
*keep if year == 2001 
bysort year: g id = _n
merge 1:1 id Forbes_Rank year using `relevantyears'
save "stata_data/Kaplan_and_Rauh_merged.dta", replace

/*
// Fixing location errors noticed when trying to merge
drop if Residence == "Washington, District Of Columbia" & statefips == 29 & Name == "Steven Rales"
drop if Residence == "New York, N/A" & temp_city == "" 
drop if Residence == "Green Bay, N/A" & temp_city == ""
drop if Residence == "Las Vegas, N/A" & temp_city == "" 
*/





