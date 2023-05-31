********************************************************************************
// Figure E.2
// Elasticities of various welfare, poverty, and inequality measures 
********************************************************************************

use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear
keep if inlist(year,1990,2019)

gen 	welf_adj = welf
replace welf_adj = $welf_fl if welf<$welf_fl 									// $0.50 floor 
				
// poverty measure - $2.15
gen 	welf_c215 = welf_adj
replace welf_c215 = $povl1 if welf_adj>=$povl1						
	

// 100 percentiles 
egen perc = xtile(welf_adj), by(year) n(100) weight(pop)							
collapse welf_* (rawsum) pop [aw=pop], by(year perc)							// average welfare and prosperity gap for each percentile

merge m:1 year using "${intermediatedatapath}GlobalData_Main.dta", nogen keep(1 3)


************************
*** POVERTY MEASURES ***
************************

// FGT measures and Watts
gen p_fgt0_215 = ( welf_adj < $povl1 )
gen p_fgt1_215 = ( $povl1 - welf_c215)/$povl1
gen p_fgt2_215 = (($povl1 - welf_c215)/$povl1 )^2
gen p_watt_215 = ln($povl1) - ln(welf_c215)

foreach v of varlist p_fgt1_215 p_fgt2_215 p_watt_215 {
	replace `v' = 0 if p_fgt0_215==0
}

// prosperity gap
gen 	p_c215 = $povl1 / welf_c215 											// C measure
replace p_c215 = 1 if p_fgt0_215==0

gen 	p_p215 = p_c215 - 1														// P measure


keep perc year p_*


***********************
*** % CONTRIBUTIONS ***
***********************															

merge m:1 year using "${intermediatedatapath}GlobalData_Main.dta", nogen keep(1 3) keepusing(watt_215 p215 fgt0_215 fgt1_215 fgt2_215)

ren *215 *215_
reshape wide p_* watt_215 p215 fgt0_215 fgt1_215 fgt2_215, i(perc) j(year)


gen hc = (p_fgt0_215_2019 - p_fgt0_215_1990)/(2019-1990)/(fgt0_215_1990/100)

gen pg = (p_fgt1_215_2019 - p_fgt1_215_1990)/(2019-1990)/(fgt1_215_1990/100)

gen sg = (p_fgt2_215_2019 - p_fgt2_215_1990)/(2019-1990)/(fgt2_215_1990/100)

gen wa = (p_watt_215_2019 - p_watt_215_1990)/(2019-1990)/(watt_215_1990/100)

gen p  = (p_p215_2019 - p_p215_1990)/(2019-1990)/p215_1990

	
**************
*** FIGURE ***
**************		
		
twoway  connected p perc, lp(solid) lc(black) ms(none) || ///
		connected hc perc, lp(longdash) lc(sand) ms(none) || ///
		connected pg perc, lp(shortdash) lc(blue) ms(none) || ///
		connected sg  perc, lp(dash) lc(green) ms(none) || ///
		connected wa  perc, lp(shortdash_dot) lc(red) ms(none)  ///
		yline(0,lp(solid) lc(gray*0.5)) ///
		xlabel(,grid) ylabel(,grid format(%5.2f)) ///
		legend(row(1) pos(6) order(1 "{it:P}" 2 "FGT{subscript:0}" 3 "FGT{subscript:1}" ///
				4 "FGT{subscript:2}" 5 "Watts")) ///
		ytitle("Contribution to % Change" "in Poverty", size(medium) xoffset(-3)) ///
		xtitle("Global percentile, 1990", size(medium))		///
		scheme(lean1) name(welfare, replace)

	
graph combine welfare, iscale(*1.3) row(1) scheme(white_tableau) 
graph display, xsize(7) ysize(5)	
graph export "${outputpath}Figure E2.png", replace


********************************************************************************
exit

