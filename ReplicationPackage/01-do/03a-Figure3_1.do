********************************************************************************
// Figure 3.1, panels A and B
// Elasticities of various welfare, poverty, and inequality measures 
********************************************************************************

// Global GIC for Panel A
use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear
keep if inlist(year,1990,2019)
gen 	welf_adj = welf									
replace welf_adj = $welf_fl if welf < $welf_fl 									// welfare floor at $0.50

egen perc = xtile(welf_adj), by(year) n(100) weight(pop)

collapse welf_adj [aw=pop], by(year perc)										// average welfare of each percentile

reshape wide welf_adj, i(perc) j(year)

gen gwelf1990_2019 = ln(welf_adj2019/welf_adj1990)/(2019-1990) * 100 		// annualized welfare growth of each percentile

keep perc gwelf1990_2019

tempfile gic
save 	`gic'

// Elasticities of W for Panel B
use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear
keep if year==1990

gen 	welf_adj = welf
replace welf_adj = $welf_fl if welf<$welf_fl 									// $0.50 floor 
	
// welfare measure
gen 	welf_w = welf_adj								

// 100 percentiles 
egen perc = xtile(welf_adj), by(year) n(100) weight(pop)							
collapse welf_* (rawsum) pop [aw=pop], by(year perc)							// average welfare and prosperity gap for each percentile


********************
*** ELASTICITIES ***
********************

// estimates to calculate elasticity		
gen N = 100																		// total number of bins	

merge m:1 year using "${intermediatedatapath}GlobalData_Main.dta", nogen keep(1 3)


// WELFARE MEASURES
gen e_w 		 = - $povl4 / (N * w25 * welf_w)								// PG, W

gen e_ybar		 = welf_adj / (N * ybar)

gen e_sen 		 = 2/N^2 * (N + 1 - perc) * welf_adj/sen

gen e_awi1		 = 1 / N

gen e_awi2		 = awi2 / (N * welf_adj)


*********************************************
************* FIGURE 3.1A *******************
*********************************************

merge 1:1 perc using `gic', nogen

twoway connected gwelf1990_2019 perc, ms(oh) lc(navy) mc(navy) || ///
	line gwelf1990_2019 perc, lc(none) xaxis(2) ///
	yline(1.5, lp(dash) lc(sand)) ///
	xlabel(0(20)100, grid)  xtitle("") ///
	ylabel(0(1)4, grid) ytitle("Average Annual Growth, %", size(medium)) ///
	xlabel(38 "$2.15" 69 "$6.85" 86 "$25.00", axis(2)) xtitle("",axis(2)) ///
	xline(38, lp(shortdash) lc(gray*0.5)) ///
	xline(69, lp(shortdash) lc(gray*0.5)) ///
	xline(86, lp(shortdash) lc(gray*0.5)) ///
	title("Panel A: Global Growth Incidence Curve 1990-2019", size(medium)) ///
	scheme(lean1) name(gic19902019, replace) legend(off)


*********************************************
************* FIGURE 3.1B *******************
*********************************************

foreach var of varlist e_w  {								// negative of the elasticities for figure
	gen `var'_neg = - 1 * `var'
}

twoway  connected e_w_neg perc, lp(solid) lc(black) ms(none) || ///
		connected e_ybar  perc, lp(longdash) lc(sand) ms(none) || ///
		connected e_sen   perc, lp(shortdash) lc(blue) ms(none) || ///
		connected e_awi1  perc, lp(dash) lc(green) ms(none) || ///
		connected e_awi2  perc, lp(shortdash_dot) lc(red) ms(none)  ///
		xlabel(,grid) ylabel(,grid format(%5.2f)) ///
		legend(row(1) pos(6) order(1 "-1 x {it:W}" 2 "Mean" 3 "Sen" ///
				4 "A{subscript:1}" 5 "A{subscript:2}")) ///
		ytitle("Elasticity", size(medium) xoffset(-3)) xtitle("Global percentile, 1990", size(medium))		///
		title("Panel B: Elasticities of Welfare Measures to Income", size(medium)) ///
		scheme(lean1) name(welfare, replace)

	
graph combine gic19902019 welfare, iscale(*1.3) row(2) scheme(white_tableau) 
graph display, xsize(10) ysize(15)	
graph export "${outputpath}Figure 3_1.png", replace	

********************************************************************************
exit
