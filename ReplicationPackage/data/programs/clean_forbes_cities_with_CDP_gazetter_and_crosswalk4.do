/*
RA: Annemarie Schweinert
Economist: Dan Wilson
Date modified: July 24, 2018
Description: Data file takes in the statefips file. We clean the city strings
for most of the OCR mismatches. We take the Census Designated Places Gazetteer
file and merge to the city name along with statefips. We also do some initial
counts on the merges.

*/
clear all
set more off
cap log close
version 14
pause on

cd "$root"

local d = c(current_date)
log using "./log/clean_city_names`d'.log", replace
*cd "C:\Users\Annemarie\Documents\Forbes_400"
*Needed to call fred through firewall
*set httpproxyhost l1proxy.frb.org
*set httpproxyport 8080
*set httpproxy on 

*ssc install egenmore


*Some name cleaning. Needs a loop once I find patterns!
*Dataset set with person, 
use "./data/stata_data/forbes400_DW_EM_long.dta", clear

g Residence2 = Residence
replace Residence2 = "New York" if regexm(Residence2, "37")==1
egen test = noccur(Residence2), string(",")
g city = substr(Residence2, 1, strpos(Residence2, ",")-1) if test>=1
replace city = Residence2 if test<1

g temp_city = city
replace temp_city = strproper(strtrim(subinstr(subinstr(subinstr(subinstr(temp_city,"•", "", .),".", " ", .),"*", " ", .),"  ", " ",  .)))
replace city = strproper(strtrim(subinstr(subinstr(subinstr(subinstr(city,"•", "", .),".", " ", .),"*", " ", .),"  ", " ",  .)))
#delimit
replace temp_city = "New York" if regexm(city, "N.Y")==1 | regexm(city, "NYC")==1 |
 regexm(city, "New York")==1 | regexm(city, "Ny")==1 | regexm(city, "Nyc")==1 |  regexm(city, "N YC,")==1 | regexm(city, "N.YC")==1 |
  regexm(city, "NyC")==1 
  | regexm(city, "NY")==1 
;
replace temp_city = "Atlanta" if regexm(city, "Atlanta")==1;
replace temp_city = "Beverly Hills" if regexm(city, "Beverly Hills")==1 |  regexm(city, "Beverlyhills")==1;
replace temp_city = "Bloomfield Hills" if regexm(city, "Bloomfield")==1;
replace temp_city = "Southern California" if regexm(city, "Southern Calif")==1;
replace temp_city = "Chicago" if regexm(city, "Chicago")==1;
replace temp_city = "Los Angeles" if regexm(city, "Los Angeles")==1 | regexm(city, "L A")==1;
replace temp_city = "Wayzata" if regexm(city, "Wayzara")==1;
replace temp_city = "Wayzata" if regexm(city, "Wayzara")==1;
replace temp_city = "Westchester" if regexm(city, "Westchester")==1;
replace temp_city = "Washington" if regexm(city, "Washington")==1;
replace temp_city = "Wynnewood" if regexm(city, "Wynewood")==1  ;
replace temp_city = "St Mary's" if regexm(city, "St Mary'S Point")==1 | regexm(city, "St Mary's Point")==1 | 
regexm(city, "St Marys Point")==1 | regexm(city, "St Mary’s Point")==1 ; 
replace temp_city = "St Paul" if regexm(city, "St. Paul")==1 | regexm(city, "St Paul")==1 ; 
compress;
replace temp_city = "St Louis" if regexm(city, "St.Louis")==1 | regexm(city, "St Louis")==1 | 
regexm(city, "St Louis")==1  ; 
replace temp_city  = "Strafford" if regexm(city, "Stratford")==1;
replace temp_city = "Seattle" if regexm(city, "Seattle")==1 ; 
replace temp_city = "Santa Clara" if regexm(city, "Santa Clara")==1 ; 
replace temp_city = "Santa Ana" if regexm(city, "Santa Ana")==1 ; 
replace temp_city = "Sioux Falls" if regexm(city, "Sious Falls")==1 ; 
replace temp_city = "San Antonio" if regexm(city, "San Antonio")==1 | regexm(city, "San Anotonio")==1 ; 
replace temp_city = "San Francisco" if regexm(city, "San Francisco")==1 | regexm(city, "Sf")==1 | regexm(city, "San Fancisco")==1   ; 
replace temp_city = "Sacramento" if regexm(city, "Sacramento")==1 ; 
replace temp_city = "Rancho Santa Fe" if regexm(city, "Rachosanta")==1 ; 
replace temp_city = "Racine" if regexm(city, "Racine")==1 | regexm(city, "Rachine")==1 ; 
replace temp_city = "Puerto Rico" if regexm(city, "Puerto Rico")==1  ; 
replace temp_city = "Prairie Village" if regexm(city, "Prairie Village")==1 | regexm(city, "Prarie Village")==1   ;
replace temp_city = "Pittsburgh" if regexm(city, "Pittsburgh")==1   ;
replace temp_city = "Philadelphia" if regexm(city, "Philadelphia")==1 | regexm(city, "Phila. Area")==1   ;
replace temp_city = "Palm Beach" if regexm(city, "Palm Beach")==1   ;
replace temp_city = "Palo Alto" if regexm(city, "Palo Al To")==1   ;
replace temp_city = "Pacific Palisades" if regexm(city, "Palisades")==1   ;
replace temp_city = "Boston" if regexm(city, "Boston")==1   ;
replace temp_city = "Corning" if regexm(city, "Corning")==1   ;
replace temp_city = "Minneapolis" if regexm(city, "Minneapoli")==1   ;
replace temp_city = "Miami" if regexm(city, "Miami")==1  ; 
replace temp_city = "Miami Beach" if regexm(city, "Miami Beach")==1 | regexm(city, "Miamibeach")==1 ; 
replace temp_city = "Memphis" if regexm(city, "Memphis")==1  ; 
replace temp_city = "Lutherville" if regexm(city, "Lutherville")==1  ; 
replace temp_city = "Cincinnati" if regexm(city, "Cincinnati")==1 | regexm(city, "Cincinnati")==1 ; 
replace temp_city = "Bedminster" if regexm(city, "Bedmisnter")==1  ; 
replace temp_city = "Artesia" if regexm(city, "Arteisa")==1  ; 


replace temp_city = "Orange County" if regexm(city, "Orange County")==1 | regexm(city, "Orange Co")==1;
replace temp_city = "Oklahoma City" if regexm(city, "Oklahoma City")==1;
replace temp_city = "West Hollywood" if regexm(city, "West Hollywood")==1;
replace temp_city = "Malibu" if regexm(city, "Mailibu")==1;
replace temp_city = "Newtown Square" if regexm(city, "Newtown Square")==1 | regexm(city, "Newton Square")==1;
replace temp_city = "Newton Centre" if regexm(city, "Newton Centre")==1 | regexm(city, "Newton Center")==1;
replace temp_city = "Hopkinton" if regexm(city, "Hopkington")==1  ; 
replace temp_city = "Mount Kisco" if regexm(city, "Mt Kisco")==1  ;
replace temp_city = "Harrison" if regexm(city, "Harrison")==1  ; 
replace temp_city = "Southampton" if regexm(city, "Southampton")==1  ; 
replace temp_city = "Scarsdale" if regexm(city, "Scarsdale")==1  ; 
replace temp_city = "Rye" if regexm(city, "Rye")==1  ; 
replace temp_city = "Greenwich" if regexm(city, "Greenwich")==1  ; 
replace temp_city = "Long Island" if regexm(city, "Long Island")==1  ; 
replace temp_city = "Upper Brookville" if regexm(city, "Upper Brookville")==1  ;
replace temp_city = "Boca Raton" if regexm(city, "Boca Raton")==1  ;

replace temp_city = "Upper Brookville" if regexm(city, "Upper Brookville")==1  ;
replace temp_city = "Deal" if regexm(city, "Deal")==1  ;
replace temp_city = "Nashua" if regexm(city, "Nashuah")==1  ;
replace temp_city = "Nanjin" if regexm(city, "Nanjing")==1  ;
replace temp_city = "Montchanin" if regexm(city, "Montchamin")==1 | regexm(city, "Montchanin")==1 ;
replace statefips2 = . if Name == "Irenee Du Pont" & statefips2 == 30;
replace temp_city = "Livingston" if regexm(city, "Livingston")==1  ;
replace temp_city = "Louisville" if regexm(city, "Louisville")==1  ;
replace temp_city = "Las Vegas" if regexm(city, "Las Vegas")==1 |  regexm(city, "Lasvegas")==1;
replace temp_city = "Lake Forest" if regexm(city, "Lake Forest")==1 |  regexm(city, "Lake Forrest")==1;

replace temp_city = "Dallas" if regexm(city, "Dllas")==1  | 
regexm(city, "Dallas")==1 & regexm(city, "Lake")!=1;

replace temp_city = "Kansas City" if regexm(city, "Kansas City")==1  | 
regexm(city, "Kansascity")==1 | regexm(city, "Kan City")==1;

replace temp_city = "Indianapolis" if regexm(city, "Indianapolis")==1 ;
replace temp_city = "Irvine" if regexm(city, "rvine")==1 ;
replace temp_city = "Houston" if regexm(city, "Houston")==1 ;
replace temp_city = "Honolulu" if regexm(city, "Honolulu")==1 ;
replace temp_city = "Baltimore" if regexm(city, "Baltimore")==1 ;
replace temp_city = "Holmby Hills" if regexm(city, "Hombly Hills")==1 ;
replace temp_city = "Paso Robles" if regexm(city, "Paso Robles")==1 ;
replace temp_city = "Fort Worth" if regexm(city, "Fort Worth")==1 |regexm(city, "Forth Worth")==1 |
regexm(city, "Ft Worth")==1 | (regexm(city, "Ft")==1 & regexm(city, "Worth")==1) ;


