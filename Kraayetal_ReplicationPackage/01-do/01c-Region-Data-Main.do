*******************************************************************************
/*
This do file produces PIP region level data for user defined year 
	used for the figures and charts in Kraay r al.
Note welfare floor implemented at $0.50 for all distributions.
*/
*******************************************************************************

foreach year in $ryr {

use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear
keep if year == `year' 									// estimates for particular year
egen id = group(region_code)

gen 	welf_adj = welf
replace welf_adj = $welf_fl if welf<$welf_fl 			// $0.50 floor uniformly applied to all distributions

***************************
*** 1. POVERTY MEASURES ***
***************************
gen fgt0_215 = .
gen fgt1_215 = .
gen fgt2_215 = .
gen watt_215 = .
gen fgt0_365 = .
gen fgt1_365 = .
gen fgt2_365 = .
gen watt_365 = .
gen fgt0_685 = .
gen fgt1_685 = .
gen fgt2_685 = .
gen watt_685 = .
gen fgt0_25 = .
gen fgt1_25 = .
gen fgt2_25 = .
gen watt_25 = .
gen ybar_b40 = welf_adj if obs<=400						// For the mean using the b40 of each country

levelsof id 
foreach i in `r(levels)' {	
	qui apoverty welf_adj [aw=pop] 	 if id==`i', line($povl1) h pgr fgt3 w
	replace fgt0_215 = `r(head_1)'   if id==`i'
	replace fgt1_215 = `r(pogapr_1)' if id==`i'
	replace fgt2_215 = `r(fogto3_1)' if id==`i'
	replace watt_215 = `r(watts_1)'	 if id==`i'
	
	qui apoverty welf_adj [aw=pop]	 if id==`i', line($povl2) h pgr fgt3 w
	replace fgt0_365 = `r(head_1)' 	 if id==`i'
	replace fgt1_365 = `r(pogapr_1)' if id==`i'
	replace fgt2_365 = `r(fogto3_1)' if id==`i'
	replace watt_365 = `r(watts_1)'	 if id==`i'
	
	qui apoverty welf_adj [aw=pop]   if id==`i', line($povl3) h pgr fgt3 w
	replace fgt0_685 = `r(head_1)'   if id==`i'
	replace fgt1_685 = `r(pogapr_1)' if id==`i'
	replace fgt2_685 = `r(fogto3_1)' if id==`i'
	replace watt_685 = `r(watts_1)'	 if id==`i'
	
	qui apoverty welf_adj [aw=pop] 	  if id==`i', line($povl4) h pgr fgt3 w
	replace fgt0_25 = `r(head_1)' 	  if id==`i'
	replace fgt1_25 = `r(pogapr_1)'   if id==`i'
	replace fgt2_25 = `r(fogto3_1)'   if id==`i'
	replace watt_25 = `r(watts_1)'	  if id==`i'
}


******************************
*** 2. INEQUALITY MEASURES ***
******************************
gen ybar = .							// Overall mean
gen sen  = . 							// Sen index
gen awi1 = .							// Atkinson welfare index (1)
gen awi2 = .							// Atkinson welfare index (2)
gen gini = .							// Gini index
gen atk1 = .							// Atkinson index (1)
gen atk2 = .							// Atkinson index (2)
gen mld  = .							// Mean Log Deviation

