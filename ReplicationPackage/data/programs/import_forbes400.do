clear all
set more off
cap log close
version 14
pause on

if "$root" == "" global root = "c:/Users/l1djw01/Dropbox (FRB SF)/Paper - Forbes"

cd "$root/data"
*cd "C:\Users\Annemarie\Documents\Forbes_400"


*SPECIAL CASE FOR 2012
import excel "./raw_data/top400.xlsx", sheet("2012nexis") clear
g year = 2012
g r = subinstr(substr(A, 1, 3), ".", "", .)
drop if A==""
destring r, g(m) force
g ind = 0
replace ind = 1 if m!=.
g Name = A if ind==1
g NetWorth = "."
g Source = "."
g Age = "."
g Extra = "."
g Num = .
replace Num = m if ind==1
forvalues k = 1(1)10{
	replace Num = m[_n-`k'] if Num==. & ind==0
}

replace NetWorth = A[_n+1] if ind==1
replace Source = A[_n+2] if ind==1
replace Age = A[_n+3] if ind==1
replace Extra = A[_n+4] if ind==1
drop if m ==.
replace Name = substr(A,5,.)
replace Source = substr(Source, 9,.)
gen Residence = regexr(Age,".*[0-9] [Rr]","")
replace Residence = substr(Residence,11,.)
replace Age = regexr(Age,"Residence.*","")
replace Age = regexr(Age,"residence.*","")
replace Age = regexr(Age,"RESIDENCE.*","")
replace Age = regexr(Age,"Age: ","")
replace Age = regexr(Age,"Age : ","")
replace Age = regexr(Age,"AGE: ","")

drop A Extra ind Num r
rename m Rank
keep if Rank>=100
save "./stata_data/2012_part2.dta", replace

*OK Code below
*CODES FOR 2011-2017
forvalues i = 2011(1)2017{
	import excel "./raw_data/top400.xlsx", sheet("`i'") firstrow clear
	g year = `i'
	if `i'>2012{
		rename Rank r
		g Rank = subinstr(r, "#", "", .)
		destring Rank, replace
		drop r
	}
	cap rename Forbes400 NetWorth
	cap rename RealTime NetWorth
	drop if Rank==.
	tempfile `i'
	save ``i''
	*save "./stata_data/`i'.dta", replace
}
forvalues i = 2011(1)2016{
  append using ``i''
	*append using "./stata_data/`i'.dta"
}
drop if year==2012 & Rank==100
append using "./stata_data/2012_part2.dta"
rename Source s
g Source = strproper(subinstr( s, "Source of wealth:", "",.))
drop s
rename NetWorth nw
g NetWorth = strproper(subinstr(subinstr(nw, "Net Worth:", "", .), "billion", "B", .))
replace Residence = strproper(Residence)
foreach txt in Sr Jr II III{
	replace Name = subinstr(Name, ",", "", .) if regexm(Name, "`txt'")==1
	replace Name = subinstr(Name, ".", "", .) if regexm(Name, "`txt'.")==1
}
replace Name = "Gwendolyn Sontheim Meyer" if regexm(Name, "GwendolynSontheim Meyer")==1
replace Name = "Jeffrey Hildebrand " if regexm(Name, "Jeffery Hildebrand ")==1

*FIGURE OUT HOW TO HANDLE JOHN A. SOBRATO VS JOHN A. SOBRATO & FAMILY
*ADD RUPERT MURDOCH AND FAMILY TO THIS SITUATION; RICHARD LEFRACK; MIN KAO; 
*MICHAEL&MARIAN iLITICH, MARTHA INGRAM, MANUAL MORON
*CHECK ON STEPHEN BECHTEL, RUPERT JOHNSON
drop nw
save "./stata_data/ForbesTop4002011_2017.dta", replace


*2010
import excel "./raw_data/top400.xlsx", sheet("2010") clear
g year = 2010
g r = subinstr(substr(A, 1, 3), ".", "", .)
drop if A==""
destring r, g(m) force
g ind = 0
replace ind = 1 if m!=.
g Name = A if ind==1
g NetWorth = "."
g Source = "."
g Age = "."
forvalues i = 1(1)5{
g Extra`i' = "."
}


g Num = .
g Residence = "."
replace Num = m if ind==1
forvalues k = 1(1)10{
	replace Num = m[_n-`k'] if Num==. & ind==0
}
replace A = strproper(A)
replace NetWorth = A[_n+1] if ind==1 & regexm(A[_n+1], "Worth")==1 & ind[_n+1]!=1
replace Source = A[_n+2] if ind==1 & regexm(A[_n+2], "Source")==1 & ind[_n+2]!=1 & ind[_n+1]!=1
replace Age = A[_n+3] if ind==1 & regexm(A[_n+3], "Age")==1 & ind[_n+2]!=1 & ind[_n+1]!=1 & ind[_n+3]!=1
*replace Extra = A[_n+5] if ind==1 & ind[_n+2]!=1 & ind[_n+1]!=1 & ind[_n+3]!=1  & ind[_n+4]!=1  & ind[_n+5]!=1 
replace Residence = A[_n+4] if ind==1 & regexm(A[_n+4], "Residence")==1 &  ind[_n+2]!=1 & ind[_n+1]!=1 & ind[_n+3]!=1  & ind[_n+4]!=1 
replace Residence = A[_n+4] if ind==1 & regexm(A, "Jess Jackson")& regexm(A[_n+4], "Hometown")==1 &  ind[_n+2]!=1 & ind[_n+1]!=1 & ind[_n+3]!=1  & ind[_n+4]!=1 

*Sources not picked up
replace Source = "food distributor" if ind==1 & (regexm(Name, "Jude Reyes")==1 | regexm(Name, "Christopher Reyes")==1)
replace Source = "inheritance" if ind==1 & (regexm(Name, "Austen Cargill")==1 | regexm(Name, "James Cargill")==1 | regexm(Name, "Barbara Piasecka Johnson")==1 | regexm(Name, "Hearst")==1 )

replace Age = A[_n+2] if ind==1 & regexm(A[_n+2], "Age")==1 & ind[_n+2]!=1 & ind[_n+1]!=1 &  Age=="."
*replace Extra = A[_n+5] if ind==1 & ind[_n+2]!=1 & ind[_n+1]!=1 & ind[_n+3]!=1  & ind[_n+4]!=1  & ind[_n+5]!=1 
replace Residence = A[_n+3] if ind==1 & regexm(A[_n+3], "Residence")==1 &  ind[_n+2]!=1 & ind[_n+1]!=1 & ind[_n+3]!=1  & Residence=="."

g Education = "."
replace Education = A[_n+5] if ind==1 & regexm(A[_n+5], "Education")==1 &  ind[_n+2]!=1 & ind[_n+1]!=1 & ind[_n+3]!=1  & ind[_n+4]!=1 & ind[_n+5]!=1 
replace Extra1 = A[_n+6] if ind==1 & ind[_n+6]!=1 & ind[_n+5]!=1
replace Extra2 = A[_n+7] if ind==1 & ind[_n+5]!=1 & ind[_n+6]!=1 & ind[_n+7]!=1
replace Extra3 = A[_n+8] if ind==1 & ind[_n+5]!=1 & ind[_n+6]!=1 & ind[_n+7]!=1 & ind[_n+8]!=1
replace Extra4 = A[_n+9] if ind==1 & ind[_n+5]!=1 & ind[_n+6]!=1 & ind[_n+7]!=1 & ind[_n+8]!=1 & ind[_n+9]!=1
replace Extra5 = A[_n+10] if ind==1 & ind[_n+5]!=1 & ind[_n+6]!=1 & ind[_n+7]!=1 & ind[_n+8]!=1 & ind[_n+9]!=1 & ind[_n+10]!=1

forvalues i = 1(1)3{
replace Education = Extra`i' if regexm(Extra`i', "Education:")==1 & Education=="." 
}
drop if m ==.
rename Age Extra6
g Age = subinstr(subinstr(substr(Extra6, 1, strpos(Extra6, ".")), "Age:", "", .), ".", "", .) 
g Married = substr(Extra6, strpos(Extra6, ".")+1, strpos(Extra6, ",")-strpos(Extra6, ".")-1)
replace Married = substr(Extra6, strpos(Extra6, ".")+1, strlen(Extra6)-strpos(Extra6, ".")) if regexm(Extra6, ",")!=1  & (regexm(Extra6,"Mar")==1 | regexm(Extra6,"Sep")==1 | regexm(Extra6,"Div")==1 | regexm(Extra6,"Sing")==1 | regexm(Extra6,"Wid")==1 ) 
g Kids = subinstr(subinstr(substr(Extra6, strpos(Extra6, ",")+1,strlen(Extra6)-strpos(Extra6, ",")+1), ".", "", .),"Kids", "Children",.) if regexm(Extra6, ",")==1
replace Education = subinstr(Education, "Education:", "", .)
replace Source = subinstr(Source,"Source:", "", .)
replace Residence = subinstr(subinstr(Residence, "Residence:", "", .), "Hometown:", "", .)
replace NetWorth = subinstr(NetWorth, "Worth:", "", .)
rename Name n
g Name = substr(n,strpos(n, ".")+1, strlen(n)-strpos(n, ".")+1)
rename m Rank
drop Extr*

keep year Name Rank NetWorth Source Residence Married Age Kids Education
order year Rank Name NetWorth Age Residence Source Married Kids Education
tempfile 2010
save `2010'



*2009
foreach val in 2009 2005{
import excel "./raw_data/top400.xlsx", sheet("`val'") clear
g year = `val'
rename A Rank
rename B Name
g temp = C/1000
tostring temp, replace force
g NetWorth = temp + "Billion"
rename D Age
rename E Residence
rename F Source

keep year Rank Name NetWorth Age Residence Source

tempfile `val'
save ``val''
}

use `2005', clear
g lastname = strtrim(substr(Name, 1, strpos(Name, ",")-1))
g firstname = strtrim(substr(Name, strpos(Name, ",")+1, strlen(Name)))
replace firstname = substr(firstname, 1, strlen(firstname)-1) if strpos(firstname, ".")==strlen(firstname)
drop Name
g Name = strtrim(firstname) + " " + strtrim(lastname)
tempfile 2005
save `2005'