replace temp_city = "Fort Collins" if regexm(city, "Fort Collins")==1 |
regexm(city, "Ft Collins")==1 | (regexm(city, "Ft")==1 & regexm(city, "Collins")==1) ;
replace city = "Corpus Christi" if 
  regexm(city, "Corpus Christi")==1;

/*
replace temp_city = "Grosse Pointe Farms" if regexm(city, "Gross Pointe Farms")==1 |
regexm(city, "Gross Point Farms")==1 | regexm(city, "Gro Sse Pointe Farms") | regexm(city, "Grosse Point Farms")==1  |
regexm(city, "Gross Point Farms")==1  ;  
compress;
replace temp_city = "Grosse Pointe" if regexm(city, "Grosse Point Shores")==1 |
regexm(city, "Gro Sse Pointe Shores")==1 | regexm(city, "Grosse Point Shores") | regexm(city, "Grosse Pointe Shore")==1  | regexm(city, "Grosse Pte Shores")==1 
| regexm(city, "Gross Point Shores")==1 | regexm(city, "Gross Pointe Shores")  ;  
*/
replace temp_city = "Grosse Pointe" if strmatch(temp_city,"*Gross* Point*");

replace temp_city = "Greenwood Village" if   regexm(city, "Greenwood")==1;
replace temp_city = "Grand Rapids" if   regexm(city, "Grand Rapids")==1;
replace temp_city = "Fort Lauderdale" if regexm(city, "Fort Lauderdale")==1 |
regexm(city, "Ft Lauderdale")==1 | (regexm(city, "Ft")==1 & regexm(city, "Lauderdale")==1) ;  
replace temp_city = "Fort Smith" if regexm(city, "Fort Smith")==1 |
regexm(city, "Ft Smith")==1 | (regexm(city, "Ft")==1 & regexm(city, "Smith")==1) ;  
 
replace temp_city = "Fort Mill" if regexm(city, "Fort Mill")==1 |
regexm(city, "Ft Mill")==1 | (regexm(city, "Ft")==1 & regexm(city, "Mill")==1) ; 

replace temp_city = "Fort Pierce" if regexm(city, "Fort Pierce")==1 |
regexm(city, "Ft Pierce")==1 | (regexm(city, "Ft")==1 & regexm(city, "Pierce")==1) ;    
  
replace temp_city = "Englewood" if   regexm(city, "Englewood")==1;
  
replace temp_city  = "Detroit" if   regexm(city, "Detroit")==1;
replace temp_city  = "Denver" if   regexm(city, "Denver")==1;
  
replace temp_city  = "Cleveland" if regexm(city, "Cleveland")==1;
    
replace temp_city  = "Columbus" if regexm(city, "Columbus")==1;
replace temp_city  = "Eightyfour" if regexm(city, "Eighty-Four")==1;
replace temp_city  = "Buffalo" if regexm(city, "Buffalo")==1;
replace temp_city  = "Bentonville" if   regexm(city, "Bentonville")==1;
replace temp_city  = "Chestnut Hill" if   regexm(city, "Chestnut Hill")==1;
replace temp_city = "Devils Tower" if regexm(city, "Devils Tower")==1 |
regexm(city, "Devil'S Tower")==1 | regexm(city, "Devil'S Tower") | regexm(city, "Devil’S Tower")==1   ;  

replace temp_city = "Charlotte" if (regexm(Residence, "Charlotte")==1 & regexm(Residence, "Charlottesville")!=1 );

replace temp_city = "Nashville-Davidson" if regexm(Residence, "Nashville")==1 & (statefips1==47 | statefips2==47 | statefips3==47) ;



*Recodes based on initial merge. These are unincorporated places in the Forbes 400 data.
;
*CHANGED BASED ON GOOGLE SEARCH. LA JOLLA IS A PART OF SAN DIEGO
;
replace temp_city = "San Diego" if regexm(city, "La Jolla")==1 |  regexm(city, "Lajolla")==1;
*Upperville, VA is unincorporated
;
replace temp_city = "Fauquier" if regexm(city, "Upperville")==1;
replace temp_city = "Washington" if (regexm(city, "Washington")==1 & statefips1==11 );

*Places w/o a specific city/county/MSA
;
replace temp_city = "" if regexm(city, "Australia")==1 | regexm(city, "Bahamas")==1| 
(regexm(city, "D")==1 & strlen(city)<2) | regexm(city, "Zug")==1 | regexm(city, "X")==1 |
regexm(city, "Virginia; S C")==1 | regexm(city, "Virginia; California")==1  | 
regexm(city, "Versailles")==1 | (regexm(city, "Va")==1& strlen(city)<3) |
regexm(city, "Us Virgin Islands")==1 | regexm(city, "Texas")==1 |
regexm(city, "Switzerland")==1 | regexm(city, "Sr")==1 | regexm(city, "Unknown")==1 |
regexm(city, "Southern California")==1 | regexm(city, "Scattered")==1 | 
(regexm(city, "San Juan")==1 & regexm(city, "San Juan Capistrano")!=1 & regexm(city, "San Juan Islands")!=1) | 
regexm(city, "Residence Unknown")==1 | regexm(city, "Origin: Fla")==1 | 
regexm(city, "Orig Florida")==1 | regexm(city, "North Carolina; Conn")==1 | 
regexm(city, "New Jersey")==1 | regexm(city, "Nanjin")==1 | 
(regexm(city, "Na")==1 & strlen(city)<3)
| regexm(city, "N/A")==1 | regexm(city, "N Carolina")==1 | regexm(city, "Meggen")==1 | 
regexm(city, "Meggan")==1 | regexm(city, "Meggan")==1 | regexm(city, "Meggan")==1 | statefips1==100
| regexm(city, "Conn")==1 | regexm(city, "Delaware")==1 | regexm(city, "Europe")==1 |
regexm(city, "Florida")==1 | regexm(city, "Delaware")==1 | regexm(city, "Illinois")==1 |
regexm(city, "Nebraska")==1 | (regexm(city, "Idaho")==1 & regexm(city, "Falls")!=1) |
regexm(city, "Hawaii")==1 | regexm(city, "London")==1 | regexm(city, "Penn")==1 |
regexm(city, "Southeast")==1 | regexm(city, "Calif")==1 | regexm(city, "-")==1 |
regexm(city, "Wyoming")==1 | regexm(city, "Calif")==1 | regexm(city, "-")==1 
;
*Adjust for Winrock Farms for Rockefellers
;
replace temp_city = "Conway County" if regexm(city, "Winrock Farm")==1;

/*
*Fix name from Cherry Hill to Cherry Hills
;
replace temp_city = "Cherry Hills Village" if regexm(city, "Cherry Hill")==1 & statefips1==8 ;
*Fix Indian Hills Colorado. It is a designated place in Jefferson County
;
replace temp_city = "Jefferson County" if (regexm(city, "Indian Hills")==1 & statefips1==8 );

*Fix Rancho Santa Fe CA. It is a neighborhood in San Diego
;
replace temp_city = "San Diego" if regexm(city, "Rancho Santa Fe")==1 & statefips1==6 ;
replace temp_city = "San Diego" if regexm(city, "Racho Santa Fe")==1 & statefips1==6 ;


*Fix Pacific Palisads CA. It is a neighborhood in LA
;
replace temp_city = "Los Angeles" if regexm(city, "Pacific Palisads")==1 & statefips1==6 ;
replace temp_city = "Los Angeles" if regexm(city, "Hollywood")==1 & statefips1==6 ;
replace temp_city = "Napa" if regexm(city, "Napa Valley")==1 & statefips1==6 ;
*/;
*Fix Bel Air CA. It is a neighborhood in LA
;
replace temp_city = "Los Angeles" if regexm(city, "Bel Air")==1 & statefips1==6 ;

/*Excel file fixes from locality_misses*/;
replace temp_city = "Bal Harbour" if regexm(city, "Bal Harbor")==1;
replace temp_city = "Miami" if regexm(city, "Coconut Grove")==1;
replace temp_city = "Carpinteria" if regexm(city, "Carpentiria")==1;
replace temp_city = "Los Angeles" if regexm(city, "Chatsworth")==1;
replace temp_city = "Cherry Hills" if regexm(city, "Cherry Hill")==1;
replace temp_city = "Cohassett" if regexm(city, "Cohasset")==1;
replace temp_city = "Corning" if regexm(city, "Coming")==1;
replace temp_city = "Newport Beach" if regexm(city, "Corona Del Mar")==1;
replace temp_city = "Crown Point" if regexm(city, "Crew Point")==1;
replace temp_city = "Daytona Beach" if regexm(city, "Daytona")==1;
replace temp_city = "Los Angeles" if regexm(city, "Encino")==1;
replace temp_city = "Fort Lauderdale" if regexm(city, "For Lauderdale")==1;
replace temp_city = "Fort Lauderdale" if regexm(city, "Ft. Lauderdale")==1;
replace temp_city = "Fort Lauderdale" if Name == "Horvitz" & statefips1 == 12;
replace temp_city = "Cleveland" if Name == "Horvitz" & statefips1 == 39;
replace temp_city = "Roseburg" if regexm(city, "Roseberg")==1;
replace temp_city = "San Marino" if regexm(city, "San Manno")==1;
replace temp_city = "Redwood" if regexm(city, "Silicon Valley")==1;
replace temp_city = "Los Angeles" if regexm(city, "Venice")==1;
// Added in an attempt to get missing people from 2001 and 2011 to show up
replace temp_city = "Philadelphia" if regexm(city, "Wynewood") == 1;
replace temp_city = "San Mateo" if regexm(city, "Hillsborough") == 1;
replace temp_city = "Los Angeles" if regexm(city, "Pacific Palisades") == 1 & statefips1 == 6;
replace temp_city = "Los Angeles" if regexm(city, "Palisades") == 1 & statefips1 == 6;
replace temp_city = "Reno" if regexm(city, "Lake Tahoe") == 1;
replace temp_city = "Sands Point" if regexm(city, "Long Island") == 1;
replace temp_city = "Grosse Point" if regexm(city, "Grosse Pointe Shores") == 1;
replace temp_city = "Singapore" if regexm(Residence, "Singapore, N/A") == 1;
replace temp_city = "Rancho Santa Fe" if regexm(Residence, "Racho Santa Fe") == 1 & statefips2 == 6;
replace statefips2 = . if Name == "Gwendolyn Sontheim Meyer";
replace statefips3 = . if regexm(Residence, "California, Nyc Area, Et Al.") == 1 & Name == "William Randpolph Hearst Jr";
g missing_vals = (temp_city=="");
compress;
#delimit cr;

