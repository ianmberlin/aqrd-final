clear all
set more off
cap log close
version 14
pause on

*Some name cleaning. 

cd "$root"

use "./data/stata_data/FORBES_1982_2017_partially_cleaned.dta", clear
cap drop test test2
replace Residence = subinstr(strtrim(Residence), "  ", " ", .)
drop if year==""
g place = substr(Residence, 1,  strpos(Residence, ","))
g st = subinstr(Residence, place, "", .)
g sec = substr(st, 1, strpos(st, ";"))
g sec2 = subinstr(st, sec, "", .)
replace st = subinstr(st, sec2, "", .)
replace Residence = "Millbrook, N.Y." if regexm(Residence, "MIllbrook, N.Y.")==1
replace Residence = "Denver, Colorado" if regexm(Residence, "Denver, California") ==1 
forvalues i = 1(1)9{
g full_state0`i' = 0
}
forvalues i = 10(1)56{
g full_state`i' = 0
}
forvalues i = 100(1)100{
g full_state`i' = 0
}
#delimit
replace full_state01 =1  if regexm(Residence, "Ala")==1 | regexm(Residence, "Alabama")==1 | (regexm(Residence, "Birmingham")==1 & regexm(Residence, "Birmingham, M")!=1)

;
/*
replace full_state02  = 1 if regexm(Residence, "")==1 | 

;
replace full_state03  = 1 if regexm(Residence, "")==1 | 

;
*/
replace full_state04   = 1 if regexm(Residence, "Arizona")==1 | regexm(Residence, "AZ")==1 | 
regexm(Residence, "Ariz.")==1 | regexm(Residence, "Ariz")==1 | regexm(Residence, "Paradise Valley")==1 | 
regexm(Residence, ", Az")==1 | regexm(Residence, "Phoenix")==1  

;
replace full_state05  = 1 if regexm(Residence, "Arkansas")==1 | regexm(Residence, "Ark.")==1 | 
 regexm(Residence, "AR")==1 |  (regexm(Residence, "Fayetteville")==1 & regexm(Residence, "Fayetteville, N")!=1  ) | regexm(Residence, "Little Rock")==1 | 
 regexm(Residence, "Springdale")==1 |  regexm(Residence, "Bentonville")==1 |
regexm(Residence, "Morrilton")==1
;

replace full_state06  = 1 if regexm(Residence, "California")==1 | regexm(Residence, "CA")==1 | 
regexm(Residence, "Cali")==1 | (regexm(Residence, "Bal Harbour")==1 & regexm(Residence, "Bal Harbour, F")!=1) | 
regexm(Residence, "Bel Air")==1 | regexm(Residence, "Beverly Hills")==1 | 
regexm(Residence, "Palm Springs")==1 | regexm(Residence, "Blackhawk")==1 | 
regexm(Residence, "Brentwood")==1 | regexm(Residence, "Burlingame")==1 | 
regexm(Residence, "Calif")==1 | regexm(Residence, "La Jolla")==1 | regexm(Residence, "Danville")==1 | 
regexm(Residence, "Encino")==1 | regexm(Residence, "Geyersville")==1 | regexm(Residence, "Hillsborough")==1 | 
regexm(Residence, "Los Altos")==1 | regexm(Residence, "Los Angeles")==1 |  regexm(Residence, "Los-Angeles")==1 | 
regexm(Residence, "Malibu")==1 | regexm(Residence, "Marin")==1 | regexm(Residence, "Marysville")==1 | 
regexm(Residence, "Menlo Park")==1 | regexm(Residence, "Modesto")==1 | regexm(Residence, "Mountain View")==1 | 
regexm(Residence, "N. Hollywood")==1 |  regexm(Residence, "Oakland")==1 | regexm(Residence, "Pacific Palisades")==1 | 
regexm(Residence, "Pasadena")==1 | regexm(Residence, "Portola Valley")==1 | 
regexm(Residence, "Rancho Santa Fe")==1 | regexm(Residence, "RanchoSanta Fe")==1 | 
regexm(Residence, "Redding")==1 | regexm(Residence, "Redlands")==1 | regexm(Residence, "Redwood City")==1 |
regexm(Residence, "Santa Barbara")==1 | regexm(Residence, "San Francisco")==1 |
 regexm(Residence, "SF")==1 |  regexm(Residence, "S.F")==1 |  regexm(Residence, "Sacramento")==1 |
 regexm(Residence, "San Diego")==1 | regexm(Residence, "San Jose")==1 | regexm(Residence, "San Fancisco")==1 |
 regexm(Residence, "San Juan Capistrano")==1 | regexm(Residence, "Santa Ana")==1 |
 regexm(Residence, "San Mateo")==1 | regexm(Residence, "Santa Marino")==1 |
 regexm(Residence, "Santa Clara")==1 | regexm(Residence, "Stockton")==1 |
 regexm(Residence, "Tiburon")==1 | regexm(Residence, "Woodside")==1 | (regexm(Residence, "Irvine")==1 & regexm(Residence, "Irvine, T")!=1)
 | regexm(Residence, "Atherton")==1 | regexm(Residence, "Geyersville")==1 | regexm(Residence, ", Ca")==1
 | regexm(Residence, "Belmont")==1| regexm(Residence, "Geyserville")==1 | regexm(Residence, "Laguna Beach")==1
 | regexm(Residence, "Palo Alto")==1 | regexm(Residence, "Hills 6")==1 | regexm(Residence, "Santa Barb")==1 |
 regexm(Residence, "Newport Beach")==1 | regexm(Residence, "Newport Coast")==1
;

*replace full_state07  = 1 if regexm(Residence, "")==1 | 
*;
replace full_state08  = 1 if (regexm(Residence, "Aspen")==1 & regexm(Residence, "Aspen, California")!=1) | 
regexm(Residence, "CO")==1 | regexm(Residence, "Colo")==1 | regexm(Residence, "Denver")==1 | 
regexm(Residence, "Elizabeth")==1 | (regexm(Residence, "Fort Collins")==1 & regexm(Residence, "Fort Collins, Ca")!=1 )|
 regexm(Residence, "Colorad")==1 | 
regexm(Residence, "Indian Hills")==1 | (regexm(Residence, "Parker")==1 & regexm(Residence, "Parker, Ca")!=1)
;
replace full_state09  = 1 if regexm(Residence, "Connecticut")==1 | 
regexm(Residence, "Ct")==1 | regexm(Residence, "Branford")==1 | regexm(Residence, "Conn.")==1 | 
regexm(Residence, "CT")==1 | regexm(Residence, "Danbury")==1 | regexm(Residence, "Darien")==1 | 
regexm(Residence, "Greenwich")==1  | regexm(Residence, "New Haven")==1 | regexm(Residence, "Westport, Conn")==1 
;

replace full_state10   = 1 if (regexm(Residence, "Delaware")==1 | regexm(Residence, "Wilmington")==1 | 
 (regexm(Residence, "Del.")==1 & regexm(Residence, "Del Mar")!=1 & regexm(Residence, "Delray")!=1 & regexm(Residence, "Dellwood")!=1)| regexm(Residence, "Centreville")==1 | regexm(Residence, ", De.")
 | regexm(Residence, "DE") | regexm(Residence, ", Del")) & regexm(Residence, "Dellwood")!=1
;

replace full_state11  = 1 if regexm(Residence, "Washington, D.C.")==1 | regexm(Residence, "Washington, Dc")==1 | regexm(Residence, "Washington, DC")==1 | regexm(Residence, "D.C.")==1 |
 regexm(Residence, "District")==1 | regexm(Residence, "D.C")==1 | regexm(Residence, "Washington, District of Columbia")==1
;

replace full_state12   = 1 if regexm(Residence, "Avon Park")==1 |  
regexm(Residence, "FL")==1 | regexm(Residence, "Fla")==1 | regexm(Residence, "Florida")==1 | 
regexm(Residence, "Florida")==1 | regexm(Residence, "Boca Raton")==1 |
regexm(Residence, "Bonita Springs")==1 | regexm(Residence, "Gasparilla Isla")==1
| regexm(Residence, "Miami Beach")==1 | regexm(Residence, "Clearwater")==1 | regexm(Residence, "Fort Lauderdale")==1
| (regexm(Residence, "Palm Beach")==1 & regexm(Residence, "Palm Beach, N")!=1)
| regexm(Residence, "Lauderdale")==1 | regexm(Residence, "Coconut Grove")==1
| regexm(Residence, "Lauderdale")==1 | regexm(Residence, "Daytona")==1 | regexm(Residence, "Delray")==1
| regexm(Residence, "Orlando")==1 | regexm(Residence, "Fischer Island")==1 | regexm(Residence, "Islamorada")==1
| regexm(Residence, "Jupiter Island")==1 | regexm(Residence, "Lamont")==1 | regexm(Residence, "Manaplan")==1
| regexm(Residence, "Miami")==1 | regexm(Residence, "Miamibeach")==1 | regexm(Residence, "Miami Beach")==1
| regexm(Residence, "Naples")==1 | regexm(Residence, "Ocala")==1 |
( regexm(Residence, "Orange County")==1 & regexm(Residence, "Orange County, C")!=1 )
| regexm(Residence, "Tampa")==1 | regexm(Residence, "Vero Beach")==1 | 
(regexm(Residence, "Westbury")==1 & regexm(Residence, "Westbury, N")!=1 )
| regexm(Residence, "Lighthouse Point")==1 | regexm(Residence, "Fisher Island")==1 | regexm(Residence, "Hobe Sound")==1
| regexm(Residence, "Manalaplan")==1 | regexm(Residence, "Marathon")==1 | regexm(Residence, "Plantation")==1
| regexm(Residence, ", Fl")==1 | regexm(Residence, ", Floria")==1
 ;
 
replace full_state13  = 1 if regexm(Residence, "Atlanta")==1 |
 regexm(Residence, "GA")==1 |  regexm(Residence, "Georgia")==1 | regexm(Residence, ", Ga.")==1  
 | regexm(Residence, ", Ga")==1  | regexm(Residence, "Duluth,Ga.")==1  
 ;
 
*replace full_state14  = 1 if regexm(Residence, "")==1 | 
*;
replace full_state15  = 1 if regexm(Residence, "Hawaii")==1 |  regexm(Residence, "HI")==1 | 
 regexm(Residence, ", Hi.")==1 |  regexm(Residence, "Honolulu")==1  

;
replace full_state16  = 1 if regexm(Residence, "Boise")==1 | 
regexm(Residence, "Idaho")==1 | regexm(Residence, "ID")==1 | regexm(Residence, "Ida.")==1 | 
regexm(Residence, "Sun Valley")==1 
;

replace full_state17  = 1 if regexm(Residence, "Chicago")==1 |
regexm(Residence, "IL")==1 | (regexm(Residence, "Aurora")==1 & regexm(Residence, "East Aurora")!=1 )| 
regexm(Residence, "Illinois")==1 | regexm(Residence, "Ill")==1 | regexm(Residence, "Barrington")==1 | 
regexm(Residence, "Champaign")==1 |   regexm(Residence, "Downers")==1 | 
regexm(Residence, "Evanston")==1 | regexm(Residence, "Glencoe")==1 |  regexm(Residence, "Ill.")==1 | 
 regexm(Residence, "Kenilworth")==1 | regexm(Residence, "Lake Forest")==1 | 
 regexm(Residence, "Northbrook")==1 |  regexm(Residence, "Oak Brook")==1 | 
 regexm(Residence, "Skokie")==1 | regexm(Residence, "Vernon Hills")==1 | 
 regexm(Residence, "Winnetka")==1 |  regexm(Residence, "Wilmette")==1  |  regexm(Residence, "Lisle")==1  
 |  regexm(Residence, "Highland Park")==1 
 ;
 
 
replace full_state18  = 1 if regexm(Residence, "Batesville")==1 | 
(regexm(Residence, "Ind")==1 & regexm(Residence, "Indian Hill")!=1 &  regexm(Residence, "Indian Springs")!=1 & regexm(Residence, "Indian Wells")!=1  )
 | regexm(Residence, "Bloomington")==1 | 
regexm(Residence, "Indiana")==1 | regexm(Residence, "IN")==1 | regexm(Residence, "Carmel")==1 | 
(regexm(Residence, "Crown Point")==1 & regexm(Residence, "Crown Point, T")!=1)
;

replace full_state19  = 1 if regexm(Residence, "Ia")==1 | regexm(Residence, "Adel")==1 |
regexm(Residence, "Iowa")==1 | regexm(Residence, "Des Moines")==1  
;
replace full_state20   = 1 if (regexm(Residence, "Kansas")==1 | regexm(Residence, "KS")==1 | 
regexm(Residence, ", Ks")==1 | regexm(Residence, "Kan.")==1 | regexm(Residence, "Kans.")==1 | 
regexm(Residence, "Stilwell")==1 | regexm(Residence, "Wichita")==1 | regexm(Residence, ", Kan")==1  
| regexm(Residence, "Mission Hills")==1)
 & regexm(Residence, "Kansas City, M")!=1 & regexm(Residence, "Kansas City,M")!=1 & regexm(Residence, "Kan. City, M")!=1 & regexm(Residence, "Kansascity, M")!=1
;
 
replace full_state21  = 1 if regexm(Residence, "Kentucky")==1 | regexm(Residence, "KY")==1 | 
regexm(Residence, "Louisville")==1 | regexm(Residence, ", Ky")==1  | regexm(Residence, "Lexington")==1  

;
replace full_state22   = 1 if regexm(Residence, "LA")==1 | 
regexm(Residence, "Louisiana")==1 | regexm(Residence, "Baton Rouge")==1 | (regexm(Residence, ", La.")==1 & regexm(Residence, ", Las")!=1) | 
 regexm(Residence, "New Orleans")==1 |  (regexm(Residence, ", La")==1  & regexm(Residence, "Las")!=1)
;

replace full_state23  = 1 if regexm(Residence, "Maine")==1 | regexm(Residence, "ME")==1 | 
 regexm(Residence, ", Me.")==1 

;
replace full_state24  = 1 if regexm(Residence, "Chevy Chase")==1 | 
regexm(Residence, "Maryland")==1 | regexm(Residence, "Baltimore")==1 | 
regexm(Residence, "Bethesda")==1 | regexm(Residence, "Md")==1 | regexm(Residence, "MD")==1 |
regexm(Residence, "Easton")==1 | regexm(Residence, "Millersville")==1 | regexm(Residence, "Potomac")==1 

;
 
replace full_state25  = 1 if (regexm(Residence, "Boston")==1 & regexm(Residence, "Boston, Mar")!=1)| regexm(Residence, "Mass")==1 | 
regexm(Residence, "Massachusetts")==1 | regexm(Residence, "Brookline")==1 | regexm(Residence, "MA")==1 | 
regexm(Residence, "Chestnut Hill")==1 | regexm(Residence, "Cohasset")==1 | regexm(Residence, "Nantucket")==1 | 
(regexm(Residence, "Milton")==1 & regexm(Residence, "Milton, Mar")!=1)
| (regexm(Residence, "Newton")==1 & regexm(Residence, "Penn")!=1 & regexm(Residence, "Newton, Mary")!=1  ) 
;

replace full_state26  = 1 if regexm(Residence, "Ada")==1 | regexm(Residence, "MI")==1 | 
regexm(Residence, "Mich")==1 | regexm(Residence, "Michigan")==1 | 
regexm(Residence, "Ann Arbor")==1 | regexm(Residence, "Bingham Farms")==1 | 
regexm(Residence, "Bloomfield Hills")==1 | regexm(Residence, "Detroit")==1 | 
(regexm(Residence, "Franklin")==1 & regexm(Residence, "Tn")!=1 & regexm(Residence, "Tenn")!=1   )
| regexm(Residence, "Grand Rapids")==1 |  regexm(Residence, "Grosse Pointe")==1 | 
regexm(Residence, "Bloomfield Hills, M")==1 | regexm(Residence, "Portage, M")==1 | regexm(Residence, "Holland, Mi")==1 |
 regexm(Residence, "Kalamazoo")==1 |  regexm(Residence, "Birmingham, M")==1 | 
regexm(Residence, "Ypsilanti")==1  
;

replace full_state27  = 1 if (regexm(Residence, "Minn")==1 & regexm(Residence, "McMinn")!=1)
| regexm(Residence, "MN")==1 | 
regexm(Residence, "Minnesota")==1 |  regexm(Residence, "Bayport")==1 | regexm(Residence, "Dellwood")==1 | 
regexm(Residence, "Minneapolis")==1 | regexm(Residence, "Edina")==1 | regexm(Residence, "Long Lake")==1 | 
regexm(Residence, "Mankato")==1 | regexm(Residence, "St. Paul")==1 | 
regexm(Residence, "Wayzata")==1 
;

replace full_state28  = 1 if regexm(Residence, "MS")==1 | regexm(Residence, "Mississippi")==1 |
(regexm(Residence, "Jackson")==1 & regexm(Name, "Rich")==1) | (regexm(Residence, "Jackson, Miss")==1)
;

replace full_state29  = 1 if regexm(Residence, "MO")==1 | regexm(Residence, "Missouri")==1 | 
(regexm(Residence, "Columbia")==1 & regexm(Residence, "Columbia, Md")!=1) |  
regexm(Residence, "St Louis")==1 | regexm(Residence, "St.Louis")==1 | regexm(Residence, "St. Louis")==1  
| (regexm(Residence, "Kansas City")==1  & regexm(Residence, "Missouri")==1 )
| (regexm(Residence, "Kansascity")==1  & regexm(Residence, "Mo")==1 )
| (regexm(Residence, "Kansas City")==1  & regexm(Residence, "Mo")==1 )
| (regexm(Residence, "Mission Hills")==1  & regexm(Residence, "Mo")==1 )
| (regexm(Residence, "Kan. City")==1  & regexm(Residence, "Mo")==1 )
| (regexm(Residence, "Springfield")==1  & regexm(Residence, "Missouri")==1 )
| (regexm(Residence, "Springfield")==1  & regexm(Residence, "Mo")==1 )
| (regexm(Residence, "Loch Lloyd")==1  & regexm(Residence, "Mo")==1 )
| (regexm(Residence, "Loch Lloyd")==1  & regexm(Residence, "Missouri")==1 )
;

replace full_state29 = 0 if regexm(Residence, "Washington, District of Columbia");

replace full_state30   = 1 if regexm(Residence, "Bozeman")==1 | 
regexm(Residence, "Montana")==1 | regexm(Residence, "MT")==1 | (regexm(Residence, "Mont.")==1 & regexm(Residence, "Montana")!=1 & regexm(Residence, "Monte")!=1 & regexm(Residence, "Montchan")!=1 )| 
regexm(Residence, ", Mt")==1 | (regexm(Residence, "Livingston")==1 & regexm(Residence, "Livingston, N")!=1)
| regexm(Residence, "Missoula")==1 | 
regexm(Residence, "St. Ignatius")==1 
;

replace full_state31  = 1 if regexm(Residence, "Nebraska")==1 |  regexm(Residence, "NE")==1 | 
regexm(Residence, "Omaha")==1 | regexm(Residence, "Neb.")==1 | regexm(Residence, "Nebr.")==1 
| regexm(Residence, ", Neb")==1 
;


replace full_state32   = 1 if regexm(Residence, "Nev.")==1 | regexm(Residence, "Nevada")==1 | 
 regexm(Residence, "NV")==1 |  (regexm(Residence, "Las Vegas")==1 & regexm(Residence, "Las Vegas, Virginia")!=1) | regexm(Residence, "Henderson")==1 | 
 regexm(Residence, "Nev")==1 | regexm(Residence, "Incline Village")==1 | regexm(Residence, "LasVegas")==1 |
 regexm(Residence, "Reno")==1 |  regexm(Residence, "La Vegas")==1
;


replace full_state33  = 1 if regexm(Residence, "New Hampshire")==1 | regexm(Residence, "NH")==1 | 
regexm(Residence, "N.H")==1 | regexm(Residence, "NH")==1  | regexm(Residence, "Hollis")==1 
;


replace full_state34  = 1 if regexm(Residence, "Nj")==1 | 
regexm(Residence, "NJ")==1 | regexm(Residence, "N.J")==1 | 
regexm(Residence, "Bedminster")==1 | regexm(Residence, "New Jersey")==1 | regexm(Residence, "Far Hills")==1 | 
regexm(Residence, "Milburn")==1 | regexm(Residence, "Princeton")==1 | 
 regexm(Residence, "Short Hills")==1 |  regexm(Residence, "Somerset")==1  
;


replace full_state35  = 1 if regexm(Residence, "New Mexico")==1 |  regexm(Residence, "N.M")==1 | 
regexm(Residence, "Nm")==1 | (regexm(Residence, "Santa Fe")==1 & regexm(Residence, "Rancho Santa Fe")!=1 )
 | regexm(Residence, "NM")==1  
;


replace full_state36  = 1 if regexm(Residence, "N.Y")==1 | regexm(Residence, "NYC")==1 |
 regexm(Residence, "New York")==1 | regexm(Residence, "Bedford")==1 | regexm(Residence, "Brooklyn")==1
 | (regexm(Residence, "Buffalo")==1 & regexm(Residence, "Buffalo Grove")!=1 & regexm(Residence, "Dwight & Buffalo")!=1 ) |
 regexm(Residence, "Ny")==1 | regexm(Residence, "Nyc")==1 |
 regexm(Residence, "Croton-on-Hudson")==1 |  regexm(Residence, "East Aurora")==1 |
 regexm(Residence, "East Setauket")==1 |  regexm(Residence, "N YC,")==1 | regexm(Residence, "N.YC")==1 |
  regexm(Residence, "NyC")==1 | regexm(Residence, "Oyster Bay")==1 | (regexm(Residence, "Rye")==1 & regexm(Residence, "Rye, N.H.")!=1 & regexm(Residence, "Rye, New Hampshire")!=1)
  | regexm(Residence, "NY")==1 |
  (regexm(Residence, "Liberty")==1 & regexm(Name, "Gerry")==1) | regexm(Residence, "Long Island")==1 
| regexm(Residence, "Westchester")==1
;


replace full_state37  = 1 if (regexm(Residence, ", N.C")==1 & regexm(Residence, "NYC")!=1)| regexm(Residence, "North Carolina")==1 | 
regexm(Residence, "Nc")==1 | regexm(Residence, "NC")==1 | regexm(Residence, "Cary")==1 | 
(regexm(Residence, "Charlotte")==1 & regexm(Residence, "Charlottesville")!=1 )  | regexm(Residence, "N. Carolina")==1 
| (regexm(Residence, "Greensboro")==1  & regexm(Residence, "Greensboro, V")!=1 )
| regexm(Residence, "Raleigh")==1 | regexm(Residence, "Rose Hill")==1 
;


replace full_state38  = 1 if regexm(Residence, "North Dakota")==1 | regexm(Residence, "ND")==1 | 
regexm(Residence, "N.D")==1  
;


replace full_state39  = 1 if regexm(Residence, "Akron")==1 | regexm(Residence, "Ohio")==1 | 
(regexm(Residence, "Brookville")==1 & regexm(Residence, "Upper Brookville")!=1)
| regexm(Residence, "Chagrin Falls")==1 | 
regexm(Residence, "Cincinnati")==1 | regexm(Residence, "OH")==1 | (regexm(Residence, "Cleveland")==1 & regexm(Residence, "Cleveland, T")!=1) | 
( regexm(Residence, "Columbus")==1 & regexm(Residence, "Columbus, G")!=1  ) | regexm(Residence, "Youngstown")==1  | regexm(Residence, "New Albany")==1 |
(regexm(Residence, "Dayton")==1  & regexm(Residence, "Daytona")!=1)
;


replace full_state40   = 1 if regexm(Residence, "Oklahoma")==1 |  regexm(Residence, "OK")==1 | 
regexm(Residence, "Tulsa")==1 | regexm(Residence, "Okla")==1 | regexm(Residence, ", Ok")==1 | 
regexm(Residence, "Okl.")==1  
;



replace full_state41  = 1 if regexm(Residence, "Oregon")==1 |  
regexm(Residence, "Beaverton")==1 | regexm(Residence, "OR")==1 | regexm(Residence, ", Or")==1 | 
regexm(Residence, ", Ore.")==1 | (regexm(Residence, "Portland")==1  & regexm(Residence, "Me")!=1)
;


replace full_state42   = 1 if regexm(Residence, "PA")==1 |  
regexm(Residence, "Ambler")==1 | regexm(Residence, "Pennsylvania")==1 | 
regexm(Residence, "Blue Bell")==1 | regexm(Residence, "Bryn Athyn")==1 | regexm(Residence, "Bryn Mawr")==1 | 
(regexm(Residence, ", Pa.")==1& regexm(Residence, "Palm")!=1 & regexm(Residence, "Paris")!=1) |
 regexm(Residence, "Chester County")==1 | regexm(Residence, "Wynnewood")==1 | 
regexm(Residence, "Coatesville")==1 | regexm(Residence, "Cochranville")==1 | 
regexm(Residence, "Fox Chapel")==1 | regexm(Residence, "Gladwyne")==1 | 
regexm(Residence, "Haverford")==1 | regexm(Residence, "Huntington Valley")==1 | 
regexm(Residence, "Penn.")==1 |  regexm(Residence, "Penna.")==1 | regexm(Residence, "Philadelphia")==1 | 
(regexm(Residence, "Newton")==1 & regexm(Residence, "P")==1 ) | regexm(Residence, "Pittsburgh")==1 | 
 regexm(Residence, "Paoli")==1 |  regexm(Residence, "Phila")==1 |  regexm(Residence, "Belle Vernon")==1 |  
 regexm(Residence, "Pottsville")==1 |  regexm(Residence, "Newtown Square")==1 |  regexm(Residence, "Ligonier")==1 |
(regexm(Residence, ", Pa")==1 & regexm(Residence, "Palm")!=1 & regexm(Residence, "Paris")!=1) |  regexm(Residence, "Villanova")==1
;


*replace full_state43  = 1 if regexm(Residence, "")==1 | 
*;


replace full_state44  = 1 if regexm(Residence, "Rhode Island")==1 | regexm(Residence, "RI")==1 | 
(regexm(Residence, "Newport")==1 & regexm(Residence, "Newport Beach")!=1 & regexm(Residence, "Newport Coast")!=1 ) | regexm(Residence, "Providence")==1  | regexm(Residence, "Middletown")==1  
;


replace full_state45  = 1 if (regexm(Residence, "W.Va.")!=1 & regexm(Residence, "W. Va.")!=1 &regexm(Residence, "Charleston")==1) | regexm(Residence, "S.C")==1 | 
regexm(Residence, "South Carolina")==1  | regexm(Residence, "SC")==1  
;


replace full_state46  = 1 if regexm(Residence, "South Dakota")==1 | regexm(Residence, "S.D")==1 | 
regexm(Residence, "Dakota Dunes")==1 | regexm(Residence, "SD")==1 | regexm(Residence, "Sioux Falls")==1 
;


replace full_state47  = 1 if regexm(Residence, "Tenn.")==1 | regexm(Residence, "Tennessee")==1 | 
 regexm(Residence, "Chattanooga")==1 |  regexm(Residence, "Tn")==1 |  regexm(Residence, "Lookout Mountain")==1 | 
 regexm(Residence, "TN")==1 |  regexm(Residence, "Memphis")==1 |  regexm(Residence, "Nashville")==1 

;


replace full_state48  = 1 if regexm(Residence, "Tex")==1 | regexm(Residence, "Texas")==1 | 
regexm(Residence, "Austin")==1 | regexm(Residence, "Fort Worth")==1 |
regexm(Residence, "Ft Worth")==1 |  regexm(Residence, "Corpus Christi")==1 | 
regexm(Residence, "Dallas")==1 | regexm(Residence, "TX")==1 | regexm(Residence, "Dllas")==1 | 
(regexm(Residence, "Ft")==1 & regexm(Residence, "Worth")==1) | regexm(Residence, "Houston")==1 | 
regexm(Residence, "San Antonio")==1 | regexm(Residence, "The Woodlands")==1 | 
 regexm(Residence, "Temple")==1 | regexm(Residence, "San Anotonio")==1
;


replace full_state49  = 1 if regexm(Residence, "Utah")==1 | regexm(Residence, ", Ut")==1 |
regexm(Residence, "UT")==1 | regexm(Residence, "Salt Lake City")==1 
;


replace full_state50   = 1 if regexm(Residence, "Vermont")==1 | regexm(Residence, "VT")==1 | 
 regexm(Residence, "Shelburne")==1  | regexm(Residence, "Vt.")==1 
;



replace full_state51  = 1 if regexm(Residence, "Great Falls, Va.")==1 | regexm(Residence, "VA")==1 | 
regexm(Residence, "Arlington")==1 | regexm(Residence, "Charlottesville")==1 |
 (regexm(Residence, "Virginia")==1 & regexm(Residence, "West Virginia")!=1)
 |  regexm(Residence, "McLean")==1 |  regexm(Residence, "Mclean")==1 | 
 regexm(Residence, "Vienna")==1  |  regexm(Residence, "Norfolk, Virgnia")==1 |
 regexm(Residence, "Belspring")==1 |  regexm(Residence, "Fairfax, Va.")==1 |  regexm(Residence, "Middleburg")==1
 |  regexm(Residence, "Norfolk")==1 |  regexm(Residence, "Richmond, V")==1 |  regexm(Residence, "Radford, V")==1
 |  regexm(Residence, "The Plains, V")==1  |  regexm(Residence, "Upperville, V")==1 |  regexm(Residence, "Va. Beach, Va.")==1
 |  regexm(Residence, "Alexandria, Va")==1
; 


*replace full_state52   = 1 if regexm(Residence, "")==1 | 
*;


replace full_state53  = 1 if (regexm(Residence, "Camas")==1 | (regexm(Residence, "Wash.")==1 & regexm(Residence, "Port Wash.")!=1 )| 
regexm(Residence, "Hunts Point")==1 | regexm(Residence, "Medina")==1 | regexm(Residence, "Mercer Island")==1 | 
regexm(Residence, "San Juan Islands")==1 | regexm(Residence, "WA")==1 | regexm(Residence, "Seattle")==1 | 
regexm(Residence, "Spokane")==1 | regexm(Residence, "Tacoma")==1 |  regexm(Residence, "Wash. State")==1 
|  regexm(Residence, "Redmond")==1) & (regexm(Residence, "D.C")!=1 & regexm(Residence, "District")!=1) 
;

replace full_state53 = 0 if regexm(Residence, "Washington, DC") == 1;
replace full_state53 = 0 if regexm(Residence, "Washington, Dc") == 1;


replace full_state54  = 1 if regexm(Residence, "West Virginia")==1 | regexm(Residence, "W. Va.")==1 | 
regexm(Residence, "W.Va.")==1 | regexm(Residence, "Wv")==1 
;


replace full_state55  = 1 if regexm(Residence, "Afton")==1 | regexm(Residence, "WI")==1 | 
regexm(Residence, "Beloit, W")==1 | regexm(Residence, "Birchwood")==1 |  regexm(Residence, "Wisconsin")==1 |  
regexm(Residence, "Brookfield")==1 |  regexm(Residence, "Eau Claire")==1 |   regexm(Residence, "Wis.")==1 |
  regexm(Residence, "Green Bay")==1 | regexm(Residence, "Kohler")==1 | regexm(Residence, "Madison")==1 |
  regexm(Residence, "Menomonee Falls")==1 |  regexm(Residence, "Milwaukee")==1 |   regexm(Residence, ", Wi")==1 |
  regexm(Residence, "Racine")==1 
;


replace full_state56  = 1 if regexm(Residence, "Wyoming")==1 | regexm(Residence, ", Wy")==1 | 
regexm(Residence, "Big Horn")==1 | regexm(Residence, "Wyo")==1 |  regexm(Residence, "Sheridan")==1 |
(regexm(Residence, "Jackson")==1 & regexm(Name, "Walton")==1) | (regexm(Residence, "Jackson")==1 & regexm(Name, "Ricketts")==1)
;



replace full_state100  = 1 if regexm(Residence, "Zug")==1 | 
regexm(Residence, "Australia")==1 |  regexm(Residence, "Bahamas")==1 | regexm(Residence, "England")
| regexm(Residence, "Europe") | (regexm(Residence, "Geneva")==1 &  regexm(Residence, "Lake Geneva")!=1 )
| regexm(Residence, "Gibraltar")==1
 | regexm(Residence, "Hamilton")==1  | regexm(Residence, "Bermuda")==1  | regexm(Residence, "Haton")==1
 | regexm(Residence, "Hong Kong")==1 | regexm(Residence, "Jerusalem")==1 | regexm(Residence, "Moscow")==1
 | regexm(Residence, "London")==1 | regexm(Residence, "United Kingdom")==1 | regexm(Residence, "Meggan")==1
| regexm(Residence, "Russia")==1 | regexm(Residence, "Monaco")==1 | regexm(Residence, "Monte Carlo")==1
| regexm(Residence, "China")==1 | regexm(Residence, "Nanjin")==1 | regexm(Residence, "Italy")==1
| regexm(Residence, "Scattered")==1 | regexm(Residence, "Scone")==1 | 
(regexm(Residence, "San Juan")==1 & regexm(Residence, "San Juan Islands")!=1 & regexm(Residence, "San Juan Capistrano")!=1)
| regexm(Residence, "Puerto Rico")==1 | regexm(Residence, "P.R")==1 | regexm(Residence, "Singapore")==1
| regexm(Residence, "Tel Aviv")==1 | regexm(Residence, "Israel")==1 | regexm(Residence, "Unknown")==1
| regexm(Residence, "United States")==1 | regexm(Residence, "unknown")==1 | regexm(Residence, "Switzerland")==1
| Residence== "x." | regexm(Residence, "VI")==1 | regexm(Residence, "Saipan")==1 | regexm(Residence, "Poland")==1 |
regexm(Residence, "Point Abino")==1 | regexm(Residence, "N/A")==1 | 
(regexm(Residence, "Na")==1 & regexm(Residence, "Nash")!=1 & regexm(Residence, "Nap")!=1)
 | regexm(Residence, "■")==1
| regexm(Residence, "U.S. Virgin Islands")==1 | regexm(Residence, "Caribbean")==1 | regexm(Residence, "Meggen")==1 
;


#delimit cr;

egen test = rowtotal(full_state01-full_state100)
tab Residence if test==0
drop if Name=="."
save "./data/stata_data/forbes400_DW_EM_wide.dta", replace
use "./data/stata_data/forbes400_DW_EM_wide.dta", clear

forvalues i = 1(1)3{
g statefips`i' = .
}
forvalues j = 1(1)3{
	forvalues i = 1(1)9{
	replace statefips`j' = `i' if statefips`j'==. & full_state0`i'==1
	replace full_state0`i' = 0 if statefips`j' == `i'
	}
	forvalues i = 10(1)56{
	replace statefips`j' = `i' if statefips`j'==. & full_state`i'==1
	replace full_state`i' = 0 if statefips`j' == `i'
	}
	forvalues i = 100(1)100{
	replace statefips`j' = `i' if statefips`j'==. & full_state`i'==1
	replace full_state`i' = 0 if statefips`j' == `i'
	}
}
*drop full_state* place sec sec2 test city state st_name
drop full_state* sec sec2 test city state st_name
drop if Name==""
save "./data/stata_data/forbes400_DW_EM_long.dta", replace