forvalues i = 2006(1)2008{
import excel "./raw_data/top400.xlsx", sheet("`i'") clear
g year = `i'
rename A Rank
rename B Name
tostring C, gen(temp)
g NetWorth = temp + "Billion"
rename D Age
rename E Residence
rename F Source

keep year Rank Name NetWorth Age Residence Source

tempfile `i'
save ``i''
*save "./stata_data/`i'.dta", replace
}

*2004 is its own
import excel "./raw_data/top400.xlsx", sheet("2004") clear
g year = 2004

g Rank = substr(A, 1, strpos(A, ".")-1)

g lastname = substr(A, strpos(A, ".")+1, strpos(A,",")-strpos(A, ".")-1)
g temp = substr(A, strpos(A,",")+1, strlen(A)-strpos(A,",") )
g firstname = substr(temp, 1, strpos(temp,",")-1)
g Name = strtrim(firstname) + " " + strtrim(lastname)

g Suffix = ""
foreach txt in Sr Jr II III{
replace Suffix = "`txt'" if Suffix =="" & regexm(Name, "`txt'")==1
replace Name = subinstr(Name, "`txt',", "", .) if regexm(Name, "`txt'")==1
replace Name = subinstr(Name, "`txt'.", "", .) if regexm(Name, "`txt'.")==1
}

replace Name = strtrim(Name) + " " + Suffix
replace Name = strtrim(Name)
g temp2 = substr(temp, strpos(temp,",")+1, strlen(A)-strpos(temp,",") )
g Age = substr(temp2, 1, strpos(temp2, "$")-3)
g temp3 = substr(temp2, strpos(temp2, "$"), strlen(temp2)-strpos(temp2, "$")+1)
g nw = substr(temp3, 1, strpos(temp3, ",")-1)
g temp_nw = substr(nw, strpos(nw, "$")+1, strpos(nw, "m")-strpos(nw, "$")-1)
destring temp_nw, replace
replace temp_nw = temp_nw/1000

rename temp_nw ttemp_nw

g tttemp_nw = round(ttemp_nw, .001)

tostring tttemp_nw, gen(temp_nw) force

replace temp_nw = "$0"+ strtrim(temp_nw) + " billion" if temp_nw!="" & temp_nw!=" " & ttemp_nw!=.
g NetWorth = temp_nw if temp_nw!="" & temp_nw!=" " & ttemp_nw!=.
replace NetWorth = nw if temp_nw!="" & temp_nw!=" " & ttemp_nw==.
drop *nw

g temp4 = substr(temp3, strpos(temp3, ",")+1, strlen(temp3)-strpos(temp3, ",")+2)
g city = strtrim(substr(temp4, 1, strpos(temp4, ",")-1))

g temp5 = substr(temp4, strpos(temp4, ",")+1, strlen(temp4)-strpos(temp4, ",")+2)
g temp_state_adj = subinstr(temp5, ".,", " ...STOP... ,", .)
g temp_state = substr(temp_state_adj, 1, strpos(temp_state_adj, ",")) if regexm(temp5, ",")==1 & (regexm(temp_state_adj, "Bermuda")==1 | regexm(temp_state_adj, " ...STOP...")==1 | regexm(temp_state_adj, "Monaco")==1 | regexm(temp_state_adj, "Switzerland")==1|   regexm(temp_state_adj, "Idaho")==1 |  regexm(temp_state_adj, "Ohio")==1 |  regexm(temp_state_adj, "Texas")==1 )
replace temp_state = strtrim(temp_state)
g state = subinstr(subinstr(temp_state, " ...STOP...", "", .), ",", "", .)
g Residence = strtrim(city)+ ", "+ state if state!=""
replace Residence = strtrim(city) if Residence=="" | Residence =="."
g Source = substr(temp_state_adj, strpos(temp_state_adj, " ...STOP... ,")+14, strlen(temp_state_adj)-strpos(temp_state_adj, " ...STOP... ,") + 13 ) if regexm(temp_state_adj, " ...STOP... ,")==1
replace Source = substr(temp_state_adj, strpos(temp_state_adj, ",")+1, strlen(temp_state_adj)-strpos(temp_state_adj, ",")+1) if regexm(temp_state_adj, ",")==1 & (regexm(temp_state_adj, "Bermuda")==1 | regexm(temp_state_adj, "Monaco")==1 | regexm(temp_state_adj, "Switzerland")==1|  regexm(temp_state_adj, "Idaho")==1 |  regexm(temp_state_adj, "Ohio")==1 |  regexm(temp_state_adj, "Texas")==1 )
replace Source = temp5 if Source=="" | Source=="."
drop if Rank=="."
keep year Rank Name NetWorth Age Residence Source city state firstname lastname Suffix

tempfile 2004
save `2004'
*save "./stata_data/2004.dta", replace


*2001*
import excel "./raw_data/top400.xlsx", sheet("2001") clear

g year = 2001
egen c_info = noccur(A), string(",")
drop if c_info==0

*STANDARD VARIABLES
*NEED TO CLEAN UP NETWORTH
g Rank = substr(A, 1, strpos(A, ",")-1)
rename A t
g A = substr(t,strpos(t, ",")+1, strlen(t)-strpos(t, ",")+1)
g lastname = substr(A, 1, strpos(A,",")-1)
g temp = substr(A, strpos(A,",")+1, strlen(A)-strpos(A,",") )
g firstname = substr(temp, 1, strpos(temp,",")-1)
g temp2 = substr(temp, strpos(temp,",")+1, strlen(A)-strpos(temp,",") )
g Name = strtrim(firstname) + " " + strtrim(lastname)

g Suffix = ""
foreach txt in Sr Jr II III{
replace Suffix = "`txt'" if Suffix =="" & regexm(Name, "`txt'")==1
replace Name = subinstr(Name, "`txt',", "", .) if regexm(Name, "`txt'")==1
replace Name = subinstr(Name, "`txt'.", "", .) if regexm(Name, "`txt'.")==1
}


g NetWorth = substr(temp2, strpos(temp2, "$"), strlen(temp2)-strpos(temp2, "$")+2)
g temp3 = substr(temp2,1, strpos(temp2, "$")-3)

drop c_info
egen c_info = noccur(temp3), string(",")


g name_2 = substr(temp3, 1, strpos(temp3,",")-1) if c_info==2
replace name_2 = substr(temp3, 1, strpos(temp3,",")-1) if c_info==1 & (regexm(temp3, "III")==1 | regexm(temp3, "Jr.")==1 | regexm(temp3, "Sr.")==1| regexm(temp3, "(Ted)")==1 | regexm(temp3, "II")==1 | regexm(temp3, "Ty")==1   )

g temp4 = strtrim(subinstr(temp3, name_2, "", .)) if (c_info==2) | (c_info==1 & (regexm(temp3, "III")==1 | regexm(temp3, "Jr.")==1 | regexm(temp3, "Sr.")==1| regexm(temp3, "(Ted)")==1 | regexm(temp3, "II")==1 | regexm(temp3, "Ty")==1))
replace temp4 = temp3 if c_info!=2 & ((c_info==1 & (regexm(temp3, "III")==1 | regexm(temp3, "Jr.")==1 | regexm(temp3, "Sr.")==1| regexm(temp3, "(Ted)")==1 | regexm(temp3, "II")==1 | regexm(temp3, "Ty")==1)))!=1
replace Name = Name + " "+ strtrim(name_2) if name_2!=""

g Residence = substr(temp4, strpos(temp4, ",")+1, strlen(temp4)- strpos(temp4, ",")+1 ) if strpos(temp4, ",")==1
replace Residence = temp4 if strpos(temp4, ",")!=1
replace Residence = strtrim(Residence)

keep year Rank Name NetWorth Residence lastname firstname 
tempfile 2001
save `2001'
*save "./stata_data/2001.dta", replace


*1999*
import excel "./raw_data/top400.xlsx", sheet("1999") clear

g year = 1999
egen c_info = noccur(A), string(",")
drop if c_info==0

*STANDARD VARIABLES*
g Rank = substr(A, 1, strpos(A, ".")-1)
rename A t
g A = substr(t,strpos(t, ".")+1, strlen(t)-strpos(t, ".")+1)
g lastname = substr(A, 1, strpos(A,",")-1)
g temp = substr(A, strpos(A,",")+1, strlen(A)-strpos(A,",") )
g firstname = substr(temp, 1, strpos(temp,",")-1)
g suffix = ""
foreach var in III Jr Sr{

replace suffix = "`var'" if (regexm(firstname, "`var'")==1)==1

}
replace suffix = "II" if (regexm(firstname, "II")==1 & regexm(firstname, "III")!=1)==1
replace suffix = "(Ted)" if regexm(firstname, "(Ted)")==1 
rename firstname t_f
g firstname = t_f if suffix==""
replace firstname = substr(t_f,1, strpos(t_f, suffix)-1) if suffix!=""

g mi = ""

g temp2 = substr(temp, strpos(temp,",")+1, strlen(temp)-strpos(temp,",") )
replace mi = substr(temp2, 1, strpos(temp2,",")-1 ) if c_info==6
replace firstname = firstname + " " + mi
replace firstname = strtrim(firstname)
replace temp2 = substr(temp2, strpos(temp2,",")+1, strlen(temp2)-strpos(temp2,",")  ) if c_info==6
g Name = strtrim(firstname) + " " + strtrim(lastname) + " "+suffix
replace Name = strtrim(Name)

g Age = substr(temp2,1,strpos(temp2, ",")-1)
g temp3 = substr(temp2,strpos(temp2, ",")+1, strlen(temp2)- strpos(temp2, ",")+1)

g temp3_help = strreverse(temp3)
g temp3_num = (strpos(temp3_help, ","))*(-1)

*NEED TO CLEAN TO BE AN INTEGER. PLUS BILLIONS VS MILLIONS PROBELM*
g NetWorth = substr(temp3, temp3_num+2, (-1)*temp3_num)

g Residence = substr(temp3, 1, strlen(temp3)+temp3_num )

keep year Rank Age Name NetWorth Residence firstname lastname suffix
tempfile 1999
save `1999'
*save "./stata_data/1999.dta", replace

*1995, 1996, 1997, 1998
forvalues i = 1995(1)1998{

*1999*
import excel "./raw_data/top400.xlsx", sheet("`i'") clear

