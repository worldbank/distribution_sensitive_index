********************************************************************************
// Figure E.1
// Elasticities of various welfare, poverty, and inequality measures 
********************************************************************************

use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear
keep if year==1990

gen 	welf_adj = welf
replace welf_adj = $welf_fl if welf<$welf_fl 									// $0.50 floor 							
	
// poverty measure - $2.15
gen 	welf_c215 = welf_adj
replace welf_c215 = $povl1 if welf_adj>=$povl1						


// 100 percentiles 
egen perc = xtile(welf_adj), by(year) n(100) weight(pop)							
collapse welf_* (rawsum) pop [aw=pop], by(year perc)							// average welfare and prosperity gap for each percentile

merge m:1 year using "${intermediatedatapath}GlobalData_Main.dta", nogen keep(1 3)


********************
*** ELASTICITIES ***
********************

// estimates to calculate elasticity		
egen double tot_i_y   = total(perc * welf_adj)	
gen N = 100																		// total number of bins	


// POVERTY MEASURES, $2.15 
gen 	e_p_215    = - $povl1 / (N * p215 * welf_c215)						
replace e_p_215    = 0 if welf_adj >= $povl1

gen 	e_c_215    = - $povl1 / (N * c215 * welf_c215)							// e for the censored version		
replace e_c_215    = 0 if welf_adj >= $povl1

gen 	e_fgt1_215 = - welf_adj / (N * fgt1_215/100 * $povl1)
replace e_fgt1_215 = 0 if welf_adj >= $povl1 

gen 	e_fgt2_215 = - 2 * welf_adj * (1 - welf_adj/$povl1) / (N * fgt2_215/100 * $povl1)
replace e_fgt2_215 = 0 if welf_adj >= $povl1 

gen 	e_watt_215 = - 1 / (N * watt_215/100) 
replace e_watt_215 = 0 if welf_adj >= $povl1 



**************
*** FIGURE ***
**************

twoway  connected e_p_215 	 perc, lp(solid) lc(black) ms(none) || ///
		connected e_fgt1_215 perc, lp(shortdash) lc(blue) ms(none) || ///
		connected e_fgt2_215 perc, lp(dash) lc(green) ms(none) || ///
		connected e_watt_215 perc, lp(shortdash_dot) lc(red) ms(none) ///
		yline(0, lp(solid) lc(gray)) ///
		xlabel(,grid) ylabel(,grid format(%5.2f)) ///
		legend(row(1) pos(6) order(1 "{it:P}" 2 "FGT{subscript:1}" ///
				3 "FGT{subscript:2}" 4 "Watts")) ///
		ytitle("Elasticity", size(medium)) xtitle("Global percentile, 1990", size(medium))		///
		scheme(lean1) name(pov, replace)	
		
		
graph combine pov, iscale(*1.3) row(1) scheme(white_tableau) 
graph display, xsize(7) ysize(5)	
graph export "${outputpath}Figure E1.png", replace		

********************************************************************************
exit

