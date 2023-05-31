*******************************************************************************
// Table 4.1 
// Prosperity gap comparison by region, income group, and select countries 
*******************************************************************************

use 		 "${intermediatedatapath}CountryData_Main2019.dta", clear
append using "${intermediatedatapath}GlobalData_Main.dta"
append using "${intermediatedatapath}RegionData_Main2019.dta"
append using "${intermediatedatapath}IncomeGroupData_Main2019.dta"

// keep specific year and countries
keep if year==2019	
keep if inlist(code,"BGD","CHN","DEU","IDN","IND","JPN","NGA") | ///
		inlist(code,"FRA","USA","BRA","BOL","ZAF","ETH") | ///
		inlist(code,"BFA","MLI","COL","PER") | ///
		missing(code)

// gen sorting variable for table	
replace region_code = "zOHI" if region_code=="OHI"	
sort code region_code incgroup_historical
gen num = _n
replace num = num - 1 
replace num = 1 if incgroup_historical=="Low income"
replace num = 2 if incgroup_historical=="Lower middle income"
replace num = 3 if incgroup_historical=="Upper middle income"
replace num = 4 if incgroup_historical=="High income"

// rename group variable
gen 	group = code 
replace group = region_code 		if missing(group) & !missing(region_code)
replace group = incgroup_historical if missing(group) & !missing(incgroup_historical)
replace group = "WLD" 				if missing(group) 
replace num = _N if group == "WLD"
drop region_code incgroup_historical
sort num 
drop num

gen poor_25 = pop * fgt0_25/100														// Number of poor under $25 threshold

keep  group w25 fgt0_25 poor_25 
order group w25 fgt0_25 poor_25

*********************
*** save to excel ***
*********************

expand 2 if _n==_N																// create an empty row before global estimates
local num = _N-1
replace group 	= "" in `num'
replace w25 	= . in `num'
replace fgt0_25 = . in `num'
replace poor_25	= . in `num'	

mkmat w25, 		mat(W)
mkmat fgt0_25, 	mat(H)
mkmat poor_25, 	mat(P)

putexcel set "${outputpath}Tables.xlsx", modify sheet(Table4_1, replace)

putexcel C1 = "Prosperity Gap, Multiple by Which Income Must Increase" , txtwrap hcenter vcenter bold
putexcel D1 = "Share of Population below Prosperity Threshold, %" , 	 txtwrap hcenter vcenter bold
putexcel E1 = "Millions of People below Prosperity Threshold" , 		 txtwrap hcenter vcenter bold

putexcel A2:A5 	 = "Income group", 		txtrotate(90) merge txtwrap hcenter vcenter
putexcel A6:A12  = "Region", 			txtrotate(90) merge txtwrap hcenter vcenter
putexcel A13:A29 = "Select countries", 	txtrotate(90) merge txtwrap hcenter vcenter

putexcel B2 = "Low income"
putexcel B3 = "Lower middle income"
putexcel B4 = "Upper middle income"
putexcel B5 = "High income"
putexcel B6 = "East Asia & Pacific"
putexcel B7 = "Europe & Central Asia"
putexcel B8 = "Latin America & Caribbean"
putexcel B9 = "Middle East & North Africa"
putexcel B10 = "South Asia"
putexcel B11 = "Sub-Saharan Africa"
putexcel B12 = "Rest of the world"
putexcel B13 = "Burkina Faso"
putexcel B14 = "Bangladesh"
putexcel B15 = "Bolivia"
putexcel B16 = "Brazil"
putexcel B17 = "China"
putexcel B18 = "Colombia"
putexcel B19 = "Germany"
putexcel B20 = "Ethiopia"
putexcel B21 = "France"
putexcel B22 = "Indonesia"
putexcel B23 = "India"
putexcel B24 = "Japan"
putexcel B25 = "Mali"
putexcel B26 = "Nigeria"
putexcel B27 = "Peru"
putexcel B28 = "United States"
putexcel B29 = "South Africa"
putexcel B31 = "Global"

putexcel C2 = matrix(W), nformat(##0.0)
putexcel D2 = matrix(H), nformat(##0.0)
putexcel E2 = matrix(P), nformat(#,##0)

*******************************************************************************
exit