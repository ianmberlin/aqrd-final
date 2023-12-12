/*******************************************************************************

RAs: Amber Flaharty, Mary Yilma
Economist: Daniel Wilson
Date Modified: 12/14/2021
Project: "Taxing Billionaires: Estate Taxes and the Geographical Location of the Ultra-Wealthy" by Enrico Moretti and Daniel Wilson
Description: Builds analysis data sets, constructs descriptive statistics, and runs regressions. 

********************************************************************************/

clear all
set more off
set matsize 11000
cap log close
pause on

/// SET PROGRAMS DIRECTORY. ALL SUBSEQUENT FILEPATHS SHOULD BE RELATIVE TO THIS DIRECTORY.
if "$root" == "" global root = "s:/dan/Paper - Forbes/ReplicationPackage"
cd "$root/data"

local d = c(current_date)
di "`d'"
log using "../log/analysis`d'.log", replace

///SET LOCALS AND GLOBALS
local postyear = 2001

///	Set controls to empty set if no controls:
local controls
local drop_condition "" 
local wealth wealth_normalized

*************************

global BuildData "yes"
global run2D "yes"
global run3D "yes"
global runINDV "yes"
global runMOVERS "yes"
global runCB "yes"
global runCOUNTS_BY_STATE "yes"


if "$BuildData"=="yes" {

//Import state GDP data and create GDP change variable
use "stata_data/gdp_inst.dta", clear 
rename state abbr
xtset fips year, yearly
g gdp_change = 100*log(gdp-L1.gdp)
tempfile stateGDP
save `stateGDP'

//Import EI and Total tax revenues by state and year
use "stata_data/EI_Tax.dta", clear
rename Year year
destring Total_Taxes, replace ignore(",")
tempfile EI_Tax
save `EI_Tax'

//Import population data and create population change variable
import haver ??rbt@uspop, tvar(year) clear
describe *uspop, varlist

foreach var in `r(varlist)' {
	local tmp = strupper(substr("`var'", 1, 2))
	di "`tmp'"
	rename `var' pop`tmp'
}

drop popC1 popC2 popC3 popC4 popC5 popC6 popC7 popC8 popC9
drop popR1 popR2 popR3 popR4 
drop popDC popPR
drop if year < 1981
reshape long pop, i(year) j(state) string
rename state abbr
egen id = group(abbr)
xtset id year, yearly
g pop_change = 100*log(pop-L1.pop)
drop if year==1981


/// ENTER EI INDICATOR
gen EI = 0

/// From Conway & Rork (2004 NTJ), Table 1:
replace EI = 1 if inlist(abbr,"AK","AL","GA","FL","AR","NV")==0 //ALL BUT 6 STATES HAD EI BEYOND PICK-UP TAX PRIOR TO 1976
replace EI = 0 if abbr=="NM" & year>=1976
replace EI = 0 if abbr=="UT" & year>=1977
replace EI = 0 if abbr=="ND" & year>=1979
replace EI = 0 if inlist(abbr,"AZ","VA","CO","VT") & year>=1980
replace EI = 0 if abbr=="MO" & year>=1981
replace EI = 0 if inlist(abbr,"CA","WA") & year>=1982
replace EI = 0 if inlist(abbr,"IL","WY","TX") & year>=1983
replace EI = 0 if abbr=="WV" & year>=1985
replace EI = 0 if inlist(abbr,"MN","ME") & year>=1986
replace EI = 0 if abbr=="OR" & year>=1987
replace EI = 0 if abbr=="ID" & year>=1988
replace EI = 0 if abbr=="WV" & year>=1985
replace EI = 0 if abbr=="RI" & year>=1991
replace EI = 0 if inlist(abbr,"SC","WI") & year>=1992
replace EI = 0 if abbr=="MI" & year>=1993
replace EI = 0 if abbr=="MA" & year>=1997
replace EI = 0 if inlist(abbr,"DE","NC") & year>=1999
replace EI = 0 if inlist(abbr,"MS", "NY") & year>=2000 //from Conway-Rork. Though NY is unclear because of EI with no gift tax: https://www.tax.ny.gov/pit/estate/etidx.htm
replace EI = 0 if inlist(abbr,"SD","MT") & year>=2001

//from https://www.thebalance.com/does-hawaii-collect-an-estate-tax-3505218...says HI replaced stand-alone I tax with pick-up tax in 1983
replace EI = 0 if abbr=="HI" & year>=1983

/// Some states from above list reinstated EI tax later on
replace EI = 1 if abbr=="OR" & year>=2003 //https://olis.leg.state.or.us/liz/2019R1/Downloads/CommitteeMeetingDocument/159041
replace EI = 1 if abbr=="VT" & year>=2004
replace EI = 1 if abbr=="RI" & year>=2002 //http://www.tax.ri.gov/forms/2018/Estate/RI-100A_2002-2014_m2018.pdf
replace EI = 1 if abbr=="DE" & inrange(year,2009,2017)
replace EI = 1 if abbr=="IL" & year>=2009
replace EI = 1 if abbr=="HI" & year>=2010 //https://www.thebalance.com/does-hawaii-collect-an-estate-tax-3505218
replace EI = 1 if abbr=="NC" & year>=2002
replace EI = 1 if abbr=="WA" & year>=2005 //(https://dor.wa.gov/sites/default/files/legacy/Docs/reports/2010/Tax_Reference_2010/06taxhistory.pdf)

replace EI = 1 if abbr=="WI" & inrange(year,2001,2007) //pick-up tax kept after EGTRRA, then repealed after 2007. https://www.wisbar.org/newspublications/wisconsinlawyer/pages/Article.aspx?Volume=80&Issue=12&ArticleID=1396
replace EI = 1 if abbr=="VA" & inrange(year,2001,2006) //pick-up tax kept after EGTRRA, then repealed after 2006. https://www.mcplegal.com/practice-areas/trusts-estate-planning/taxes/
replace EI = 1 if abbr=="ME" & year>=2013 //from MN study and verified at https://www.maine.gov/revenue/incomeestate/estate/index.htm
replace EI = 1 if abbr=="MA" & year>=2001 //from https://www.mass.gov/guides/a-guide-to-estate-taxes
replace EI = 1 if abbr=="MN" & year>=2001

replace EI = 0 if abbr=="KS" & year>2009 //KS estate tax repealed after 2009: https://www.ksrevenue.org/taxnotices/notice10-07.pdf

//NY: from https://www.tax.ny.gov/pit/estate/etidx.htm and http://riker.com/publications/significant-new-york-tax-legislation-replaces-current-estate-tax-with-a-pic
//It seems NY replaced their EI tax with a pick-up tax in 2000 and they repealed their gift tax. Hence, one could avoid EI taxes by giving gifts before death. In April 2014, they brought back the gift tax.
replace EI = 1 if abbr=="NY" & /*year>=2001*/ year>2014

***************** CT PUT $20M CAP ON ESTATE TAX PAYMENT STARTING IN 2016 (REDUCED TO $15M IN 2019) ***************
***************** NOTE $20M WOULD BE THE ET BILL FOR A CT ESTATE WORTH $323M ($20M/(12%*(8.25/16)))
***************** ALSO NOTE THAT $20M ET BILL ON $1B CT ESTATE EQUATE TO ET RATE OF 2%...SO SMALL BUT NON-TRIVIAL
***************** WE TREAT CT HAS CONTINUING TO HAVE ET AFTER 2015. BUT LATER SHOW RESULTS ROBUST TO DROPPING CT.
*replace EI = 0 if abbr=="CT" & year>=2016  //https://www.cga.ct.gov/2017/ACT/pa/2017PA-00002-R00SB-01502SS1-PA.htm

/// More recent repeals (from MN study)
replace EI = 0 if inlist(abbr,"NJ") & year>=2018
replace EI = 0 if inlist(abbr,"NC","OH") & year>=2013
replace EI = 0 if abbr=="OK" & year>=2010		//found online

/// Dealing with Inheritance-tax-only cases, which all have low or zero rates for lineal heirs (and ~16% for non-lineal heirs). 
//B&S says IA, KY, and NJ had I tax (as of 1998) only on collateral heirs. I confirmed this is true post-98 as well (see Michael 2018).
//NE repealed its estate tax in 2007. It retained an inheritance tax but with a rate on lineal heirs (kids) of just 1%. EI taxes/gdp plummeted after 2007
//NH had an I tax for death before 2003: https://www.revenue.nh.gov/faq/inheritance-estate.htm
//In 2008, LA repealed its I tax which was a pick-up tax that had never been coupled to fed credit; deaths after 2004 not subject to tax 
//In 2012, TN I tax was phased out to be fully repealed by 2016.
//The IN I tax is being phased out from 2013-2022 by 10% each year. Lineal heirs have low rate.

// NJ had an estate tax in addition to I tax up until 2018: https://www.state.nj.us/treasury/taxation/inheritance-estate/tax-rates.shtml
replace EI = 0 if inlist(abbr,"IA","KY","NE","NH","LA","TN","IN")
gen Ionly = 0 
replace Ionly = 1 if inlist(abbr,"IA","KY") | (abbr=="NE" & year>=2007) | (abbr=="NH" & year<2003) | (abbr=="LA" & year<2008) | (abbr=="TN" & year<2012) | (abbr=="IN" & year<2013)  | (abbr=="NJ" & year>=2018)

preserve
keep abbr year EI Ionly
save stata_data/stateEI.dta, replace  //save state panel dataset of estate taxes for researchers who request it.
restore


// COULD CHANGE PA TO I-ONLY STATE (SEE MICHAEL 2018 ). It is unique among I-only states in having tax (4.5%) on lineal heirs (and 15% on other heirs)...so more similar to ET.
// at least check into robustness of this choice

levelsof abbr if EI==1 & year==2000, local(temp)
levelsof abbr if EI==1 & year==2001, local(temp)
levelsof abbr if EI==1 & year==2017, local(temp)

/// ENTER STATUTORY ET RATES AND THEN COMPUTE COMBINED FED+STATE ET RATE FOR EACH STATE-YEAR
gen EIrate_state = 0
replace EIrate_state = 0.16*EI if inlist(abbr,"NJ","OR","OK","KS","MN","WI","IL","OH","NC") | inlist(abbr,"VA","MD","DE","PA","NY","RI","MA","VT")
replace EIrate_state = 0.157*EI if abbr=="HI"
replace EIrate_state = 0.12*EI if abbr=="ME"
replace EIrate_state = 0.20*EI if abbr=="WA"

replace EIrate_state = 0.16*EI if abbr=="CT" & year<2010
replace EIrate_state = 0.12*EI if abbr=="CT" & year>=2010
replace EIrate_state = 0.02*EI if abbr=="CT" & inrange(year,2016,2018) //implied ET rate on $1B estate given $20M max tax
replace EIrate_state = 0.015*EI if abbr=="CT" & year>=2019 //implied ET rate on $1B estate given $15M max tax


/// Federal top ET rate by year (https://www.sparrowcapital.com/resource-center/estate/a-brief-history-of-estate-taxes)
gen EIrate_fed = .70 if year<1982
replace EIrate_fed = .65 if inrange(year,1982,1982) 
replace EIrate_fed = .60 if inrange(year,1983,1983) 
replace EIrate_fed = .55 if inrange(year,1984,2001) 
replace EIrate_fed = .50 if inrange(year,2002,2002)
replace EIrate_fed = .49 if inrange(year,2003,2003)
replace EIrate_fed = .48 if inrange(year,2004,2004)
replace EIrate_fed = .47 if inrange(year,2005,2005)
replace EIrate_fed = .46 if inrange(year,2006,2006)
replace EIrate_fed = .45 if inrange(year,2007,2009)
replace EIrate_fed = 0 if inrange(year,2010,2010)
replace EIrate_fed = .35 if inrange(year,2011,2012)
replace EIrate_fed = .396 if inrange(year,2013,2017)
replace EIrate_fed = .37 if inrange(year,2018,2019)

gen EIratecombined = EIrate_state + EIrate_fed - EIrate_state if year<=2001  //full federal credit for state ET
replace EIratecombined = EIrate_state + EIrate_fed - .75*EIrate_state if year==2002  //75% federal credit for state ET
replace EIratecombined = EIrate_state + EIrate_fed - .5*EIrate_state if year==2003  //50% federal credit for state ET
replace EIratecombined = EIrate_state + EIrate_fed - .25*EIrate_state if year==2004  //25% federal credit for state ET
replace EIratecombined = EIrate_state + EIrate_fed*(1 - EIrate_state) if year>=2005  //federal deduction for state ET

save stata_data/popEI.dta, replace

//Merge in state GDP data
use "stata_data/EI_Tax_Merged_v2.dta", clear

rename Year year
sort year State
drop if year < 1982
drop if abbr == "" | abbr == "DC"
merge m:1 abbr year using stata_data/popEI.dta, nogen keepusing(pop_change pop EI Ionly) keep(1 3)
merge m:1 abbr year using `stateGDP', nogen keepusing(gdp gdp_change) keep(1 3)

//Relabel variables that will be included in regression
label variable pop_change "Pop. Change"
label variable gdp_change "GDP Change"
label variable EI "ET indicator"

/// EI tax revenues data
destring Total_Taxes, replace ignore(",")
gen EIshare = EI_Tax/Total_Taxes

//Import annual CPI-U data
preserve
import haver cpiuann@usecon, tvar(year) clear
rename cpiuann cpi
replace cpi = cpi/245.120  //re-base cpi to be 1 in 2017
tempfile cpi
save `cpi'
restore
merge m:1 year using `cpi', nogen keep(1 3)

// Dropping observations that are not reported, out of the country, or Washington D.C.
drop if State == "Washington DC"
drop if State == ""
drop if Name == ""

//Generate average
g avg = (State_Rate_Wages + State_Rate_Long_Gains)/2

glevelsof abbr, local(state)

drop if Name == "Henry Earl Singleton" & year == 1988 & ourrank == . // Keeping higher ranked observation

//Adding 2 to the younger family members with the same name in order to be able to differentiate
duplicates tag Name year, gen(tag)
g young_man=0
sort year Name Age_num
replace young_man = 1 if Name[_n]==Name[_n+1] & year[_n]==year[_n+1] & Age_num[_n]!=Age_num[_n+1] & tag==1

replace Name = "Charles A Vose 2" if Name == "Charles A Vose" & young_man==1
replace Name = "Pierre Samuel Du Pont Family" if Name == "Pierre Samuel Du Pont" & family == 1
replace Name = "Stephen Davidson Betchel 2" if Name == "Stephen Davidson Betchel" & young_man == 1
replace Name = "Stephen Davidson Betchel Family" if Name == "Stephen Davidson Betchel" & family == 1
replace Name = "Robert Boisseau Pamplin 2" if Name == "Robert Boisseau Pamplin" & young_man == 1
replace Name = "Robert Boisseau Pamplin 2" if Name == "Robert Boisseau Pamplin" & year >= 1995
*****I am letting the second occurence of Alice Francis Du Pont Mills in 1994 drop because I did not see two entries in the scanned Forbes document**********
replace Name = "Frank Batten 2" if Name == "Frank Batten" & young_man == 1
replace Name = "Jim Davis 2" if Name == "Jim Davis" & young_man == 1
replace Name = "Edward Crosby Johnson 2" if Name == "Edward Crosby Johnson" & young_man == 1

drop tag

duplicates tag Name year, gen(tag)
drop if tag~=0	//drops individuals with multiple residences
drop tag
tempfile cleaned
save `cleaned'

//Relabel some variables
label variable avg "Top State Personal MTR"
label variable our_wealthy "Inheritors" 
label variable state_tax "CIT Rate"

//Changing name to make it easier to differentiate between family members with same name
replace Name = "Edward Johnson" if Name == "Edward Crosby Johnson" & year == 2017 & Age_num == 53 

//Other name fixes
replace Name = "Oakleigh Blakeman Thorne" if Name=="Oakleigh Blakeman Thome"

drop stab //redundant with abbr

//Fix units
replace our_wealthy = 1 if our_wealthy==2
replace avg = avg/100

encode Name, gen(nameid)
egen stateyear = group(abbr year)
egen stateyearnameid = group(abbr year nameid)