g year = `i'
egen c_info = noccur(A), string(",")
drop if c_info==0

*STANDARD VARIABLES*
g Rank = substr(A, 1, strpos(A, ".")-1)
rename A t
g A = substr(t,strpos(t, ".")+1, strlen(t)-strpos(t, ".")+1)
g lastname = substr(A, 1, strpos(A,",")-1)
g temp = substr(A, strpos(A,",")+1, strlen(A)-strpos(A,",") )
g firstname = substr(temp, 1, strpos(temp,",")-1)
g suffix = ""
foreach var in III Jr Sr{

replace suffix = "`var'" if (regexm(firstname, "`var'")==1)==1

}
replace suffix = "II" if (regexm(firstname, "II")==1 & regexm(firstname, "III")!=1)==1

replace suffix = "(J. Paul Jr.)" if regexm(firstname, "(J. Paul Jr.)")==1
foreach nickname in Ted Doc Hank{
replace suffix = "(`nickname')" if regexm(firstname, "(`nickname')")==1
}

g suffix2 = ""
replace suffix2 = "family" if regexm(firstname, "family")==1

rename firstname t_f
g firstname = t_f if suffix==""
replace firstname = substr(t_f,1, strpos(t_f, suffix2)-1) if suffix2!=""
replace firstname = substr(t_f,1, strpos(t_f, suffix)-1) if suffix!=""

g temp2 = substr(temp, strpos(temp,",")+1, strlen(temp)-strpos(temp,",") )
replace firstname = strtrim(firstname)

replace suffix = "T. Jr.," if regexm(temp2, "T. Jr.,")==1
g te_2 = substr(temp2, strpos(temp2,",")+1, strlen(temp2)-strpos(temp2,",") )
replace firstname = firstname + te_2 if regexm(temp2, "T. Jr.")==1
replace firstname = strtrim(firstname)

replace temp2 = te_2 if regexm(temp2, "T. Jr.,")==1
drop te_2

replace suffix = "M." if regexm(temp2, "M., Edina")==1
g te_2 = substr(temp2, strpos(temp2,",")+1, strlen(temp2)-strpos(temp2,",") )
replace temp2 = te_2 if regexm(temp2, "M., Edina")==1

replace firstname = firstname + te_2 if regexm(temp2, "M., Edina")==1
replace firstname = strtrim(firstname)

replace temp2 = substr(temp2, strpos(temp2,",")+1, strlen(temp2)-strpos(temp2,",")  ) if c_info==6
g Name = strtrim(firstname) + " " + strtrim(lastname) + " "+suffix
replace Name = strtrim(Name)


g temp3 = substr(temp2,1, strlen(temp2))

g temp3_help = strreverse(temp3)
g temp3_num = (strpos(temp3_help, "$"))*(-1)

*NEED TO CLEAN TO BE AN INTEGER. PLUS BILLIONS VS MILLIONS PROBELM*
g NetWorth = substr(temp3, temp3_num+2, (-1)*temp3_num)

g Residence = substr(temp3, 1, strlen(temp3)+temp3_num-2)

keep year Rank Name NetWorth Residence firstname lastname suffix
tempfile `i'
save ``i''
*save "./stata_data/`i'.dta", replace
}
forvalues i = 1989(1)1994{
import excel "./raw_data/top400.xlsx", sheet("`i'") clear
rename A Name
rename B NetWorth
rename C year
tempfile `i'
save ``i''
*save "./stata_data/`i'.dta", replace
}
forvalues i = 1988(1)1988{
import excel "./raw_data/top400.xlsx", sheet("`i'") clear
drop if A=="." | A==""
rename A Name2
rename B NetWorth
rename C Residence
rename D Source
rename E Age

g Rank = substr(Name,1 , strpos(Name, ")")-1)
g Name = substr(Name2, strpos(Name2, ")")+1, strlen(Name2)-strpos(Name2, ")"))
drop Name2
destring Rank, replace
g year = "`i'"
tempfile `i'
save ``i''
*save "./stata_data/`i'.dta", replace
}

forvalues i = 1987(1)1987{
import excel "./raw_data/top400.xlsx", sheet("`i'") clear
drop if A=="." | A==""

g year = `i'
egen c_info = noccur(A), string(",")
drop if c_info==0

*STANDARD VARIABLES
*NEED TO CLEAN UP NETWORTH
g Rank = substr(A, 1, strpos(A, "-")-1)
rename A t
g A = substr(t,strpos(t, "--")+2, strlen(t)-strpos(t, "--")+2)
g lastname = substr(A, 1, strpos(A,",")-1)
g temp = substr(A, strpos(A,",")+1, strlen(A)-strpos(A,",") )
g firstname = substr(temp, 1, strpos(temp,",")-1)
g temp2 = substr(temp, strpos(temp,",")+1, strlen(A)-strpos(temp,",") )
g Name = strtrim(firstname) + " " + strtrim(lastname)


g NetWorth = subinstr(substr(temp2, 1, strpos(temp2, ",")-1), "$", "", .)
destring NetWorth, replace force
g temp3 = substr(temp2, strpos(temp2, ",")+1, strlen(temp2)-strpos(temp2, ","))
g NW_fix = substr(temp3, 1, strpos(temp3, ",")-1) if NetWorth<10
destring NW_fix, g(nwf) force
replace NetWorth = (1000*NetWorth) + nwf if NetWorth<10

g temp4 = temp3 if nwf==.
replace temp4 = substr(temp3, strpos(temp3, ",")+1, strlen(temp3)-strpos(temp3, ",")) if nwf!=.
g temp6 = strreverse(temp4)

g extra = substr(temp4, (-1)*strpos(temp6, ",") + 1, strpos(temp6, ",") )
g temp5 = substr(temp4, 1, strlen(temp4)-strpos(temp6, ",")) if (regexm(extra, "F")==1 | regexm(extra, "E")==1 | regexm(extra, "M")==1 | regexm(extra, "G")==1 | regexm(extra, "R")==1 | regexm(extra, "S")==1 | regexm(extra, "T")==1)==1
replace temp5 = temp4  if (regexm(extra, "F")==1 | regexm(extra, "E")==1 | regexm(extra, "M")==1 | regexm(extra, "G")==1 | regexm(extra, "R")==1 | regexm(extra, "S")==1 | regexm(extra, "T")==1)!=1
replace extra = "." if (regexm(extra, "F")==1 | regexm(extra, "E")==1 | regexm(extra, "M")==1 | regexm(extra, "G")==1 | regexm(extra, "R")==1 | regexm(extra, "S")==1 | regexm(extra, "T")==1)!=1

g temp7 = strreverse(temp5)
g Age = substr(temp5, (-1)*strpos(temp7, ",") + 1, strpos(temp7, ",")  )
destring Age, replace
g temp8 = substr(temp5, 1, strlen(temp5)-strpos(temp7, ","))

g city = substr(temp8, 1, strpos(temp8, ",")-1)
g temp9 = substr(temp8, strpos(temp8, ",")+1, strlen(temp8)-strpos(temp8, ","))

g state = "."
g temp_state = substr(temp9, 1, strpos(temp9, ",")-1)
#delimit
replace state = substr(temp9, 1, strpos(temp9, ",")-1) if regexm(temp_state, "Tex.")==1 | 
regexm(temp_state, "R.I.")==1 | regexm(temp_state, "S.C.")==1 | regexm(temp_state, "Wis.")==1 | 
regexm(temp_state, "Tenn.")==1 | regexm(temp_state, "Switzerland")==1 | regexm(temp_state, "N.Y.")==1 | 
regexm(temp_state, "N.M.")==1 | regexm(temp_state, "R.I.")==1 | regexm(temp_state, "N.H.")==1 |
regexm(temp_state, "N.J.")==1 | regexm(temp_state, "Mo.")==1 | regexm(temp_state, "Mich.")==1 |
regexm(temp_state, "Minn.")==1 | regexm(temp_state, "Md.")==1 | regexm(temp_state, "La.")==1 |
regexm(temp_state, "Kan.")==1 | regexm(temp_state, "Ill.")==1 | regexm(temp_state, "Ida.")==1 |
regexm(temp_state, "Ga.")==1 | regexm(temp_state, "Fla.")==1 | regexm(temp_state, "England")==1 |
regexm(temp_state, "D.C.")==1 | regexm(temp_state, "Del.")==1 | regexm(temp_state, "Conn.")==1 |
regexm(temp_state, "Colo.")==1 | regexm(temp_state, "Calif.")==1 | regexm(temp_state, "Ark.")==1 |
regexm(temp_state, "Ala.")==1 | regexm(temp_state, "Ohio")==1 | regexm(temp_state, "Pa.")==1 |
regexm(temp_state, "Mass.")==1 | regexm(temp_state, "Va.")==1 | regexm(temp_state, "Wash.")==1 |
 regexm(temp_state, "Ore.")==1 | regexm(temp_state, "Nev.")==1 ; 
#delimit cr;

g Residence = city 
replace Residence = city +"," + state if state!="." & state!=""
g Source = temp9
replace Source = substr(temp9, strpos(temp9, ",")+1, strlen(temp9)-strpos(temp9, ",")) if state!="." & state!=""
keep Name Age Rank Source Residence NetWorth extra firstname lastname

g Suffix = ""
foreach txt in Sr Jr II III{
replace Suffix = "`txt'" if Suffix =="" & regexm(Name, "`txt'")==1
replace Name = subinstr(Name, "`txt',", "", .) if regexm(Name, "`txt'")==1
replace Name = subinstr(Name, "`txt'.", "", .) if regexm(Name, "`txt'.")==1
}


foreach var in Name Source Residence{
replace `var' = strproper(`var')
}

tempfile `i'
save ``i''
*save "./stata_data/`i'.dta", replace
}

