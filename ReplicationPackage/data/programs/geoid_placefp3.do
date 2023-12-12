/*
RA: Annemarie Schweinert
Economist: Dan Wilson
Date modified: July 9, 2018
Description: Create crosswalk file containing Census place names, counties, and Consolidated Statistical Areas.
*/

/*PUll in CDP data and clean it 
First clean placename strings for merging
Final string cleaning for merging
*/

cd "$root"

import delimited "./data/raw_data/MAGGOT_geocorr14.csv", varnames(1) clear
drop if _n==1
drop necta* afact

///Cleaning the strings. Creating an etype for locations that we won't likely see
rename placenm temp_city
levelsof stab, local(statenames)
foreach s of local statenames {
  replace temp_city = usubinstr(temp_city,", `s'","",.)
  replace cntyname = usubinstr(cntyname," `s'","",.)
}

g etype = 1 
local ki = 2
foreach type in comunidad zona reservation county {
  replace etype = `ki' if regexm(temp_city, "`type'")==1
  replace temp_city = strtrim(subinstr(temp_city, "`type'", "", .))
  local ki = `ki'+1
}
foreach type in CDP town city village Village City metropolitan government metro consolidated unified borough {
  replace temp_city = strtrim(subinstr(temp_city, " `type'", "", .))
}
replace temp_city = strtrim(subinstr(temp_city, " (balance)", "", .))

rename state statefips
destring statefips county cousubfp placefp cbsa10 csa10 metdiv10 pop10, replace

replace temp_city = strproper(temp_city)
*replace temp_city = temp_city + " " + EntityDescription if  regexm(EntityDesc, "Reservation")==1
replace temp_city = strproper(strtrim(subinstr(temp_city, "Village", "", .)))
replace temp_city = strtrim(subinstr(subinstr(subinstr(subinstr(temp_city, "County", "",.), "  ", " ", .), "Cdp", "", .), "Town", "", .))

sort statefips temp_city etype pop10
duplicates drop temp_city stab statefips etype, force
replace temp_city = strproper(strtrim(subinstr(subinstr(subinstr(subinstr(temp_city,"•", "", .),".", " ", .),"*", " ", .),"  ", " ",  .)))
replace temp_city = subinstr(temp_city,"Urban ","",.)

duplicates drop statefips placefp temp_city etype, force

/// Affix list of CCD names in case they are not already included in the place names
preserve
replace cousubnm = usubinstr(cousubnm," CCD","",.)
replace cousubnm = usubinstr(cousubnm," township","",.)
replace cousubnm = usubinstr(cousubnm," town","",.)
replace cousubnm = usubinstr(cousubnm," borough","",.)
replace cousubnm = usubinstr(cousubnm," village","",.)
replace cousubnm = usubinstr(cousubnm," city","",.)
egen tag = tag(cousubfp statefips)
keep if tag
drop tag
replace temp_city = cousubnm
tempfile CCD
save `CCD'
restore

append using `CCD'

/// remove duplicate temp_city*statefips observations...keep highest pop observation
gen popinv = 1/pop10
sort statefips temp_city popinv
egen tag = tag(statefips temp_city)
keep if tag
drop tag popinv

save "./data/stata_data/temp_crosswalk_for_CDPv4.dta", replace