/// CLEAN UP THE AGE VARIABLE (Note: there truly was someone who was 101, and the ages for 400 and 800 are for families and are mistakes)
if _rc==0 {
tab Age
replace Age_num = 25 if Age == "20s"
replace Age_num = 35 if Age == "30s"
replace Age_num = 45 if Age == "40s"
replace Age_num = 55 if inlist(Age,"50s",">51")
replace Age_num = 65 if Age == "60s"
replace Age_num = 75 if Age == "70s"
replace Age_num = 85 if Age == "80s"
replace Age_num = 95 if Age == "90s"
replace Age_num = 68 if Age == "late 60s"
replace Age_num = 78 if Age == "late 70s"
replace Age_num = 88 if Age == "late 80s"
replace Age_num = 50 if Age == "near 50"
replace Age_num = 70 if Age == "near 70"
replace Age_num = 68 if Age == "late 60s"
replace Age_num = 83 if Age == "83, 79 "
replace Age_num = 74 if Age == "74, 75 "
replace Age_num = 65 if Age == "65, 63 "
replace Age_num = real(subinstr(Age,",","",.))
replace Age_num = real(subinstr(Age,"*","",.))
replace Age_num = real(subinstr(Age,"'","",.))
replace Age_num = real(subinstr(Age,"`","",.))
replace Age_num = real(subinstr(Age,"_","",.))
replace Age_num = real(subinstr(Age,"-","",.))
replace Age_num = real(subinstr(Age," ","",.))
replace Age_num = real(subinstr(Age,"Q","0",.))
replace Age_num = real(subinstr(Age,">","",.))
replace Age_num = real(subinstr(Age,"a","0",.))
replace Age_num = real(subinstr(Age,".","",.))


//Fixing Forbes age issues 
replace Age_num = 77 if Name == "John Hammond Krehbiel Jr" & year == 1983
replace Age_num = 33 if Name == "Swanee Hunt" & year == 1983
replace Age_num = (1998 - 1945) if year == 1998 & Name == "Gary Tharaldson"
replace Age_num = (1997 - 1945) if year == 1997 & Name == "Gary Tharaldson"
replace Age_num = 85 if year==2015 & Name == "Warren Edward Buffett"
replace Age_num = 60 if year==2015 & Name == "William Henry Gates"
replace Age_num = 95 if year==1994 & Name == "Katsumasa (Roy) Sakioka"

replace Age_num = 51 if Name == "Abigail Johnson" & year == 2012
replace Age_num = . if Name == "Abigail Johnson" & (year >= 2013 | year < 2012)

replace Age_num = 58 if Name == "Adolph Alfred Taubman" & year == 1982
replace Age_num = . if Name == "Adolph Alfred Taubman" & year >= 1983

replace Age_num = 48 if Name == "Alan C Ashton" & year == 1990 
replace Age_num = . if Name == "Alan C Ashton" & year > 1990

replace Age_num = 82 if Name == "Alan Gerry" & year == 2011
replace Age_num = . if Name == "Alan Gerry" & year > 2011

replace Age_num = 66 if Name == "Albert Lee Ueltschi" & year == 1983

replace Age_num = 64 if Name == "Alberto Vilar" & year == 2004

replace Age_num = 72 if Name == "Zachary Fisher" & year == 1982
replace Age_num = . if Name == "Zachary Fisher" & year > 1982

replace Age_num = 44 if Name == "Winthrop Paul Rockefeller" & year == 1992
replace Age_num = . if Name == "Winthrop Paul Rockefeller" & year > 1992

replace Age_num = 46 if Name == "Winnie Johnson-Marquart" & year == 2004
replace Age_num = . if Name == "Winnie Johnson-Marquart" & year > 2004

replace Age_num = 62 if Name == "Alec Gores" & year == 2015

replace Age_num = 38 if Name == "Alejandro Santo Domingo" & year == 2015
replace Age_num = . if Name == "Alejandro Santo Domingo" & year > 2015

replace Age_num = 66 if Name == "Alice L Walton" & year == 2015
replace Age_num = . if Name == "Alice L Walton" & year > 2015

replace Age_num = 74 if Name == "Allan Goldman" & year == 2016

replace Age_num = 81 if Name == "Amos Barr Hostetter" & year == 2017
replace Age_num = . if Name == "Amos Barr Hostetter" & year < 2017

replace Age_num = 44 if Name == "Amy Wyss" & year == 2015
replace Age_num = 45 if Name == "Amy Wyss" & year == 2016

replace Age_num = 37 if Name == "Andres Santo Domingo" & year == 2015

replace Age_num = 62 if Name == "Andrew Beal" & year == 2014
replace Age_num = . if Name == "Andrew Beal" & year > 2014

replace Age_num = 84 if Name == "Andrew Jerrold Perenchio" & year == 2015
replace Age_num = 85 if Name == "Andrew Jerrold Perenchio" & year == 2016

replace Age_num = 59 if Name == "Anita Zucker" & year == 2010 //Overwrote Forbes age
replace Age_num = . if Name == "Anita Zucker" & year > 2010

replace Age_num = . if Name == "Ann Walton Kroenke" & year < 2017

replace Age_num = . if Name == "Anne Cox Chambers" & year > 1982

replace Age_num = 80 if Name == "Anne Gittinger" & year == 2015
replace Age_num = . if Name == "Anne Gittinger" & year < 2015

replace Age_num = 54 if Name == "Anthony Pritzker" & year == 2015
replace Age_num = . if Name == "Anthony Pritzker" & year > 2015

replace Age_num = . if Name == "Archie Aldis Emmerson" & year < 2017

replace Age_num = . if Name == "Arthur M Blank" & year < 2017

replace Age_num = . if Name == "Arturo Moreno" & year < 2017

replace Age_num = . if Name == "Austen S Cargill" & year < 2017

replace Age_num = 69 if Name == "Barbara Carlson Gage" & year == 2011 //Overwrote Forbes age
replace Age_num = . if Name == "Barbara Carlson Gage" & year > 2011  //Overwrote Forbes age
replace Age_num = . if Name == "Barbara Carlson Gage" & year < 2011  //Overwrote Forbes age

replace Age_num = . if Name == "Barry Diller" & year < 2017

replace Age_num = . if Name == "Bennett Dorrance" & year < 2017

replace Age_num = . if Name == "Bernard Francis Saul" & year < 2017

replace Age_num = . if Name == "Bernard Marcus" & year < 2017

replace Age_num = . if Name == "Bharat Desai" & year < 2016

replace Age_num = . if Name == "Bill Haslam" & year < 2017

replace Age_num = . if Name == "Blase Thomas Golisano" & year < 2017

replace Age_num = . if Name == "Bob Parsons" & year < 2017

replace Age_num = . if Name == "Bobby Murphy" & year < 2017

replace Age_num = . if Name == "Brad Kelley" & year < 2017

replace Age_num = . if Name == "Bradley Wayne Hughes" & year < 2017

replace Age_num = . if Name == "Brian Acton" & year < 2017

replace Age_num = . if Name == "Brian Chesky" & year < 2017

replace Age_num = . if Name == "Bruce Halle" & year < 2016

replace Age_num = . if Name == "Bruce Karsh" & year < 2017

replace Age_num = . if Name == "Bruce Kovner" & year < 2017

replace Age_num = . if Name == "Bubba Cathy" & year < 2017

replace Age_num = . if Name == "C Dean Metropoulos" & year < 2017

replace Age_num = . if Name == "Carl Celian Icahn" & year < 2017

replace Age_num = . if Name == "Carl Cook" & year < 2017

replace Age_num = . if Name == "Charles Bartlett Johnson" & year < 2017

replace Age_num = . if Name == "Charles Butt" & year >= 2014

replace Age_num = 65 if Name == "Charles Cohen" & year == 2016

replace Age_num = . if Name == "Charles Ergen" & year < 2017

replace Age_num = . if Name == "Charles Francis Dolan" & year < 2017

replace Age_num = . if Name == "Charles R Schwab" & year < 2017

replace Age_num = . if Name == "Charles de Ganahl Koch" & year < 2017

replace Age_num = . if Name == "Chase Coleman" & year < 2017

replace Age_num = . if Name == "Christopher Cline" & year < 2017

replace Age_num = . if Name == "Christy Walton" & year < 2017

replace Age_num = . if Name == "Clayton Lee Mathile" & year < 2017

replace Age_num = . if Name == "Clemmie Dixon Spangler" & year < 2017

replace Age_num = 66 if Name == "Craig O Mccaw" & year == 2015 //Forbes age overwritten

replace Age_num = . if Name == "Dagmar Dolby" & year < 2017

replace Age_num = . if Name == "Dan Cathy" & year < 2017

replace Age_num = . if Name == "Dan Friedkin" & year < 2017

replace Age_num = . if Name == "Dan Snyder" & year < 2017

replace Age_num = . if Name == "Daniel D'Aniello" & year < 2017

replace Age_num = . if Name == "Daniel Gilbert" & year < 2017

replace Age_num = . if Name == "Daniel Loeb" & year < 2017

replace Age_num = . if Name == "Daniel Morton Ziff" & year < 2017

replace Age_num = . if Name == "Daniel Och" & year < 2017

replace Age_num = . if Name == "Daniel Pritzker" & year < 2017

replace Age_num = 51 if Name == "Dannine Avara" & year == 2014
replace Age_num = . if Name == "Dannine Avara" & year > 2014

replace Age_num = . if Name == "David A Duffield" & year < 2017

replace Age_num = . if Name == "David Bonderman" & year < 2017

replace Age_num = 44 if Name == "David Einhorn" & year == 2012
replace Age_num = . if Name == "David Einhorn" & year > 2012

replace Age_num = . if Name == "David Filo" & year < 2017

replace Age_num = . if Name == "David Geffen" & year < 2017

replace Age_num = . if Name == "David Green" & year < 2017

replace Age_num = . if Name == "David Hamilton Koch" & year < 2017

replace Age_num = . if Name == "David Howard Murdock" & year < 2017

replace Age_num = 101 if Name == "David Rockefeller" & year == 2016
replace Age_num = 99 if Name == "David Rockefeller" & year == 2014
replace Age_num = . if Name == "David Rockefeller" & year < 2014

replace Age_num = . if Name == "David Rubenstein" & year < 2017

replace Age_num = . if Name == "David Shaw" & year < 2017

replace Age_num = . if Name == "David Siegel" & year < 2017 & Source == "Hedge Funds"

replace Age_num = . if Name == "David Sun" & year < 2017

replace Age_num = . if Name == "David Tepper" & year < 2017

replace Age_num = . if Name == "David Walentas" & year < 2017

replace Age_num = 92 if Name == "Dean White" & year == 2015

replace Age_num = . if Name == "Denise Debartolo York" & year < 2017

replace Age_num = . if Name == "Dennis Washington" & year < 2017

replace Age_num = . if Name == "Diane Hendricks" & year < 2017

replace Age_num = . if Name == "Dirk Edward Ziff" & year < 2017

replace Age_num = . if Name == "Don Hankey" & year < 2017

replace Age_num = . if Name == "Donald Edward Newhouse" & year < 2017

replace Age_num = . if Name == "Donald Leroy Bren" & year < 2017

replace Age_num = . if Name == "Donald Sterling" & year < 2017

replace Age_num = . if Name == "Doris Feigenbaum Fisher" & year < 2017

replace Age_num = . if Name == "Douglas Leone" & year < 2017

replace Age_num = . if Name == "Dustin Moskovitz" & year < 2017

replace Age_num = . if Name == "Edward Crosby Johnson" & year < 2016

replace Age_num = . if Name == "Edward John Debartolo Jr" & year < 2017

replace Age_num = 53 if Name == "Edward Lampert" & year == 2015

replace Age_num = . if Name == "Edward Perry Bass" & year < 2017

replace Age_num = . if Name == "Edward Roski" & year < 2017

replace Age_num = . if Name == "Eli Broad" & year < 2017

replace Age_num = 31 if Name == "Elizabeth Holmes" & year == 2015

replace Age_num = . if Name == "Elon Musk" & year < 2017

replace Age_num = . if Name == "Enos Stanley Kroenke" & year < 2017

replace Age_num = . if Name == "Eric Schmidt" & year < 2017

replace Age_num = . if Name == "Evan Spiegel" & year < 2017

replace Age_num = 43 if Name == "Evan Williams" & year == 2015 //Overwrote Forbes age

replace Age_num = 87 if Name == "Fayez Shalaby Sarofim" & year == 2015 //Overwrote Forbes age
replace Age_num = . if Name == "Fayez Shalaby Sarofim" & year < 2015

replace Age_num = 84 if Name == "Forrest Edward Mars Jr" & year == 2015
replace Age_num = . if Name == "Forrest Edward Mars Jr" & year < 2015

replace Age_num = 82 if Name == "Forrest Preston" & year == 2015

replace Age_num = . if Name == "Frank Fertitta" & year < 2017

replace Age_num = . if Name == "Frederick Wallace Smith" & year < 2017

replace Age_num = . if Name == "Gabe Newell" & year < 2017

replace Age_num = 73 if Name == "Gail Miller" & year == 2015
replace Age_num = 74 if Name == "Gail Miller" & year == 2016

replace Age_num = . if Name == "Gary Rollins" & year < 2017

replace Age_num = . if Name == "Gayle Cook" & year < 2013

replace Age_num = . if Name == "George B Kaiser" & year < 2017

replace Age_num = . if Name == "George Bishop" & year < 2017

replace Age_num = . if Name == "George L Lindemann" & year < 2017

replace Age_num = . if Name == "George Leon Argyros" & year < 2017

replace Age_num = . if Name == "George Lucas" & year < 2017

replace Age_num = . if Name == "George R Roberts" & year < 2017

replace Age_num = . if Name == "George Soros" & year < 2017

replace Age_num = . if Name == "Gerald J Ford" & year < 2017

replace Age_num = . if Name == "Glen Taylor" & year < 2017

replace Age_num = . if Name == "Glenn Dubin" & year < 2017

replace Age_num = . if Name == "Gordon Earle Moore" & year < 2017

replace Age_num = . if Name == "Gordon Peter Getty" & year < 2017

replace Age_num = . if Name == "Gwendolyn Sontheim Meyer" & year < 2017

replace Age_num = . if Name == "H Fisk Johnson" & year < 2017

replace Age_num = . if Name == "H Ty Warner" & year < 2017

replace Age_num = . if Name == "Haim Saban" & year < 2017

replace Age_num = 64 if Name == "Hamilton James" & year == 2015

replace Age_num = . if Name == "Harold Hamm" & year < 2017

replace Age_num = . if Name == "Harry Stine" & year < 2017

replace Age_num = . if Name == "Harry Wayne Huizenga" & year < 2017

replace Age_num = . if Name == "Helen Johnson-Leipold" & year < 2017

replace Age_num = 97 if Name == "Henry Lea Hillman" & year == 2016

replace Age_num = . if Name == "Henry Nicholas" & year < 2017

replace Age_num = . if Name == "Henry R Kravis" & year < 2017

replace Age_num = . if Name == "Henry Ross Perot" & year < 2017

replace Age_num = . if Name == "Henry Ross Perot Jr" & year < 2017

replace Age_num = . if Name == "Henry Samueli" & year < 2017

replace Age_num = . if Name == "Herbert Kohler" & year < 2017

replace Age_num = 88 if Name == "Herbert Louis" & year == 2014

replace Age_num = . if Name == "Herbert Simon" & year < 2017

replace Age_num = . if Name == "Howard Marks" & year < 2017

replace Age_num = . if Name == "Howard Schultz" & year < 2017

replace Age_num = . if Name == "Igor Olenicoff" & year < 2017

replace Age_num = 86 if Name == "Imogene Powers Johnson" & year == 2017
replace Age_num = . if Name == "Imogene Powers Johnson" & year < 2017

replace Age_num = . if Name == "Ira L Rennert" & year < 2017

replace Age_num = . if Name == "Irwin Mark Jacobs" & year < 2014

replace Age_num = . if Name == "Isaac Perlmutter" & year < 2017

replace Age_num = . if Name == "Israel Englander" & year < 2017

replace Age_num = . if Name == "J Christopher Reyes" & year < 2017

replace Age_num = 93 if Name == "Jack Crawford Taylor" & year == 2015

replace Age_num = . if Name == "Jack Dangermond" & year < 2017

replace Age_num = . if Name == "Jack Dorsey" & year < 2017

replace Age_num = . if Name == "Jacqueline Mars" & year < 2017

replace Age_num = . if Name == "James C France" & year < 2016

replace Age_num = . if Name == "James Coulter"  & year < 2017

replace Age_num = . if Name == "James Dinan" & year < 2016

replace Age_num = . if Name == "James Goodnight" & year < 2017

replace Age_num = . if Name == "James H Clark" & year < 2017

replace Age_num = . if Name == "James Irsay" & year < 2017

replace Age_num = . if Name == "James Jannard" & year < 2017

replace Age_num = . if Name == "James Leprino" & year < 2017

replace Age_num = . if Name == "James R Cargill II" & year < 2017

replace Age_num = . if Name == "James Simons" & year < 2017

replace Age_num = . if Name == "Jan Koum" & year < 2017

replace Age_num = . if Name == "Jay Paul" & year < 2017

replace Age_num = . if Name == "Jay Robert (JB) Pritzker" & year < 2017

replace Age_num = . if Name == "Jean (Gigi) Pritzker" & year < 2017

replace Age_num = . if Name == "Jeff Greene" & year < 2017

replace Age_num = . if Name == "Jeff Sutton" & year < 2017

replace Age_num = . if Name == "Jeffery Hildebrand" & year < 2017

replace Age_num = . if Name == "Jeffrey Lorberbaum" & year < 2017

replace Age_num = . if Name == "Jeffrey P Bezos" & year < 2017

replace Age_num = . if Name == "Jeffrey Skoll" & year < 2017

replace Age_num = . if Name == "Jen-Hsun Huang" & year < 2017

replace Age_num = . if Name == "Jennifer Pritzker" & year < 2016

replace Age_num = . if Name == "Jeremy Maurice Jacobs" & year < 2017

replace Age_num = . if Name == "Jerral Wayne Jones" & year < 2017

replace Age_num = . if Name == "Jerry Speyer" & year < 2017

replace Age_num = . if Name == "Jerry Yang" & year < 2017

replace Age_num = . if Name == "Jim Breyer" & year < 2017

replace Age_num = . if Name == "Jim C Walton" & year < 2017

replace Age_num = 72 if Name == "Jim Davis" & year == 2015

replace Age_num = . if Name == "Jim Kennedy" & year < 2017

replace Age_num = 62 if Name == "Jimmy Haslam" & year == 2015
replace Age_num = . if Name == "Jimmy Haslam" & year > 2015
replace Age_num = . if Name == "Jimmy Haslam" & year < 2015

replace Age_num = . if Name == "Jin Sook & Do Won Chang" & year < 2017

replace Age_num = . if Name == "Joan Tisch" & year < 2016

replace Age_num = . if Name == "Joe Gebbia" & year < 2017

replace Age_num = . if Name == "John Andreas Catsimatidis" & year < 2017

replace Age_num = . if Name == "John Anthony Sobrato" & year < 2017

replace Age_num = 44 if Name == "John Arnold" & year == 2017
replace Age_num = . if Name == "John Arnold" & year < 2017

replace Age_num = 78 if Name == "John Arrillaga" & year == 2015

replace Age_num = . if Name == "John C Malone" & year < 2017

replace Age_num = 90 if Name == "John Farber" & year == 2015

replace Age_num = . if Name == "John Franklyn Mars" & year < 2017

replace Age_num = . if Name == "John Henry" & year < 2017 & Source == "Sports"

replace Age_num = . if Name == "John J Fisher" & year < 2017 

replace Age_num = 72 if Name == "John Kapoor" & year == 2015

replace Age_num = . if Name == "John Middleton" & year < 2017

replace Age_num = . if Name == "John Morris" & year < 2017

replace Age_num = . if Name == "John Overdeck" & year < 2017

replace Age_num = . if Name == "John Paul Dejoria" & year < 2017

replace Age_num = . if Name == "John Paulson" & year < 2017

replace Age_num = 62 if Name == "John Pritzker" & year == 2015
replace Age_num = . if Name == "John Pritzker" & year > 2015

replace Age_num = . if Name == "John R Menard" & year < 2017

replace Age_num = 67 if Name == "John Sall" & year == 2015

replace Age_num = . if Name == "John Tu" & year < 2017

replace Age_num = . if Name == "John W Brown" & year < 2017 

replace Age_num = . if Name == "Johnelle Hunt" & year < 2017

replace Age_num = . if Name == "Jon LLoyd Stryker" & year < 2017

replace Age_num = . if Name == "Jonathan Gray" & year < 2017

replace Age_num = 59 if Name == "Jonathan Nelson" & year == 2015

replace Age_num = 66 if Name == "Jorge Perez" & year == 2015

replace Age_num = . if Name == "Joseph D Mansueto" & year < 2017

replace Age_num = . if Name == "Joseph Dahr Jamail" & year < 2014

replace Age_num = . if Name == "Joseph Grendys" & year < 2017

replace Age_num = 85 if Name == "Josephine Louis" & year == 2015

replace Age_num = . if Name == "Joshua Harris" & year < 2017

replace Age_num = . if Name == "Judy Faulkner" & year < 2017

replace Age_num = . if Name == "Julian Robertson" & year < 2017

replace Age_num = . if Name == "Julio Mario Santo Domingo" & year < 2017

replace Age_num = . if Name == "Karen Pritzker" & year < 2017

replace Age_num = . if Name == "Kavitark Ram Shriram" & year < 2017

replace Age_num = 87 if Name == "Keith Rupert Murdoch" & year == 2017
replace Age_num = . if Name == "Keith Rupert Murdoch" & year < 2017

replace Age_num = . if Name == "Kelcy Warren" & year < 2017

replace Age_num = . if Name == "Ken Fisher" & year < 2017

replace Age_num = . if Name == "Kenneth C Griffin" & year < 2017

replace Age_num = . if Name == "Kenneth Feld" & year < 2017

replace Age_num = . if Name == "Kenneth G Langone" & year < 2017

replace Age_num = . if Name == "Kevin Plank" & year < 2016

replace Age_num = . if Name == "Kieu Hoang" & year < 2017

replace Age_num = 97 if Name == "Kirk Kerkorian" & year == 2014

replace Age_num = . if Name == "L John Doerr" & year < 2017

replace Age_num = . if Name == "Larry E Page" & year < 2017

replace Age_num = 46 if Name == "Larry Robbins" & year == 2015

replace Age_num = 52 if Name == "Laurene Powell Jobs" & year == 2015

replace Age_num = . if Name == "Lawrence Joseph Ellison" & year < 2017

replace Age_num = . if Name == "Leandro Rizzuto" & year < 2016

replace Age_num = . if Name == "Lee Marshall Bass" & year < 2017

replace Age_num = . if Name == "Leon Black" & year < 2017

replace Age_num = . if Name == "Leon G Cooperman" & year < 2017

replace Age_num = 84 if Name == "Leonard Alan Lauder" & year == 2017 //Overwrote Forbes Age
replace Age_num = . if Name == "Leonard Alan Lauder" & year < 2017

replace Age_num = . if Name == "Leonard Norman Stern" & year < 2017

replace Age_num = . if Name == "Leslie Herbert Wexner" & year < 2017

replace Age_num = . if Name == "Linda Pritzker" & year < 2016

replace Age_num = . if Name == "Lorenzo Fertitta" & year < 2017

replace Name = "Louis Moore Bacon" if Name == "Lours Moore Bacon" //Name mistake
replace Age_num = . if Name == "Louis Moore Bacon" & year < 2016

replace Age_num = . if Name == "Lynn Schusterman" & year < 2017

replace Age_num = . if Name == "M Jude Reyes" & year < 2017

replace Age_num = 88 if Name == "Manuel Moroun" & year == 2015

replace Age_num = . if Name == "Marc Benioff" & year < 2017

replace Age_num = 55 if Name == "Marc Lasry" & year == 2015

replace Age_num = 53 if Name == "Marc Rowan" & year == 2015

replace Age_num = . if Name == "Margaret C Whitman" & year < 2017

replace Age_num = . if Name == "Marianne Liebmann" & year < 2017

replace Age_num = . if Name == "Marilyn Carlson Nelson" & year < 2014

replace Age_num = . if Name == "Mark Cuban" & year < 2017

replace Age_num = . if Name == "Mark Shoen" & year < 2017

replace Age_num = . if Name == "Mark Stevens" & year < 2017

replace Age_num = . if Name == "Mark Walter" & year < 2017

replace Age_num = . if Name == "Mark Zuckerberg" & year < 2017

replace Age_num = . if Name == "Martha Robinson Rivers Ingram" & year < 2017

replace Age_num = . if Name == "Mary Alice Dorrance Malone" & year < 2017

replace Age_num = . if Name == "Michael Dell" & year < 2017

replace Age_num = . if Name == "Michael Moritz" & year < 2017

replace Age_num = . if Name == "Michael Robert Milken" & year < 2017

replace Age_num = . if Name == "Michael Rubens Bloomberg" & year < 2017

replace Age_num = . if Name == "Michael Rubin" & year < 2017

replace Age_num = . if Name == "Micky Arison" & year < 2017

replace Age_num = . if Name == "Milane Duncan Frantz" & year < 2017

replace Age_num = . if Name == "Min H Kao" & year < 2017

replace Age_num = . if Name == "Mitchell Rales" & year < 2017

replace Age_num = . if Name == "Mortimer Benjamin Zuckerman" & year < 2017

replace Age_num = . if Name == "Nancy Walton Laurie" & year < 2017

replace Age_num = . if Name == "Nathan Blecharczyk" & year < 2017

replace Age_num = . if Name == "Neil Gary Bluhm" & year < 2017

replace Age_num = 73 if Name == "Nelson Peltz" & year == 2015

replace Age_num = 40 if Name == "Nicholas Woodman" & year == 2015

replace Age_num = . if Name == "Noam Gottesman" & year < 2017

replace Age_num = . if Name == "Norman Braman" & year < 2017

replace Age_num = . if Name == "Oprah Winfrey" & year < 2017

replace Age_num = . if Name == "Pat Stryker" & year < 2017

replace Age_num = . if Name == "Patrick George Ryan" & year < 2017

replace Age_num = 76 if Name == "Patrick Joseph Mcgovern" & year == 2013

replace Age_num = . if Name == "Patrick Soon-Shiong" & year < 2017

replace Age_num = 64 if Name == "Paul Gardner Allen" & year == 2017 //overwrote Forbes age
replace Age_num = . if Name == "Paul Gardner Allen" & year < 2017

replace Age_num = . if Name == "Paul Tudor Jones" & year < 2017

replace Age_num = 83 if Name == "Pauline Macmillan Keinath" & year == 2017 //overwrote Forbes age
replace Age_num = . if Name == "Pauline Macmillan Keinath" & year < 2017

replace Age_num = . if Name == "Peter Buck" & year < 2017

replace Age_num = . if Name == "Peter R Kellogg" & year < 2017

replace Age_num = . if Name == "Peter Thiel" & year < 2017

replace Age_num = . if Name == "Philip Hampson Knight" & year < 2017

replace Age_num = . if Name == "Phillip Frederick Anschutz" & year < 2017

replace Age_num = 82 if Name == "Phillip Frost" & year == 2017
replace Age_num = . if Name == "Phillip Frost" & year < 2017

replace Age_num = . if Name == "Phillip Ruffin" & year < 2017

replace Age_num = . if Name == "Pierre M Omidyar" & year < 2017

replace Age_num = . if Name == "Ralph Lauren" & year < 2017

replace Age_num = . if Name == "Randa Williams" & year < 2017

replace Age_num = . if Name == "Randal J Kirk" & year < 2017

replace Age_num = . if Name == "Randall Rollins" & year < 2017

replace Age_num = . if Name == "Ray Dalio" & year < 2017

replace Age_num = . if Name == "Ray Davis" & year < 2017

replace Age_num = . if Name == "Ray Lee Hunt" & year < 2017

replace Age_num = . if Name == "Reid Hoffman" & year < 2017

replace Age_num = . if Name == "Reinhold Schmieding" & year < 2017

replace Age_num = . if Name == "Richard Kinder" & year < 2017

replace Age_num = . if Name == "Richard Lefrak" & year < 2017

replace Age_num = 91 if Name == "Richard M Devos" & year == 2017
replace Age_num = . if Name == "Richard M Devos" & year < 2017

replace Age_num = . if Name == "Richard M Schulze" & year < 2017

replace Age_num = . if Name == "Richard Taylor Peery" & year < 2017

replace Age_num = . if Name == "Richard Yuengling" & year < 2016

replace Age_num = . if Name == "Rick Caruso" & year < 2017

replace Age_num = . if Name == "Riley P Bechtel" & year < 2017

replace Age_num = 80 if Name == "Robert C Mcnair" & year == 2017
replace Age_num = . if Name == "Robert C Mcnair" & year < 2017

replace Age_num = . if Name == "Robert David Ziff" & year < 2017

replace Age_num = . if Name == "Robert Drayton Mclane" & year < 2017

replace Age_num = . if Name == "Robert Duggan" & year < 2016

replace Age_num = . if Name == "Robert Edward (Ted) Turner" & year < 2017

replace Age_num = . if Name == "Robert Edward Rich Jr" & year < 2017

replace Age_num = . if Name == "Robert Kraft" & year < 2017

replace Age_num = . if Name == "Robert Muse Bass" & year < 2017

replace Age_num = 40 if Name == "Robert Pera" & year == 2017
replace Age_num = . if Name == "Robert Pera" & year < 2017

replace Age_num = . if Name == "Robert Rowling" & year < 2017

replace Age_num = . if Name == "Robert Smith" & year < 2017

replace Age_num = . if Name == "Romesh T Wadhwani" & year < 2017

replace Age_num = . if Name == "Ron Baron" & year < 2017

replace Age_num = . if Name == "Ronald Owen Perelman" & year < 2017

replace Age_num = . if Name == "Ronald Steven Lauder" & year < 2017

replace Age_num = . if Name == "Ronald Wanek" & year < 2017

replace Age_num = . if Name == "Ronda E Stryker" & year < 2017

replace Age_num = . if Name == "Rupert Harris Johnson" & year < 2017

replace Age_num = . if Name == "Russ Weiner" & year < 2017

replace Age_num = . if Name == "Alexander Gus Spanos" & year < 2017

replace Age_num = 63 if Name == "Alfred James Clark" & year == 1991

replace Age_num = . if Name == "Amar Gopal Bose" & year < 2008

replace Age_num = . if Name == "Arthur Charles Nielsen" & year < 1992

replace Age_num = 65 if Name == "David Durst" & year == 1990

replace Age_num = . if Name == "Donald John Trump" & year < 2016

replace Age_num = 83 if Name == "Dorothy Green" & year == 1989
replace Age_num = . if Name == "Dorothy Green" & year < 1989

replace Age_num = . if Name == "Elizabeth Ann Reid" & year < 2004

replace Age_num = . if Name == "Estee Lauder" & year < 1995

replace Age_num = . if Name == "Fred Deluca" & year < 2014

replace Age_num = . if Name == "Harry Brakmann Helmsley" & year < 1996

replace Age_num = . if Name == "Irene Sophie Du Pont May" & year < 1997

replace Age_num = . if Name == "James LeVoy Sorenson" & year < 2007

replace Age_num = . if Name == "Jane B Engelhard" & year < 1996

replace Age_num = 77 if Name == "Larry Fisher" & year == 1985
replace Age_num = . if Name == "Larry Fisher" & year < 1985

replace Age_num = . if Name == "Louis Larrick Ward" & year < 1994

replace Age_num = . if Name == "Marc Lasry" & year < 2015

replace Age_num = . if Name == "Patrick Joseph Mcgovern" & year < 2013

replace Age_num = . if Name == "Paul Milstein" & year < 2009

replace Age_num = . if Name == "Preston Robert Tisch" & year < 2005

replace Age_num = . if Name == "Richard Mellon Scaife" & year < 2013

replace Age_num = . if Name == "S Robson Walton" & year < 2017

replace Age_num = . if Name == "Samuel Irving Newhouse" & year < 2016

replace Age_num = . if Name == "Samuel Zell" & year < 2017

replace Age_num = . if Name == "Scott Duncan" & year < 2017

replace Age_num = . if Name == "Sergey Brin" & year < 2017

replace Age_num = . if Name == "Sheldon Adelson" & year < 2017

replace Age_num = . if Name == "Sheldon Henry Solow" & year < 2017

replace Age_num = . if Name == "Sid Richardson Bass" & year < 2017

replace Age_num = . if Name == "Stanley Druckenmiller" & year < 2017

replace Age_num = . if Name == "Stephen A Schwarzman" & year < 2017

replace Age_num = . if Name == "Stephen A Wynn" & year < 2017

replace Age_num = . if Name == "Stephen Ross" & year < 2017

replace Age_num = . if Name == "Steve Ballmer" & year < 2017

replace Age_num = . if Name == "Steven A Cohen" & year < 2017

replace Age_num = . if Name == "Steven Allan Spielberg" & year < 2017

replace Age_num = . if Name == "Steven Udvar-Hazy" & year < 2017

replace Age_num = . if Name == "Stewart Rahr" & year < 2017

replace Age_num = . if Name == "Sumner Murray Redstone" & year < 2017

replace Age_num = . if Name == "Theodore Nathan Lerner" & year < 2017

replace Age_num = . if Name == "Thomas F Frist" & year < 2017

replace Age_num = . if Name == "Thomas J Pritzker" & year < 2017

replace Age_num = . if Name == "Trevor Rees-Jones" & year < 2017

replace Age_num = . if Name == "Warren Stephens" & year < 2017

replace Age_num = . if Name == "Whitney Macmillan" & year < 2017

replace Age_num = . if Name == "William Bernard Ziff" & year < 1994

replace Age_num = . if Name == "William Herbert Hunt" & year < 2017

replace Age_num = 75 if Name == "William Ingrahm Koch" & year == 2015
replace Age_num = . if Name == "William Ingrahm Koch" & year < 2015

replace Age_num = . if Name == "William Morse Davidson" & year < 2008

replace Age_num = . if Name == "William Wrigley" & year < 2017
}