forvalues i = 1987(1)1987{
import excel "./raw_data/top400.xlsx", sheet("`i'") clear
drop if A=="." | A==""

g year = `i'
egen c_info = noccur(A), string(",")
drop if c_info==0

*STANDARD VARIABLES
*NEED TO CLEAN UP NETWORTH
g Rank = substr(A, 1, strpos(A, "-")-1)
rename A t
g A = substr(t,strpos(t, "--")+2, strlen(t)-strpos(t, "--")+2)
g lastname = substr(A, 1, strpos(A,",")-1)
g temp = substr(A, strpos(A,",")+1, strlen(A)-strpos(A,",") )
g firstname = substr(temp, 1, strpos(temp,",")-1)
g temp2 = substr(temp, strpos(temp,",")+1, strlen(A)-strpos(temp,",") )
g Name = strtrim(firstname) + " " + strtrim(lastname)


g NetWorth = subinstr(substr(temp2, 1, strpos(temp2, ",")-1), "$", "", .)
destring NetWorth, replace force
g temp3 = substr(temp2, strpos(temp2, ",")+1, strlen(temp2)-strpos(temp2, ","))
g NW_fix = substr(temp3, 1, strpos(temp3, ",")-1) if NetWorth<10
destring NW_fix, g(nwf) force
replace NetWorth = (1000*NetWorth) + nwf if NetWorth<10

g temp4 = temp3 if nwf==.
replace temp4 = substr(temp3, strpos(temp3, ",")+1, strlen(temp3)-strpos(temp3, ",")) if nwf!=.
g temp6 = strreverse(temp4)

g extra = substr(temp4, (-1)*strpos(temp6, ",") + 1, strpos(temp6, ",") )
g temp5 = substr(temp4, 1, strlen(temp4)-strpos(temp6, ",")) if (regexm(extra, "F")==1 | regexm(extra, "E")==1 | regexm(extra, "M")==1 | regexm(extra, "G")==1 | regexm(extra, "R")==1 | regexm(extra, "S")==1 | regexm(extra, "T")==1)==1
replace temp5 = temp4  if (regexm(extra, "F")==1 | regexm(extra, "E")==1 | regexm(extra, "M")==1 | regexm(extra, "G")==1 | regexm(extra, "R")==1 | regexm(extra, "S")==1 | regexm(extra, "T")==1)!=1
replace extra = "." if (regexm(extra, "F")==1 | regexm(extra, "E")==1 | regexm(extra, "M")==1 | regexm(extra, "G")==1 | regexm(extra, "R")==1 | regexm(extra, "S")==1 | regexm(extra, "T")==1)!=1

g temp7 = strreverse(temp5)
g Age = substr(temp5, (-1)*strpos(temp7, ",") + 1, strpos(temp7, ",")  )
destring Age, replace
g temp8 = substr(temp5, 1, strlen(temp5)-strpos(temp7, ","))

g city = substr(temp8, 1, strpos(temp8, ",")-1)
g temp9 = substr(temp8, strpos(temp8, ",")+1, strlen(temp8)-strpos(temp8, ","))

g state = "."
g temp_state = substr(temp9, 1, strpos(temp9, ",")-1)
#delimit
replace state = substr(temp9, 1, strpos(temp9, ",")-1) if regexm(temp_state, "Tex.")==1 | 
regexm(temp_state, "R.I.")==1 | regexm(temp_state, "S.C.")==1 | regexm(temp_state, "Wis.")==1 | 
regexm(temp_state, "Tenn.")==1 | regexm(temp_state, "Switzerland")==1 | regexm(temp_state, "N.Y.")==1 | 
regexm(temp_state, "N.M.")==1 | regexm(temp_state, "R.I.")==1 | regexm(temp_state, "N.H.")==1 |
regexm(temp_state, "N.J.")==1 | regexm(temp_state, "Mo.")==1 | regexm(temp_state, "Mich.")==1 |
regexm(temp_state, "Minn.")==1 | regexm(temp_state, "Md.")==1 | regexm(temp_state, "La.")==1 |
regexm(temp_state, "Kan.")==1 | regexm(temp_state, "Ill.")==1 | regexm(temp_state, "Ida.")==1 |
regexm(temp_state, "Ga.")==1 | regexm(temp_state, "Fla.")==1 | regexm(temp_state, "England")==1 |
regexm(temp_state, "D.C.")==1 | regexm(temp_state, "Del.")==1 | regexm(temp_state, "Conn.")==1 |
regexm(temp_state, "Colo.")==1 | regexm(temp_state, "Calif.")==1 | regexm(temp_state, "Ark.")==1 |
regexm(temp_state, "Ala.")==1 | regexm(temp_state, "Ohio")==1 | regexm(temp_state, "Pa.")==1 |
regexm(temp_state, "Mass.")==1 | regexm(temp_state, "Va.")==1 | regexm(temp_state, "Wash.")==1 |
 regexm(temp_state, "Ore.")==1 | regexm(temp_state, "Nev.")==1 ; 
#delimit cr;

g Residence = city 
replace Residence = city +"," + state if state!="." & state!=""
g Source = temp9
replace Source = substr(temp9, strpos(temp9, ",")+1, strlen(temp9)-strpos(temp9, ",")) if state!="." & state!=""
keep Name Age Rank Source Residence NetWorth extra firstname lastname

g Suffix = ""
foreach txt in Sr Jr II III{
replace Suffix = "`txt'" if Suffix =="" & regexm(Name, "`txt'")==1
replace Name = subinstr(Name, "`txt',", "", .) if regexm(Name, "`txt'")==1
replace Name = subinstr(Name, "`txt'.", "", .) if regexm(Name, "`txt'.")==1
}


foreach var in Name Source Residence{
replace `var' = strproper(`var')
}
g year = "`i'"

tempfile `i'
save ``i''
*save "./stata_data/`i'.dta", replace
}

*2002 is mostly cleaned
forvalues i = 2002(1)2002{
import excel "./raw_data/top400.xlsx", sheet("`i'") firstrow clear
drop if Rank=="." | Rank==""

g year = `i'
g r = substr(Rank, 1, strpos(Rank, " ")-2)
g name = subinstr(substr(Rank, strpos(Rank, " ")+1, strlen(Rank)-strpos(Rank, " ")), "  ", " ", .)
replace Name = strtrim(Name)
replace name = strtrim(name)
replace Name = Name +" " +  name
drop Rank
rename r Rank

keep Name Rank Source NetWorth prev_rank prev_NetWorth year
destring Rank, replace


foreach var in Name Source{
replace `var' = strproper(`var')
}

tempfile `i'
save ``i''
*save "./stata_data/`i'.dta", replace

}
*Note edited from here on 
forvalues i = 2001(4)2001{
import excel "./raw_data/top400.xlsx", sheet("`i'")clear

g Rank = substr(A, 1, strpos(A, ",")-1)
g temp = substr(A, strpos(A, ",")+1, strlen(A)-strpos(A, ","))

drop if Rank=="." | Rank==""

g year = `i'

g lastname = substr(temp, 1, strpos(temp,",")-1)
g temp2 = substr(temp, strpos(temp,",")+1, strlen(temp)-strpos(temp,",") )
g firstname = substr(temp2, 1, strpos(temp2,",")-1)
g suffix2 = ""
replace suffix2 = "& family" if regexm(firstname, "family")==1
replace firstname = subinstr(firstname, suffix2, "", .)

g temp3 = substr(temp2, strpos(temp2,",")+1, strlen(temp2)-strpos(temp2,",") )
g Name = strtrim(firstname) + " " + strtrim(lastname) + strtrim(suffix2)
g temp4 = temp3

g NetWorth = substr(temp4, strpos(temp4, "$"), strlen(temp4)-strpos(temp4, "$")+3)
g temp5 = substr(temp4, 1, strpos(temp4, "$")-3)

g suffix = ""
foreach var in III Jr Sr{

replace suffix = "`var'" if (regexm(temp5, "`var'")==1)==1

}
replace suffix = "II" if (regexm(temp5, "II")==1 & regexm(temp5, "III")!=1)==1

replace suffix = "(J. Paul Jr.)" if regexm(firstname, "(J. Paul Jr.)")==1
foreach nickname in Ted Doc Hank{
replace suffix = "(`nickname')" if regexm(firstname, "(`nickname')")==1
}
replace suffix = "(Ted)" if regexm(temp5, "(Ted)")==1
replace suffix = "& family" if regexm(temp5, "family")==1
foreach var in Ty Lowry{
replace suffix = "`var'" if regexm(temp5, "`var',")==1
}
egen c_info = noccur(A), string(",")
foreach var in Wayne{
replace suffix = "`var'" if regexm(temp5, "`var',")==1 & c_info>1
}
replace Name = Name + " "+suffix
replace Name = strtrim(Name)
g temp_fix = suffix + "," if suffix!=""
g Residence = temp5 if suffix==""
replace Residence = subinstr(temp5, temp_fix, "", .) if suffix!=""
g temp_fix2 = suffix + ".,"
replace Residence = subinstr(Residence, temp_fix2, "", .) if suffix!=""
keep Name Residence NetWorth Rank year suffix lastname firstname


tempfile `i'
save ``i''
*save "./stata_data/`i'.dta", replace

}
*Note edited from here on 
forvalues jibberish = 2003(4)2003{
import excel "./raw_data/top400.xlsx", sheet("`jibberish'")clear

g sorter = _n

g State = 0
replace State = 1 if regexm(A, ",")==0 & A!="" & A !="."

bys State: g st_ind = _n if State==1
replace st_ind = . if State==0
g st_name = A if State==1
sort sorter
g new_state = st_ind
drop if A==""
local conditions "& new_state==. & State==0"
forvalues i = 1(1)105{
sort sorter
	replace new_state = st_ind[_n-`i'] if State[_n-`i']==1 & st_ind[_n-`i']!=. `conditions'
	sort sorter
	replace st_name = A[_n-`i'] if new_state==new_state[_n-`i']
	local conditions =  "`conditions' & st_ind[_n-`i']==. & State[_n-`i']==0"
	
	}
	
drop if State==1
keep new_state st_name A
compress
g Rank = substr(A, 1, strpos(A, ",")-1)
g temp1 = substr(A, strpos(A, ",")+1, strlen(A)-strpos(A, ","))