// Generating multi city variables
save "./data/stata_data/temp_city_1_generated.dta", replace

// Drop all observations that do not have a second state code
keep if statefips2 != .  

// Generate tempcity variables
// All of the states are backwards from the city order, so if Cleveland comes first, its state is being read as Florida

generate temp_city_2 = temp_city if statefips3 == . 

// Fixing temp_city variable where reverse state is not the case
replace temp_city_2 = "New York City" if regexm(Residence, "California, Nyc Area, Et Al.") == 1 & Name == "William Randolph Hearst Jr"
replace temp_city_2 = "Purchase" if regexm(Residence, "Purchase") == 1 & statefips2 == 36
replace temp_city_2 = "New York City" if regexm(Residence, "New York City") & statefips2 == 36
replace temp_city_2 = "New York City" if regexm(Residence, "NYC") & statefips2 == 36
replace temp_city_2 = "Newport" if regexm(Residence, "Newport") & statefips2 == 44
replace temp_city_2 = "Houston" if regexm(Residence, "Houston") == 1 & statefips2 == 48
replace temp_city_2 = "Puerto Rico" if regexm(Residence, "Puerto Rico") == 1 & statefips2 == 100
replace temp_city_2 = "Cheyenne" if regexm(Residence, "Cheyenne") == 1 & statefips2 == 56
replace temp_city_2 = "Las Vegas" if regexm(Residence, "Las Vegas") == 1 & statefips2 == 32
replace temp_city_2 = "Middleburg" if regexm(Residence, "Middleburg") == 1 & statefips2 == 51
replace temp_city_2 = "London" if regexm(Residence, "London") == 1 & statefips2 == 100
replace temp_city_2 = "East Hampton" if regexm(Residence, "East Hampton") == 1 & statefips2 == 36
replace temp_city_2 = "Jacksonville" if regexm(Residence, "Jacksonville") == 1 & statefips2 == 12
replace temp_city_2 = "Tacoma" if regexm(Residence, "Tacoma") == 1 & statefips2 == 53
replace temp_city_2 = "Monaco" if regexm(Residence, "Monaco") == 1 & statefips2 == 100
replace temp_city_2 = "Kansas City" if regexm(Residence, "Mission Hills, Mo.") == 1 & statefips2 == 29
replace temp_city_2 = "New Orleans" if regexm(Residence, "New Orleans") == 1 & statefips2 == 22
replace temp_city_2 = "Warrenton" if regexm(Residence, "Upperville") == 1 & statefips2 == 51
replace temp_city_2 = "Orlando" if regexm(Residence, "Orlando") == 1 & statefips2 == 12 
replace temp_city_2 = "Detroit" if regexm(Residence, "Detroit, New York City, Palm Beach") == 1 
replace temp_city_2 = "Oklahoma City" if regexm(Residence, "Oklahoma City") == 1 & statefips2 == 40
replace temp_city_2 = "New York City" if regexm(Residence, "New York") == 1 & statefips2 == 36 & Name == "Jeanette Annenberg Hooker"
replace temp_city_2 = "New York City" if regexm(Residence, "New York") == 1 & statefips2 == 36 & Name == "Lita Annenberg Hazen"
replace temp_city_2 = "New York City" if regexm(Residence, "New York") == 1 & statefips2 == 36 & Name == "Donald Leroy Bren"
replace temp_city_2 = "Washington" if regexm(Residence, "Washington, D.C.") == 1 & Name == "Joe Lewis Allbritton"
replace temp_city_2 = "New York City" if regexm(Residence, "New York") == 1 & statefips2 == 36 & Name == "Leon Hess"
replace temp_city_2 = "Duluth" if regexm(Residence, "Duluth") == 1 & statefips2 == 27
replace temp_city_2 = "New York City" if regexm(Residence, "New York") == 1 & statefips2 == 36 & Name == "Jack Parker"
replace temp_city_2 = "Somerville" if regexm(Residence, "Somerville, N.J., Newport, R.I., Honolulu") == 1
replace temp_city_2 = "New York City" if regexm(Residence, "New York") == 1 & statefips2 == 36 & Name == "Leonard Davis"
replace temp_city_2 = "" if regexm(Residence, "Palm Beach, Fla. and New York") == 1 & Name == "Robert Olnick"
replace temp_city_2 = "Gasparilla Island" if regexm(Residence, "Gasparilla Island") == 1 
replace temp_city_2 = "New York City" if regexm(Residence, "New York") == 1 & statefips2 == 36 & Name == "Mary Jane Du Pont Lunger"
replace temp_city_2 = "Boston" if regexm(Residence, "New York, Boston and Washington, D.C.") == 1
replace temp_city_2 = "Highlands" if regexm(Residence, "Highlands") == 1 & statefips2 == 37
replace temp_city_2 = "" if regexm(Residence, "New York") == 1 & statefips2 == 36 & Name == "Sherman Cohen"
replace temp_city_2 = "" if regexm(Residence, "Washington, D.C., and Idaho") == 1 & Name == "Catherine Mellon Conover"
replace temp_city_2 = "New York City" if regexm(Residence, "New York") == 1 & Name == "Armand Hammer"
replace temp_city_2 = "New York City" if regexm(Residence, "Nyc") == 1 & Name == "Donald Leroy Bren" & statefips2 == 36
replace temp_city_2 = "New York City" if regexm(Residence, "Nyc") == 1 & statefips2 == 36
replace temp_city_2 = "New York City" if regexm(Residence, "New York") == 1 & statefips2 == 36 & Name == "Sherman Cohen"
replace temp_city_2 = "Minneapolis" if regexm(Residence, "Minneapolis") == 1 & statefips2 == 27 
replace temp_city_2 = "New York City" if regexm(Residence, "Nyc") == 1 & Name == "Max Martin Fisher"
replace temp_city_2 = "Detroit" if regexm(Residence, "Detroit") == 1 & statefips2 == 26
replace temp_city_2 = "" if regexm(Residence, "Centreville, Del.; Fla.") == 1 & statefips2 == 12
replace temp_city_2 = "Baltimore" if regexm(Residence, "Baltimore") == 1 & statefips2 == 24
replace temp_city_2 = "Seattle" if regexm(Residence, "Seattle") == 1 & statefips2 == 53
replace temp_city_2 = "Boston" if regexm(Residence, "Nyc, Boston, Wash., D.C.") == 1
replace temp_city_2 = "Houston" if regexm(Residence, "Houston; Washington, D.C.") == 1
replace temp_city_2 = "Cleveland" if regexm(Residence, "Cleveland Area") == 1
replace temp_city_2 = "Chicago" if regexm(Residence, "Chicago") == 1
replace temp_city_2 = "Mclean" if regexm(Residence, "Mclean") == 1
replace temp_city_2 = "Philadelphia" if regexm(Residence, "Phila. Area; Nyc; Et Al.") == 1
replace temp_city_2 = "" if regexm(Residence, "Centreville, Del.; Florida") == 1
replace temp_city_2 = "" if regexm(Residence, "St. Paul; Wash. State") == 1
replace temp_city_2 = "" if regexm(Residence, "Denver; Fla") == 1
replace temp_city_2 = "" if regexm(Residence, "Middleburg, Va., Calif.") == 1
replace temp_city_2 = "" if regexm(Residence, "Washington, District Of Columbia") == 1 & Name == "Steven M Rales"
replace temp_city_2 = "" if regexm(Residence, "N/A") == 1
replace temp_city_2 = "Rancho Santa Fe" if regexm(Residence, "Racho Santa Fe") == 1 & statefips2 == 35
replace temp_city_2 = "" if regexm(Residence, "Newport Beach, Florida") == 1
replace temp_city_2 = "Cleveland" if Name == "Horvitz" & statefips2 == 39
replace temp_city_2 = "Buffalo" if regexm(Residence, "Palm Beach, Florida; Buffalo, New York.") == 1
replace statefips2 = 36 if regexm(Residence, "Palm Beach, Florida; Buffalo, New York.") == 1

// Fixing temp_city_2 and state
replace temp_city_2 = "Lyford Cay" if regexm(Residence, "Lyford Cay") == 1
replace statefips2 = 100 if temp_city_2 == "Lyford Cay"

replace temp_city_2 = "" if regexm(Residence, "Westchester Cty., N.Y") == 1
replace statefips2 = . if regexm(Residence, "Westchester Cty., N.Y") == 1

replace temp_city_2 = "" if regexm(Residence, "Vero Beach, California") == 1
replace statefips2 = 6 if regexm(Residence, "Vero Beach, California") == 1

replace temp_city_2 = "" if regexm(Residence, "Portland, Me.; Florida") == 1
replace statefips2 = 12 if regexm(Residence, "Portland, Me.; Flordia") == 1

replace temp_city_2 = "" if regexm(Residence, "Charlottesville, Va., and New York") == 1
replace statefips2 = 36 if regexm(Residence, "Charlottesville, Va., and New York") == 1
// Generating temp_city_3 variable 
generate temp_city_3 = temp_city if statefips3 != . & statefips3 != 100

