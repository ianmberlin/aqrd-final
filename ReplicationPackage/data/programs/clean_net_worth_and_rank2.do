/*
RAs: 			Amber Flaharty
Economists: 	Enrico Morretti and Dan Wilson
Date created:   July 11, 2018
Date modified:  July 19, 2018
Notes: Cleans net worth variable by creating NetWorthMill, in which all amounts are in million dollar increments. 
Fills in missing values for Rank by creating rankings based off NetWorthMill where ranking data is not available.  			

*/

clear all
set more off
cap log close
version 14
pause on

use "$root/data/stata_data/Forbes_400_locality_data_CDP.dta", clear

// Labeling all billion values with billion
forvalues j = 0/9{
replace NetWorth = NetWorth + " billion" if strpos(NetWorth, ".`j'") != 0 & regexm(NetWorth, "B") != 1 & regexm(NetWorth, "b") != 1
}
replace NetWorth = subinstr(NetWorth, "Billion", " billion",.)
replace NetWorth = subinstr(NetWorth, "B", " billion",.) 

// Remove outliers for 1982 and 1983
replace NetWorth = "400 million" if year == "1982" & Name == "Kennedy"
replace NetWorth = "343 million" if year == "1983" & Name == "John Hammond Krehbiel Jr"
foreach x of numlist 1/9 {
	replace NetWorth = "1`x'00 million" if NetWorth=="1.`x' billion."
	replace NetWorth = "2`x'00 million" if NetWorth=="2.`x' billion."
	replace NetWorth = "3`x'00 million" if NetWorth=="3.`x' billion."
}
replace NetWorth = "330 million" if NetWorth=="33d million."
replace NetWorth = "430 million" if NetWorth == ". 430"

// Getting rid of strange character in NW 
*replace NetWorth = subinstr(NetWorth, ".","",.)
replace NetWorth = subinstr(NetWorth, "$","",.)
replace NetWorth = subinstr(NetWorth, "million","",.)
replace NetWorth = subinstr(NetWorth, "-x","",.)
replace NetWorth = subinstr(NetWorth, "*","",.)
replace NetWorth = subinstr(NetWorth, "-","",.)
replace NetWorth = subinstr(NetWorth, ",","",.)
replace NetWorth = subinstr(NetWorth, `"""',"",.)
replace NetWorth = subinstr(NetWorth, "+","",.)
replace NetWorth = subinstr(NetWorth, "'","",.)
replace NetWorth = subinstr(NetWorth, "`","",.)
replace NetWorth = subinstr(NetWorth, "..","",.)
replace NetWorth = subinstr(NetWorth, " ","",.) if regexm(NetWorth,"b") != 1 
replace NetWorth = strtrim(subinstr(NetWorth, "v", "",.))
replace NetWorth = strtrim(subinstr(NetWorth, "Stockmarket", "",.))

// Converting billion to million
replace NetWorth = NetWorth + " million" if regexm(NetWorth, " ") != 1 & regexm(NetWorth, "b") != 1  & NetWorth!="" & NetWorth!="N/A"
generate billion = (regexm(NetWorth, "billion")==1)
replace NetWorth = "1000 million" if NetWorth=="1 million"
replace NetWorth = "2000 million" if NetWorth=="2 million"
replace NetWorth = "3000 million" if NetWorth=="3 million"
replace NetWorth = "4000 million" if NetWorth=="4 million"
replace NetWorth = "5000 million" if NetWorth=="5 million"
generate NetWorthMill = NetWorth
replace NetWorthMill = strtrim(subinstr(NetWorthMill, " billion", "",.))
replace NetWorthMill = strtrim(subinstr(NetWorthMill, " million","",.))
destring NetWorthMill, replace force
replace NetWorthMill = NetWorthMill * 1000 if billion == 1

// Destring rank
destring Rank, replace force

// Sorting new million dollar variable
sort y Rank NetWorthMill
// Sorting to find missing values in rank
egen first_ob = tag(Name y)
bysort y: egen ourrank = rank(NetWorthMill) if first_ob == 1, field

//Replace missing ranks where NetWorthMill ranking is available
**replace Rank = ourrank if missing(Rank)
rename Rank Forbes_Rank

// Making changes to strange name occurences in data
replace lastname = Name if lastname == ""
replace lastname = "Fisher" if Name == "Fisher (Seattle)" 
replace firstname = "" if Name == "Fisher (Seattle)"

//Sorting
sort y Forbes_Rank ourrank lastname firstname midname
// Creating ID for appropriate merge years
/*
foreach letter in a b c d{
foreach y in 1982 1992 2001 2011{
gen `letter'_id = _n
}
}
*gen id = _n if y == 1982 | y == 1992 | y == 2001 | y == 2011
*/


save "$root/data/stata_data/Forbes_400_net_worth_and_rank_cleaned2.dta", replace