g year = `jibberish'
local i = 1
local k = `i'+1
foreach var in lastname firstname Age NetWorth city{
g `var' = substr(temp`i', 1, strpos(temp`i', ",")-1)
g temp`k' = substr(temp`i', strpos(temp`i', ",")+1, strlen(temp`i')-strpos(temp`i', ","))
local i = `i'+1
local k = `i'+1
}
g Source = temp`i'
g Suffix = ""
foreach var in Jr Sr{
	replace Suffix = "`var'." if regexm(firstname, "`var'.")==1 
}
foreach var in I II III Jr Sr{
	replace Suffix = "`var'" if regexm(firstname, "`var'")==1 & regexm(firstname, "`var'.")!=1 & regexm(firstname, "Ir")!=1 & regexm(firstname, "In")!=1 & regexm(firstname, "Il")!=1 & regexm(firstname, "Is")!=1 & regexm(firstname, "It")!=1 & regexm(firstname, "Iv")!=1 & regexm(firstname, "Ia")!=1 & regexm(firstname, "Im")!=1 & regexm(firstname, "Id")!=1 & regexm(firstname, "Ip")!=1

}
replace Suffix = "and family" if regexm(firstname, "family")==1
replace Suffix = "Red" if regexm(firstname, "Red")==1
replace firstname = substr(firstname, 1, strpos(firstname, "Red")-2) if Suffix=="Red"
replace firstname = subinstr(firstname, Suffix, "", .) if Suffix!="" & Suffix!="Red"
g Name = strtrim(firstname) + " " + strtrim(lastname) 
replace Name = strtrim(Name) + " " + strtrim(Suffix) if Suffix!=""
g Residence = city +", " + st_name
keep Name Rank Source NetWorth Age city Residence st_name year Suffix lastname firstname
destring Rank, replace


foreach var in Name Source{
replace `var' = strproper(`var')
}
compress

tempfile `jibberish'
save ``jibberish''
*save "./stata_data/`jibberish'.dta", replace

}

*Note edited from here on 
forvalues jibberish = 1986(4)1986{
import excel "./raw_data/top400.xlsx", sheet("`jibberish'")clear
drop if A ==""
compress
g lastname = substr(A, 1, strpos(A, ",")-1)
g temp1 = substr(A, strpos(A, ",")+1, strlen(A)-strpos(A, ","))

g year = `jibberish'
local i = 1
local k = `i'+1
foreach var in firstname city{
g `var' = substr(temp`i', 1, strpos(temp`i', ",")-1)
g temp`k' = substr(temp`i', strpos(temp`i', ",")+1, strlen(temp`i')-strpos(temp`i', ","))
local i = `i'+1
local k = `i'+1
}

g second_half = substr(temp3, strpos(temp3, "$")+1, strlen(temp3)-strpos(temp3, "$"))

g nw = strtrim(substr(second_half, 1, strpos(second_half, ",")-1))
g temp_sh = substr(second_half, strpos(second_half, ",")+1, strlen(second_half)-strpos(second_half, ",")+1)
g temp_fix = strtrim(substr(temp_sh, 1, strpos(temp_sh, ",")-1))
g NetWorth = nw if strlen(nw)>1
replace NetWorth = nw+","+temp_fix if strlen(nw)<=1

g Source = strtrim(subinstr(second_half, NetWorth, "", .))
replace Source = substr(Source, 2, strlen(Source)-1)
g temp4 = subinstr(subinstr(temp3, second_half, "", .), "$", "", .)
g temp5 = temp4

forvalues num = 1(1)9{
 replace temp4 = subinstr(temp4, "`num'", "STOP`num'", .)
}
 g Age = subinstr(substr(temp4, strpos(temp4, "STOP")+4, strlen(temp4)- strpos(temp4, "STOP")), "STOP", "", .) if regexm(temp4, "STOP")==1
 
 g state = strtrim(subinstr(temp5, Age, "", .))
 replace state = substr(state, 1, strlen(state)-1)
 replace Age = strtrim(Age)
 replace Age = substr(Age, 1, strlen(Age)-1)
 g Residence = city + ", " + state if state!=""
 replace Residence = city if state==""
 rename state st_name

g Suffix = ""
foreach var in Jr Sr{
	replace Suffix = "`var'." if regexm(firstname, "`var'.")==1 
}
foreach var in I II III Jr Sr{
replace Suffix = "`var'" if regexm(firstname, "`var'")==1 & regexm(firstname, "`var'.")!=1 & regexm(firstname, "Ir")!=1 & regexm(firstname, "In")!=1 & regexm(firstname, "Il")!=1 & regexm(firstname, "Is")!=1 & regexm(firstname, "It")!=1 & regexm(firstname, "Iv")!=1 & regexm(firstname, "Ia")!=1 & regexm(firstname, "Im")!=1 & regexm(firstname, "Id")!=1 & regexm(firstname, "Ip")!=1

}
replace Suffix = "and family" if regexm(firstname, "family")==1
replace Suffix = "Red" if regexm(firstname, "Red")==1
replace firstname = substr(firstname, 1, strpos(firstname, "Red")-2) if Suffix=="Red"
replace firstname = subinstr(firstname, Suffix, "", .) if Suffix!="" & Suffix!="Red"
g Name = strtrim(firstname) + " " + strtrim(lastname) 
replace Name = strtrim(Name) + " " + strtrim(Suffix) if Suffix!=""

keep Name Source NetWorth Age city Residence st_name firstname lastname Suffix
order Name Source NetWorth Age city Residence st_name


foreach var in Name Source firstname lastname{
replace `var' = strproper(`var')
} 
g year = "`jibberish'"
compress

tempfile `jibberish'
save ``jibberish''
*save "./stata_data/`jibberish'.dta", replace

}