// Fixing temp_city_3
replace temp_city_3 = "Newport Beach" if regexm(Residence, "Newport Beach and Los Angeles, Calif., and New York") == 1 
replace temp_city_3 = "Newport" if regexm(Residence, "Newport") == 1
replace temp_city_3 = "New York City" if regexm(Residence, "New York") == 1 & statefips2 == 36 & Name == "Mortimer Benjamin Zuckerman"
replace temp_city_3 = "New York City" if regexm(Residence, "Nyc") == 1 & statefips2 == 36 & Name == "Mortimer Benjamin Zuckerman"
replace temp_city_3 = "Moscow" if regexm(Residence, "Moscow") == 1 & statefips3 == 100
replace temp_city_3 = "Los Angeles" if regexm(Residence, "Newport Beach, L.A., Nyc") == 1 
replace temp_city_3 = "Paris" if regexm(Residence, "London, Paris, Connecticut") == 1
replace temp_city_3 = "Moscow" if regexm(Residence, "L.A.; Nyc; Moscow") == 1
replace temp_city_3 = "Moscow" if regexm(Residence, "L.A., Nyc, Moscow") == 1
replace temp_city_3 = "" if regexm(Residence, "Newport Beach, Florida") == 1

// Fixing temp_city_3 variable where third residence is abroad
replace temp_city_3 = "London" if regexm(Residence, "London") & statefips3 == 100

// Replace temp_city with second residence. Doing this manually which isn't the most efficient.
replace temp_city = "Palm Beach" if regexm(Residence, "Palm Beach") == 1 & statefips1 == 6
replace temp_city = "Los Angeles" if regexm(Residence, "Los Angeles") == 1 & statefips1 == 6
replace temp_city = "Greenwich" if regexm(Residence, "Greenwich") == 1 & statefips1 == 9
replace temp_city = "Palm Beach" if regexm(Residence, "Palm Beach") == 1 & statefips1 == 12
replace temp_city = "Rancho Mirage" if regexm(Residence, "Rancho Mirage") == 1 & statefips1 == 6
replace temp_city = "New York City" if regexm(Residence, "NYC") == 1 & statefips1 == 36
replace temp_city = "Washington" if regexm(Residence, "Washington, D.C.") == 1 & statefips1 == 11
replace temp_city = "Fort Lauderdale" if regexm(Residence, "Fort Lauderdale") == 1 & statefips1 == 12
replace temp_city = "Santa Barbara" if regexm(Residence, "Santa Barbara") == 1 & statefips1 == 6
replace temp_city = "Wilmington" if regexm(Residence, "Wilmington") == 1 & statefips1 == 10
replace temp_city = "Montecito" if regexm(Residence, "Montecito") == 1 & statefips1 == 6
replace temp_city = "Palm Springs" if regexm(Residence, "Palm Springs") == 1 & statefips1 == 6
replace temp_city = "Santa Fe" if regexm(Residence, "Santa Fe") == 1 & statefips1 == 35
replace temp_city = "Pittsburgh" if regexm(Residence, "Pittsburgh") == 1 & statefips1 == 42
replace temp_city = "St. Paul" if regexm(Residence, "St. Paul") == 1 & statefips1 == 27
replace temp_city = "Beverly Hills" if regexm(Residence, "Beverly Hills") == 1 & statefips1 == 6
replace temp_city = "San Diego" if regexm(Residence, "RanchoSanta Fe") == 1 & statefips1 == 6
replace temp_city = "Bridgewater" if regexm(Residence, "Bridgewater") == 1 & statefips1 == 9
replace temp_city = "Westport" if regexm(Residence, "Westport") == 1 & statefips1 == 9
replace temp_city = "Honolulu" if regexm(Residence, "Honolulu") == 1 & statefips1 == 15
replace temp_city = "New York City" if regexm(Residence, "New York City") == 1 & statefips1 == 36
replace temp_city = "Cohasset" if regexm(Residence, "Cohasset") == 1 & statefips1 == 12
replace temp_city = "Sanford" if regexm(Residence, "Sanford") == 1 & statefips1 == 12
replace temp_city = "Boca Raton" if regexm(Residence, "Boca Raton") == 1 & statefips1 == 12
replace temp_city = "Nantucket" if regexm(Residence, "Nantucket") == 1 & statefips1 == 25
replace temp_city = "" if regexm(Residence, "Charlottesville, Va., and New York") == 1 & statefips1 == 36
replace temp_city = "Sarasota" if regexm(Residence, "Sarasota") == 1 & statefips1 == 12
replace temp_city = "San Diego" if regexm(Residence, "La Jolla") == 1 & statefips1 == 6
replace temp_city = "Scottsdale" if regexm(Residence, "Scottsdale") == 1 & statefips1 == 4
replace temp_city = "Emerald Bay" if regexm(Residence, "Emerald Bay") == 1 & statefips1 == 6
replace temp_city = "Manalapan" if regexm(Residence, "Manalapan") == 1 & statefips1 == 12
replace temp_city = "Washington" if regexm(Residence, "Wash., D.C.") == 1 & statefips1 == 11
replace temp_city = "Miami Beach" if regexm(Residence, "Miami Beach") == 1 & statefips1 == 12
replace temp_city = "Versailles" if regexm(Residence, "Versailles") == 1 & statefips1 == 21
replace temp_city = "Hollywood" if regexm(Residence, "Hollywood") == 1 & statefips1 == 12
replace temp_city = "Atlanta" if regexm(Residence, "Atlanta") == 1 & statefips1 == 13
replace temp_city = "New York City" if regexm(Residence, "Nyc Area") == 1 & statefips1 == 36
replace temp_city = "Hobe Sound" if regexm(Residence, "Hobe Sound") == 1 & statefips1 == 12
replace temp_city = "New York City" if regexm(Residence, "Nyc") == 1 & statefips1 == 36
replace temp_city = "Bal Harbour" if regexm(Residence, "Bal Harbour") == 1 & statefips1 == 12
replace temp_city = "" if regexm(Residence, "Columbus, Ohio; Calif.") == 1 & statefips1 == 6
replace temp_city = "Des Moines" if regexm(Residence, "Des Moines") == 1 & statefips1 == 19
replace temp_city = "" if regexm(Residence, "Portland, Me.; Florida") == 1
replace temp_city = "Colorado Springs" if regexm(Residence, "Colorado Spgs.") == 1 & statefips1 == 8
replace temp_city = "" if regexm(Residence, "Racho Santa Fe, California") == 1 & statefips1 == 6
replace temp_city = "" if regexm(Residence, "Vero Beach, California") == 1 & statefips1 == 6

// Fixing temp_city and state 
replace temp_city = "Sundance" if regexm(Residence, "Devil's Tower") == 1
replace statefips1 = 56 if temp_city == "Devil's Tower"

replace statefips1 = 36 if regexm(Residence, "Westchester Cty., N.Y") == 1
replace temp_city = "White Plains" if regexm(Residence, "Westchester Cty.") == 1 & statefips1 == 36

replace temp_city_2 = "" if regexm(Residence, "Columbus, Ohio; Calif.") == 1
replace statefips2 = 6 if regexm(Residence, "Columbus, Ohio; Calif.") == 1
// Replacing Puerto Rico with correct Statefips code
replace statefips1 = 72 if regexm(temp_city, "Puerto Rico") == 1 & statefips1 == 100
replace statefips2 = 72 if regexm(temp_city_2, "Puerto Rico") == 1 & statefips2 == 100
replace statefips3 = 72 if regexm(temp_city_3, "Puerto Rico") == 1 & statefips3 == 100


// Fixing misc. errors
replace temp_city_2 = "" if temp_city == "Hunterdon Cty" 
replace statefips1 = 34 if temp_city == "Hunterdon Cty"
replace statefips2 = . if temp_city_2 == ""
replace temp_city = "Flemington" if temp_city == "Hunterdon Cty"
replace temp_city_3 = "Australia" if regexm(Residence, "Australia, London, New York City") == 1
replace statefips3 = 100 if temp_city_3 == "Australia" 
replace temp_city_3 = "New York City" if regexm(Residence, "New York City") == 1 & statefips3 == 36
replace statefips3 = 6 if temp_city_3 == "Newport Beach"
// Fixing statefips2 
replace statefips2 = 32 if regexm(Residence, "Nev.") == 1
replace statefips2 = 32 if regexm(Residence, "Nevada") == 1
replace statefips2 = 51 if regexm(Residence, "VA.") == 1
replace statefips2 = 39 if regexm(Residence, "Delaware, Ohio") == 1
replace statefips2 = 26 if temp_city_2 == "Detroit"
replace statefips2 = 11 if temp_city_2 == "Washington"
replace statefips2 = 34 if temp_city_2 == "Somerville"
replace statefips2 = 25 if temp_city_2 == "Boston"
replace statefips2 = 16 if regexm(Residence, "Washington, D.C., and Idaho") == 1 & Name == "Catherine Mellon Conover"
replace statefips2 = 36 if regexm(Residence, "New York and Greenwich, Conn.") == 1 & Name == "Sherman Cohen"
replace statefips2 = 36 if regexm(Residence, "Los Angeles, New York and Moscow") == 1 & Name == "Armand Hammer"
replace statefips3 = 6 if temp_city_3 == "Los Angeles"
replace statefips2 = 36 if temp_city_2 == "New York City"
replace statefips3 = 100 if temp_city_3 == "Paris"
replace statefips2 = 37 if regexm(Residence, "N. Carolina, Conn., Et Al.") == 1 & Name == "Richardson"
replace statefips2 = 12 if regexm(Residence, "Centreville, Del.; Fla.") == 1
replace statefips1 = 6 if regexm(Residence, "Columbus, Ohio; Calif.") == 1 
replace statefips2 = 48 if temp_city_2 == "Houston"
replace statefips2 = 6 if temp_city_2 == "Los Angeles"
replace statefips3 = 100 if temp_city_3 == "Moscow"
replace statefips2 = 39 if temp_city_2 == "Cleveland"
replace statefips2 = 100 if regexm(Residence, "Europe; Conn.") == 1
replace statefips2 = 37 if regexm(Residence, "North Carolina; Conn.") == 1
replace statefips2 = 31 if regexm(Residence, "Illinois; Nebraska") == 1
replace statefips2 = 12 if regexm(Residence, "Centreville, Del.; Florida") == 1
replace statefips2 = 51 if regexm(Residence, "Virginia; California") == 1
replace statefips2 = 53 if regexm(Residence, "St. Paul; Wash. State") == 1
replace statefips2 = 35 if regexm(Residence, "Calif; Nm") == 1
replace statefips2 = 39 if regexm(Residence, "Delaware; Ohio") == 1
replace statefips2 = 12 if regexm(Residence, "Denver; Fla") == 1
replace statefips2 = 51 if regexm(Residence, "Virginia; S.C.") == 1
replace statefips2 = 100 if regexm(Residence, "Europe & Connecticut") == 1
replace statefips2 = 12 if regexm(Residence, "Delaware; Florida") == 1
replace statefips1 = 51 if temp_city == "Middleburg"
replace statefips2 = 6 if regexm(Residence, "Middleburg, Va., Calif.") == 1
replace statefips1 = 6 if regexm(Residence, "Racho Santa Fe, California") == 1
replace statefips2 = 12 if regexm(Residence, "Newport Beach, Florida") == 1
replace statefips1 = 6 if regexm(Residence, "Vero Beach, California") == 1 
save "./data/stata_data/multi_city_generated.dta", replace

