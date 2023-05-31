*******************************************************************************
// Figure C.1
// Contribution of each global percentile in overall W(y,z) and mean in 2019 
*******************************************************************************
*** INPUT PARAMETERS ***
global yr	   "2019"	// YEAR TO ESTIMATE PG

*******************************************************************************

use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear
keep if year == $yr 															// estimates for particular year

gen 	welf_adj = welf
replace welf_adj = $welf_fl if welf<$welf_fl 									// $0.50 floor uniformly applied to all distributions

******************************************************
*** 1. PROSPERITY GAP, MEAN, AND GLOBAL PERCENTILE ***
******************************************************
	
gen 	welf_w  = welf_adj														// welfare measure
gen 	w 		=   $povl4 / welf_w						

gen ybar = welf_adj																// mean

xtile perc = welf_adj [aw=pop], n(100)											// global percentile


************************
*** 2. POVERTY RATES ***
************************

qui apoverty welf_adj [aw=pop], line($povl1) h 									// FOR FIGURE
gen f215 = `r(head_1)'
qui apoverty welf_adj [aw=pop], line($povl2) h
gen f365 = `r(head_1)'
qui apoverty welf_adj [aw=pop], line($povl3) h
gen f685 = `r(head_1)'
qui apoverty welf_adj [aw=pop], line($povl4) h
gen f25 = `r(head_1)'

************************
*** 3. CONTRIBUTIONS ***
************************

preserve
collapse w ybar [aw=pop], by(year)
tempfile wld
save 	`wld'
restore

ren w wperc
ren ybar ybarperc

collapse wperc ybarperc f215 f365 f685 f25 [aw=pop], by(year perc)

merge m:1 year using `wld', nogen keep(3)


gen w_c = wperc/w 																// contribution of each percentile to W
gen y_c = ybarperc/ybar															// contribution of each percentile to Mean

gen w_c_cum = sum(w_c)
gen y_c_cum = sum(y_c) 

foreach var of varlist f215 f365 f685 f25 {										// poverty rates for figure
	sum `var'
	local k = substr("`var'",2,.)
	local poor`k' = `r(mean)'
}


tw  line w_c_cum perc, lc(navy) || ///
	line y_c_cum perc, lc(orange) || ///
	line perc perc, lp(solid) lc(gray) xaxis(2) || ///
	pcarrowi 20 20 54 20, lc(navy) color(navy) msize(3) barbs(2) lw(thick) ||  ///
	pcarrowi 80 80 33 80, lc(orange) color(orange) msize(3) barbs(2) lw(thick) ///
	xline(`poor215', lp(shortdash) lc(gray*0.5)) ///
	xline(`poor365', lp(shortdash) lc(gray*0.5)) ///
	xline(`poor685', lp(shortdash) lc(gray*0.5)) ///
	xline(`poor25', lp(shortdash) lc(gray*0.5)) ///
	xlabel(,grid ) ylabel(,grid) xlabel(`poor215' "$2.15" `poor365' "$3.65" `poor685' "$6.85" `poor25' "$25.00", axis(2)) ///
	legend(pos(6) row(1) order(1 "{it:W}" 2 "Mean" 5 "45{c 176} line")) ///
	xtitle("Percentile of Income Distribution (p)") xtitle("", axis(2)) ///
	ytitle("Contribution of People Below p") ///
	scheme(lean1) name(cont, replace)
	
graph combine cont, scheme(lean1) iscale(*1.1) xsize(12) ysize(12)
graph export "${outputpath}Figure C1.png", replace


********************************************************************************

exit