forvalues jibberish = 1985(1)1985{

import excel "./raw_data/top400.xlsx", sheet("`jibberish'") clear

g year = `jibberish'
drop if A==""
g lastname = substr(A, 1, strpos(A, ",")-1)
g temp1 = substr(A, strpos(A, ",") + 1, strlen(A)-strpos(A, ","))
g firstname = substr(temp1, 1, strpos(temp1, ",")-1)
g temp2 = substr(temp1, strpos(temp1, ",")+1, strlen(temp1)- strpos(temp1, ","))
g Age = substr(temp2, 1, strpos(temp2, ",")-1)
g temp3 = substr(temp2, strpos(temp2, ",")+1, strlen(temp2)- strpos(temp2, ","))
g NetWorth = substr(temp3, strpos(temp3, "$"), strlen(temp3)- strpos(temp3, "$")+1)
replace NetWorth = substr(temp3, strpos(temp3, "amount of wealth not disclosed"), strlen(temp3)-strpos(temp3, "amount of wealth not disclosed")) if NetWorth==""
g temp4 = strtrim(subinstr(temp3, NetWorth, "", .))
g city = substr(temp4, 1, strpos(temp4, ",")-1)
g temp5 = substr(temp4, strpos(temp4, ",")+1, strlen(temp4)-strpos(temp4, ",")-1)


egen c_info = noccur(temp5), string(",")

g Source = strtrim(temp5) if c_info==0
g temp6 = subinstr(temp5, Source, "", .)

g temp_state = temp6
g state = ""
#delimit
replace state = substr(temp6, 1, strpos(temp6, ",")-1) if regexm(temp_state, "Tex.")==1 | 
regexm(temp_state, "R.I.")==1 | regexm(temp_state, "S.C.")==1 | regexm(temp_state, "Wis.")==1 | 
regexm(temp_state, "Tenn.")==1 | regexm(temp_state, "Switzerland")==1 | regexm(temp_state, "N.Y.")==1 | 
regexm(temp_state, "N.M.")==1 | regexm(temp_state, "R.I.")==1 | regexm(temp_state, "N.H.")==1 |
regexm(temp_state, "N.J.")==1 | regexm(temp_state, "Mo.")==1 | regexm(temp_state, "Mich.")==1 |
regexm(temp_state, "Minn.")==1 | regexm(temp_state, "Md.")==1 | regexm(temp_state, "La.")==1 |
regexm(temp_state, "Kan.")==1 | regexm(temp_state, "Ill.")==1 | regexm(temp_state, "Ida.")==1 |
regexm(temp_state, "Ga.")==1 | regexm(temp_state, "Fla.")==1 | regexm(temp_state, "England")==1 |
regexm(temp_state, "D.C.")==1 | regexm(temp_state, "Del.")==1 | regexm(temp_state, "Conn.")==1 |
regexm(temp_state, "Colo.")==1 | regexm(temp_state, "Calif.")==1 | regexm(temp_state, "Ark.")==1 |
regexm(temp_state, "Ala.")==1 | regexm(temp_state, "Ohio")==1 | regexm(temp_state, "Pa.")==1 |
regexm(temp_state, "Mass.")==1 | regexm(temp_state, "Va.")==1 | regexm(temp_state, "Wash.")==1 |
 regexm(temp_state, "Ore.")==1 | regexm(temp_state, "Nev.")==1 | regexm(temp_state, "Texas")==1 |
 regexm(temp_state, "Del.")==1 | regexm(temp_state, "N.C.")==1 | regexm(temp_state, "Ariz.")==1  |
  regexm(temp_state, "Okla.")==1 | regexm(temp_state, "Boston")==1 | regexm(temp_state, "Hawaii")==1 |
   regexm(temp_state, "Minn.")==1 | regexm(temp_state, "Ind.")==1 | regexm(temp_state, "Texas")==1 |
   regexm(temp_state, "V.t.")==1 | regexm(temp_state, "Wyo.")==1 |  regexm(temp_state, "Neb.")==1 
 ; 
#delimit cr;

g temp7 = strtrim(subinstr(temp6, state, "", .))
g test = strpos(temp7, ",")
replace temp7 = substr(temp7, test+1, strlen(temp7)-test+1) if test==1
g state2 = ""
replace temp_state = temp7
#delimit
replace state2 = substr(temp7, 1, strpos(temp7, ",")-1) if regexm(temp_state, "Tex.")==1 | 
regexm(temp_state, "R.I.")==1 | regexm(temp_state, "S.C.")==1 | regexm(temp_state, "Wis.")==1 | 
regexm(temp_state, "Tenn.")==1 | regexm(temp_state, "Switzerland")==1 | regexm(temp_state, "N.Y.")==1 | 
regexm(temp_state, "N.M.")==1 | regexm(temp_state, "R.I.")==1 | regexm(temp_state, "N.H.")==1 |
regexm(temp_state, "N.J.")==1 | regexm(temp_state, "Mo.")==1 | regexm(temp_state, "Mich.")==1 |
regexm(temp_state, "Minn.")==1 | regexm(temp_state, "Md.")==1 | regexm(temp_state, "La.")==1 |
regexm(temp_state, "Kan.")==1 | regexm(temp_state, "Ill.")==1 | regexm(temp_state, "Ida.")==1 |
regexm(temp_state, "Ga.")==1 | regexm(temp_state, "Fla.")==1 | regexm(temp_state, "England")==1 |
regexm(temp_state, "D.C.")==1 | regexm(temp_state, "Del.")==1 | regexm(temp_state, "Conn.")==1 |
regexm(temp_state, "Colo.")==1 | regexm(temp_state, "Calif.")==1 | regexm(temp_state, "Ark.")==1 |
regexm(temp_state, "Ala.")==1 | regexm(temp_state, "Ohio")==1 | regexm(temp_state, "Pa.")==1 |
regexm(temp_state, "Mass.")==1 | regexm(temp_state, "Va.")==1 | regexm(temp_state, "Wash.")==1 |
regexm(temp_state, "Ore.")==1 | regexm(temp_state, "Nev.")==1 | regexm(temp_state, "Texas")==1 |
 regexm(temp_state, "Del.")==1 | regexm(temp_state, "N.C.")==1 | regexm(temp_state, "Ariz.")==1  |
 regexm(temp_state, "Okla.")==1 | regexm(temp_state, "Boston")==1 | regexm(temp_state, "Hawaii")==1 |
 regexm(temp_state, "Minn.")==1 | regexm(temp_state, "Ind.")==1 | regexm(temp_state, "Texas")==1 | 
  regexm(temp_state, "Del.")==1 | regexm(temp_state, "N.C.")==1 | regexm(temp_state, "Ariz.")==1  |
  regexm(temp_state, "Okla.")==1 | regexm(temp_state, "Boston")==1 | regexm(temp_state, "Hawaii")==1 |
   regexm(temp_state, "Minn.")==1 | regexm(temp_state, "Ind.")==1 | regexm(temp_state, "Texas")==1 |
   regexm(temp_state, "V.t.")==1 | regexm(temp_state, "Wyo.")==1 |  regexm(temp_state, "Neb.")==1 | 
regexm(temp_state, "New York")==1 | regexm(temp_state, "Palm Beach")==1 | regexm(temp_state, "Las Vegas")==1  |
regexm(temp_state, "Honolulu")==1 | regexm(temp_state, "Vt.")==1 | regexm(temp_state, "Moscow")==1  
 ; 
#delimit cr;

forvalues i = 8(1)9{
local k = `i'-1
local p = `i'-6
local kp = `i'-5
g temp`i' = strtrim(subinstr(temp`k', state`p', "", .))
replace temp`i' = substr(temp`i', 2, strlen(temp`i')) if state`p'!=""
g state`kp' = ""
replace temp_state = temp`i'
#delimit
replace state`kp' = substr(temp`i', 1, strpos(temp`i', ",")-1) if regexm(temp_state, "Tex.")==1 | 
regexm(temp_state, "R.I.")==1 | regexm(temp_state, "S.C.")==1 | regexm(temp_state, "Wis.")==1 | 
regexm(temp_state, "Tenn.")==1 | regexm(temp_state, "Switzerland")==1 | regexm(temp_state, "N.Y.")==1 | 
regexm(temp_state, "N.M.")==1 | regexm(temp_state, "R.I.")==1 | regexm(temp_state, "N.H.")==1 |
regexm(temp_state, "N.J.")==1 | regexm(temp_state, "Mo.")==1 | regexm(temp_state, "Mich.")==1 |
regexm(temp_state, "Minn.")==1 | regexm(temp_state, "Md.")==1 | regexm(temp_state, "La.")==1 |
regexm(temp_state, "Kan.")==1 | regexm(temp_state, "Ill.")==1 | regexm(temp_state, "Ida.")==1 |
regexm(temp_state, "Ga.")==1 | regexm(temp_state, "Fla.")==1 | regexm(temp_state, "England")==1 |
regexm(temp_state, "D.C.")==1 | regexm(temp_state, "Del.")==1 | regexm(temp_state, "Conn.")==1 |
regexm(temp_state, "Colo.")==1 | regexm(temp_state, "Calif.")==1 | regexm(temp_state, "Ark.")==1 |
regexm(temp_state, "Ala.")==1 | regexm(temp_state, "Ohio")==1 | regexm(temp_state, "Pa.")==1 |
regexm(temp_state, "Mass.")==1 | regexm(temp_state, "Va.")==1 | regexm(temp_state, "Wash.")==1 |
regexm(temp_state, "Ore.")==1 | regexm(temp_state, "Nev.")==1 | regexm(temp_state, "Texas")==1 |
 regexm(temp_state, "Del.")==1 | regexm(temp_state, "N.C.")==1 | regexm(temp_state, "Ariz.")==1  |
 regexm(temp_state, "Okla.")==1 | regexm(temp_state, "Boston")==1 | regexm(temp_state, "Hawaii")==1 |
 regexm(temp_state, "Minn.")==1 | regexm(temp_state, "Ind.")==1 | regexm(temp_state, "Texas")==1 | 
  regexm(temp_state, "Del.")==1 | regexm(temp_state, "N.C.")==1 | regexm(temp_state, "Ariz.")==1  |
  regexm(temp_state, "Okla.")==1 | regexm(temp_state, "Boston")==1 | regexm(temp_state, "Hawaii")==1 |
   regexm(temp_state, "Minn.")==1 | regexm(temp_state, "Ind.")==1 | regexm(temp_state, "Texas")==1 |
   regexm(temp_state, "V.t.")==1 | regexm(temp_state, "Wyo.")==1 |  regexm(temp_state, "Neb.")==1 | 
regexm(temp_state, "New York")==1 | regexm(temp_state, "Palm Beach")==1 | regexm(temp_state, "Las Vegas")==1  |
regexm(temp_state, "Honolulu")==1 | regexm(temp_state, "Vt.")==1 | regexm(temp_state, "Moscow")==1  
 ; 
#delimit cr;
}
g temp10 = subinstr(temp9, state4, "", .)
replace Source = temp10 if Source==""
replace Source = strtrim(subinstr(temp9, state4, "", .)) if state4!=""
replace Source = subinstr(Source, ", etc.,", "", .)
g Residence = strtrim(city)
replace Residence = strtrim(city) + ", " + strtrim(state) if state!=""
replace Residence = Residence + ", "+ strtrim(state2) if state2!=""
replace Residence = Residence + ", "+ strtrim(state3) if state3!=""
replace Residence = Residence + ", "+ strtrim(state4) if state4!=""

g Suffix = ""
foreach var in Jr Sr{
	replace Suffix = "`var'." if regexm(firstname, "`var'.")==1 
}
foreach var in I II III Jr Sr{
replace Suffix = "`var'" if regexm(firstname, "`var'")==1 & regexm(firstname, "`var'.")!=1 & regexm(firstname, "Ir")!=1 & regexm(firstname, "In")!=1 & regexm(firstname, "Il")!=1 & regexm(firstname, "Is")!=1 & regexm(firstname, "It")!=1 & regexm(firstname, "Iv")!=1 & regexm(firstname, "Ia")!=1 & regexm(firstname, "Im")!=1 & regexm(firstname, "Id")!=1 & regexm(firstname, "Ip")!=1
}
replace Suffix = "and family" if regexm(firstname, "family")==1
replace Suffix = "Red" if regexm(firstname, "Red")==1
replace firstname = substr(firstname, 1, strpos(firstname, "Red")-2) if Suffix=="Red"
replace firstname = subinstr(firstname, Suffix, "", .) if Suffix!="" & Suffix!="Red"
g Name = strtrim(firstname) + " " + strtrim(lastname) 
replace Name = strtrim(Name) + " " + strtrim(Suffix) if Suffix!=""
replace Residence = strtrim(Residence)


keep year Age Name NetWorth Residence Source firstname lastname Suffix

tempfile `jibberish'
save ``jibberish''
*save "./stata_data/`jibberish'.dta", replace
}