use "./data/stata_data/temp_city_1_generated.dta", clear
merge 1:1 Name A year SUFFIX Suffix suffix family NetWorth using "./data/stata_data/multi_city_generated.dta", keep(master match) update replace 

g Entity = 0
replace Entity = 1 if regexm(city, "Reservation")==1
replace Entity = 2 if regexm(city, "County")==1
replace temp_city = strproper(strtrim(subinstr(temp_city, "County", "",.)))
keep Name lastname firstname midname year statefip* temp_city temp_city_2 temp_city_3 Residence Age Rank missing_vals Entity Source NetWorth Rank family
unab test:_all
di "`test'"
local notoca "statefips1 statefips2 statefips3"
local forresh: list test - notoca
di "`forresh'"

// New reshape
tempfile reshape1
save `reshape1'
use `reshape1', clear

// Reshape 1
rename temp_city tempcity1
rename temp_city_2 tempcity2
rename temp_city_3 tempcity3
g id = _n 
reshape long tempcity, i(id) j(location_order) 
tempfile reshape2
save `reshape2'

// Reshape 2
use `reshape1', clear
g id = _n
reshape long statefips, i(id) j(location_order) 
tempfile reshape3
save `reshape3'

// Merge two reshapes
merge 1:1 Name year location_order id using `reshape2'
drop temp_city temp_city_2 temp_city_3 statefips1 statefips2 statefips3 id
rename tempcity temp_city
drop _m

**reshape long statefips, i(`forresh') j(num) string

replace temp_city = strproper(strtrim(subinstr(temp_city, "  ", " ", .)))
g etype = 1
local ki = 2
foreach type in Comunidad Zona Reservation County{
replace etype = `ki' if regexm(temp_city, "`type'")==1
replace temp_city = strtrim(subinstr(temp_city, "`type'", "", .))
local ki = `ki'+1
}
foreach type in CDP Town City Village Borough{
  replace temp_city = strtrim(subinstr(temp_city, " `type'", "", .))
}
destring statefips, replace
drop if statefips==. & year != "2002"

*FURTHER ADJUSTMENTS FROM THE EXCEL SPREADSHEET ON BAD MATCHES
*SEE LOCALITY FOLDER FOR MORE DETAIL
replace statefips=8 if temp_city=="Aspen" & statefips==6
replace statefips=11 if temp_city=="Washington" & statefips==53 & inlist(year, "2009", "1995", "1988", "2014", "2013")
replace statefips=8 if temp_city=="Cherry Hills" & statefips==6
replace statefips=18 if temp_city=="Crown Point" & statefips==48
replace statefips=8 if temp_city=="Englewood" & statefips==6
replace statefips=8 if temp_city=="Fort Collins" & statefips==6
replace statefips=8 if temp_city=="Parker" & statefips==6
replace statefips=6 if temp_city=="Woodbridge" & statefips==8
replace temp_city="Indian Wells" if temp_city=="Indian Springs" & statefips==8
replace temp_city="Indian Wells" if temp_city=="Indian Springs" & statefips==8

replace statefips=25 if temp_city=="Framingham" & statefips==24
replace statefips=25 if temp_city=="Hopkinton" & statefips==24
replace statefips=25 if temp_city=="Milton" & statefips==24
replace statefips=25 if temp_city=="Newton" & statefips==24

// Making changes to prevent bad merges.
replace temp_city = "Augusta-Richmond" if temp_city == "Augusta" & statefips == 13
replace temp_city = "Setauket-East Setauket" if temp_city == "East Setauket" & statefips == 36
replace temp_city = "East Hampton" if temp_city == "Easthampton" & statefips == 36
replace temp_city = "Islamorada, Of Islands" if temp_city == "Islamorada" & statefips == 12
replace temp_city = "Islamorada, Of Islands" if temp_city == "Islamoradora" & statefips == 12
replace temp_city = "Jacksonville" if temp_city == "Jackson" & statefips == 12
replace temp_city = "Las Vegas" if temp_city == "La Vegas" & statefips == 32
replace temp_city = "Lexington-Fayette Northwest" if temp_city == "Lexington" & statefips == 21
replace temp_city = "Louisville/Jefferson" if temp_city == "Louisville" & statefips == 21
replace temp_city = "Mill Neck" if temp_city == "Millneck" & statefips == 36
replace temp_city = "Newton" if temp_city == "Newton Centre" & statefips == 25
replace temp_city = "Rancho Santa Fe" if Residence == "Racho Santa Fe, California" & statefips == 6
replace Residence = "Rancho Santa Fe, CA" if Residence == "Racho Santa Fe, California"
replace temp_city = "Redwood" if temp_city == "Redwood Shores" & statefips == 6
replace temp_city = "St. Petersburg" if temp_city == "Saint Petersburg" & statefips == 12
replace temp_city = "San Juan Island" if temp_city == "San Juan Islands" & statefips == 53
replace temp_city = "Southampton" if temp_city == "Southhampton" & statefips == 36
replace temp_city = "St. Marys Point" if temp_city == "St Mary'S" & statefips == 27
replace temp_city = "St. Marys Point" if temp_city == "St Mary’S Point" & statefips == 27
replace temp_city = "Upper St. Clair" if temp_city == "Upper Saint Clair" & statefips == 42
replace temp_city = "Virginia Beach" if temp_city == "Va Beach" & statefips == 51
replace statefips = 11 if temp_city == "Washington" & Name == "John Davison Rockefeller"
replace statefips = 11 if temp_city == "Washington" & Name == "Alice Sheets Marriott"
replace statefips = 11 if temp_city == "Washington" & Name == "John Willard Marriott Jr"
replace statefips = 11 if temp_city == "Washington" & Name == "Richard Edwin Marriott"
replace temp_city = "Baton Rouge" if temp_city == "Wells" & Name == "Irene Wells Pennington" // Appears last name added in error to residence
replace Residence = "Old Westbury, New York" if Name == "Steven Schonfeld" & year == "2009" // State accidentally left off, cross referenced with Forbes magazine for the year in question
replace temp_city = "Old Westbury" if Name == "Steven Schonfeld" & year == "2009"
replace statefips = 36 if Name == "Steven Schonfeld" & year == "2009"

** Fix incorrect state
replace statefips = 51 if temp_city == "Charlottesville" & statefips == 36
replace temp_city = "" if Residence == "Columbus, Ohio; Calif." & statefips == 6 & Source == "Publishing, broadcasting, bkg."
replace statefips = 39 if Residence == "Columbus, Ohio; Calif." & Source == "Inheritance (media, banking)"
replace statefips = 32 if temp_city == "Las Vegas"
replace statefips = 12 if temp_city == "Palm Beach"
replace statefips = 23 if Residence == "Portland, Me.; Florida" & temp_city == "Portland"
replace statefips = 6 if temp_city == "Rancho Santa Fe"
replace temp_city = "Rancho Santa Fe" if Residence == "Racho Santa Fe, California" & statefips == 6
replace statefips = 12 if temp_city == "Vero Beach"

** Several records for 2003 mislabeled Boston as being in Maryland (as well as other cities)
replace Residence = "Boston, Massachusetts" if Residence == "Boston, Maryland" & year == "2003"
replace statefips = 25 if Residence == "Boston, Massachusetts"
replace Residence = "Concord, Massachusetts" if Residence == "Concord, Maryland" 
replace statefips = 25 if Residence == "Concord, Massachusetts"

