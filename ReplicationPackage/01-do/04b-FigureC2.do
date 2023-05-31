*******************************************************************************
// Figure C.2
// Contribution of each global percentile in overall P(y,z) and comparators in 2019 
*******************************************************************************
*** INPUT PARAMETERS ***
global yr	   "2019"	// YEAR TO ESTIMATE PG

*******************************************************************************

use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear
keep if year == $yr 												// estimates for particular year

gen 	welf_adj = welf
replace welf_adj = $welf_fl if welf<$welf_fl 						// $0.50 floor uniformly applied to all distributions

*************************
*** 1. PROSPERITY GAP ***
*************************

xtile perc = welf_adj [aw=pop], n(100)								// global percentiles

	
gen 	welf_c  = welf_adj
replace welf_c  = $povl3 if welf_adj>$povl3								

gen 	c 		= $povl3 / welf_c									// c and p measures			
gen 	p 		= c - 1


qui apoverty welf_adj [aw=pop], line($povl3) h pgr fgt3 w			// aggregate poverty measures for the entire distirbution 
gen f0 = `r(head_1)'												// headcount
gen f1 = `r(pogapr_1)' 												// poverty gap
gen f2 = `r(fogto3_1)' 												// squared poverty gap
gen w  = `r(watts_1)'												// watts index

gen f0perc = . 
gen f1perc = .
gen f2perc = .
gen wperc  = .
levelsof perc 
foreach i in `r(levels)' {											// poverty measures for each percentile
	qui apoverty welf_adj [aw=pop] if perc==`i', line($povl3) h pgr fgt3 w
	replace f0perc = `r(head_1)'   if perc==`i'
	replace f1perc = `r(pogapr_1)' if perc==`i'
	replace f2perc = `r(fogto3_1)' if perc==`i'
	replace wperc  = `r(watts_1)'  if perc==`i'
}	

************************
*** 2. CONTRIBUTIONS ***
************************

preserve
collapse p f0 f1 f2 w [aw=pop], by(year)
tempfile wld
save 	`wld'
restore

ren p  pperc

collapse pperc f0perc f1perc f2perc wperc [aw=pop], by(year perc)

merge m:1 year using `wld', nogen keep(3)

// contribution and cumulative contribution for figure
foreach var of varlist p f0 f1 f2 w {
	gen `var'_c 	= `var'perc/`var' 
	gen `var'_c_cum = sum(`var'_c)
}

sum f0																			// poverty rate for figure
local povline = `r(mean)'

tw  line p_c_cum perc if inrange(perc,0,60), lc(navy) lp(solid) || ///
	line f0_c_cum perc if inrange(perc,0,60), lc(orange) lp(shortdashdotshortdash) || ///
	line f1_c_cum perc if inrange(perc,0,60), lc(forest_green) lp(longdash) || ///
	line f2_c_cum perc if inrange(perc,0,60), lc(blue) lp(dot) || ///
	line w_c_cum perc if inrange(perc,0,60), lc(sand) lp(shortdash) || ///
	scatter perc perc if inrange(perc,0,60), ms(none) xaxis(2) ///
	xline(`povline', lp(shortdash) lc(gray*0.5)) ///
	xlabel(0(10)60,grid ) ylabel(,grid) xlabel(`povline' "$6.85", axis(2)) ///
	legend(pos(6) row(2) order(1 "{it:P}" 2 "FGT{subscript:0}" 3 "FGT{subscript:1}" 4 "FGT{subscript:2}" 5 "Watts")) ///
	xtitle("Percentile of Income Distribution (p)") ///
	ytitle("Contribution of People Below p") xtitle("", axis(2)) ///
	scheme(lean1) name(cont_p, replace)
	
graph combine cont_p, scheme(lean1) iscale(*1.1) xsize(12) ysize(12)
graph export "${outputpath}Figure C2.png", replace

********************************************************************************

exit