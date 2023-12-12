/*
RAs: 			Nathaniel Barlow, Annemarie Schweinert,Amber Flaharty, and Nicole Trachman
Economists: 	Enrico Moretti and Dan Wilson
*/

clear all
set more off
cap log close
version 14
pause on

/// CHANGE ROOT DIRECTORY BELOW TO THE DIRECTORY WHERE THE "REPLICATIONPACKAGE" FOLDER IS STORED:
global root = "../../ReplicationPackage"

local programloc "$root/data/programs/"
local analysisloc "$root/programs/"

cd "$root/data"

set haverdir c:/DLX/DATA   //need to change to whereever you're haver DLX directory is.

*Needed to call fred through firewall
*set httpproxyhost l1proxy.frb.org //if using FRED
*set httpproxyport 8080 //if using FRED
*set httpproxy on  //if using FRED

/*
foreach var in egenmore winsor winsor2 reghdfe estout xtivreg2 ivreg2 binscatter gtools maptile spmap outtable tabout{
ssc install `var', replace
}
**Install maptile template**
maptile_install using "http://files.michaelstepner.com/geo_state.zip"
*/


/******STEP 0
We pull in the Forbes 400 list through the Wayback machine, the Forbes website,
Lexis/Nexis, and OCR'd copies from UC-Berkeley and the Boston Fed

Input: Webpages/PDFs
Output: ./data/raw_data/top400.xlsx
*******/

/******STEP 1
Pulls in the initial spreadsheet and does some initial formatting.
Some years are comma delimited, some are already space delimited, some are
long strings that we parse through by finding special characters

Input: ./data/raw_data/top400.xlsx
Output: ./data/stata_data/FORBES_1982_2017.dta
**************************************************************************/
do "`programloc'import_forbes400.do"


/******STEP 2
Pulls in the data set from step one and goes through the names to construct
consistent individual names throughout. For individuals with families, there
is a family variable indicating if "And Family" is attached.

Input: ./data/stata_data/FORBES_1982_2017.dta
Output: ./data/stata_data/FORBES_1982_2017_partially_cleaned.dta
Previous versions: 
do ./clean_forbes_names.do
**************************************************************************/
do "`programloc'clean_forbes_names_new.do"


/******STEP 3
Pulls in the data set with the cleaned names and constructs a consistent
state fips indicator. Individuals have at most 3 states indicated. 
Statefips1-3 go alphabetically in the end. If a state is out of the country
 or invalid, the statefips variable is set to 100.

Input: ./data/stata_data/FORBES_1982_2017_partially_cleaned.dta
Output:  ./data/stata_data/forbes400_DW_EM_long.dta AND  ./data/stata_data/forbes400_DW_EM_wide.dta
Previous versions: 
**************************************************************************/
do "`programloc'clean_forbes_locations.do"


/******STEP 4
Takes Gazetteer file for places and merges to file for crosswalk.
First matches on GEOID. If no initial match, then matches on statefips
and string.

Input: ./Forbes_400_locality ./data/raw_data/MAGGOT_geocorr14.csv
Output:   data/stata_data/temp_crosswalk_for_CDPv4.dta
**************************************************************************/
do "`programloc'geoid_placefp3.do"


/******STEP 5
Pulls in the long data set from step 3 and works on matching location names
with gazetteer files (https://www.census.gov/geo/maps-data/data/gazetteer2017.html)
The current gazetteer file is the places gazetteer file with about 88%
of potential places matched.

There is a separate file at the end of this where we manually investigate
places that did not match to see if they were invalid matches based on 
reshaping in step 3 or if the places are unicorporated localities. 

ADDED SOURCE OF WEATLTH, NETWORTH, AND RANK ON 7/9/18

NOTE: CHANGED THE GAZETTEER FILE ON 7.9.18 TO 2010 GAZETTEER FOR CROSSWALK
IN FILE 5
Input: ./data/stata_data/forbes400_DW_EM_long.dta, "./fips_codes.xlsx" , ./data/stata_data/temp_crosswalk_for_CDPv4.dta
Output:  ./data/stata_data/Forbes_400_locality_data_CDP.dta
**************************************************************************/
do "`programloc'clean_forbes_cities_with_CDP_gazetter_and_crosswalk4.do"

/******STEP 6
Description: File reads in locations and names from the Forbes 400. Merges
with state populations, median earnings in each state, and state gpd from Haver.

Inputs:  "./data/raw_data/fips_codes.xlsx", Haver codes, ./data/stata_data/forbes400_DW_EM_long.dta,
		./data/stata_data/taxrates_p50_p95_p99_p999.dta,
Output:  ./forbes400_DW_EM_pop.dta
**************************************************************************/
do "`programloc'merge_state_pop_locality_data.do"


/******STEP 9
Description: File cleans net worth, converting it to consistent million dollar units
for each entry. A rank variable, ourRank, is also generated based off of the net worth of each
person. 

Input: ./data/stata_data/Forbes_400_locality_data_CDPv2.dta
Output: ./data/stata_data/Forbes_400_net_worth_and_rank_cleaned2.dta
*/
do "`programloc'clean_net_worth_and_rank2.do"


/******STEP 10
Description: Constructs variable our_wealthy by assigning 2(inheritor) based on certain rules, such as inheritance 
being matched in the source or wealth. The Forbes data is then matched with the 2011 Kaplan and Rauh data. Note these data end up NOT being used in any of the analyses.

Input: ./data/raw_data/KaplanRauh.xlsx
       ./data/stata_data/Forbes_400_net_worth_and_rank_cleaned2.dta
Output: ./data/stata_data/KaplanRauh.dta
		./stata_data/Kaplan_and_Rauh_merged.dta
*/
do "`programloc'wealth_indicator.do"

/******STEP 11
Description: Constructs data set with yearly population by state and city.

Input:  ./raw_data/fips_haver_county_codes.xls
Output: ./stata_data/pop_merged_crosswalk.dta
*/
do "`programloc'create_pop.do"


/******STEP 12
Description: Merge in data on state personal income tax rates, from NBER TaxSim, used in Moretti and Wilson (2017 AER)
Input: 	./data/stata_data/Kaplan_and_Rauh_merged.dta
				./stata_data/pop_merged_crosswalk.dta
Output: ./data/stata_data/Tax_Rate_Merged_2.dta
*/
do "`programloc'Merge_Tax_Data_85_95_05.do"


/******STEP 13
Description: Merge in data on state corporate income tax rates from Moretti and Wilson (2017 AER) and data on state tax revenues from Census Bureau (Annual Survey of State Tax Collections)
Input: 	./data/stata_data/Tax_Rate_Merged_2.dta
				./data/raw_data/EstateTaxes/STC_Historical_DB (2017).xls
Output: ./data/stata_data/EI_Tax_Merged.dta
*/
do "`programloc'Merge_taxes.do"


/******STEP 14
Description: Fixes incorrect names to make consistent panel data
Input: ./data/stata_data/EI_Tax_Merged.dta
Output: ./data/stata_data/EI_Tax_Merged_v2.dta
*/
do "`programloc'Inconsistent_Name_Check.do" 


******RUN FINAL ANALYSIS PROGRAM
** Input: ./data/stata_data/EI_Tax_Merged_v2.dta
do "`analysisloc'analysis.do"
