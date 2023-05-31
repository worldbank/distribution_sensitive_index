********************************************************************************
// Figure 3.2, panels A and B
// GIC and Elasticities of poverty measures 
********************************************************************************

// Global GIC for Panel A
use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear
keep if inlist(year,1990,2019)
gen 	welf_adj = welf									
replace welf_adj = $welf_fl if welf < $welf_fl 									// welfare floor at $0.50

egen perc = xtile(welf_adj), by(year) n(100) weight(pop)

collapse welf_adj [aw=pop], by(year perc)										// average welfare of each percentile

reshape wide welf_adj, i(perc) j(year)

gen gwelf1990_2019 = ln(welf_adj2019/welf_adj1990)/(2019-1990) * 100 			// annualized welfare growth of each percentile

keep perc gwelf1990_2019

tempfile gic
save 	`gic'

// Elasticities of W for Panel B
use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear
keep if year==1990

gen 	welf_adj = welf
replace welf_adj = $welf_fl if welf<$welf_fl 									// $0.50 floor 
	
// censored measure
gen 	welf_c685 = welf_adj		
replace welf_c685 = $povl3 if welf_adj>=$povl3								

// 100 percentiles 
egen perc = xtile(welf_adj), by(year) n(100) weight(pop)							
collapse welf_* (rawsum) pop [aw=pop], by(year perc)							// average welfare and prosperity gap for each percentile


********************
*** ELASTICITIES ***
********************

// estimates to calculate elasticity		
gen N = 100																		// total number of bins	

merge m:1 year using "${intermediatedatapath}GlobalData_Main.dta", nogen keep(1 3)


// POVERTY MEASURES, $6.85 
gen 	e_p_685    = - $povl3 / (N * p685 * welf_c685)						
replace e_p_685    = 0 if welf_adj >= $povl3

gen 	e_c_685    = - $povl3 / (N * c685 * welf_c685)							// e for the censored version	
replace e_c_685    = 0 if welf_adj >= $povl3

gen 	e_fgt1_685 = - welf_adj / (N * fgt1_685/100 * $povl3)
replace e_fgt1_685 = 0 if welf_adj >= $povl3 

gen 	e_fgt2_685 = - 2 * welf_adj * (1 - welf_adj/$povl3) / (N * fgt2_685/100 * $povl3)
replace e_fgt2_685 = 0 if welf_adj >= $povl3 

gen 	e_watt_685 = - 1 / (N * watt_685/100) 
replace e_watt_685 = 0 if welf_adj >= $povl3 


*********************************************
************* FIGURE 3.2A *******************
*********************************************

merge 1:1 perc using `gic', nogen

twoway connected gwelf1990_2019 perc, ms(oh) lc(navy) mc(navy) || ///
	line gwelf1990_2019 perc, lc(none) xaxis(2) ///
	yline(1.5, lp(dash) lc(sand)) ///
	xlabel(0(20)100, grid)  xtitle("") ///
	ylabel(0(1)4, grid format(%5.2f)) ytitle("Average Annual Growth, %", size(medium)) ///
	xlabel(38 "$2.15" 69 "$6.85" 86 "$25.00", axis(2)) xtitle("",axis(2)) ///
	xline(38, lp(shortdash) lc(gray*0.5)) ///
	xline(69, lp(shortdash) lc(gray*0.5)) ///
	xline(86, lp(shortdash) lc(gray*0.5)) ///
	title("Panel A: Global Growth Incidence Curve 1990-2019", size(medium)) ///
	scheme(lean1) name(gic19902019, replace) legend(off)


*********************************************
************* FIGURE 3.2B *******************
*********************************************

twoway  connected e_p_685 	 perc, lp(solid) lc(black) ms(none) || ///
		connected e_fgt1_685 perc, lp(shortdash) lc(blue) ms(none) || ///
		connected e_fgt2_685 perc, lp(dash) lc(green) ms(none) || ///
		connected e_watt_685 perc, lp(shortdash_dot) lc(red) ms(none) ///
		xlabel(,grid) ylabel(,grid format(%5.2f)) ///
		legend(row(1) pos(6) order(1 "{it:P}" 2 "FGT{subscript:1}" ///
				3 "FGT{subscript:2}" 4 "Watts")) ///
		ytitle("Elasticity", size(medium)) xtitle("Global percentile, 1990", size(medium))		///
		title("Panel B:  Elasticities of Poverty Measures to Income", size(medium)) ///
		scheme(lean1) name(pov, replace)	

	
graph combine gic19902019 pov, iscale(*1.3) row(2) scheme(white_tableau) 
graph display, xsize(10) ysize(15)	
graph export "${outputpath}Figure 3_2.png", replace	

********************************************************************************
exit