sum id
local id_max = `r(max)'
qui ineqdeco welf_adj [aw=pop], welfare bygroup(id)
forval i = 1/`id_max' {
	replace ybar = `r(mean_`i')'  if id==`i'
	replace sen	 = `r(wgini_`i')' if id==`i'
	replace awi1 = `r(ede1_`i')'  if id==`i'
	replace awi2 = `r(ede2_`i')'  if id==`i'
	
	replace gini = `r(gini_`i')' * 100 if id==`i'
	replace atk1 = `r(a1_`i')' 	 * 100 if id==`i'
	replace atk2 = `r(a2_`i')' 	 * 100 if id==`i'
	replace mld  = `r(ge0_`i')'  * 100 if id==`i'
} 

*************************
*** 3. PROSPERITY GAP ***
*************************
	
// (a) welfare measure
gen 	welf_w = welf_adj								
	
// (b) censored measure (censored index at various thresholds)
gen 	welf_c215 = welf_adj												
replace welf_c215 = $povl1 if welf_adj>=$povl1
gen 	welf_c365 = welf_adj
replace welf_c365 = $povl2 if welf_adj>=$povl2
gen 	welf_c685 = welf_adj
replace welf_c685 = $povl3 if welf_adj>=$povl3
gen 	welf_c25  = welf_adj
replace welf_c25  = $povl4 if welf_adj>=$povl4
											
	
// (c) inequality measure
gen 	welf_i = welf_adj			


gen 	w215 =   $povl1 / welf_w
gen 	w365 =   $povl2 / welf_w
gen 	w685 =   $povl3 / welf_w						
gen 	w25  =   $povl4 / welf_w	
gen 	c215 =   $povl1 / welf_c215 
gen 	c365 =   $povl2 / welf_c365 
gen 	c685 =   $povl3 / welf_c685 
gen 	c25  =   $povl4 / welf_c25 
gen 	i    =    ybar  / welf_i
	
	
	
collapse *25 *215 *365 *685 i gini sen mld atk* awi* ybar* (rawsum) pop [aw=pop], by(region_code year)

// (d) poverty measure, P = C -1 
foreach l in 215 365 685 25 {
	gen p`l' = c`l' - 1
}
	
	
********************
*** DATA CLEANUP ***
********************

order year pop w* c* p* i ybar* fgt* watt* gini sen mld atk* awi* 

label var pop 	  "Population, millions"

label var w215 	  "Welfare measure, z=$povl1/day"
label var w365 	  "Welfare measure, z=$povl2/day"
label var w685 	  "Welfare measure, z=$povl3/day"
label var w25 	  "Welfare measure, z=$povl4/day"
label var c215 	  "Censored measure, z=$povl1/day"
label var c365 	  "Censored measure, z=$povl2/day"
label var c685 	  "Censored measure, z=$povl3/day"
label var c25 	  "Censored measure, z=$povl4/day"
label var p215 	  "Poverty measure, z=$povl1/day"
label var p365 	  "Poverty measure, z=$povl2/day"
label var p685 	  "Poverty measure, z=$povl3/day"
label var p25 	  "Poverty measure, z=$povl4/day"
label var i 	  "Inequality measure, z=ybar"

label var ybar    "Global mean"
label var sen     "Sen index"
label var awi1    "Atkinson welfare index (1)"
label var awi2    "Atkinson welfare index (2)"

label var fgt0_215 "Headcount under $povl1/day, %"
label var fgt1_215 "Poverty gap under $povl1/day, %"
label var fgt2_215 "Poverty severity under $povl1/day, %"
label var watt_215 "Watts index under $povl1/day"

label var fgt0_365 "Headcount under $povl2/day"
label var fgt1_365 "Poverty gap under $povl2/day, %"
label var fgt2_365 "Poverty severity under $povl2/day, %"
label var watt_365 "Watts index under $povl2/day"

label var fgt0_685 "Headcount under $povl3/day"
label var fgt1_685 "Poverty gap under $povl3/day, %"
label var fgt2_685 "Poverty severity under $povl3/day, %"
label var watt_685 "Watts index under $povl3/day"

label var fgt0_25  "Headcount under $povl4/day, %"
label var fgt1_25  "Poverty gap under $povl4/day, %"
label var fgt2_25  "Poverty severity under $povl4/day, %"
label var watt_25  "Watts index under $povl4/day"


label var gini     "Gini index"
label var atk1     "Atkinson index (1)"
label var atk2     "Atkinson index (2)"
label var mld      "Mean Log Deviation"

label var ybar_b40 "Mean income of the bottom 40 percent"

compress
save "${intermediatedatapath}RegionData_Main`year'.dta", replace

}

*******************************************************************************
exit