/*
forvalues jibberish = 1982(1)1984{

import excel "./raw_data/top400.xlsx", sheet("`jibberish'") clear

g year = `jibberish'
cap g G = ""
g string = A + B + C + D + E + F + G



g first_cut = .
forvalues i = 0(1)9{
	g temp = strpos(string, "`i'")
	replace first_cut = min(temp, first_cut) if temp!=. & temp!=0
	drop temp
}
g temp_name =  substr(string, 1, first_cut-1)
g Name = strproper(subinstr(substr(string, 1, first_cut-1), "..", "", .))
replace Name = subinstr(subinstr(Name, ".", "REMOVEPLZ", .), "REMOVEPLZ", "", .)
replace string = subinstr(string, temp_name, "", .)

replace first_cut = .
g temp_string = lower(string)
foreach i in a b c d e f g h i j k l m n o p q r s t u v w x y z{
	g temp = strpos(temp_string, "`i'")
	replace first_cut = min(temp, first_cut) if temp!=. & temp!=0
	drop temp
}
g temp_page = substr(string, 1, first_cut-1)
g page = substr(string, 1, first_cut-1)
destring page, replace
replace string = subinstr(string, temp_page, "", 1)

replace first_cut = .
forvalues i = 0(1)9{
	g temp = strpos(string, "`i'")
	replace first_cut = min(temp, first_cut) if temp!=. & temp!=0
	drop temp
}
g temp = strpos(string, "—")
replace first_cut = min(temp, first_cut) if temp!=. & temp!=0
drop temp
g temp_loc =  substr(string, 1, first_cut-1)
g Residence = strproper(subinstr(substr(string, 1, first_cut-1), "..", "", .))
replace string = subinstr(string, temp_loc, "", .)

g temp = strpos(string, "—")
g Age = substr(string, 1, 2)
g temp_Age = substr(string, 1, 2)
replace Age = "." if temp==1 | regexm(Name, "Family")==1 | regexm(string, "ageless")==1
replace temp_Age = "—" if temp==1 | regexm(Name, "Family")==1 | regexm(string, "ageless")==1
destring Age, replace

replace string = subinstr(string, temp_Age, "", 1)

replace first_cut = .
drop temp_string temp
g temp_string = lower(string)
foreach i in a b c d e f g h i j k l m n o p q r s t u v w x y z{
	g temp = strpos(temp_string, "`i'")
	replace first_cut = min(temp, first_cut) if temp!=. & temp!=0
	drop temp
}
g temp_nw = substr(string, 1, first_cut-1)
g NetWorth = substr(string, 1, first_cut-1)
replace string = subinstr(string, temp_nw, "", 1)
compress
rename string Source
keep year Name Residence Age NetWorth Source page
drop if Name==""


rename Name A

replace A = subinstr(A, "fam ily", "family", 1)
replace A = subinstr(A, "Fam Ily", "Family", 1)
replace A = subinstr(A, "A  D A M  S ", "Adams", 1)
replace A = subinstr(A, "T Aper", "Taper", 1)
replace A = subinstr(A, "Z Iff", "Ziff", 1)
replace A = subinstr(A, "N Ewhouse", "Newhouse", 1)
replace A = subinstr(A, "V    A N Andel", "Van Andel", 1)
replace A = subinstr(A, "★", "", .)
replace A = subinstr(A, "*", "", .)
replace A = subinstr(A, "O'N Eill ", "O'Neill", 1)
replace A = subinstr(A, " K Irk >  ", "Kirk", 1)
replace A = subinstr(A, "W Illiam", "William", 1)
replace A = subinstr(A, "M Iles", "Miles", 1)
replace A = subinstr(A, "C A B O T ", "Cabot", 1)
g lastname = substr(A, 1, strpos(A, ",")-1)
replace A = substr(A, strpos(A, ",")+1, strlen(A))
g firstname = A



g Suffix = ""
foreach var in Jr Sr{
	replace Suffix = "`var'." if regexm(firstname, "`var'.")==1 
	replace firstname = subinstr(firstname, "`var'.", "", .) if regexm(firstname, "`var'.")==1 
}
foreach var in I II III Jr Sr{
replace Suffix = "`var'" if regexm(firstname, "`var'")==1 & regexm(firstname, "`var'.")!=1 & regexm(firstname, "Ir")!=1 & regexm(firstname, "In")!=1 & regexm(firstname, "Il")!=1 & regexm(firstname, "Is")!=1 & regexm(firstname, "It")!=1 & regexm(firstname, "Iv")!=1 & regexm(firstname, "Ia")!=1 & regexm(firstname, "Im")!=1 & regexm(firstname, "Id")!=1 & regexm(firstname, "Ip")!=1
	replace firstname = subinstr(firstname, "`var'", "", .) if regexm(firstname, "`var'.")==1 & regexm(firstname, "`var'.")!=1 & regexm(firstname, "Ir")!=1 & regexm(firstname, "In")!=1 & regexm(firstname, "Il")!=1
}
replace Suffix = "and family" if regexm(firstname, "and family")==1
replace Suffix = "Red" if regexm(firstname, "Red")==1
replace firstname = substr(firstname, 1, strpos(firstname, "Red")-2) if Suffix=="Red"
replace firstname = subinstr(firstname, Suffix, "", .) if Suffix!="" & Suffix!="Red"
g Name = strtrim(firstname) + " " + strtrim(lastname) 
replace Name = strtrim(Name) + " " + strtrim(Suffix) if Suffix!=""

replace Name = strtrim(Name)

foreach var in year Name Residence Age NetWorth Source page firstname lastname Suffix{
	cap replace `var' = strtrim(`var')
}

save ``jibberish'', replace

foreach var in A B C D E F{
g temp`var' = subinstr(`var', "..", "", .)
g kB`var' = strpos(temp`var', ".")
replace temp`var' = substr(temp`var', 2, strlen(temp`var')) if kB`var'==1
*g x`var' = 1 if regexm(temp`var', "^([A-Z][A-Z])") | regexm(temp`var', "^([A-Z][a-z])") | regexm(temp`var', "^([a-z][A-Z])") | regexm(temp`var', "^([a-z][a-z])")
egen N`var' = sieve(`var'), char(0123456789)
*egen S`var' = sieve(`var'), keep(a n)

g temp`var'2 = lower(strtrim(temp`var'))

foreach alpha in a b c d e f g h i j k l m n o p q r s t u v w x y z{
	replace temp`var'2 = subinstr(temp`var'2, "`alpha'", "", .) 
}
g temp`var'3 = strtrim(temp`var')
forvalues i = 0(1)9{
	replace temp`var'3 = subinstr(temp`var'3, "`i'", "", .)
}

}

}
*/
forvalues jibberish = 1982(1)1984{

import excel "./raw_data/top400.xlsx", sheet("`jibberish'") clear

g year = `jibberish'
cap g G = ""
g string = A + B + C + D + E + F + G

g first_cut = .
forvalues i = 0(1)9{
	g temp = strpos(string, "`i'")
	replace first_cut = min(temp, first_cut) if temp!=. & temp!=0
	drop temp
}
g temp_name =  substr(string, 1, first_cut-1)
g Name = strproper(subinstr(substr(string, 1, first_cut-1), "..", "", .))
replace Name = subinstr(subinstr(Name, ".", "REMOVEPLZ", .), "REMOVEPLZ", "", .)
replace string = subinstr(string, temp_name, "", .)
tab temp_name

replace first_cut = .
g temp_string = lower(string)
foreach i in a b c d e f g h i j k l m n o p q r s t u v w x y z{
	g temp = strpos(temp_string, "`i'")
	replace first_cut = min(temp, first_cut) if temp!=. & temp!=0
	drop temp
}
g temp_page = substr(string, 1, first_cut-1)
g page = substr(string, 1, first_cut-1)
destring page, replace
replace string = subinstr(string, temp_page, "", 1)

replace first_cut = .
forvalues i = 0(1)9{
	g temp = strpos(string, "`i'")
	replace first_cut = min(temp, first_cut) if temp!=. & temp!=0
	drop temp
}
g temp = strpos(string, "—")
replace first_cut = min(temp, first_cut) if temp!=. & temp!=0
drop temp
g temp_loc =  substr(string, 1, first_cut-1)
g Residence = strproper(subinstr(substr(string, 1, first_cut-1), "..", "", .))
replace string = subinstr(string, temp_loc, "", .)

g temp = strpos(string, "—")
g Age = substr(string, 1, 2)
g temp_Age = substr(string, 1, 2)
replace Age = "." if temp==1 | regexm(Name, "Family")==1 | regexm(string, "ageless")==1
replace temp_Age = "—" if temp==1 | regexm(Name, "Family")==1 | regexm(string, "ageless")==1
destring Age, replace

replace string = subinstr(string, temp_Age, "", 1)

replace first_cut = .
drop temp_string temp
g temp_string = lower(string)
foreach i in a b c d e f g h i j k l m n o p q r s t u v w x y z{
	g temp = strpos(temp_string, "`i'")
	replace first_cut = min(temp, first_cut) if temp!=. & temp!=0
	drop temp
}
g temp_nw = substr(string, 1, first_cut-1)
g NetWorth = substr(string, 1, first_cut-1)
replace string = subinstr(string, temp_nw, "", 1)
compress
rename string Source
keep year Name Residence Age NetWorth Source page
drop if Name==""


rename Name A

replace A = subinstr(A, "fam ily", "family", 1)
replace A = subinstr(A, "Fam Ily", "Family", 1)
replace A = subinstr(A, "A  D A M  S ", "Adams", 1)
replace A = subinstr(A, "T Aper", "Taper", 1)
replace A = subinstr(A, "Z Iff", "Ziff", 1)
replace A = subinstr(A, "N Ewhouse", "Newhouse", 1)
replace A = subinstr(A, "V    A N Andel", "Van Andel", 1)
replace A = subinstr(A, "★", "", .)
replace A = subinstr(A, "*", "", .)
replace A = subinstr(A, "O'N Eill ", "O'Neill", 1)
replace A = subinstr(A, " K Irk >  ", "Kirk", 1)
replace A = subinstr(A, "W Illiam", "William", 1)
replace A = subinstr(A, "M Iles", "Miles", 1)
replace A = subinstr(A, "C A B O T ", "Cabot", 1)
g lastname = substr(A, 1, strpos(A, ",")-1)
replace A = substr(A, strpos(A, ",")+1, strlen(A))
g firstname = A
replace firstname = strproper(firstname)


g Suffix = ""
foreach var in Jr Sr{
	replace Suffix = "`var'." if regexm(firstname, "`var'.")==1 
	replace firstname = subinstr(firstname, "`var'.", "", .) if regexm(firstname, "`var'.")==1 
}
foreach var in I II III Jr Sr{
replace Suffix = "`var'" if regexm(firstname, "`var'")==1 & regexm(firstname, "`var'.")!=1 & regexm(firstname, "Ir")!=1 & regexm(firstname, "In")!=1 & regexm(firstname, "Il")!=1 & regexm(firstname, "Is")!=1 & regexm(firstname, "It")!=1 & regexm(firstname, "Iv")!=1 & regexm(firstname, "Ia")!=1 & regexm(firstname, "Im")!=1 & regexm(firstname, "Id")!=1 & regexm(firstname, "Ip")!=1
	replace firstname = subinstr(firstname, "`var'", "", .) if regexm(firstname, "`var'")==1 & regexm(firstname, "Ir")!=1 & regexm(firstname, "In")!=1 & regexm(firstname, "Il")!=1
}

replace Suffix = "and family" if regexm(firstname, "and family")==1
replace Suffix = "Red" if regexm(firstname, "Red")==1
replace firstname = substr(firstname, 1, strpos(firstname, "Red")-2) if Suffix=="Red"
replace firstname = subinstr(firstname, Suffix, "", .) if Suffix!="" & Suffix!="Red"
g Name = strtrim(firstname) + " " + strtrim(lastname) 
replace Name = strtrim(Name) + " " + strtrim(Suffix) if Suffix!=""

replace Name = strtrim(Name)

foreach var in year Name Residence Age NetWorth Source page firstname lastname Suffix{
	cap replace `var' = strtrim(`var')
}
tempfile `jibberish'
save ``jibberish''
/*
foreach var in A B C D E F{
g temp`var' = subinstr(`var', "..", "", .)
g kB`var' = strpos(temp`var', ".")
replace temp`var' = substr(temp`var', 2, strlen(temp`var')) if kB`var'==1
*g x`var' = 1 if regexm(temp`var', "^([A-Z][A-Z])") | regexm(temp`var', "^([A-Z][a-z])") | regexm(temp`var', "^([a-z][A-Z])") | regexm(temp`var', "^([a-z][a-z])")
egen N`var' = sieve(`var'), char(0123456789)
*egen S`var' = sieve(`var'), keep(a n)

g temp`var'2 = lower(strtrim(temp`var'))

foreach alpha in a b c d e f g h i j k l m n o p q r s t u v w x y z{
	replace temp`var'2 = subinstr(temp`var'2, "`alpha'", "", .) 
}
g temp`var'3 = strtrim(temp`var')
forvalues i = 0(1)9{
	replace temp`var'3 = subinstr(temp`var'3, "`i'", "", .)
}

} */

}