///Impute age for individual-year obs when we observe age for same individual in another year
sort nameid year
tsset nameid  year, yearly
sleep 1000
foreach lag of num 1/36 {
	replace Age_num = L`lag'.Age_num + (year - L`lag'.year) if Age_num==. & L`lag'.Age_num ~=.
}
foreach lag of num 1/36 {
	replace Age_num = F`lag'.Age_num + (year - F`lag'.year) if Age_num==. & F`lag'.Age_num ~=.
}
replace Age_num = . if Age_num > 110
replace Age_num = 96 if Age_num>=96 & Age_num~=.  //lumping together for graphing purposes

gen flag = 0
replace flag = 1 if (Age_num ~= L.Age_num+1) & (L.Age_num~=. & Age_num~=.)
tab Name if flag == 1

drop if Age_num==.
tab Age_num
gen old = 0 if Age_num~=.
replace old = 1 if Age_num >= 65 & Age_num~=.
gen old60 = 0 if Age_num~=. 
replace old60 = 1 if Age_num >= 60 & Age_num~=. 
gen old70 = 0 if Age_num~=. & inrange(Age_num,65,69)==0
replace old70 = 1 if Age_num >= 70 & Age_num~=.
gen old75 = 0 if Age_num~=. & inrange(Age_num,65,74)==0
replace old75 = 1 if Age_num >= 75 & Age_num~=.
gen footloose = (our_wealthy | old)
label variable Age_num "Age"
gen wealth = (NetWorthMill/1000)/cpi
label variable wealth "Net Worth (billions, 2017 dollars)"

drop if inrange(year,2002,2002)  // no location for Forbes 400 in 2002...and possibly exclude phase-out period