tempfile forbes
save `forbes'
merge m:1 temp_city statefips using "./data/stata_data/temp_crosswalk_for_CDPv4.dta",nogen keep(master match)
rename csa10 CSA
rename cbsa10 CBSA
rename csaname10 CSAname
rename cbsaname10 CBSAname
gen CA = CSA if CSA~=999
replace CA = CBSA if CSA==999
replace CA = placefp if CSA==999 & CBSA==99999

gen CAname = CSAname if CSA~=999
replace CAname = CBSAname if CSA==999
replace CAname = temp_city if CSA==999 & CBSA==99999

// Adding CA and County After Merge
replace CA = 266 if temp_city == "Ada" & statefips == 26
replace CAname = "Grand Rapids-Muskegon-Holland, MI Combined Statistical Area" if temp_city == "Ada" & statefips == 26
replace cntyname = "Wood" if temp_city == "Ada" & statefips == 26 
replace county = 26081 if temp_city == "Ada" & statefips == 26
replace CA = 27500 if temp_city == "Afton" & statefips == 55
replace CAname = "Janesville, WI Metropolitan Statistical Area" if temp_city == "Afton" & statefips == 55
replace cntyname = "Rock" if temp_city == "Afton" & statefips == 55
replace county = 55105 if temp_city == "Afton" & statefips == 55
replace statefips = 12 if Name == "Micky Arison" & temp_city == "Bal Harbour"
replace CA = 33100 if temp_city == "Bal Harbour" & statefips == 12
replace CAname = "Miami-Fort Lauderdale-Pompano Beach, FL Metropolitan Statistical Area" if temp_city == "Bal Harbour" & statefips == 12
replace county = 12086 if temp_city == "Bal Harbour" & statefips == 12
replace cntyname = "Miami-Dade" if temp_city == "Bal Harbour" & statefips == 12
replace CA = 148 if temp_city == "Beacon Hill" & statefips == 25
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if temp_city == "Beacon Hill" & statefips == 25
replace county = 25025 if temp_city == "Beacon Hill" & statefips == 25
replace cntyname = "Suffolk" if temp_city == "Beacon Hill" & statefips == 25
replace county = 34035 if temp_city == "Bedminster"& statefips == 34
replace CA = 408 if temp_city == "Bedminster"& statefips == 34
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Bedminster"& statefips == 34
replace cntyname = "Somerset" if temp_city == "Bedminster"& statefips == 34
replace CA = 408 if temp_city == "Brooklyn" & statefips == 36
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Brooklyn" & statefips == 36
replace county = 36085 if temp_city == "Brooklyn" & statefips == 36
replace cntyname = "Richmond" if temp_city == "Brooklyn" & statefips == 36
replace CA = 408 if temp_city == "Campbell Hall" & statefips == 36
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Campbell Hall" & statefips == 36
replace county = 36071 if temp_city == "Campbell Hall" & statefips == 36
replace cntyname = "Orange" if temp_city == "Campbell Hall" & statefips == 36
replace CA = 428 if temp_city == "Centerville" & statefips == 10
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Centerville" & statefips == 10
replace county = 10003 if temp_city == "Centerville" & statefips == 10
replace cntyname = "New Castle" if temp_city == "Centerville" & statefips == 10
replace CA = 428 if temp_city == "Centreville" & statefips == 10
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Centreville" & statefips == 10
replace county = 10003 if temp_city == "Centreville" & statefips == 10
replace cntyname = "New Castle" if temp_city == "Centreville" & statefips == 10
replace CA = 148 if temp_city == "Chelmsford" & statefips == 25
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if temp_city == "Chelmsford" & statefips == 25
replace county = 25017 if temp_city == "Chelmsford" & statefips == 25
replace cntyname = "Middlesex" if temp_city == "Chelmsford" & statefips == 25
replace CA = 148 if temp_city == "Chestnut Hill" & statefips == 25 // Spans multiple counties (we picked Middlesex)
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if temp_city == "Chestnut Hill" & statefips == 25
replace cntyname = "Middlesex" if temp_city == "Chestnut Hill" & statefips == 25
replace county = 25017 if temp_city == "Chestnut Hill" & statefips == 25
replace CA = 428 if temp_city == "Christiana Hundred" & statefips == 10
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Christiana Hundred" & statefips == 10
replace county = 10003 if temp_city == "Christiana Hundred" & statefips == 10
replace cntyname = "New Castle" if temp_city == "Christiana Hundred" & statefips == 10
replace CA = 99999 if temp_city == "Clark" & statefips == 56
replace CAname = "Clark, WY" if temp_city == "Clark" & statefips == 56
replace county = 56029 if temp_city == "Clark" & statefips == 56
replace cntyname = "Park" if temp_city == "Clark" & statefips == 56
replace CA = 148 if temp_city == "Cohassett" & statefips == 25
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if temp_city == "Cohassett" & statefips == 25
replace county = 25021 if temp_city == "Cohassett" & statefips == 25
replace cntyname = "Norfolk" if temp_city == "Cohassett" & statefips == 25
replace CA = 99999 if temp_city == "Devils Tower" & statefips == 56 // Rural and not in crosswalk
replace CAname = "Devil's Tower, WY" if temp_city == "Devils Tower" & statefips == 56
replace county = 56011 if temp_city == "Devils Tower" & statefips == 56
replace cntyname = "Crook" if temp_city == "Devils Tower" & statefips == 56 
replace CA = 99999 if temp_city == "Edgartown" & statefips == 25 // Rural and not in crosswalk
replace CAname = "Edgartown, MA" if temp_city == "Edgartown" & statefips == 25
replace county = 25007 if temp_city == "Edgartown" & statefips == 25
replace cntyname = "Dukes" if temp_city == "Edgartown" & statefips == 25
replace CA = 430 if temp_city == "Eightyfour" & statefips == 42
replace CAname = "Pittsburgh-New Castle, PA Combined Statistical Area" if temp_city == "Eightyfour" & statefips == 42
replace county = 42125 if temp_city == "Eightyfour" & statefips == 42
replace cntyname = "Washington" if temp_city == "Eightyfour" & statefips == 42
replace CA = 408 if temp_city == "Essex" & statefips == 34
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Essex" & statefips == 34
replace county = 34013 if temp_city == "Essex" & statefips == 34
replace cntyname = "Essex" if temp_city == "Essex" & statefips == 34
replace CA = 548 if temp_city == "Fauquier" & statefips == 51
replace CAname = "Washington-Baltimore-Northern Virginia, DC-MD-VA-WV Combined Statistical Area" if temp_city == "Fauquier" & statefips == 51
replace county = 51061 if temp_city == "Fauquier" & statefips == 51
replace cntyname = "Fauquier" if temp_city == "Fauquier" & statefips == 51
replace CA = 408 if temp_city == "Flushing" & statefips == 36
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Flushing" & statefips == 36
replace county = 36085 if temp_city == "Flushing" & statefips == 36
replace cntyname = "Richmond" if temp_city == "Flushing" & statefips == 36
replace CA = 428 if temp_city == "Gladwyne Pa" & statefips == 42
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Gladwyne Pa" & statefips == 42
replace county = 42091 if temp_city == "Gladwyne Pa" & statefips == 42
replace cntyname = "Montgomery" if temp_city == "Gladwyne Pa" & statefips == 42
replace CA = 220 if temp_city == "Gladwyne" & statefips == 42
replace CAname = "Detroit-Warren-Flint, MI Combined Statistical Area" if temp_city == "Gladwyne" & statefips == 42
replace county = 42091 if temp_city == "Gladwyne" & statefips == 42
replace cntyname = "Montgomery" if temp_city == "Gladwyne" & statefips == 42

replace CA = 220 if temp_city == "Gro Sse Pointe Farms" & statefips == 26
replace CAname = "Detroit-Warren-Flint, MI Combined Statistical Area" if temp_city == "Gro Sse Pointe Farms" & statefips == 26
replace county = 26163 if temp_city == "Gro Sse Pointe Farms" & statefips == 26
replace cntyname = "Wayne" if temp_city == "Gro Sse Pointe Farms" & statefips == 26
replace CA = 220 if temp_city == "Gro Sse Pointe Shores" & statefips == 26
replace CAname = "Detroit-Warren-Flint, MI Combined Statistical Area" if temp_city == "Gro Sse Pointe Shores" & statefips == 26
replace county = 26163 if temp_city == "Gro Sse Pointe Shores" & statefips == 26
replace cntyname = "Wayne" if temp_city == "Gro Sse Pointe Shores" & statefips == 26
replace CA = 220 if temp_city == "Grosse Point" & statefips == 26
replace CAname = "Detroit-Warren-Flint, MI Combined Statistical Area" if temp_city == "Grosse Point" & statefips == 26
replace county = 26163 if temp_city == "Grosse Point" & statefips == 26
replace cntyname = "Wayne" if temp_city == "Grosse Point" & statefips == 26
replace CA = 220 if temp_city == "Grosse Pte Shores" & statefips == 26
replace CAname = "Detroit-Warren-Flint, MI Combined Statistical Area" if temp_city == "Grosse Pte Shores" & statefips == 26
replace county = 26163 if temp_city == "Grosse Pte Shores" & statefips == 26
replace cntyname = "Wayne" if temp_city == "Grosse Pte Shores" & statefips == 26
replace CA = 220 if temp_city == "Hinckley" & statefips == 39
replace CAname = "Detroit-Warren-Flint, MI Combined Statistical Area" if temp_city == "Hinckley" & statefips == 39
replace county = 39103 if temp_city == "Hinckley" & statefips == 39
replace cntyname = "Medina" if temp_city == "Hinckley" & statefips == 39
replace CA = 148 if temp_city == "Hollis" & statefips == 33
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if temp_city == "Hollis" & statefips == 33
replace county = 33011 if temp_city == "Hollis" & statefips == 33
replace cntyname = "Hillsborough" if temp_city == "Hollis" & statefips == 33
replace CA = 348 if temp_city == "Holmby Hills" & statefips == 6
replace CAname = "Los Angeles-Long Beach-Riverside, CA Combined Statistical Area" if temp_city == "Holmby Hills" & statefips == 6
replace county = 6037 if temp_city == "Holmby Hills" & statefips == 6
replace cntyname = "Los Angeles" if temp_city == "Holmby Hills" & statefips == 6
replace CA = 348 if temp_city == "Holmby Hills" & statefips == 6
replace CAname = "Los Angeles-Long Beach-Riverside, CA Combined Statistical Area" if temp_city == "Holmby Hills" & statefips == 6
replace county = 6037 if temp_city == "Holmby Hills" & statefips == 6
replace cntyname = "Los Angeles" if temp_city == "Holmby Hills" & statefips == 6
replace CA = 428 if temp_city == "Huntingdon Valley" & statefips == 42
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Huntingdon Valley" & statefips == 42
replace county = 42091 if temp_city == "Huntingdon Valley" & statefips == 42
replace cntyname = "Montgomery" if temp_city == "Huntingdon Valley" & statefips == 42
replace CA = 428 if temp_city == "Huntington Valley" & statefips == 42
replace CAname  = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Huntington Valley" & statefips == 42
replace county = 42091 if temp_city == "Huntington Valley" & statefips == 42
replace cntyname = "Montgomery" if temp_city == "Huntington Valley" & statefips == 42
replace CA = 178 if temp_city == "Indian Hill" & statefips == 39
replace CAname = "Cincinnati-Middletown-Wilmington, OH-KY-IN Combined Statistical Area" if temp_city == "Indian Hill" & statefips == 39
replace county = 39061 if temp_city == "Indian Hill" & statefips == 39
replace cntyname = "Hamilton" if temp_city == "Indian Hill" & statefips == 39
replace temp_city = "Indian Wells" if temp_city == "Indian Springs" & statefips ==6
replace CA = 348 if temp_city == "Indian Springs" & statefips ==6
replace CAname = "Los Angeles-Long Beach-Riverside, CA Combined Statistical Area" if temp_city == "Indian Springs" & statefips ==6
replace county = 6065 if temp_city == "Indian Springs" & statefips ==6
replace cntyname = "Riverside" if temp_city == "Indian Springs" & statefips ==6
replace CA = 206 if temp_city == "Irvine" & statefips == 48
replace CAname = "Dallas-Fort Worth, TX Combined Statistical Area" if temp_city == "Irvine" & statefips == 48
replace county = 48113 if temp_city == "Irvine" & statefips == 48
replace cntyname = "Dallas" if temp_city == "Irvine" & statefips == 48
replace CA = 26180 if temp_city == "Kahala Beach" & statefips == 15
replace CAname = "Honolulu, HI Metropolitan Statistical Area" if temp_city == "Kahala Beach" & statefips == 15
replace county = 15003 if temp_city == "Kahala Beach" & statefips == 15
replace cntyname = "Honolulu" if temp_city == "Kahala Beach" & statefips == 15
replace CA = 428 if temp_city == "Kennett Pike" & statefips == 10
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Kennett Pike" & statefips == 10
replace county = 10003 if temp_city == "Kennett Pike" & statefips == 10
replace cntyname = "New Castle" if temp_city == "Kennett Pike" & statefips == 10
replace CA = 204  if temp_city == "King Ranch" & statefips == 48
replace CAname = "Corpus Christi-Kingsville, TX Combined Statistical Area" if temp_city == "King Ranch" & statefips == 48
replace county = 48273  if temp_city == "King Ranch" & statefips == 48
replace cntyname = "Kleberg"  if temp_city == "King Ranch" & statefips == 48
replace CA = 428 if temp_city == "Lafayette Hill" & statefips == 42
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Lafayette Hill" & statefips == 42
replace county = 42091 if temp_city == "Lafayette Hill" & statefips == 42
replace cntyname = "Montgomery" if temp_city == "Lafayette Hill" & statefips == 42
replace CA = 22660 if temp_city == "Larimer" & statefips == 8
replace CAname = "Fort Collins-Loveland, CO Metropolitan Statistical Area" if temp_city == "Larimer" & statefips == 8
replace county = 8069 if temp_city == "Larimer" & statefips == 8
replace cntyname = "Larimer" if temp_city == "Larimer" & statefips == 8
replace CA = 148 if temp_city == "Lincoln" & statefips == 25
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if temp_city == "Lincoln" & statefips == 25
replace county = 25017 if temp_city == "Lincoln" & statefips == 25
replace cntyname = "Middlesex" if temp_city == "Lincoln" & statefips == 25
replace CA = 27220 if temp_city == "Little Jackson Hole" & statefips == 56
replace CAname = "Little Jackson Hole, WY" if temp_city == "Little Jackson Hole" & statefips == 56
replace county = 56039 if temp_city == "Little Jackson Hole" & statefips == 56
replace cntyname = "Teton" if temp_city == "Little Jackson Hole" & statefips == 56
replace CA = 408 if temp_city == "Livingston" & statefips == 34
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Livingston" & statefips == 34
replace county = 34013 if temp_city == "Livingston" & statefips == 34
replace cntyname = "Essex" if temp_city == "Livingston" & statefips == 34
replace CA = 408 if temp_city == "Lyndhurst" & statefips == 34
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Lyndhurst" & statefips == 34
replace county = 34003 if temp_city == "Lyndhurst" & statefips == 34
replace cntyname = "Bergen" if temp_city == "Lyndhurst" & statefips == 34
replace CA = 216 if temp_city == "Magness" & statefips == 8
replace CAname = "Denver-Aurora-Boulder, CO Combined Statistical Area" if temp_city == "Magness" & statefips == 8
replace county = 8031 if temp_city == "Magness" & statefips == 8
replace cntyname = "Denver" if temp_city == "Magness" & statefips == 8
replace CA = 408 if temp_city == "Milburn" & statefips == 34
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Milburn" & statefips == 34
replace county = 34013 if temp_city == "Milburn" & statefips == 34
replace cntyname = "Essex" if temp_city == "Milburn" & statefips == 34
replace CA = 548 if temp_city == "Millersville" & statefips == 24
replace CAname = "Washington-Baltimore-Northern Virginia, DC-MD-VA-WV Combined Statistical Area" if temp_city == "Millersville" & statefips == 24
replace county = 24003 if temp_city == "Millersville" & statefips == 24
replace cntyname = "Anne Arundel" if temp_city == "Millersville" & statefips == 24
replace statefips = 10 if temp_city == "Montchanin"
replace CA = 428 if temp_city == "Montchanin" & statefips == 10
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Montchanin" & statefips == 10
replace county = 10003 if temp_city == "Montchanin" & statefips == 10
replace cntyname = "New Castle" if temp_city == "Montchanin" & statefips == 10
replace CA = 428 if temp_city == "Montchamin" & statefips == 10
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Montchamin" & statefips == 10
replace county = 10003 if temp_city == "Montchamin" & statefips == 10
replace cntyname = "New Castle" if temp_city == "Montchamin" & statefips == 10
replace CA = 408 if temp_city == "Morris" & statefips == 34
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Morris" & statefips == 34
replace county = 34027 if temp_city == "Morris" & statefips == 34
replace cntyname = "Morris" if temp_city == "Morris" & statefips == 34
replace CA = 348 if temp_city == "N Hollywood" & statefips == 6
replace CAname = "Los Angeles-Long Beach-Riverside, CA Combined Statistical Area" if temp_city == "N Hollywood" & statefips == 6
replace county = 6037 if temp_city == "N Hollywood" & statefips == 6
replace cntyname = "Los Angeles" if temp_city == "N Hollywood" & statefips == 6
replace CA = 488 if temp_city == "Napa Valley" & statefips == 6
replace CAname = "San Jose-San Francisco-Oakland, CA Combined Statistical Area" if temp_city == "Napa Valley" & statefips == 6
replace county = 6055 if temp_city == "Napa Valley" & statefips == 6
replace cntyname = "Napa" if temp_city == "Napa Valley" & statefips == 6
replace CA = 408 if temp_city == "New Canaan" & statefips == 9
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "New Canaan" & statefips == 9
replace county = 9001 if temp_city == "New Canaan" & statefips == 9
replace cntyname = "Fairfield" if temp_city == "New Canaan" & statefips == 9
replace CA = 408 if temp_city == "New Vernon" & statefips == 34
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "New Vernon" & statefips == 34
replace county = 34027 if temp_city == "New Vernon" & statefips == 34
replace cntyname = "Morris" if temp_city == "New Vernon" & statefips == 34
replace CA = 348 if temp_city == "Newport Coast" & statefips == 6
replace CAname = "Los Angeles-Long Beach-Riverside, CA Combined Statistical Area" if temp_city == "Newport Coast" & statefips == 6
replace county = 6059 if temp_city == "Newport Coast" & statefips == 6
replace cntyname = "Orange" if temp_city == "Newport Coast" & statefips == 6
replace CA = 428 if temp_city == "Newtown Square" & statefips == 42
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Newtown Square" & statefips == 42
replace county = 42045 if temp_city == "Newtown Square" & statefips == 42
replace cntyname = "Delaware" if temp_city == "Newtown Square" & statefips == 42
replace CA = 348 if temp_city == "North Hollywood" & statefips == 6
replace CAname = "Los Angeles-Long Beach-Riverside, CA Combined Statistical Area" if temp_city == "North Hollywood" & statefips == 6
replace county = 6037 if temp_city == "North Hollywood" & statefips == 6
replace cntyname = "Los Angeles" if temp_city == "North Hollywood" & statefips == 6
replace CA = 28580 if temp_city == "Ocean Reef" & statefips == 12
replace CAname = "Key West, FL Micropolitan Statistical Area" if temp_city == "Ocean Reef" & statefips == 12
replace county = 12087 if temp_city == "Ocean Reef" & statefips == 12
replace cntyname = "Monroe" if temp_city == "Ocean Reef" & statefips == 12
replace CA = 35980 if temp_city == "Old Lyme" & statefips == 9
replace CAname = "Norwich-New London, CT Metropolitan Statistical Area" if temp_city == "Old Lyme" & statefips == 9
replace county = 9011 if temp_city == "Old Lyme" & statefips == 9
replace cntyname = "New London" if temp_city == "Old Lyme" & statefips == 9
replace temp_city = "Palisades" if temp_city == "Pacific Palisades" & Name == "James Chambers" // Incorrect temp_city
replace CA = 408 if temp_city == "Palisades" 
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Palisades" 
replace county = 36087 if temp_city == "Palisades"
replace cntyname = "Rockland" if temp_city == "Palisades"
replace CA = 408 if temp_city == "Purchase" & statefips == 36
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Purchase" & statefips == 36
replace county = 36119 if temp_city == "Purchase" & statefips == 36
replace cntyname = "Westchester" if temp_city == "Purchase" & statefips == 36
replace CA = 428 if temp_city == "Radnor" & statefips == 42
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Radnor" & statefips == 42
replace county = 42045 if temp_city == "Radnor" & statefips == 42
replace cntyname = "Delaware" if temp_city == "Radnor" & statefips == 42
replace CA = 428 if temp_city == "Rockland" & statefips == 10
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Rockland" & statefips == 10
replace county = 10003 if temp_city == "Rockland" & statefips == 10
replace cntyname = "New Castle" if temp_city == "Rockland" & statefips == 10
replace CA = 428 if temp_city == "Rydal" & statefips == 42
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Rydal" & statefips == 42
replace county = 42091 if temp_city == "Rydal" & statefips == 42
replace cntyname = "Montgomery" if temp_city == "Rydal" & statefips == 42
replace CA = 148 if temp_city == "Rye" & statefips == 33
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if temp_city == "Rye" & statefips == 33
replace county = 33015 if temp_city == "Rye" & statefips == 33
replace cntyname = "Rockingham" if temp_city == "Rye" & statefips == 33
replace CA = 99999 if temp_city == "Seal Cove" & statefips == 23 // Rural, but no placefp
replace CAname = "Seal Cove, ME" if temp_city == "Seal Cove" & statefips == 23 
replace county = 23009 if temp_city == "Seal Cove" & statefips == 23
replace cntyname = "Hancock" if temp_city == "Seal Cove" & statefips == 23
replace CA = 430 if temp_city == "Shadyside" & statefips == 42
replace CAname = "Pittsburgh-New Castle, PA Combined Statistical Area" if temp_city == "Shadyside" & statefips == 42
replace county = 42003 if temp_city == "Shadyside" & statefips == 42
replace cntyname = "Allegheny" if temp_city == "Shadyside" & statefips == 42
replace CA = 312 if temp_city == "Shawnee Mission" & statefips == 20
replace CAname = "Kansas City-Overland Park-Kansas City, MO-KS Combined Statistical Area" if temp_city == "Shawnee Mission" & statefips == 20
replace county = 20091 if temp_city == "Shawnee Mission" & statefips == 20
replace cntyname = "Johnson" if temp_city == "Shawnee Mission" & statefips == 20
replace CA = 148 if temp_city == "Sherborn" & statefips == 25
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if temp_city == "Sherborn" & statefips == 25
replace county = 25017 if temp_city == "Sherborn" & statefips == 25
replace cntyname = "Middlesex" if temp_city == "Sherborn" & statefips == 25
replace CA = 312 if temp_city == "Stilwell" & statefips == 20
replace CAname = "Kansas City-Overland Park-Kansas City, MO-KS Combined Statistical Area" if temp_city == "Stilwell" & statefips == 20
replace county = 20091 if temp_city == "Stilwell" & statefips == 20
replace cntyname = "Johnson" if temp_city == "Stilwell" & statefips == 20
replace CA = 148 if temp_city == "Stratham" & statefips == 33
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if temp_city == "Stratham" & statefips == 33
replace county = 33015 if temp_city == "Stratham" & statefips == 33
replace cntyname = "Rockingham" if temp_city == "Stratham" & statefips == 33
replace CA = 408 if temp_city == "Hunterdon" & statefips == 34
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Hunterdon" & statefips == 34
replace county = 34019 if temp_city == "Hunterdon" & statefips == 34
replace cntyname = "Hunterdon" if temp_city == "Hunterdon" & statefips == 34
replace temp_city = "Indian Springs" if temp_city == "Indian Wells" & statefips ==6
replace CA = 46380 if temp_city == "Indian Springs" & statefips == 6
replace CAname = "Ukiah, CA Micropolitan Statistical Area" if temp_city == "Indian Springs" & statefips == 6
replace county = 6045 if temp_city == "Indian Springs" & statefips == 6
replace cntyname = "Mendocino" if temp_city == "Indian Springs" & statefips == 6
replace CA = 408 if temp_city == "Pottersville" & statefips == 34
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Pottersville" & statefips == 34
replace county = 34035 if temp_city == "Pottersville" & statefips == 34
replace cntyname = "Somerset" if temp_city == "Pottersville" & statefips == 34
replace CA = 428 if temp_city == "Strafford" & statefips == 42 // Spans two counties
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Strafford" & statefips == 42
replace cntyname = "Delaware" if temp_city == "Strafford" & statefips == 42
replace county = 42045 if temp_city == "Strafford" & statefips == 42
replace CA = 428 if temp_city == "Stratford" & statefips == 42 // Spans two counties
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Stratford" & statefips == 42
replace CA = 428 if temp_city == "Villanova" & statefips == 42 // Spans two counties
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Villanova" & statefips == 42 
replace cntyname = "Delaware" if temp_city == "Villanova" & statefips == 42
replace county = 42045 if temp_city == "Villanova" & statefips == 42
replace temp_city = "Waban" if temp_city == "Wabun" & statefips == 25 // City spelled incorrectly
replace CA = 148 if temp_city == "Waban" & statefips == 25
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if temp_city == "Waban" & statefips == 25
replace county = 25017 if temp_city == "Waban" & statefips == 25
replace cntyname = "Middlesex" if temp_city == "Waban" & statefips == 25
replace CA = 148 if temp_city == "Wayland" & statefips == 25
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if temp_city == "Wayland" & statefips == 25
replace county = 25017 if temp_city == "Wayland" & statefips == 25
replace cntyname = "Middlesex" if temp_city == "Wayland" & statefips == 25
replace CA = 408 if temp_city == "Westchester" & statefips == 36
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Westchester" & statefips == 36
replace county = 36119 if temp_city == "Westchester" & statefips == 36
replace cntyname = "Westchester" if temp_city == "Westchester" & statefips == 36
replace CA = 148 if temp_city == "Weston" & statefips == 25
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if temp_city == "Weston" & statefips == 25 
replace county =25017 if temp_city == "Weston" & statefips == 25
replace cntyname = "Middlesex" if temp_city == "Weston" & statefips == 25
replace CA = 408 if temp_city == "Woodbridge" & statefips == 9
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if temp_city == "Woodbridge" & statefips == 9
replace county = 9009 if temp_city == "Woodbridge" & statefips == 9
replace cntyname = "New Haven" if temp_city == "Woodbridge" & statefips == 9
replace CA = 428 if temp_city == "Wynnewood" & statefips == 42
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if temp_city == "Wynnewood" & statefips == 42
replace cntyname = "Delaware" if temp_city == "Wynnewood" & statefips == 42
replace county = 42045 if temp_city == "Wynnewood" & statefips == 42
replace county = 42091 if temp_city == "Woodbridge" & statefips == 9
replace cntyname = "Montgomery" if temp_city == "Woodbridge" & statefips == 9

/*
// Merging in 2017 Census file
tempfile beforemerge
save `beforemerge'
import excel using "./data/raw_data/2017_Gaz_cbsa_national.xlsx",firstrow clear
save "./data/stata_data/2017_Gaz_cbsa_national", replace
use `beforemerge', clear
merge m:1 CBSA using "./data/stata_data/2017_Gaz_cbsa_national.dta", update replace keep(master match) nogen
*/

*Manual fixes for the non-merged data
*use "./data/stata_data/Forbes_400_locality_data_CDP.dta", clear
*drop if missing_vals!=1 & statefips==100
*Non-matched Las Vegas data
*drop if m==2 & statefips==4

// Trying to fix formatting
replace Residence = "Singapore" if Name == "Robert M Friedland" & year == "2011"

// Fixing further CAname issues
replace CAname = "Boston-Worcester-Manchester, MA-RI-NH Combined Statistical Area" if CA == 148
replace CAname = "Philadelphia-Camden-Vineland, PA-NJ-DE-MD Combined Statistical Area" if CA == 428
replace CAname = "Grand Rapids-Muskegon-Holland, MI Combined Statistical Area" if CA == 266
replace CAname = "Corpus Christi-Kingsville, TX Combined Statistical Area" if CA == 204
replace CAname = "Washington-Baltimore-Northern Virginia, DC-MD-VA-WV Combined Statistical Area" if CA == 548
replace CAname = "Detroit-Warren-Flint, MI Combined Statistical Area" if CA == 220
replace CAname = "Cincinnati-Middletown-Wilmington, OH-KY-IN Combined Statistical Area" if CA == 178
replace CAname = "New York-Newark-Bridgeport, NY-NJ-CT-PA Combined Statistical Area" if CA == 408
replace CAname = "Los Angeles-Long Beach-Riverside, CA Combined Statistical Area" if CA == 348
replace CAname = "Jackson, WY" if CA == 27220
replace CAname = "Cleveland-Akron-Elyria, OH Combined Statistical Area" if CA == 184
/*
//Merge in population data
rename county fips
destring year, replace
merge m:1 year fips using "./data/stata_data/population.dta", nogen keep(master match)
*/
save "./data/stata_data/Forbes_400_locality_data_CDP.dta", replace

/*
*Count how many merges there are for each year
tab year if m==3
tab statefips if m==3
tab statefips if m==2
tab missing_vals if m==2
*Try and get a feel of any bad merges (in the case where an individual may have
*two localities and the previous reshape may create a false match)
duplicates report Name Age Rank Residence year m

duplicates tag year Name Age Rank, g(dup)
g bad_merge = 1 if m==2
*Duplicates of non-merges
g dup_bad_loc = dup if dup!=0 & m==2
*Duplicate names with a positive merge (in case of multiple residences)
g mult_loc = dup if dup!=0 & m==3
g good_merge = m if m==3
tabstat bad_merge dup_bad_loc mult_loc good_merge, by(year) stat(count)
*/

cap log close