forvalues jibberish = 1989(1)1993{

import excel "./raw_data/top400.xlsx", sheet("`jibberish'_Berkeley") clear

g year = `jibberish'

replace A = subinstr(A, "fam ily", "family", 1)
g lastname = substr(A, 1, strpos(A, ",")-1)
replace A = substr(A, strpos(A, ",")+1, strlen(A))
g firstname = A



g Suffix = ""
foreach var in Jr Sr{
	replace Suffix = "`var'." if regexm(firstname, "`var'.")==1 
}
foreach var in I II III Jr Sr{
replace Suffix = "`var'" if regexm(firstname, "`var'")==1 & regexm(firstname, "`var'.")!=1 & regexm(firstname, "Ir")!=1 & regexm(firstname, "In")!=1 & regexm(firstname, "Il")!=1 & regexm(firstname, "Is")!=1 & regexm(firstname, "It")!=1 & regexm(firstname, "Iv")!=1 & regexm(firstname, "Ia")!=1 & regexm(firstname, "Im")!=1 & regexm(firstname, "Id")!=1 & regexm(firstname, "Ip")!=1

} 
replace Suffix = "and family" if regexm(firstname, "and family")==1
replace Suffix = "Red" if regexm(firstname, "Red")==1
replace firstname = substr(firstname, 1, strpos(firstname, "Red")-2) if Suffix=="Red"
replace firstname = subinstr(firstname, Suffix, "", .) if Suffix!="" & Suffix!="Red"
g Name = strtrim(firstname) + " " + strtrim(lastname) 
replace Name = strtrim(Name) + " " + strtrim(Suffix) if Suffix!=""

replace Name = strtrim(Name)
*rename A Name
rename B page
rename C Residence
rename D Age
rename E NetWorth
rename F Source

keep year Name Residence Age NetWorth Source page firstname lastname Suffix
foreach var in year Name Residence Age NetWorth Source page firstname lastname Suffix{
	cap replace `var' = strtrim(`var')
}

save "./stata_data/`jibberish'_Berkeley.dta", replace
}


***STILL NEED TO FIX NAMES!
forvalues jibberish = 1994(1)1994{

import excel "./raw_data/Berkeley1994.xlsx", sheet("Sheet1") clear

g year = `jibberish'

replace A = subinstr(A, "fam ily", "family", 1)
g lastname = substr(A, 1, strpos(A, ",")-1)
replace A = substr(A, strpos(A, ",")+1, strlen(A))
g firstname = A



g Suffix = ""
foreach var in Jr Sr{
	replace Suffix = "`var'." if regexm(firstname, "`var'.")==1 
}
foreach var in I II III Jr Sr{
replace Suffix = "`var'" if regexm(firstname, "`var'")==1 & regexm(firstname, "`var'.")!=1 & regexm(firstname, "Ir")!=1 & regexm(firstname, "In")!=1 & regexm(firstname, "Il")!=1 & regexm(firstname, "Is")!=1 & regexm(firstname, "It")!=1 & regexm(firstname, "Iv")!=1 & regexm(firstname, "Ia")!=1 & regexm(firstname, "Im")!=1 & regexm(firstname, "Id")!=1 & regexm(firstname, "Ip")!=1
}
replace Suffix = "and family" if regexm(firstname, "and family")==1
replace Suffix = "Red" if regexm(firstname, "Red")==1
replace firstname = substr(firstname, 1, strpos(firstname, "Red")-2) if Suffix=="Red"
replace firstname = subinstr(firstname, Suffix, "", .) if Suffix!="" & Suffix!="Red"
g Name = strtrim(firstname) + " " + strtrim(lastname) 
replace Name = strtrim(Name) + " " + strtrim(Suffix) if Suffix!=""

replace Name = strtrim(Name)
*rename A Name
rename B page
rename C Residence
rename D Age
rename E NetWorth
rename F Source
keep year Name Residence Age NetWorth Source page firstname lastname Suffix
foreach var in year Name Residence Age NetWorth Source page firstname lastname Suffix{
	cap replace `var' = strtrim(`var')
}
save "./stata_data/`jibberish'_Berkeley.dta", replace
}
***STILL NEED TO FIX NAMES!
forvalues jibberish = 2000(1)2000{

import excel "./raw_data/top400.xlsx", sheet("`jibberish'") clear

g year = `jibberish'
drop if A==""
g Name = substr(A, 1, strpos(A, "$")-1)
drop if Name==""
g temp = substr(A, strpos(A, "$"), strlen(A))
g NetWorth = substr(temp, 1 , strpos(temp, "illion")+6)
g temp2 = substr(temp, strpos(temp, "illion")+6, strlen(temp))
g Source = substr(temp2, 1, strpos(temp2, ". "))
g temp3 = substr(temp2, strpos(temp2, ". ")+1, strlen(temp2))
egen children = noccur(temp3),  string("children")
g Residence = substr(temp3, 1, strpos(temp3, ". "))
g temp4 = substr(temp3, strpos(temp3, ". ")+1, strlen(temp3))
g Age = substr(temp4, 1, strpos(temp4, ". ")+1) if regexm(temp4, ". ")==1
replace Age = "." if strlen(strtrim(Age))>3
g Other = substr(temp4, strpos(temp4, ". ")+1, strlen(temp4))

/*
g nm

rename Name firstname
g Suffix = ""
foreach var in Jr Sr{
	replace Suffix = "`var'." if regexm(firstname, "`var'.")==1 
}
foreach var in I II III Jr Sr{
	replace Suffix = "`var'" if regexm(firstname, "`var'")==1 & regexm(firstname, "`var'.")!=1 & regexm(firstname, "Ir")!=1 & regexm(firstname, "In")!=1 & regexm(firstname, "Il")!=1

}
replace Suffix = "and family" if regexm(firstname, "and family")==1
replace Suffix = "Red" if regexm(firstname, "Red")==1
replace firstname = substr(firstname, 1, strpos(firstname, "Red")-2) if Suffix=="Red"
replace firstname = subinstr(firstname, Suffix, "", .) if Suffix!="" & Suffix!="Red"
g temp_fn = strreverse(strtrim(firstname))
g test = 

g Name = strtrim(firstname) + " " + strtrim(lastname) 
replace Name = strtrim(Name) + " " + strtrim(Suffix) if Suffix!=""
*/
keep year Name Residence Age NetWorth Source Other
duplicates drop
compress
foreach var in year Name Residence Age NetWorth Source Other{
	cap replace `var' = strtrim(`var')
}
tempfile `jibberish'
save ``jibberish''
*save "./stata_data/`jibberish'.dta", replace
}

use "./stata_data/ForbesTop4002011_2017.dta", clear
unab test: _all
foreach var of local test{
	tostring `var', replace force
}
save "./stata_data/FORBES_1982_2017.dta", replace
forvalues i = 1982(1)1988{
use ``i'', clear
unab test: _all
foreach var of local test{
	tostring `var', replace force
}
append using "./stata_data/FORBES_1982_2017.dta"
save "stata_data/FORBES_1982_2017.dta", replace
}
forvalues i = 1989(1)1994{
	use "stata_data/`i'_Berkeley.dta", clear
	unab test: _all
	foreach var of local test{
		tostring `var', replace force
	}
	append using "./stata_data/FORBES_1982_2017.dta"
	save "./stata_data/FORBES_1982_2017.dta", replace
}
forvalues i = 1995(1)2010{
	use ``i'', clear
	unab test: _all
	foreach var of local test{
		tostring `var', replace force
	}
	append using "./stata_data/FORBES_1982_2017.dta"
	duplicates drop
	save "./stata_data/FORBES_1982_2017.dta", replace
}
use `2002', clear
unab test: _all
foreach var of local test{
	tostring `var', replace force
}
cap g year = "2002"
append using "./stata_data/FORBES_1982_2017.dta"
duplicates drop

g SUFFIX = ""
foreach var in firstname lastname Suffix suffix Name{
	replace `var' = strtrim(`var')
	replace `var' = subinstr(`var', ".", "",.)
	replace `var' = subinstr(`var', "  ", " ", .)
	replace `var' = strproper(`var')
	g temp = ""
	foreach vars in Jr Sr Iii Ii {
	replace temp = "`vars'" if regexm(`var', " `vars'")==1
	replace `var' = strtrim(subinstr(`var', " `vars'", "", .))
	replace SUFFIX = temp if SUFFIX ==""
	replace `var' = strtrim(`var')
	replace temp = ""
	}
	drop temp
}

replace SUFFIX = "I" if Name == "William Koch I"
replace Name = "William Koch" if Name == "William Koch I"


/*
// Add observations
local addition = _N + 2
display `addition'
set obs `addition'

local obsmin1 = _N - 1
local obsmin2 = _N - 2

// Add in Charles Johnson for 2011
replace Name = "Charles Johnson" in `obsmin1'
replace NetWorth = "$4.4 B" in `obsmin1'
replace Source = "Financial Services" in `obsmin1'
replace prev_rank = "74" in `obsmin1'
replace prev_NetWorth = "$4 B" in `obsmin1'
replace year = "2011" in `obsmin1'
replace Rank = "72" in `obsmin1'
replace Age = "78" in `obsmin1'
replace Residence = "Hillsborough, California" in `obsmin1'
replace lastname = "Johnson" in `obsmin1'
replace firstname = "Charles" in `obsmin1'
replace city = "Hillsborough" in `obsmin1'
replace state = "Calif" in `obsmin1'

// Add in Walter Hubert Annenberg for 2001
replace Name = "Walter Hubert Annenberg" in `obsmin2'
replace NetWorth = "$4.0 B" in `obsmin2'
replace Source = "Publishing" in `obsmin2'
replace prev_NetWorth = "$4 B" in `obsmin2'
replace year = "2001" in `obsmin2'
replace Rank = "42" in `obsmin2'
replace Age = "93" in `obsmin2'
replace Residence = "Wynewood, PA" in `obsmin2'
replace lastname = " Hubert Annenberg" in `obsmin2'
replace firstname = "Walter" in `obsmin2'
replace city = "Wynewood" in `obsmin2'
replace state = "Pa" in `obsmin2'
*/

save "./stata_data/FORBES_1982_2017.dta", replace