gen post=(year>`postyear')
gen AgeXpost = Age_num*post
label variable post "post-`postyear'"
label variable AgeXpost "Age X post-`postyear'"
label variable Age_num "Age"
encode abbr, gen(statenum)


drop _m
merge 1:1 Name year Forbes_Rank using "stata_data\Forbes_2015_top_100_companies.dta", keep(1 3) keepusing(company* officer* company_location*) gen(from_company)

******** construct officer_tied = 1 if any officer* are non-missing AND Residence==company_location* 
generate company_state = substr(company_location,-2,2)
generate company_state_2 = substr(company_location_2,-2,2)
generate company_state_3 = substr(company_location_3,-2,2)
generate company_tied = .
replace company_tied = 0 if from_company==3
replace company_tied = 1 if from_company==3 & abbr==company_state

save ./stata_data/IndivAnalysisDataset.dta, replace


use ./stata_data/IndivAnalysisDataset.dta, clear
/// KEEP ONLY VARIABLES NECESSARY FOR ANALYSES
keep nameid wealth NetWorthMill pop_change gdp_change gdp Age_num cpi year abbr old old60 old70 old75 ourrank stateyear
label var old "Indicator equal to 1 if age>=65; 0 otherwise"
label var old60 "Indicator equal to 1 if age>=60; 0 otherwise"
label var old70 "Indicator equal to 1 if age>=70; 0 otherwise"
label var old75 "Indicator equal to 1 if age>=75; 0 otherwise"
label var ourrank "Ranking in Forbes 400"
label var stateyear "Unique identifier for state-year combo"
label var nameid "Individual Name"
label var year "Year"
label var NetWorthMill "Net Worth in Millions of Current Dollars"
label var gdp "State real GDP"



/// GET STATE*YEAR DATA ON PIT RATES TO MERGE IN BELOW
use stata_data/State_Max_Tax_Rates.dta, clear
rename Year year
rename State_ID irsstatecode
merge m:1 irsstatecode using stata_data/irscode_fips_xwalk.dta
rename stateabbrev abbr
rename fips statefips
drop irsstatecode statefips
sort abbr year
tempfile PIT
save `PIT'

/// Get state CIT rates
use stata_data/CIT_rates.dta, clear
rename Year year
keep year State state_tax
rename state_tax CIT_rate
label var CIT_rate "state corp income tax rate"
tempfile CIT
save `CIT'

//Import CEPR/CPS data (h/t Olivia Lofton) on state-year population for top 3%, top 10%, and total
use "stata_data/styr_pop_by_wpctile.dta", clear
drop state
rename st_string State
gen pop_90to97 = (pop_above90 - pop_above97)/1000
label var pop_above90 "State population with earnings in top 10% nationally (from CPS)"
label var pop_above97 "State population with earnings in top 3% nationally (from CPS)"
label var pop_total "State population (thous)(from CPS)"
label var pop_90to97 "State population with earnings between top 10% and 3% nationally (from CPS)"
tempfile toppop
save `toppop'

use "stata_data/styr_pop_by_wpctile_young.dta", clear
append using "stata_data/styr_pop_by_wpctile_old.dta", gen(old)
drop state
rename st_string State
gen pop_90to97 = (pop_above90 - pop_above97)/1000
label var pop_above90 "State population with earnings in top 10% nationally (from CPS)"
label var pop_above97 "State population with earnings in top 3% nationally (from CPS)"
label var pop_total "State population (thous)(from CPS)"
label var pop_90to97 "State population with earnings between top 10% and 3% nationally (from CPS)"
tempfile toppop_old
save `toppop_old'

/// CREATE STATE*YEAR PANEL DATA SET
use ./stata_data/IndivAnalysisDataset.dta, clear
gcollapse (count) stock=nameid (sum) wealth NetWorthMill (mean) pop_change gdp_change gdp Age_num cpi, by(year abbr)
label variable stock "Population of Forbes 400"
label variable Age_num "Age"
label variable wealth "Net Worth (billions 2017 dollars)"
label variable NetWorthMill "Net Worth of Forbes 400 (billions nom. dollars)"


/// Add observations for AK, which had no billionaires over the entire sample period
insobs 1, before(1)
replace abbr = "AK" if _n==1
replace year = 1982 if abbr=="AK"

fillin abbr year
replace wealth = 0 if _fillin | abbr=="AK"
replace stock = 0 if _fillin | abbr=="AK"

merge 1:1 abbr year using stata_data/popEI.dta, keep(1 3) nogen
label variable EI "Estate Tax Indicator"

merge 1:1 abbr year using `PIT', nogen keep(1 3)
gen avg = (State_Rate_Wages + State_Rate_Long_Gains)/2
label variable avg "Top PIT Rate"

merge 1:1 State year using `CIT', nogen keep(1 3)
merge 1:1 State year using `toppop', nogen keep(1 3)
merge 1:1 abbr year using `EI_Tax', nogen keep(1 3)
gen EIshare = EI_Tax/Total_Taxes

egen stateyear = group(abbr year)
sort abbr year
encode abbr, gen(statenum)
tsset statenum year, yearly
save ./stata_data/StateyearAnalysisDataset.dta, replace

preserve
gen EI_GDP = EI_Tax/(gdp)
line EI_Tax year if abbr=="NY"
restore


/// CREATE STATE*YEAR PANEL DATA SET FOR FORBES 100, 200, 300
foreach x of num 100 200 300 {
	use ./stata_data/IndivAnalysisDataset.dta, clear
	drop if ourrank>`x'
	gcollapse (count) stock=nameid (sum) wealth NetWorthMill (mean) pop_change gdp_change Age_num cpi, by(year abbr)
	label variable stock "Population of Forbes 200"
	label variable Age_num "Age"
	label variable wealth "Net Worth (billions 2017 dollars)"
	label variable NetWorthMill "Net Worth of Forbes 200 (billions nom. dollars)"
	
	/// Add observations for AK, which had no billionaires over the entire sample period
	insobs 1, before(1)
	replace abbr = "AK" if _n==1
	replace year = 1982 if abbr=="AK"

	fillin abbr year
	replace wealth = 0 if _fillin | abbr=="AK"
	replace stock = 0 if _fillin | abbr=="AK"

	merge 1:1 abbr year using stata_data/popEI.dta, keep(1 3) nogen
	label variable EI "Estate Tax Indicator"

	merge 1:1 abbr year using `PIT', nogen keep(1 3)
	gen avg = (State_Rate_Wages + State_Rate_Long_Gains)/2
	label variable avg "Top PIT Rate"

	merge 1:1 abbr year using `EI_Tax', nogen keep(1 3)
	gen EIshare = EI_Tax/Total_Taxes

	egen stateyear = group(abbr year)
	sort abbr year
	encode abbr, gen(statenum)
	tsset statenum year, yearly
	save ./stata_data/StateyearTop`x'AnalysisDataset.dta, replace
}
/// CREATE STATE*YEAR PANEL DATA SET FOR FORBES INDIVIDUAL WITH AT LEAST 10 OBSERVATIONS
use ./stata_data/IndivAnalysisDataset.dta, clear
egen obs = count(year), by(nameid)
keep if obs>=10
gcollapse (count) stock=nameid (sum) wealth NetWorthMill (mean) pop_change gdp_change Age_num cpi, by(year abbr)
label variable stock "Population of Forbes 400"
label variable Age_num "Age"
label variable wealth "Net Worth (billions 2017 dollars)"
label variable NetWorthMill "Net Worth of Forbes 400 (billions nom. dollars)"


/// Add observations for AK, which had no billionaires over the entire sample period
insobs 1, before(1)
replace abbr = "AK" if _n==1
replace year = 1982 if abbr=="AK"

fillin abbr year
replace wealth = 0 if _fillin | abbr=="AK"
replace stock = 0 if _fillin | abbr=="AK"

merge 1:1 abbr year using stata_data/popEI.dta, keep(1 3) nogen
label variable EI "Estate Tax Indicator"

merge 1:1 abbr year using `PIT', nogen keep(1 3)
gen avg = (State_Rate_Wages + State_Rate_Long_Gains)/2
label variable avg "Top PIT Rate"

merge 1:1 abbr year using `EI_Tax', nogen keep(1 3)
gen EIshare = EI_Tax/Total_Taxes

egen stateyear = group(abbr year)
sort abbr year
encode abbr, gen(statenum)
tsset statenum year, yearly
save ./stata_data/Stateyear10obsAnalysisDataset.dta, replace


/// CREATE STATE*YEAR*AGE PANEL DATA SET
use ./stata_data/IndivAnalysisDataset.dta, clear
gcollapse (count) stock=nameid (sum) wealth NetWorthMill (mean) pop_change gdp_change cpi, by(year abbr Age_num)
label variable stock "Population of Forbes 400"
label variable Age_num "Age"
label variable wealth "Net Worth of Forbes 400 (billions 2017 dollars)"
label variable NetWorthMill "Net Worth of Forbes 400 (billions nom. dollars)"

/// Add observation AK, which had no billionaires over the entire sample period
insobs 1, before(1)
replace abbr = "AK" if _n==1
replace year = 1982 if abbr=="AK"
replace Age_num = 96 if abbr=="AK"
fillin abbr year Age_num

replace wealth = 0 if _fillin | abbr=="AK"
replace stock = 0 if _fillin | abbr=="AK"
merge m:1 abbr year using stata_data/popEI.dta, nogen keep(1 3)

merge m:1 abbr year using `PIT', nogen keep(1 3)
gen avg = (State_Rate_Wages + State_Rate_Long_Gains)/2
label variable avg "Top PIT Rate"

encode abbr, gen(statenum)
egen stateyear = group(abbr year)
save ./stata_data/StateyearAgeAnalysisDataset.dta, replace


/// CREATE STATE*YEAR*OLD PANEL DATA SET
foreach v in old old60 old70 old75 {
	use ./stata_data/IndivAnalysisDataset.dta, clear
	drop if `v'==.
	gcollapse (count) stock=nameid (sum) wealth (mean) stateyear pop_change gdp_change, by(year abbr `v')
	rename `v' old

	/// Add observations for AK, which had no billionaires over the entire sample period
	insobs 1, before(1)
	replace abbr = "AK" if _n==1
	replace year = 1982 if abbr=="AK"
	replace old = 0 if abbr=="AK"
	fillin abbr year old
	replace wealth = 0 if _fillin | abbr=="AK"
	replace stock = 0 if _fillin | abbr=="AK"

	merge m:1 abbr year using stata_data/popEI.dta, nogen keep(1 3)
	label variable EI "Estate Tax Indicator"
	merge m:1 abbr year using `PIT', nogen keep(1 3)
	gen avg = (State_Rate_Wages + State_Rate_Long_Gains)/2
	label variable avg "Top Personal Income Tax (PIT) Rate"
	merge 1:1 State year old using `toppop_old', nogen keep(1 3)

	gen post=(year>`postyear')
	label variable EI "ET-state"
	label variable post "post-`postyear'"
	gen EIxPost = EI*post
	label variable EIxPost "ET-state X post-`postyear'"
	gen avgxPost = avg*post
	label variable avgxPost "PIT X post-`postyear'"
	gen EIratecombinedxPost = EIratecombined*post
	label variable EIratecombinedxPost "ET rate X post-`postyear'"
	gen EIxold = EI*old
	label variable EIxold "ET-state X old"
	gen avgxold = avg*old
	label variable avgxold "PIT X old"
	gen oldxPost = old*post
	label variable oldxPost "old X post-`postyear'"
	gen EIxPostxold = EI*post*old
	label variable EIxPostxold "ET-state X post-`postyear' X old"
	gen avgxPostxold = avg*post*old
	label variable avgxPostxold "PIT X post-`postyear' X old"
	gen EIratecombinedxPostxold = EIratecombined*post*old
	label variable EIratecombinedxPostxold "ET rate X post-`postyear' X old"
	egen stateold = group(abbr old)

	encode abbr, gen(statenum)
	tsset stateold year, yearly
	save ./stata_data/Stateyear`v'AnalysisDataset.dta, replace
}
	
/// CREATE STATE*YEAR*OLD PANEL DATA SET FOR TOP 100, 200, AND 300
foreach x of num 100 200 300 {
	use ./stata_data/IndivAnalysisDataset.dta, clear
	drop if ourrank>`x'	
	gcollapse (count) stock=nameid (sum) wealth (mean) stateyear pop_change gdp_change, by(year abbr old)

	/// Add observations for AK, which had no billionaires over the entire sample period
	insobs 1, before(1)
	replace abbr = "AK" if _n==1
	replace year = 1982 if abbr=="AK"
	replace old = 0 if abbr=="AK"
	fillin abbr year old
	replace wealth = 0 if _fillin | abbr=="AK"
	replace stock = 0 if _fillin | abbr=="AK"

	merge m:1 abbr year using stata_data/popEI.dta, nogen keep(1 3)
	label variable EI "Estate Tax Indicator"
	merge m:1 abbr year using `PIT', nogen keep(1 3)
	gen avg = (State_Rate_Wages + State_Rate_Long_Gains)/2
	label variable avg "Top PIT Rate"

	gen post=(year>`postyear')
	label variable EI "ET-state"
	label variable post "post-`postyear'"
	gen EIxPost = EI*post
	label variable EIxPost "ET-state X post-`postyear'"
	gen EIxold = EI*old
	label variable EIxold "ET-state X old"
	gen oldxPost = old*post
	label variable oldxPost "old X post-`postyear'"
	gen EIxPostxold = EI*post*old
	label variable EIxPostxold "ET-state X post-`postyear' X old"
	egen stateold = group(abbr old)

	encode abbr, gen(statenum)
	tsset stateold year, yearly
	save ./stata_data/StateyearOldTop`x'AnalysisDataset.dta, replace
}

/// CREATE STATE*YEAR*OLD PANEL DATA SET FOR FORBES INDIVIDUAL WITH AT LEAST 10 OBSERVATIONS
use ./stata_data/IndivAnalysisDataset.dta, clear
egen obs = count(year), by(nameid)
keep if obs>=10
gcollapse (count) stock=nameid (sum) wealth (mean) stateyear pop_change gdp_change, by(year abbr old)

/// Add observations for AK, which had no billionaires over the entire sample period
insobs 1, before(1)
replace abbr = "AK" if _n==1
replace year = 1982 if abbr=="AK"
replace old = 0 if abbr=="AK"
fillin abbr year old
replace wealth = 0 if _fillin | abbr=="AK"
replace stock = 0 if _fillin | abbr=="AK"

merge m:1 abbr year using stata_data/popEI.dta, nogen keep(1 3)
label variable EI "Estate Tax Indicator"
merge m:1 abbr year using `PIT', nogen keep(1 3)
gen avg = (State_Rate_Wages + State_Rate_Long_Gains)/2
label variable avg "Top PIT Rate"

gen post=(year>`postyear')
label variable EI "ET-state"
label variable post "post-`postyear'"
gen EIxPost = EI*post
label variable EIxPost "ET-state X post-`postyear'"
gen EIxold = EI*old
label variable EIxold "ET-state X old"
gen oldxPost = old*post
label variable oldxPost "old X post-`postyear'"
gen EIxPostxold = EI*post*old
label variable EIxPostxold "ET-state X post-`postyear' X old"
egen stateold = group(abbr old)

encode abbr, gen(statenum)
tsset stateold year, yearly
save ./stata_data/StateyearOld10obsAnalysisDataset.dta, replace

/// CREATE STATE*YEAR*OLD UNDER-40 PANEL DATA SET
use ./stata_data/IndivAnalysisDataset.dta, clear
keep if Age_num>=40
gcollapse (count) stock=nameid (sum) wealth (mean) stateyear pop_change gdp_change, by(year abbr old)

/// Add observation AK, which had no billionaires over the entire sample period
insobs 1, before(1)
replace abbr = "AK" if _n==1
replace year = 1982 if abbr=="AK"
replace old = 0 if abbr=="AK"

fillin abbr year old
replace wealth = 0 if _fillin | abbr=="AK"
replace stock = 0 if _fillin | abbr=="AK"

merge m:1 abbr year using stata_data/popEI.dta, nogen keep(1 3)
label variable EI "Estate Tax Indicator"
merge m:1 abbr year using `PIT', nogen keep(1 3)
gen avg = (State_Rate_Wages + State_Rate_Long_Gains)/2
label variable avg "PIT"

gen post=(year>`postyear')
label variable EI "ET-state"
label variable post "post-`postyear'"
gen EIxPost = EI*post
label variable EIxPost "ET-state X post-`postyear'"
gen EIxold = EI*old
label variable EIxold "ET-state X old"
gen EIxPostxold = EI*post*old
label variable EIxPostxold "ET-state X post-`postyear' X old"
gen oldxPost = old*post
label variable oldxPost "old X post-`postyear'"
egen stateold = group(abbr old)

gen avgxold = avg*old
label variable avgxold "PIT X old"
gen avgxPostxold = avg*post*old
label variable avgxPostxold "PIT X post-`postyear' X old"
gen avgxPost = avg*post
label variable avgxPost "PIT X post-`postyear'"

encode abbr, gen(statenum)
tsset stateold year, yearly	
save ./stata_data/StateyearOldU40AnalysisDataset.dta, replace
}  //end BuildData IF code

*********************************************** ANALYSES **********************************************************
/// 1. ANALYSIS OF STATE*YEAR FORBES POPULATION
if "$run2D" == "yes" {


use ./stata_data/StateyearAnalysisDataset.dta, clear


*****************************************************************
***Figure B1: Distribution of Top PIT Rates by State ET Status***
*****************************************************************

*Panel A: 2001, Non ET states
sum avg if EI==0 & year==`postyear'
local mean0 = r(mean)
histogram avg if EI==0 & year==`postyear', bin(25) xline(`mean0') xscale(range(0 15)) ///
xlabels(0 2 4 6 8 10 12 14) graphregion(color(white))
graph export ../Figures/FigureB1_a.pdf, replace as(pdf)

*Panel B: 2001, ET states
sum avg if EI==1 & year==`postyear'
local mean1 = r(mean)
histogram avg if EI==1 & year==`postyear', bin(25) xline(`mean1') xscale(range(0 15)) ///
xlabels(0 2 4 6 8 10 12 14) graphregion(color(white))
graph export ../Figures/FigureB1_b.pdf, replace as(pdf)

*Panel C: 2017, Non ET states
sum avg if EI==0 & year==2017
local mean0 = r(mean)
histogram avg if EI==0 & year==2017, bin(25) xline(`mean0') xscale(range(0 15)) ///
xlabels(0 2 4 6 8 10 12 14) graphregion(color(white))
graph export ../Figures/FigureB1_c.pdf, replace as(pdf)

*Panel D: 2017, ET states
sum avg if EI==1 & year==2017
local mean1 = r(mean)
histogram avg if EI==1 & year==2017, bin(25) xline(`mean1') xscale(range(0 15)) ///
xlabels(0 2 4 6 8 10 12 14) graphregion(color(white))
graph export ../Figures/FigureB1_d.pdf, replace as(pdf)


****************************************************************
***Table B2: Probability of State Having an Estate Tax -- LPM***
****************************************************************

gen post = (year>`postyear')
label variable post "post-`postyear'"
gen avgXpost = avg*post
gen CITXpost = CIT_rate*post
gen gdp_changeXpost = gdp_change*post
label var gdp_change "Log Change in real GDP"
label var CIT_rate "Top Corp. Income Tax (CIT) Rate"
label var avgXpost "Top PIT Rate X post-2001"
label var CITXpost "Top CIT Rate X post-2001"
label var gdp_changeXpost "GDP Change X post-2001"

*No FE (Col 1)
eststo adopt1: reg EI avg CIT_rate gdp_change avgXpost CITXpost gdp_changeXpost, cluster(statenum)
	estadd local yearFE       "No",   replace:   adopt1
	estadd local stateFE      "No",   replace:   adopt1

*Year FE (Col 2)
eststo adopt2: reg EI i.year avg CIT_rate gdp_change avgXpost CITXpost gdp_changeXpost, cluster(statenum)
	estadd local yearFE       "Yes",   replace:   adopt2
	estadd local stateFE      "No",   replace:   adopt2

*State + Year FE (Col 3)
eststo adopt3: xtreg EI i.year avg CIT_rate gdp_change avgXpost CITXpost gdp_changeXpost, fe cluster(statenum)
	estadd local yearFE       "Yes",   replace:   adopt3
	estadd local stateFE      "Yes",   replace:   adopt3

#delimit ;
	esttab adopt1 adopt2 adopt3
	  using ../Tables/TableB2.tex, replace se scalars(stateFE yearFE) drop(*year)
 		noconstant label compress substitute(\_ _  yearFE "Year Fixed Effects" stateFE "State Fixed Effects" main "") star(* 0.1 ** 0.05 *** 0.01 )
 		postfoot("\hline \hline" "\multicolumn{3}{l}{\footnotesize Standard errors (clustered by state) in parentheses.}\\"
 		"\multicolumn{3}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}  \end{tabular} }");
#delimit cr

*****************
***CREATE MAPS***
*****************
*************************************************************
****Figure 1: Percentage of Years with Estate Tax by State***
*************************************************************

preserve
gen state = abbr
keep if year<=`postyear'
collapse (mean) EI, by(state)
maptile EI, geo(state) geoid(state) ndfcolor(gray) cutvalues(0 .5 .99)  twopt(legend(lab(2 "Never") lab(3 "Less than half") lab(4 "More than half") lab(5 "All Years") ))
graph export ../Figures/Figure1_a.pdf, replace as(pdf)
restore
preserve
gen state = abbr
keep if year>`postyear'
collapse (mean) EI, by(state)
maptile EI, geo(state) geoid(state) ndfcolor(gray) cutvalues(0 .5 .99)  twopt(legend(lab(2 "Never") lab(3 "Less than half") lab(4 "More than half") lab(5 "All Years") ))
graph export ../Figures/Figure1_b.pdf, replace as(pdf)
restore

*****************************************************************************************
***Figure 5: Share of Forbes 400 Living in a 2001 Estate Tax State (Time-series graph)***
*****************************************************************************************

preserve

gen dum`postyear' = (year==`postyear')
gen x = EI*dum`postyear'
egen EI`postyear' = max(x), by(abbr)

egen total_wealth = total(wealth), by(year)
gen wealth_share = (wealth/total_wealth)*100
sum total_wealth if year==2017
gen wealth_normalized = (wealth)*(r(mean)/total_wealth)   //rescale each state-year's wealth so national total is constant over time (equal to 2017 national total).

collapse (sum) stock `wealth', by(EI`postyear' year)
reshape wide stock `wealth', i(year) j(EI`postyear')

gen prop = (stock1/(stock1 + stock0))*100 

qui sum prop if year<=`postyear'
gen premean = r(mean) if year<2002 

qui sum prop if year>`postyear'
gen postmean = r(mean) if year>2002 

twoway line prop premean postmean year, ytitle(Percentage) yscale(range(0 30)) ///
xline(`postyear'(.01)2004, lcolor(gs14)) xline(`postyear', lcolor(black)) ///
graphregion(color(white)) ylabel(#10) lcolor(black red red) lpattern(solid dash dash) legend(off)

graph export "../Figures/Figure5.pdf", replace as(pdf)

restore


****************************************************************
***Table B3: Panel C. State-by-Year Observations. 1982 - 2017*** 
****************************************************************

estpost sum stock wealth EI avg, detail
esttab . using "../Tables/TableB3_c.tex", replace modelwidth(10 20) cell((mean(fmt(%9.2f) label(Mean)) p50(fmt(%9.2f) label(Median)) sd(fmt(%9.2f) label(Standard Deviation)) min(label(Minimum)) max(label(Maximum)))) nonumber nomtitle label

********************************************
***DIFF-IN-DIFF (BEFORE/AFTER `postyear')***
********************************************

replace avg = avg*100
replace State_Rate_Wages = State_Rate_Wages*100
replace State_Rate_Long_Gains =  State_Rate_Long_Gains*100

label variable EI "ET-state"
label variable avg "PIT"
gen EIxPost = EI*post
gen avgxPost = avg*post
gen EIratecombinedxPost = EIratecombined*post
label variable EIxPost "ET-state X post-`postyear'"
label variable avgxPost "PIT X post-`postyear'"
label variable EIratecombinedxPost "ET rate X post-`postyear'"
gen logwealth = ln(wealth+.001)
gen logstock = ln(stock)
gen stockpc = (stock/pop)*1000
gen logstockpc = log(stockpc)
egen total_wealth = total(wealth), by(year)
gen wealth_share = (wealth/total_wealth)*100
sum total_wealth if year==2017
gen wealth_normalized = (wealth)*(r(mean)/total_wealth)   //rescale each state-year's wealth so national total is constant over time (equal to 2017 national total).


***************************************************************
***Table 2: DD, Dependent Variable: Population of Forbes 400***
***************************************************************

sum stock if year==2001 & EI==1	//yields baseline number of billionaires pre-`postyear'
local baseline_stock = r(mean)
local numEIStates = r(N)

sum wealth if year>2001
local post_wealth_mean = r(mean)

sum wealth if year==2001
local pre_wealth_mean = r(mean)

sum wealth if year==2001 & EI==1, detail //yields baseline statewide wealth of billionaires pre-`postyear'
local baseline_wealth = r(mean)*(`post_wealth_mean'/`pre_wealth_mean')

sum stockpc if year==2001 & EI==1	//yields baseline number of billionaires pre-`postyear'
local baseline_stockpc = r(mean)

sum wealth_share if year==2001 & EI==1 //yields baseline statewide wealth of billionaires pre-`postyear'
local baseline_wealth_share = r(mean)

sum wealth_normalized if year==2001 & EI==1 //yields baseline statewide wealth of billionaires pre-`postyear'
local baseline_wealth_normalized = r(mean)



//Adding i.statenum
eststo stock_EI3: ivreg2 stock EIxPost `controls' EI i.year i.statenum, dkraay(10) partial(i.statenum i.year)
estadd local elas = round((_b[EIxPost]/`baseline_stock')*1000)/1000,   replace:   stock_EI3
estadd local stderr = round((_se[EIxPost]/`baseline_stock')*1000)/1000,   replace:   stock_EI3
estadd local yearFE      "Yes",   replace:   stock_EI3
estadd local stateFE     "Yes",   replace:   stock_EI3

//Replace ET dummy with ET rate
eststo stock_EIrate3: ivreg2 stock EIratecombinedxPost `controls' EI i.year i.statenum, dkraay(10) partial(i.statenum i.year)
estadd local yearFE      "Yes",   replace:   stock_EIrate3
estadd local stateFE     "Yes",   replace:   stock_EIrate3


// Interact EIxPost with average billionaire wealth in the state-year
cap gen Avgwealth = wealth/stock
cap gen EIxPostxAvgwealth = EIxPost*Avgwealth
ivreg2 stock EIxPost EIxPostxAvgwealth `controls' EI i.year i.statenum, dkraay(10) partial(i.statenum i.year)


sleep 1000


//Change dep var to stock p.c.
eststo stock_EI9: ivreg2 stockpc EIxPost `controls' EI i.year i.statenum, dkraay(10) partial(i.statenum i.year)
estadd local elas = round((_b[EIxPost]/`baseline_stockpc')*1000)/1000,   replace:   stock_EI9
estadd local stderr = round((_se[EIxPost]/`baseline_stockpc')*1000)/1000,   replace:   stock_EI9
estadd local yearFE      "Yes",   replace:   stock_EI9
estadd local stateFE     "Yes",   replace:   stock_EI9

sleep 1000
//Adding PIT
eststo stock_EI4: ivreg2 stock EIxPost `controls' EI i.year i.statenum avgxPost avg, dkraay(10) partial(i.statenum i.year)
estadd local elas = round((_b[EIxPost]/`baseline_stock')*1000)/1000,   replace:   stock_EI4
estadd local stderr = round((_se[EIxPost]/`baseline_stock')*1000)/1000,   replace:   stock_EI4
estadd local yearFE      "Yes",  replace:   stock_EI4
estadd local stateFE     "Yes",  replace:   stock_EI4

//Control for ordinary high earner population
egen pop_90to97_natl = total(pop_90to97), by(year)
gen topshr_90to97 = (pop_90to97/pop_90to97_natl)*100
label var topshr_90to97 "High earners share"
eststo stock_EI10: ivreg2 stock EIxPost `controls' EI i.year i.statenum topshr_90to97, dkraay(10) partial(i.statenum i.year)
estadd local elas = round((_b[EIxPost]/`baseline_stock')*1000)/1000,   replace:   stock_EI10
estadd local stderr = round((_se[EIxPost]/`baseline_stock')*1000)/1000,   replace:   stock_EI10
estadd local yearFE      "Yes",  replace:   stock_EI10
estadd local stateFE     "Yes",  replace:   stock_EI10

//Reduced-Form reg replacing post-`postyear' EI with 2001 EI
levelsof abbr if year==2001 & EI==1, local(temp)
gen EI2001 = 0
foreach s of local temp {
	di "`s'"
	replace EI2001 = 1 if abbr == "`s'" & year>=2001
}

gen EI2001xPost = EI2001*post
label variable EI2001xPost "ET-state-2001 X post-2001"


eststo stock_EI6: ivreg2 stock  `controls' i.year i.statenum (EI EIxPost = EI2001 EI2001xPost), dkraay(10) partial(i.year i.statenum) first endog(EI EIxPost)
estadd local elas = round((_b[EIxPost]/`baseline_stock')*1000)/1000,   replace:   stock_EI6
estadd local stderr = round((_se[EIxPost]/`baseline_stock')*1000)/1000,   replace:   stock_EI6
estadd local yearFE       "Yes",   replace:    stock_EI6
estadd local stateFE      "Yes",   replace:    stock_EI6

eststo stock_EI7: ivreg2 `wealth' EIxPost `controls' EI i.year i.statenum, dkraay(10) partial(i.statenum i.year)
estadd local elas = round((_b[EIxPost]/`baseline_wealth_normalized')*1000)/1000, replace:   stock_EI7
estadd local stderr = round((_se[EIxPost]/`baseline_wealth_normalized')*1000)/1000, replace:   stock_EI7
estadd local yearFE      "Yes",   replace:   stock_EI7
estadd local stateFE     "Yes",   replace:   stock_EI7

//Drop phase-out period (2002-2004)
eststo stock_EI3e: ivreg2 stock EIxPost `controls' EI i.year i.statenum if inrange(year,2002,2004)==0, dkraay(10) partial(i.statenum i.year)
estadd local elas = round((_b[EIxPost]/`baseline_stock')*1000)/1000,   replace:   stock_EI3e
estadd local stderr = round((_se[EIxPost]/`baseline_stock')*1000)/1000,   replace:   stock_EI3e
estadd local yearFE      "Yes",   replace:   stock_EI3e
estadd local stateFE     "Yes",   replace:   stock_EI3e


//Count Inheritance-tax-only cases as EI=1 (be sure to do this reg last because it changes EI data)
replace EI = 1 if Ionly==1
eststo stock_EI3c: ivreg2 stock EIxPost `controls' EI i.year i.statenum, dkraay(10) partial(i.statenum i.year)
estadd local elas = round((_b[EIxPost]/`baseline_stock')*1000)/1000,   replace:   stock_EI3c
estadd local stderr = round((_se[EIxPost]/`baseline_stock')*1000)/1000,   replace:   stock_EI3c
estadd local yearFE      "Yes",   replace:   stock_EI3c
estadd local stateFE     "Yes",   replace:   stock_EI3c


***Table 2 exported***

#delimit ;
esttab stock_EI3 stock_EI4 stock_EI10 stock_EI6 stock_EI9 stock_EI7 stock_EI3c stock_EI3e /*stock_EIrate3*/
using ../Tables/Table2.tex, replace se scalars(elas stderr stateFE yearFE) mtitle("" "" "" "IV" "Per Capita" "Wealth" "Incl. inher. tax" "Drop 2002-04" /*"ET Rate"*/) 
noconstant label compress substitute(0000000000001 "" \_ _  elas "Semi-elasticity" stderr "\quad \textit{Std. Error}" yearFE "Year Fixed Effects" stateFE "State Fixed Effects" main "") star(* 0.1 ** 0.05 *** 0.01 )
postfoot("\hline \hline" "\multicolumn{8}{l}{\footnotesize Driscoll-Kraay (with 10-year bandwidth) standard errors in parentheses. IV regression instruments for ET-state\textsubscript{s,t}} \\" 
"\multicolumn{8}{l}{\footnotesize and its interactions using a variable (and its corresponding interactions) equal to ET-state\textsubscript{s,t} for t$<$2001 and to ET-state\textsubscript{s,2001}} \\"
"\multicolumn{8}{l}{\footnotesize  for t$\geq$2001.  \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}  \end{tabular} }");

#delimit cr

*********************************************************************
***Figure B3: Robustness to Dropping Individual ET States, Panel A***
*********************************************************************
 
local i=1
qui ivreg2 stock EIxPost `controls' EI i.year i.statenum, dkraay(10) partial(i.statenum i.year)
lincom EIxPost
gen beta=r(estimate) if _n==`i'
gen ub = r(ub) if _n==`i'
gen lb = r(lb) if _n==`i'
gen n = `i' if _n==`i'
label define n `i' "None", add
foreach s in WA OR HI OK KS MN WI IL OH NC VA MD DE PA NJ NY CT RI MA VT ME {
	local ++i
	qui ivreg2 stock EIxPost `controls' EI i.year i.statenum if abbr~="`s'", dkraay(10) partial(i.statenum i.year)
	di "State: `s'"
	lincom EIxPost
	replace beta=r(estimate) if _n==`i'
	replace ub = r(ub) if _n==`i'
	replace lb = r(lb) if _n==`i'
	replace n = `i' if _n==`i'
	label define n `i' "`s'", add
}

label values n n

#delimit ;
twoway (rcap ub lb n, lcolor(ltblue)) (scatter beta n, mcolor(blue)) if inrange(n,1,`i'), 
xlabel(1(1)`i',valuelabel alternate) xtitle(Excluded ET State) legend(off) graphregion(color(white))
ytitle(Point Estimate and 95% Confidence Interval) yline(0, lcolor(black)) 
yscale(range(-5 1)) ylabel(-5(1)1, nogrid)
;
#delimit cr
graph export ../Figures/FigureB3_a.pdf, replace as(pdf) //Figure exported.
drop beta ub lb n


*******************************************
***Table B6: Robustness, Panel A. D-in-D***
*******************************************

//Restrict to top 100, 200, 300, or 10+ observations
local m = 10
foreach x in Top100 Top200 Top300 10obs {
	use ./stata_data/Stateyear`x'AnalysisDataset.dta, clear
	gen post = (year>`postyear')
  	drop if stock==0 & "`drop'"=="yes"
	sum stock if year==2001 & EI==1	//yields baseline number of billionaires pre-`postyear'
	local baseline_stock`x' = r(mean)
	label variable post "post-`postyear'"
	label variable EI "ET-state"
	gen EIxPost = EI*post
	label variable EIxPost "ET-state X post-`postyear'"
	label variable avg "PIT"
	gen avgxPost = avg*post
	label variable avgxPost "PIT X post-`postyear'"
	eststo stock_EI`m': ivreg2 stock EIxPost `controls' EI i.year i.statenum, dkraay(10) partial(i.statenum i.year)
	estadd local elas = round((_b[EIxPost]/`baseline_stock`x'')*1000)/1000,   replace:   stock_EI`m'
	estadd local stderr = round((_se[EIxPost]/`baseline_stock`x'')*1000)/1000,   replace:   stock_EI`m'
	estadd local yearFE      "Yes",   replace:   stock_EI`m'
	estadd local stateFE     "Yes",   replace:   stock_EI`m'
	local m = `m'+1
}


#delimit ;
esttab stock_EI10 stock_EI11 stock_EI12 stock_EI13
using ../Tables/TableB6_a.tex, replace se scalars(elas stderr) mtitle("Top 100" "Top200" "Top300" "10+ Obs" ) 
noconstant label compress substitute(\_ _  elas "Semi-elasticity" stderr "\quad \textit{Std. Error}") star(* 0.1 ** 0.05 *** 0.01 )
postfoot("\hline \hline" "\multicolumn{5}{l}{\footnotesize Driscoll-Kraay (with 10-year bandwidth) standard errors in parentheses.} \\" 
"\multicolumn{5}{l}{\footnotesize All regressions include state and year fixed effects.} \\"
"\multicolumn{5}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}  \end{tabular} }");
#delimit cr

****************************************************************************
***Table 5: Effect of Tax Induced Mobility on State Aggregate Tax Base	 ***
*** The values shown in Table 5 of the paper are hard-coded in the    	 ***
*** AEJEP_final.tex using the numbers displayed by the stata code below. ***
****************************************************************************
*Cell(1,1)
local cell_11 = `baseline_stock'*`numEIStates'
di `cell_11'

*Cell(1,2)
estimates restore stock_EI3
local cell_12 = `cell_11'*(_b[EIxPost]/`baseline_stock')
di `cell_12'

*Cell(2,1)
local cell_21 = `baseline_wealth'*`numEIStates'
di `cell_21'

*Cell(2,2)
estimates restore stock_EI7
local cell_22 = `cell_21'*(_b[EIxPost]/`baseline_wealth_normalized')
di `cell_22'
*pause

} // end Run2D IF code

/// 2. ANALYSIS OF STATE*YEAR*OLD FORBES POPULATION
if "$run3D" == "yes" {
	
	use ./stata_data/StateyearoldAnalysisDataset.dta, clear

 	gen stockpc = (stock/pop)*1000
	sum stock if year==2001 & EI==1 & old==1	//yields baseline number of old billionaires pre-`postyear'
	local baseline_stock_old = r(mean)
	sum stock if year==2001 & EI==1 & old==0	//yields baseline number of young billionaires pre-`postyear'
	local baseline_stock_young = r(mean)
	sum stockpc if year==2001 & EI==1 & old==1	//yields baseline number of old billionaires p.c. pre-`postyear'
	local baseline_stockpc_old = r(mean)
	sum stockpc if year==2001 & EI==1 & old==0	//yields baseline number of young billionaires p.c. pre-`postyear'
	local baseline_stockpc_young = r(mean)
	sum wealth if year>2001
	local post_wealth_mean = r(mean)
	sum wealth if year==2001
	local pre_wealth_mean = r(mean)
	sum wealth if year==2001 & EI==1 & old==1, detail //yields baseline statewide wealth of old billionaires pre-`postyear'
	local baseline_wealth_old = r(mean)*(`post_wealth_mean'/`pre_wealth_mean')
	sum wealth if year==2001 & EI==1 & old==0, detail //yields baseline statewide wealth of young billionaires pre-`postyear'
	local baseline_wealth_young = r(mean)*(`post_wealth_mean'/`pre_wealth_mean')

	egen total_wealth = total(wealth), by(year)
	sum total_wealth if year==2001 & old==1
	sum total_wealth if year==2017 & old==1	
	gen wealth_normalized = (wealth)*(r(mean)/(total_wealth))   //rescale each state-year-generation's wealth so national total is constant over time (equal to 2017 national total).
	sum wealth_normalized if year==2001 & EI==1 & old==1
	local baseline_wealth_normalized_old = r(mean)
	sum wealth_normalized if year==2001 & EI==1 & old==0
	local baseline_wealth_normalized_yng = r(mean)

	****************************************************************
	***Table 3: Triple-Difference -- DV: Population of Forbes 400***
	****************************************************************
	
	//Adding i.year
	eststo stock_EI_old2: ivreg2 stock `controls' EIxPostxold EIxold EIxPost oldxPost EI old i.year, dkraay(10) partial(i.year)
	estadd local elas_young = round((_b[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old2
	estadd local stderr_young = round((_se[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old2
	estadd local elas_old = round(((_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old')*1000)/1000,   replace:   stock_EI_old2
	nlcom elas_old: (_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old', post
	local stderr_old = round(_se[elas_old]*1000)/1000
	estadd local stderr_old = `stderr_old',   replace:   stock_EI_old2
	estadd local yearFE      "Yes",   replace:   stock_EI_old2
	estadd local stateFE     "No",   replace:   stock_EI_old2

	
	//Replace ET dummy with ET rate
	label var EIratecombinedxPostxold  "ET rate X post-2001 X old"
	label var EIratecombinedxPost "ET rate X post-2001"
	eststo stock_EIrate_old3: ivreg2 stock `controls' EIratecombinedxPostxold EIxold EIratecombinedxPost oldxPost EI old i.year i.statenum, dkraay(10) partial(i.year i.statenum)
	estadd local yearFE      "Yes",   replace:   stock_EIrate_old3
	estadd local stateFE     "Yes",   replace:   stock_EIrate_old3

	//Adding PIT
	label var avgxPostxold  "PIT X post-2001 X old"
	label var avgxold  "PIT X old"
	label var avgxPost  "PIT X post-2001"
	label var avg "PIT"
	eststo stock_EI_old4: ivreg2 stock `controls' EIxPostxold EIxold EIxPost avgxPostxold avgxold avgxPost oldxPost EI avg old i.year i.statenum, dkraay(10) partial(i.statenum i.year)
	estadd local elas_young = round((_b[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old4
	estadd local stderr_young = round((_se[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old4
	estadd local elas_old = round(((_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old')*1000)/1000,   replace:   stock_EI_old4
	nlcom elas_old: (_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old', post
	local stderr_old = round(_se[elas_old]*1000)/1000
	estadd local stderr_old = `stderr_old',   replace:   stock_EI_old4
	estadd local yearFE      "Yes",  replace:   stock_EI_old4
	estadd local stateFE     "Yes",  replace:   stock_EI_old4

	//Control for ordinary high earners
	egen pop_90to97_natl = total(pop_90to97), by(year old)
	gen topshr_90to97 = (pop_90to97/pop_90to97_natl)*100
	label var topshr_90to97 "High earners share"
	eststo stock_EI_old20: ivreg2 stock `controls' EIxPostxold EIxold EIxPost oldxPost EI old topshr_90to97 i.year i.statenum, dkraay(10) partial(i.statenum i.year)
	estadd local elas_young = round((_b[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old20
	estadd local stderr_young = round((_se[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old20
	estadd local elas_old = round(((_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old')*1000)/1000,   replace:   stock_EI_old20
	nlcom elas_old: (_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old', post
	local stderr_old = round(_se[elas_old]*1000)/1000
	estadd local stderr_old = `stderr_old',   replace:   stock_EI_old20
	estadd local yearFE      "Yes",  replace:   stock_EI_old20
	estadd local stateFE     "Yes",  replace:   stock_EI_old20
	
	//wealth
	eststo stock_EI_old7: ivreg2 `wealth' `controls' EIxPostxold EIxold EIxPost oldxPost EI old i.year i.statenum, dkraay(10) partial(i.statenum i.year)
	estadd local elas_young = round((_b[EIxPost]/`baseline_wealth_normalized_yng')*1000)/1000,   replace:   stock_EI_old7
	estadd local stderr_young = round((_se[EIxPost]/`baseline_wealth_normalized_yng')*1000)/1000,   replace:   stock_EI_old7
	estadd local elas_old = round(((_b[EIxPostxold] +  _b[EIxPost])/`baseline_wealth_normalized_old')*1000)/1000,   replace:   stock_EI_old7
	nlcom elas_old: (_b[EIxPostxold] +  _b[EIxPost])/`baseline_wealth_normalized_old', post
	local stderr_old = round(_se[elas_old]*1000)/1000
	estadd local stderr_old = `stderr_old',   replace:   stock_EI_old7
	estadd local yearFE      "Yes",   replace:   stock_EI_old7
	estadd local stateFE     "Yes",   replace:   stock_EI_old7
	
	
	//Change dep var to stock p.c.
	eststo stock_EI_old9: ivreg2 stockpc `controls' EIxPostxold EIxold EIxPost oldxPost EI old i.year i.statenum, dkraay(10) partial(i.year i.statenum)
	estadd local elas_young = round((_b[EIxPost]/`baseline_stockpc_young')*1000)/1000,   replace:   stock_EI_old9
	estadd local stderr_young = round((_se[EIxPost]/`baseline_stockpc_young')*1000)/1000,   replace:   stock_EI_old9
	estadd local elas_old = round(((_b[EIxPostxold] +  _b[EIxPost])/`baseline_stockpc_old')*1000)/1000,   replace:   stock_EI_old9
	nlcom elas_old: (_b[EIxPostxold] +  _b[EIxPost])/`baseline_stockpc_old', post
	local stderr_old = round(_se[elas_old]*1000)/1000
	estadd local stderr_old = `stderr_old',   replace:   stock_EI_old9
	estadd local yearFE      "Yes",   replace:   stock_EI_old9
	estadd local stateFE     "Yes",   replace:   stock_EI_old9

	//Instrument post-2001 EI with 2001 EI
	levelsof abbr if year==2001 & EI==1, local(temp)
	gen EI2001 = 0
	foreach s of local temp {
		di "`s'"
		replace EI2001 = 1 if abbr == "`s'" & year>=2001
	}
	gen EI2001xPost = EI2001*post
	gen EI2001xPostxold = EI2001xPost*old
	gen EI2001xold = EI2001*old
	eststo stock_EI_old6: ivreg2 stock  `controls' oldxPost old i.year i.statenum (EI EIxold EIxPost EIxPostxold = EI2001 EI2001xold EI2001xPost EI2001xPostxold), dkraay(10) partial(i.year i.statenum)
	estadd local elas_young = round((_b[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old6
	estadd local stderr_young = round((_se[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old6
	estadd local elas_old = round(((_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old')*1000)/1000,   replace:   stock_EI_old6
	nlcom elas_old: (_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old', post
	local stderr_old = round(_se[elas_old]*1000)/1000
	estadd local stderr_old = `stderr_old',   replace:   stock_EI_old6
	estadd local yearFE       "Yes",   replace:    stock_EI_old6
	estadd local stateFE      "Yes",   replace:    stock_EI_old6
	

	//Drop phase-out period (2002-2004)
	eststo stock_EI_old3e: ivreg2 stock `controls' EIxPostxold EIxold EIxPost oldxPost EI old i.year i.statenum if inrange(year,2002,2004)==0, dkraay(10) partial(i.year i.statenum)
	estadd local elas_young = round((_b[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old3e
	estadd local stderr_young = round((_se[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old3e
	estadd local elas_old = round(((_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old')*1000)/1000,   replace:   stock_EI_old3e
	nlcom elas_old: (_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old', post
	local stderr_old = round(_se[elas_old]*1000)/1000
	estadd local stderr_old = `stderr_old',   replace:   stock_EI_old3e
	estadd local yearFE      "Yes",   replace:   stock_EI_old3e
	estadd local stateFE     "Yes",   replace:   stock_EI_old3e


	//Count Inheritance-tax-only cases as EI=0
	replace EI = 1 if Ionly==1
	eststo stock_EI_old3c: ivreg2 stock `controls' EIxPostxold EIxold EIxPost oldxPost EI old i.year i.statenum, dkraay(10) partial(i.year i.statenum)
	estadd local elas_young = round((_b[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old3c
	estadd local stderr_young = round((_se[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old3c
	estadd local elas_old = round(((_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old')*1000)/1000,   replace:   stock_EI_old3c
	nlcom elas_old: (_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old', post
	local stderr_old = round(_se[elas_old]*1000)/1000
	estadd local stderr_old = `stderr_old',   replace:   stock_EI_old3c
	estadd local yearFE      "Yes",   replace:   stock_EI_old3c
	estadd local stateFE     "Yes",   replace:   stock_EI_old3c

	
	****Outputting Table 3****
	
	#delimit ;
	esttab stock_EI_old2 stock_EI_old4 stock_EI_old20 stock_EI_old6 stock_EI_old9 stock_EI_old7 stock_EI_old3c stock_EI_old3e /*stock_EIrate_old3*/
	using ../Tables/Table3.tex, replace se scalars(elas_young stderr_young elas_old stderr_old) mtitle("" "" "" "IV" "Per Capita" "Wealth" "Incl. inher. tax" "Drop 2002-04" /*"ET Rate"*/) 
	noconstant label compress 
	substitute(topshr_90to97 "High Earners Share" EIratecombinedxPostxold "ET rate X post-2001 X old" EIratecombinedxPost "ET rate X post-2001" 0000000000001 "" \_ _  elas_young "Semi-elasticity, Young" stderr_young "\quad \textit{Std. Error}" elas_old "Semi-elasticity, Old" stderr_old "\quad \textit{Std. Error}" main "") star(* 0.1 ** 0.05 *** 0.01 )
	postfoot("\hline \hline" "\multicolumn{9}{l}{\footnotesize Driscoll-Kraay (with 10-year bandwidth) standard errors in parentheses. All regressions include year fixed effects. Note state fixed effects are absorbed by} \\" 
	"\multicolumn{9}{l}{\footnotesize old-young differencing. IV regression instruments for ET-state\textsubscript{s,t} and its interactions using a variable (and its corresponding interactions) equal to} \\"
	"\multicolumn{9}{l}{\footnotesize ET-state\textsubscript{s,t} for t$<$2001 and to ET-state\textsubscript{s,2001} for t$\geq$2001..} \\"
	"\multicolumn{9}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}  \end{tabular} }");
	
	
	#delimit cr

	
	****************************************
	***Table B6: Robustness, Panel B. DDD***
	****************************************
	//Restrict to top 100, 200, 300, or 10+ observations
	
	local m = 10
	foreach x in Top100 Top200 Top300 10obs {
		use ./stata_data/StateyearOld`x'AnalysisDataset.dta, clear
		sum stock if year==2001 & EI==1 & old==1	//yields baseline number of billionaires pre-`postyear'
		local baseline_stock_old = r(mean)
		eststo stock_EI_old`m': ivreg2 stock `controls' EIxPostxold EIxold EIxPost oldxPost EI old i.year i.statenum, dkraay(10) partial(i.year i.statenum)
		estadd local elas_young = round((_b[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old`m'
		estadd local stderr_young = round((_se[EIxPost]/`baseline_stock_young')*1000)/1000,   replace:   stock_EI_old`m'
		estadd local elas_old = round(((_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old')*1000)/1000,   replace:   stock_EI_old`m'
		nlcom elas_old: (_b[EIxPostxold] +  _b[EIxPost])/`baseline_stock_old', post
		local stderr_old = round(_se[elas_old]*1000)/1000
		estadd local stderr_old = `stderr_old',   replace:   stock_EI_old`m'
		estadd local yearFE      "Yes",   replace:   stock_EI_old`m'
		estadd local stateFE     "Yes",   replace:   stock_EI_old`m'
		local m = `m'+1
	}

	#delimit ;
	esttab stock_EI_old10 stock_EI_old11 stock_EI_old12 stock_EI_old13
	using ../Tables/TableB6_b.tex, replace se scalars(elas_young stderr_young elas_old stderr_old) mtitle("Top 100" "Top200" "Top300" "10+ Obs") 
	noconstant label compress substitute(0000000000001 "" \_ _  elas_young "Semi-elasticity, Young" stderr_young "\quad \textit{Std. Error}" elas_old "Semi-elasticity, Old" stderr_old "\quad \textit{Std. Error}") star(* 0.1 ** 0.05 *** 0.01 )
	postfoot("\hline \hline" "\multicolumn{5}{l}{\footnotesize Driscoll-Kraay (with 10-year bandwidth) standard errors in parentheses. All regressions} \\" 
	"\multicolumn{5}{l}{\footnotesize include year fixed effects. State fixed effects are absorbed by old-young differencing.} \\"
	"\multicolumn{5}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}  \end{tabular} }");
	#delimit cr
	
	*********************************************************************
	***Figure B3: Robustness to Dropping Individual ET States, Panel B***
	*********************************************************************

	//Drop each ET state one at a time 
	local i=1
	qui ivreg2 stock `controls' EIxPostxold EIxold EIxPost oldxPost EI old i.year i.statenum, dkraay(10) partial(i.year i.statenum)
	lincom EIxPostxold
	gen beta=r(estimate) if _n==`i'
	gen ub = r(ub) if _n==`i'
	gen lb = r(lb) if _n==`i'
	gen n = `i' if _n==`i'
	label define n `i' "None", add
	foreach s in WA OR HI OK KS MN WI IL OH NC VA MD DE PA NJ NY CT RI MA VT ME {
		local ++i
		qui ivreg2 stock `controls' EIxPostxold EIxold EIxPost oldxPost EI old i.year i.statenum if abbr~="`s'", dkraay(10) partial(i.year i.statenum)
		di "State: `s'"
		lincom EIxPostxold
		replace beta=r(estimate) if _n==`i'
		replace ub = r(ub) if _n==`i'
		replace lb = r(lb) if _n==`i'
		replace n = `i' if _n==`i'
		label define n `i' "`s'", add
	}
	label values n n
	#delimit ;
	twoway (rcap ub lb n, lcolor(ltblue)) (scatter beta n, mcolor(blue)) if inrange(n,1,`i'), 
	xlabel(1(1)`i',valuelabel alternate) xtitle(Excluded ET State) legend(off) graphregion(color(white))
	ytitle(Point Estimate and 95% Confidence Interval) yline(0, lcolor(black)) 
	yscale(range(-3 1)) ylabel(-3(1)1)
	;
	#delimit cr
	graph export ../Figures/FigureB3_b.pdf, replace as(pdf)

} // end run3D IF code

/// 3. INDIVIDUAL LEVEL ANALYSIS
if "$runINDIV" == "yes" {

use ./stata_data/IndivAnalysisDataset.dta, clear
tsset nameid year, yearly
gen oldXpost = old*post
gen LEI = L.EI
gen EIxPost = EI*post
gen LEIxPost = L.EI*post
gen avgxPost = avg*post
label variable EI "ET-state"
label variable LEI "ET-state(t-1)"
label variable avg "PIT"
label variable EIxPost "ET-state X post-`postyear'"
label variable LEIxPost "ET-state(t-1) X post-`postyear'"
label variable avgxPost "PIT X post-`postyear'"


/// INDIVIDUAL LEVEL SUMMARY STATISTICS

***********************************************************************
***Table B3, Panel A -- Individual-by-Year Observations, 1982 - 2017***
***********************************************************************

eststo clear
estpost sum Age_num wealth, detail
esttab using "../Tables/TableB3_a.tex", replace modelwidth(10 20) cell((mean(fmt(%9.2f) label(Mean)) p50(fmt(%9.2f) label(Median)) sd(fmt(%9.2f) label(Standard Deviation)) min(label(Minimum)) max(label(Maximum)))) nonumber nomtitle label 

sum Age_num if year>`postyear', detail
local median = r(p50)

***********************************************************
***Table B3, Panel B -- Distribution of Net Worth (2017)***
***********************************************************
preserve
gen NetWorthBill = NetWorthMill/1000
keep if year==2017
gen rowlabel = "Net Worth (bill)"
tabout rowlabel using "../Tables/TableB3_b.tex", style(tex) h2(nil) bt ///
replace sum cells(p1 NetWorthBill p10 NetWorthBill p25 NetWorthBill p50 NetWorthBill p75 ///
NetWorthBill p90 NetWorthBill p99 NetWorthBill) f(1 1 1 1 1 1 1) oneway clab(1st 10th 25th 50th 75th 90th 99th) ptotal(none)
restore

*******************************************************************
***Figure B2: Average Wealth of Forbes 400 Sample (1982 to 2017)***
*******************************************************************

preserve
collapse (mean) wealth NetWorthMill (count) nameid, by(year)
gen NetWorthBill = NetWorthMill/1000
label variable NetWorthBill "Nominal"
label variable wealth "Real (2017 $)"
twoway bar nameid year, ytitle("Count") graphregion(color(white)) 
twoway line wealth NetWorthBill year, ytitle("Billions ($)") graphregion(color(white)) ylabels(0(1)7) lpattern(solid dash) lwidth(thick .) lcolor(navy red)
graph export ../Figures/FigureB2.pdf, replace as(pdf)
restore

************************************************************************************
***Figure 4: Impact of Billionaire Death on State Estate Tax Revenues Event Study***
************************************************************************************

preserve
import excel using ../data/raw_data/ForbesDeaths2.xlsx, firstrow clear sheet(Table_For_Export)
drop Notes ResidenceStateForbes
rename YearofDeath death_year
rename StateofDeath state_of_death
drop if death_year==.
tempfile deaths
save `deaths', replace
restore

preserve
merge 1:1 Name year using `deaths', keep(1 3)
gen death = (_merge==3)
drop _merge

gen tag3 = (death==1)
gen tag4 = (death==1 & death_married==0)

collapse (sum) tag*, by(ResidenceStateObituary death_year)
rename ResidenceStateObituary abbr

rename death_year year
keep if -tag3<0

tempfile deathcounts
save `deathcounts'
use ./stata_data/StateyearAnalysisDataset.dta, clear
drop _merge
merge 1:1 abbr year using `deathcounts', keep(1 3) nogen
tsset statenum year, yearly

replace tag4 = 0 if tag4==. 
replace tag4 = 1 if -tag4<-1
replace tag4 = 0 if year>2004 & EI==0
gen dtag4 = D.tag4 

replace EI_Tax = 0 if EI_Tax==.
replace EI_Tax = (EI_Tax/cpi)/1000 //convert to millions
gen Post = (year>`postyear')
capture drop cEI_Tax* eventtime b b_*
gen eventtime = .
gen b = .
gen b_lb = .
gen b_ub = .



foreach h of num 1/5 {
  gen cEI_TaxL`h' = 0

  replace cEI_TaxL`h' = (L`h'.EI_Tax)
  xtreg cEI_TaxL`h' i.year tag4, fe

  local i = 6-`h'
  replace eventtime = -`h' if _n==`i'
  replace b = _b[tag4] if _n==`i'
  replace b_lb = _b[tag4] - 1.65*_se[tag4] if _n==`i'
  replace b_ub = _b[tag4] + 1.65*_se[tag4] if _n==`i'
  
}

foreach h of num 0/12 {
  gen cEI_TaxF`h' = 0

  replace cEI_TaxF`h' = (F`h'.EI_Tax)
  xtreg cEI_TaxF`h' i.year tag4, fe

  local i = 6 + `h'
  replace eventtime = `h' if _n==`i'
  replace b = _b[tag4] if _n==`i'
  replace b_lb = _b[tag4] - 1.65*_se[tag4] if _n==`i'
  replace b_ub = _b[tag4] + 1.65*_se[tag4] if _n==`i'
}

***Exporting Figure 4***
#delimit ;
twoway 
	(connected b eventtime if eventtime<=-1, color(black))  (connected b eventtime if eventtime>=-1 & eventtime<6, color(black) )
	(line b_lb eventtime if eventtime<=-1, color(black) lpattern(dash))  (line b_lb eventtime if eventtime>=-1 & eventtime<6, color(black) lpattern(dash))
	(line b_ub eventtime if eventtime<=-1, color(black) lpattern(dash))  (line b_ub eventtime if eventtime>=-1 & eventtime<6, color(black) lpattern(dash)), 
		legend(off) ytitle(State E&I Tax Revenues (Millions of 2017 $)) xtitle(Years Since Death (t=0)) yscale(range(0 250)) ylabel(0 50 100 150 200 250, nogrid)
		yline(99,lcolor(gs10)) graphregion(color(white)) plotregion(color(white))
;
#delimit cr
graph export ../Figures/Figure4.pdf, replace as(pdf)

*******************************************************************************************
***Figure 3: Impact of Billionaire Death on State Estate Tax Revenues - Two Case Studies***
*******************************************************************************************

twoway connected EI_Tax year if abbr=="OK", xline(2003, lcolor(gs8) lpattern(dash)) graphregion(color(white)) plotregion(color(white)) color(black) ytitle(State E&I Tax Revenues (Millions of 2017 $))
graph export ../Figures/Figure3_b.pdf, replace as(pdf)

twoway connected EI_Tax year if abbr=="AR", xline(1995, lcolor(gs8) lpattern(dash)) graphregion(color(white)) plotregion(color(white)) color(black) ytitle(State E&I Tax Revenues (Millions of 2017 $))
graph export ../Figures/Figure3_a.pdf, replace as(pdf)

restore



/// FALSIFICATION TEST: PROB OF CHOOSING HIGH-MTR STATE
**********************************************************************
***Figure B4: Probability of Living in High Income Tax State by Age***
**********************************************************************

gen Age_num_trunc = Age_num

replace Age_num_trunc = 85 if Age_num_trunc>=85 & Age_num_trunc~=.  //lumping together for graphing purposes

gen highMTR = (avg > .03)

binscatter highMTR Age_num_trunc if Age_num>40 & year<=2001, discrete reportreg yscale(range(0 1)) ylabel(0 .2 .4 .6 .8 1) xlabel(40 45 50 55 60 65 70 75 80 85 "85+")  ytitle("Fraction of Age Group Living in State with High MTR") xtitle("Age")
graph export ../Figures/FigureB4_a.pdf, replace as(pdf)

binscatter highMTR Age_num_trunc if Age_num>40 & year>=2005, discrete reportreg yscale(range(0 1)) ylabel(0 .2 .4 .6 .8 1) xlabel(40 45 50 55 60 65 70 75 80 85 "85+") ytitle("Fraction of Age Group Living in State with High MTR") xtitle("Age")
graph export ../Figures/FigureB4_b.pdf, replace as(pdf)



****************************************************************
***Figure 6: Probability of Living in Estate Tax State By Age***
****************************************************************

binscatter EI Age_num_trunc if Age_num_trunc>40 & post==0, discrete reportreg yscale(range(0 .55)) xlabel(40 45 50 55 60 65 70 75 80 85 "85+") ylabel(0 .1 .2 .3 .4 .5) ytitle("Fraction of Age Group Living in State with Estate Tax") xtitle("Age") 
graph export ../Figures/Figure6_a.pdf, replace as(pdf)

binscatter EI Age_num_trunc if Age_num_trunc>40 & post==1, discrete reportreg yscale(range(0 .55)) xlabel(40 45 50 55 60 65 70 75 80 85 "85+") ylabel(0 .1 .2 .3 .4 .5) ytitle("Fraction of Age Group Living in State with Estate Tax") xtitle("Age") 
graph export ../Figures/Figure6_b.pdf, replace as(pdf)


***********************************************************************************
*** Table 4: Linear Probability Model: Probability of Living in Estate Tax State***
***********************************************************************************

eststo highMTR_age4: reghdfe highMTR AgeXpost Age_num if Age_num>40, cluster(stateyear nameid) absorb(statenum year)
estadd local stateFE     "Yes",   replace:   highMTR_age4
estadd local indivFE     "No",   replace:   highMTR_age4
estadd local yearFE      "Yes",   replace:   highMTR_age4

eststo EI_age1: ivreg2 EI Age_num i.year if post==0, dkraay(2)  partial(i.year)
estadd local stateFE     "No",   replace:   EI_age1
estadd local indivFE     "No",   replace:   EI_age1
estadd local yearFE      "Yes",   replace:   EI_age1


eststo EI_age2: ivreg2 EI Age_num i.year if post==1, dkraay(2) partial(i.year)
estadd local stateFE     "No",   replace:   EI_age2
estadd local indivFE     "No",   replace:   EI_age2
estadd local yearFE      "Yes",   replace:   EI_age2


eststo EI_age3: ivreg2 EI AgeXpost Age_num i.year, dkraay(2)  partial(i.year)
estadd local stateFE     "No",   replace:   EI_age3
estadd local indivFE     "No",   replace:   EI_age3
estadd local yearFE      "Yes",   replace:   EI_age3

eststo EI_age4: ivreg2 EI AgeXpost Age_num i.statenum i.year, dkraay(2)  partial(i.statenum i.year)
estadd local stateFE     "Yes",  replace:   EI_age4
estadd local indivFE     "No",   replace:   EI_age4
estadd local yearFE      "Yes",   replace:   EI_age4


eststo EI_age5: ivreg2 EI AgeXpost Age_num i.statenum i.year i.nameid, dkraay(2)  partial(i.statenum i.year i.nameid)
estadd local stateFE     "Yes",   replace:   EI_age5
estadd local indivFE     "Yes",   replace:   EI_age5
estadd local yearFE      "Yes",   replace:   EI_age5



local py1 = `postyear'+1
if `postyear'==2001 {
	local py1 = 2003  //no data in 2002
}

#delimit ;
esttab EI_age1 EI_age2 EI_age3 EI_age4 EI_age5 highMTR_age4 
     using ../Tables/Table4.tex, replace se scalars(yearFE stateFE indivFE) mtitle("1982-`postyear'" "`py1'-2017" "1982-2017" "1982-2017" "1982-2017" "High MTR") 
     noconstant label compress substitute(\_ _  yearFE "Year Fixed Effects" stateFE "State Fixed Effects" indivFE "Individual Fixed Effects") star(* 0.1 ** 0.05 *** 0.01 )
	 postfoot("\hline \hline" "\multicolumn{5}{l}{\footnotesize Driscoll-Kraay standard errors (in parentheses).} \\" 
	 "\multicolumn{5}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}  \end{tabular} }");
#delimit cr

*************************************************************
***Table B6: Robustness, Panel C. Linear Probability Model***
*************************************************************

preserve
use ./stata_data/IndivAnalysisDataset.dta, clear
drop if ourrank>100	
eststo EI_age10: ivreg2 EI AgeXpost Age_num i.statenum i.year, dkraay(2)  partial(i.statenum i.year)
use ./stata_data/IndivAnalysisDataset.dta, clear
drop if ourrank>200	
eststo EI_age11: ivreg2 EI AgeXpost Age_num i.statenum i.year, dkraay(2)  partial(i.statenum i.year)
use ./stata_data/IndivAnalysisDataset.dta, clear
drop if ourrank>300	
eststo EI_age12: ivreg2 EI AgeXpost Age_num i.statenum i.year, dkraay(2)  partial(i.statenum i.year)
use ./stata_data/IndivAnalysisDataset.dta, clear
egen obs = count(year), by(nameid)
keep if obs>=10
eststo EI_age13: ivreg2 EI AgeXpost Age_num i.statenum i.year, dkraay(2)  partial(i.statenum i.year)
#delimit ;
esttab EI_age10 EI_age11 EI_age12 EI_age13
	using ../Tables/TableB6_c.tex, replace se mtitle("Top 100" "Top200" "Top300" "10+ Obs" ) /*drop(*year *cons)*/
	noconstant label compress substitute(\_ _ ) star(* 0.1 ** 0.05 *** 0.01 )
	postfoot("\hline \hline" "\multicolumn{5}{l}{\footnotesize Driscoll-Kraay standard errors in parentheses.} \\" 
	"\multicolumn{5}{l}{\footnotesize All regressions include state and year fixed effects.} \\"
	"\multicolumn{5}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}  \end{tabular} }");
#delimit cr
restore

**************************************************************************************************************
***Figure 7: Estimated Age Gradient for Probability of Living in Estate Tax State, Year-by-Year Regressions***
**************************************************************************************************************

gen y = _n + 1981 if _n <= 2017 - 1981
label variable y "year"
gen b = .
gen b_lb = .
gen b_ub = .

foreach y of num 1982/2001 2003/2017 {
	qui ivreg2 EI Age_num_trunc if Age_num_trunc>40  & year==`y', cluster(stateyear)
	replace b = _b[Age_num] if _n==`y'-1981
	replace b_lb = _b[Age_num] - 1.65*_se[Age_num] if _n==`y'-1981
	replace b_ub = _b[Age_num] + 1.65*_se[Age_num] if _n==`y'-1981
}

#delimit ;

egen pretrend = mean(b) if y<2002;
egen posttrend = mean(b) if y>2002;

twoway (rcap b_lb b_ub y, lcolor(ltblue)) (scatter b y, mcolor(blue)) (line pretrend posttrend y, lcolor(maroon maroon) lpattern(dash dash))
	if y<=2017, xline(`postyear'(.1)2004, lwidth(thick) lcolor(gs15)) xline(2001, lcolor(black)) graphregion(color(white)) plotregion(color(white)) legend(off) 
	ytitle(Age Gradient for Prob of Living in ET State)
	ylabel(#8, nogrid)
	xlabels(1985(5)2015)
	;
graph export ../Figures/Figure7.pdf, replace as(pdf);

#delimit cr

}  //end runINDIV IF code

/// 4. ANALYSES OF MOVERS
if "$runMOVERS" == "yes" {
use ./stata_data/IndivAnalysisDataset.dta, clear

sort nameid year
keep nameid year abbr EI Age_num
reshape wide abbr EI Age_num, i(nameid) j(year)
gen one=1

preserve
drop if abbr2001 == ""	//keep only individuals observed in 2001 (N=376)

local startyr = 2001


matrix A = J(9,2009-`startyr'-1 + 8,.)
matrix colnames A=1993 1994 1995 1996 1997 1998 1999 2000 2003 2004 2005 2006 2007 2008 2009

matrix rownames A="\%_from_ET_to_non-ET" "\%_from_non-ET_to_ET" "Difference" ///
"\%_from_ET_to_non-ET" "\%_from_non-ET_to_ET" "Difference" "\%_from_ET_to_non-ET" "\%_from_non-ET_to_ET" "Difference"

local m = -2
foreach ifc in ~=. >=65 <65  {
  local m = `m'+3
	foreach endyr of num 1993/2000 {
		
		local j = `endyr'-1992
		
		qui sum one if abbr`endyr'~="" & EI`startyr'==1  & Age_num2001 `ifc'
		local num_E`startyr' = r(N)
	
		qui sum one if abbr`endyr'~="" & EI`startyr'==1 & EI`endyr' == 0 & (abbr`startyr'~=abbr`endyr') & Age_num2001 `ifc'
		local num_E`startyr'_N`endyr' = r(N)
		
		local row1 = (`num_E`startyr'_N`endyr''/`num_E`startyr'')*100
		matrix A[`m'+1,`j'] = `row1'
		
		qui sum one if abbr`endyr'~="" & EI`startyr'==0  & Age_num2001 `ifc'
		local num_N`startyr' = r(N)
	
		qui sum one if abbr`endyr'~="" & EI`startyr'==0 & EI`endyr' == 1  & (abbr`startyr'~=abbr`endyr') & Age_num2001 `ifc'
		local num_N`startyr'_E`endyr' = r(N)
		
		local row2 = (`num_N`startyr'_E`endyr''/`num_N`startyr'')*100
		matrix A[`m',`j'] = `row2'

		local row3_`endyr' = `row2' - `row1'
		matrix A[`m'+2,`j'] = `row3_`endyr''

		
	}
	foreach endyr of num 2003/2009 {
		
		local j = `endyr'-2002 + 8 
		
		qui sum one if abbr`endyr'~="" & EI`startyr'==1  & Age_num2001 `ifc'
		local num_E`startyr' = r(N)
	
		qui sum one if abbr`endyr'~="" & EI`startyr'==1 & EI`endyr' == 0 & (abbr`startyr'~=abbr`endyr') & Age_num2001 `ifc'
		local num_E`startyr'_N`endyr' = r(N)
		
		local row1 = (`num_E`startyr'_N`endyr''/`num_E`startyr'')*100
		matrix A[`m',`j'] = `row1'
		
		qui sum one if abbr`endyr'~="" & EI`startyr'==0  & Age_num2001 `ifc'
		local num_N`startyr' = r(N)
	
		qui sum one if abbr`endyr'~="" & EI`startyr'==0 & EI`endyr' == 1  & (abbr`startyr'~=abbr`endyr') & Age_num2001 `ifc'
		local num_N`startyr'_E`endyr' = r(N)
		
		local row2 = (`num_N`startyr'_E`endyr''/`num_N`startyr'')*100
		matrix A[`m'+1,`j'] = `row2'

		local row3_`endyr' = `row1' - `row2'
		matrix A[`m'+2,`j'] = `row3_`endyr''

	}
}
matrix list A
matrix A1 = A[1..3,1..15]
matrix A2 = A[4..6,1..15]
matrix A3 = A[7..9,1..15]

foreach i of num 1/3 {
	clear
	svmat A`i'
	gen type = _n
	reshape long A`i', i(type) j(year)
	replace year = year+1992
	replace year = year+2 if year>=2001
	tempfile A`i'
	save `A`i''
}
merge 1:1 type year using `A1', keep(3) nogen
merge 1:1 type year using `A2', keep(3) nogen
rename A1 all
rename A2 over64
rename A3 under65
gen flow = "fromET" if type==1
replace flow = "toET" if type==2
replace flow = "Difference" if type==3
drop type
reshape wide all over64 under65, i(year) j(flow) string
insobs 1
replace year=2001 if year==.
sort year

*************************************************************************
***Figure 8: Probability of Moving Between ET States and Non-ET States***
*************************************************************************

***Panel A: All***
twoway connected allfromET alltoET year if inrange(year,1993,2009), legend(  order(1 "Prob moved ET to non-ET" 2 "Prob moved non-ET to ET") rows(1) )  graphregion(color(white)) lpattern(solid dash) lwidth(thick .) lcolor(navy red) yscale(range(-2 44)) ylabels(0 5 10 15 20 25 30 35 40 45, nogrid) xline(2001, lcolor(black)) ytitle("% of Forbes 400 observed in both 2001 and t") xtitle(year(t)) yline(0, lcolor(gs12)) xlabel(1993(2)2009)
graph export ../Figures/Figure8_a.pdf, replace as(pdf)

***Panel B: 65 and Over***
twoway connected over64fromET over64toET year,  legend(  order(1 "Prob moved ET to non-ET" 2 "Prob moved non-ET to ET") rows(1) )  graphregion(color(white)) lpattern(solid dash) lwidth(thick .) lcolor(navy red) yscale(range(-2 44)) ylabels(0 5 10 15 20 25 30 35 40 45, nogrid) xline(2001, lcolor(black)) ytitle("% of Forbes 400 observed in both 2001 and t") xtitle(year(t)) yline(0, lcolor(gs12)) xlabel(1993(2)2009)
graph export ../Figures/Figure8_b.pdf, replace as(pdf)

***Panel C. Under 65***
twoway connected under65fromET under65toET year,  legend(  order(1 "Prob moved ET to non-ET" 2 "Prob moved non-ET to ET") rows(1) )  graphregion(color(white)) lpattern(solid dash) lwidth(thick .) lcolor(navy red) yscale(range(-2 44)) ylabels(0 5 10 15 20 25 30 35 40 45, nogrid) xline(2001, lcolor(black)) ytitle("% of Forbes 400 observed in both 2001 and t") xtitle(year(t)) yline(0, lcolor(gs12)) xlabel(1993(2)2009)
graph export ../Figures/Figure8_c.pdf, replace as(pdf)

restore


}   //end runMOVERS section

/// 5. COST-BENEFIT ANALYSIS
if "$runCB" == "yes" { 

	matrix R1 = J(11,6,.)
	matrix colnames R1="Baseline" "Alt_1" "Alt_2" "Alt_3" "Alt_4" "Alt_5" 
	matrix rownames R1= "ET_States_(10)" "Average_CB_ratio" "Number_with_CB$\geq$1" "" "Non-ET_States_(28)" "Average_CB_ratio" "Number_with_CB$\geq$1" "Average_CB_ratio" "Number_with_CB$\geq$1" "" "All_States_(38)"
	matrix R2 = R1
	matrix colnames R2="Baseline" "Alt_1" "Alt_2" "Alt_3" "Alt_4" "Alt_5" 
	matrix rownames R2="ET_States_(14)" "Average_CB_ratio" "Number_with_CB$\geq$1" "" "Non-ET_States_(36)" "Average_CB_ratio" "Number_with_CB$\geq$1" "Average_CB_ratio" "Number_with_CB$\geq$1" "" "All_States_(50)"
	local col = 0

	foreach scenario in baseline alt1 alt2 alt3 alt4 alt5 {

		local col = `col'+1
		/// locals and scalars for baseline scenario:
		local t = 2017
		scalar eta = 0.373		//DiD table, column 6 (wealth elasticity)
		local tauE = 0.16
		scalar eta0 = 0.00186		//from column 3 Table 4

		scalar delta = 0.00320  //estimated age gradient -- column 3 of Table 4
		local LP = 89.783/82.585  //Male life exp of someone at 100th percentile income relative to 50th percentile income from Chetty et al (2016 JAMA)
		local r = 0.02
		local g = 1
		local spouse = 0
		preserve
		use ./stata_data/IndivAnalysisDataset.dta, clear
		sum wealth if year==2017, detail
		restore
		local W = r(mean)*1000*(8.25/16)
		local Y = `W'*0.103  //0.103 is ratio of taxable income to taxable estate values according to IRS SOI (08es03lk.xls)


		/// set locals and scalars for each scenario
		if "`scenario'" == "alt1" {
			local g = 1.070  //annual growth rate of real wealth in Fig 1
		}	
		if "`scenario'" == "alt2" {
			local spouse = 10
		}	
		if "`scenario'" == "alt3" {
			local r = 0.01
		}	
		if "`scenario'" == "alt4" {
			local r = 0.03
		}	
		if "`scenario'" == "alt5" {
			local Y = 159*(245.134/236.715)  //Saez-Zucman (2019) estimate of mean gross income for top 400 income taxpayers in 2014 (in millions, adjusted to 2017 dollars)
		}	


		*** Note: cost is upper bound b/c:
		***		1. forbes 400 likely to have taxable income below that of top 400 income-tax payers (due to shelters)
		*** 	2. we're assuming all of Y is taxed at state's avg of top MTR on wages/salaries and LTCG; true effective rate may be lower
		*** 	3. we're assuming lost billionaires live another 29 years. median age of EI-sensitive billionaires is older, like 74, and so T is more like 24.
		*** But could be lower bound b/c:
		*** 	1. ignores property and sales tax revenues from lost billionaires


		/// NOW ALLOW FOR AGE HETEROGENEITY
		use ./stata_data/StateyearAgeAnalysisDataset.dta, clear
		egen stateage = group(abbr Age_num)
		tsset stateage year, yearly
		gen EInextyear = EI
		if `t' == 2001 {
			replace EInextyear = F.EI 
		}
		keep if year==`t'

		qui {
			/// Set T by age according to IRS Pub 590-B, Appendix B, Tables I (age<30) and II (30<=age<70), assuming spouse 10 years younger, and III for age>=70 (which appears to assume spouse is 10 years younger) :
			gen T = 82.04 if Age_num==0
			replace T = 81.6 + 10 if Age_num==1
			replace T = 75.8 + 10 if inrange(Age_num,5,9)
			replace T = 70.8 + 10 if inrange(Age_num,10,14)
			replace T = 66 + 10 if inrange(Age_num,15,19)
			replace T = 61.1 + 10 if inrange(Age_num,20,24)
			replace T = 56.2 + 10 if inrange(Age_num,25,29)
			replace T = 64.3 if inrange(Age_num,30,34)
			replace T = 59.4 if inrange(Age_num,35,39)
			replace T = 54.4 if inrange(Age_num,40,44)
			replace T = 49.5 if inrange(Age_num,45,49)
			replace T = 44.6 if inrange(Age_num,50,54)
			replace T = 39.7 if inrange(Age_num,55,59)
			replace T = 34.9 if inrange(Age_num,60,64)
			replace T = 30.2 if inrange(Age_num,65,69)

			replace T = 27.4 if Age_num==70
			replace T = 26.5 if Age_num==71
			replace T = 25.6 if Age_num==72
			replace T = 24.7 if Age_num==73
			replace T = 23.8 if Age_num==74
			replace T = 22.9 if Age_num==75
			replace T = 22.0 if Age_num==76
			replace T = 21.2 if Age_num==77
			replace T = 20.3 if Age_num==78
			replace T = 19.5 if Age_num==79
			replace T = 18.7 if Age_num==80
			replace T = 17.9 if Age_num==81
			replace T = 17.1 if Age_num==82
			replace T = 16.3 if Age_num==83
			replace T = 15.5 if Age_num==84
			replace T = 14.8 if Age_num==85
			replace T = 14.1 if Age_num==86
			replace T = 13.4 if Age_num==87
			replace T = 12.7 if Age_num==88
			replace T = 12.0 if Age_num==89
			replace T = 11.4 if Age_num==90
			replace T = 10.8 if Age_num==91
			replace T = 10.2 if Age_num==92
			replace T = 9.6 if Age_num==93
			replace T = 9.1 if Age_num==94
			replace T = 8.6 if Age_num==95
			replace T = 8.1 if Age_num==96
			replace T = 7.6 if Age_num==97
			replace T = 7.1 if Age_num==98
			replace T = 6.7 if Age_num==99
			replace T = 6.3 if Age_num==100
			replace T = 5.9 if Age_num==101
			replace T = 5.5 if Age_num==102
			replace T = 5.2 if Age_num==103
			replace T = 4.9 if Age_num==104
			replace T = 3.5 if Age_num>105
		}

		/// Adjust T by Chetty et al longevity premium for wealthy
		replace T = T*`LP' + `spouse'

		replace wealth = wealth*1000   //convert to millions

		gen cost = 0
		levelsof Age_num, local(agelevels)
		foreach a of local agelevels {
			preserve
			keep if Age_num == `a'
			qui sum T
			local T = int(round(r(mean)))
			foreach i of num 1/`T' {
				qui replace cost = cost + (1/(1+`r'))^(`i')*(`Y'*(`g'^`i'))*(eta0 + delta*`a')*(avg/100)*stock
			}
			tempfile age`a'
			save `age`a''
			restore
		}
		
		clear
		foreach a of local agelevels {
			if `a' ~= 0 append using `age`a'' 
		}

		gen benefit = (1/(1+`r'))^(T)*(`W'*(`g'^T))*(1-(eta0 + delta*Age_num))*`tauE'*stock
		
		****************************************************************************************************
		***Table B7: Cost-Benefit Results Under Alternative Assumptions (Panel A: Billionaire Estate Tax)***
		****************************************************************************************************
		
		gcollapse (sum) cost benefit stock wealth (mean) EInextyear avg, by(State abbr)
		gen CBratio = cost/benefit

		sum CBratio
		matrix R1[10,`col'] = r(mean)
		sum CBratio if CBratio>=1
		matrix R1[11,`col'] = r(N)
		sum CBratio if EInextyear==1
		matrix R1[2,`col'] = r(mean)
		sum CBratio if EInextyear==1 & CBratio>=1
		matrix R1[3,`col'] = r(N)
		sum CBratio if EInextyear==0
		matrix R1[6,`col'] = r(mean)
		sum CBratio if EInextyear==0 & CBratio>=1
		matrix R1[7,`col'] = r(N)
		outtable using "../Tables/TableB7_a", mat(R1) replace center  format(%3.2f)

		rename abbr state


		gen net_revenues = (benefit - cost)
		
		*******************************************************************
		***Table 6: Cost-Benefit Calculations for Billionaire Estate Tax***
		*******************************************************************
		
		if "`scenario'" == "baseline"{
			foreach x of num 0 1 {
				if `x' { //Panel A. States w/ Estate Tax
				#delimit ;
				tabout State using "../Tables/Table6_a.tex" if EInextyear==`x', style(tex) h2(nil) bt replace sum 
				cells(mean stock mean wealth mean avg mean CBratio mean net_revenues) f(0 0c 2 2 0c) 
				oneway h3( &Forbes  &Forbes &Personal Income & &EPV Net Revenues\\State& Population& Wealth (mil)& Tax Rate&Cost/Benefit&from Adopting (mil)\\) total(Average);
				#delimit cr
				}
				else{ //Panel B. States w/out Estate Tax
				#delimit ;
				tabout State using "../Tables/Table6_b.tex" if EInextyear==`x', style(tex) h2(nil) bt replace sum 
				cells(mean stock mean wealth mean avg mean CBratio mean net_revenues) f(0 0c 2 2 0c) 
				oneway h3( &Forbes  &Forbes &Personal Income & &EPV Net Revenues\\State& Population& Wealth (mil)& Tax Rate&Cost/Benefit&from Adopting (mil)\\) total(Average);
				#delimit cr
				}
			}
		}

		eststo clear


		/// COMPUTE CB RATIOS FOR ALL POTENTIAL ESTATE TAX PAYERS
		import excel using ./raw_data/15es02st.xls, clear cellrange(A9:I59)
		keep A C
		rename A statename
		rename C amount
		gen year = 2015
		tempfile soi15
		save `soi15'
		import excel using ./raw_data/16es02st.xls, clear cellrange(A9:I59)
		keep A C
		rename A statename
		rename C amount
		gen year = 2016
		tempfile soi16
		save `soi16'
		import excel using ./raw_data/17es02st.xls, clear cellrange(A9:I59)
		keep A B C
		rename A statename
		rename B number
		rename C amount
		destring amount, replace force
		destring number, replace force
		gen year = 2017
		
		******************************************************************
		***Figure B5: Number of Federal Estate Taxpayers by State, 2017***
		******************************************************************
		
		if "`scenario'"=="baseline" {
			preserve
			import excel using ./raw_data/state_fips_crosswalk.xlsx, clear firstrow
			rename State statename
			rename abbr state
			keep state statename
			tempfile mapping
			save `mapping'
			restore
			merge 1:1 statename using `mapping', nogen keep(1 3) 
			maptile number, geo(state) geoid(state) ndfcolor(gray) cutvalues(0 50 100 200 500 1000) twopt(legend(lab(2 "0") lab(3 "1 - 50") ))
			graph export ../Figures/FigureB5.pdf, replace as(pdf)
			drop number state
		}
		
		append using `soi15'
		append using `soi16'
		collapse (mean) amount, by(statename)
		tempfile soi
		save `soi'


		use ./stata_data/StateyearAnalysisDataset.dta, clear
		gen EInextyear = EI
		keep if year==2017

		merge 1:1 statename using `soi', keep(1 3) nogen

		scalar natlW_U70 = 30529954/1000
		scalar natlW_7079 = 33297568/1000
		scalar natlW_O79 = 53305929/1000
		scalar natlW = natlW_U70 + natlW_7079 + natlW_O79 

		/// set prob of death equal to mortality rates from SSA for mean age in forbes for each group, taking 75/25 weighted avg of male and female rates
		scalar prob_death_U70 = .75*0.013302 + .25*0.007893   	//62yr old 
		scalar prob_death_7079 = .75*0.030070 + .25*0.020705  	//73yr old 
		scalar prob_death_O79 = .75*0.107390 + .25*0.082465 		//86yr old 
		/// adjust using mortality differential for top 1% from Fig 3 of Saez-Zucman (2019)
		scalar prob_death_U70 =  prob_death_U70*.3
		scalar prob_death_7079 = prob_death_7079*.5
		scalar prob_death_O79 = prob_death_O79*.7  //see fig 3 of SZ 2019

		scalar natl_YW_ratio_U70 = 0.103		//see 08es03lk.xls
		scalar natl_YW_ratio_7079 = 0.071
		scalar natl_YW_ratio_O79 = 0.058


		///merge in estate values from IRS SOI for 2015-2017; average by state
		gen W_U70 = (amount/1000)*(natlW_U70/natlW)/prob_death_U70 
		gen W_7079 = (amount/1000)*(natlW_7079/natlW)/prob_death_7079 
		gen W_O79 = (amount/1000)*(natlW_O79/natlW)/prob_death_O79
		gen Y_U70 = W_U70*(natl_YW_ratio_U70) 
		gen Y_7079 = W_7079*(natl_YW_ratio_7079) 
		gen Y_O79 = W_O79*(natl_YW_ratio_O79)

		scalar tauE = 0.16*(.25/.40)  // .25 is federal estate ATR, .4 is federal statutory top MTR, so this accounts for progressivity

		local T_U70 = 31.6*`LP' + `spouse'
		local T_7079 = 22.9*`LP'+ `spouse'
		local T_O79 = 14.8*`LP'+ `spouse'

		local etaBaseU70 = eta0 + delta*62
		local etaAltU70 = `etaBaseU70'/2
		local etaBase7079 = eta0 + delta*73
		local etaAlt7079 = `etaBase7079'/2
		local etaBaseO79 = eta0 + delta*86
		local etaAltO79 = `etaBaseO79'/2

		rename abbr state
		foreach j in Base Alt {
			gen cost_`j'U70 = 0
			foreach i of num 1/`T_U70' {
				replace cost_`j'U70 = cost_`j'U70 + (1/(1+`r'))^(`i')*(Y_U70*(`g'^`i'))*`eta`j'U70'*(avg/100)
			}
			gen benefit_`j'U70 = (1/(1+`r'))^(`T_U70')*(W_U70*(`g'^`T_U70'))*(1-`eta`j'U70')*tauE
			gen cost_`j'7079 = 0
			foreach i of num 1/`T_7079' {
				replace cost_`j'7079 = cost_`j'7079 + (1/(1+`r'))^(`i')*(Y_7079*(`g'^`i'))*`eta`j'7079'*(avg/100)
			}
			gen benefit_`j'7079 = (1/(1+`r'))^(`T_7079')*(W_7079*(`g'^`T_7079'))*(1-`eta`j'7079')*tauE
			gen cost_`j'O79 = 0
			foreach i of num 1/`T_O79' {
				replace cost_`j'O79 = cost_`j'O79 + (1/(1+`r'))^(`i')*(Y_O79*(`g'^`i'))*`eta`j'O79'*(avg/100)
			}
			gen benefit_`j'O79 = (1/(1+`r'))^(`T_O79')*(W_O79*(`g'^`T_O79'))*(1-`eta`j'O79')*tauE

			gen CBratio`j' = (cost_`j'U70+cost_`j'7079+cost_`j'O79)/(benefit_`j'U70+benefit_`j'7079+benefit_`j'O79)
			gen net_revenues`j' = benefit_`j'U70+benefit_`j'7079+benefit_`j'O79 - (cost_`j'U70+cost_`j'7079+cost_`j'O79)
		}
		
		*************************************************************
		***Table 7: Cost-Benefit Calculations for Broad Estate Tax***
		*************************************************************

		if "`scenario'" == "baseline"{

			foreach x of num 0 1 {
				if `x' {  //Panel A: States w/ Estate Tax
				#delimit ;
				tabout State using "../Tables/Table7_a.tex" if EInextyear==`x', style(tex) h2(nil) bt replace sum 
				cells(mean avg mean CBratioBase mean net_revenuesBase mean CBratioAlt mean net_revenuesAlt) f(2 2 0c 2 0c)
				oneway h3(& & \multicolumn{2}{c}{\underline{Baseline Elasticity}}& \multicolumn{2}{c}{\underline{Lower Elasticity}}\\ &Personal Income & &EPV Net Revenues& &EPV Net Revenues\\State& Tax Rate&Cost/Benefit&from Adopting (mil)&Cost/Benefit&from Adopting (mil)\\) total(Average);
				#delimit cr
				}
				else{ //Panel B: States w/out Estate Tax
				#delimit ;
				tabout State using "../Tables/Table7_b.tex" if EInextyear==`x', style(tex) h2(nil) bt replace sum 
				cells(mean avg mean CBratioBase mean net_revenuesBase mean CBratioAlt mean net_revenuesAlt) f(2 2 0c 2 0c)
				oneway h3(& & \multicolumn{2}{c}{\underline{Baseline Elasticity}}& \multicolumn{2}{c}{\underline{Lower Elasticity}}\\ &Personal Income & &EPV Net Revenues& &EPV Net Revenues\\State& Tax Rate&Cost/Benefit&from Adopting (mil)&Cost/Benefit&from Adopting (mil)\\) total(Average);
				#delimit cr
				}
			}
		}
		
		**********************************************************************************************
		***Table B7: Cost-Benefit Results Under Alternative Assumptions (Panel B: Broad Estate Tax)***
		**********************************************************************************************

		sum CBratioBase
		matrix R2[10,`col'] = r(mean)
		sum CBratioBase if CBratioBase>=1
		matrix R2[11,`col'] = r(N)
		sum CBratioBase if EInextyear==1
		matrix R2[2,`col'] = r(mean)
		sum CBratioBase if EInextyear==1 & CBratioBase>=1
		matrix R2[3,`col'] = r(N)
		sum CBratioBase if EInextyear==0
		matrix R2[6,`col'] = r(mean)
		sum CBratioBase if EInextyear==0 & CBratioBase>=1
		matrix R2[7,`col'] = r(N)

		outtable using "../Tables/TableB7_b", mat(R2) replace center format(%3.2f)


		drop cost_* benefit_* CBratio* net_revenues*
	
	}  //end scenario loop

} //end runCB IF code

/// 6. TABLE OF LEVELS AND CHANGES BY STATE
if "$runCOUNTS_BY_STATE" == "yes" {

****************************************
***Table 1: Forbes 400 by State, 2017***
****************************************

use ./stata_data/StateyearAnalysisDataset.dta, clear
gen pbwealth = NetWorthMill/stock
keep stock pbwealth EI year State
reshape wide stock pbwealth EI, i(State) j(year)
gen stock_delta82_17 = stock2017 - stock1982
gen stock_delta82_00 = stock2000 - stock1982
gen stock_delta00_17 = stock2017 - stock2000

#delimit ;
tabout State using "../Tables/Table1.tex", style(tex) h2(nil) bt replace sum 
		cells(mean stock2017 mean pbwealth2017 mean stock_delta82_17 mean stock_delta82_00 mean stock_delta00_17) f(0 0 0 0 0) 
		oneway h3( & Forbes Population & Mean Wealth & 1982-2017 Change & 1982-2000 Change & 2000-2017 Change\\State & in 2017& in 2017 (mil) & in Forbes Population & in Forbes Population & in Forbes Population\\) total(Average);
#delimit cr

*************************************************
***Figure 2: Population of Forbes 400 by State***
*************************************************

preserve
import excel using ./raw_data/state_fips_crosswalk.xlsx, clear firstrow
rename abbr state
keep state State
tempfile mapping
save `mapping'
restore
merge 1:1 State using `mapping', nogen keep(1 3)
maptile stock1982, geo(state) geoid(state) ndfcolor(gray) cutvalues(0 2 5 10 30 70)  twopt(legend(lab(2 "0") lab(3 "1-5")))
graph export ../Figures/Figure2_a.pdf, replace as(pdf) //Panel A, 1982
maptile stock2017, geo(state) geoid(state) ndfcolor(gray) cutvalues(0 2 5 10 30 70)  twopt(legend(lab(2 "0") lab(3 "1-5") ))
graph export ../Figures/Figure2_b.pdf, replace as(pdf) //Panel B, 2017

********************************************************************
***Table B4: Forbes 400 by Consolidated Metro Area (Top 40), 2017***
********************************************************************

use ./stata_data/IndivAnalysisDataset.dta, clear
collapse (count) stock=nameid (sum) NetWorthMill, by(CAname year)
gen pbwealth = NetWorthMill/stock
keep stock pbwealth year CAname
reshape wide  stock pbwealth, i(CAname) j(year)
replace stock1982=0 if stock1982==.
gen stock_delta82_17 = stock2017 - stock1982

gen neg_stock2017 = -stock2017
sort neg_stock2017, stable

keep if _n <= 40
replace CAname = subinstr(CAname," Combined Statistical Area","",.)
replace CAname = subinstr(CAname," Metropolitan Statistical Area","",.)
label variable CAname "City Name"
#delimit ;
tabout CAname using "../Tables/TableB4.tex", style(tex) h2(nil) bt replace sum 
		cells(mean stock2017 mean pbwealth2017 mean stock_delta82_17) f(0 0 0) 
		oneway h3( & Forbes Population & Mean Wealth & 1982-2017 Change\\City & in 2017& in 2017 (mil) & in Forbes Population\\) total(Average);
#delimit cr

}
