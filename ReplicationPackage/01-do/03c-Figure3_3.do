********************************************************************************
// Figure 3.3
// Elasticities of various welfare, poverty, and inequality measures 
********************************************************************************

use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear
keep if inlist(year,1990,2019)

gen 	welf_adj = welf
replace welf_adj = $welf_fl if welf<$welf_fl 									// $0.50 floor 
	
// poverty measure - $6.85
gen 	welf_c685 = welf_adj		
replace welf_c685 = $povl3 if welf_adj>=$povl3						
	

// 100 percentiles 
egen perc = xtile(welf_adj), by(year) n(100) weight(pop)							
collapse welf_* (rawsum) pop [aw=pop], by(year perc)							// average welfare and prosperity gap for each percentile


************************
*** POVERTY MEASURES ***
************************

// FGT measures and Watts
gen p_fgt0_685 = ( welf_adj < $povl3 )
gen p_fgt1_685 = ( $povl3 - welf_c685)/$povl3
gen p_fgt2_685 = (($povl3 - welf_c685)/$povl3 )^2
gen p_watt_685 = ln($povl3) - ln(welf_c685)

foreach v of varlist p_fgt1_685 p_fgt2_685 p_watt_685 {
	replace `v' = 0 if p_fgt0_685==0
}

// prosperity gap
gen 	p_c685 = $povl3 / welf_c685 											// C measure
replace p_c685 = 1 if p_fgt0_685==0

gen 	p_p685 = p_c685 - 1													// P measure


keep perc year p_*


***********************
*** % CONTRIBUTIONS ***
***********************																// total number of bins	

merge m:1 year using "${intermediatedatapath}GlobalData_Main.dta", nogen keep(1 3) keepusing(watt_685 p685 fgt0_685 fgt1_685 fgt2_685)

ren *685 *685_
reshape wide p_* watt_685 p685 fgt0_685 fgt1_685 fgt2_685, i(perc) j(year)


gen hc = (p_fgt0_685_2019 - p_fgt0_685_1990)/(2019-1990)/(fgt0_685_1990/100)

gen pg = (p_fgt1_685_2019 - p_fgt1_685_1990)/(2019-1990)/(fgt1_685_1990/100)

gen sg = (p_fgt2_685_2019 - p_fgt2_685_1990)/(2019-1990)/(fgt2_685_1990/100)

gen wa = (p_watt_685_2019 - p_watt_685_1990)/(2019-1990)/(watt_685_1990/100)

gen p  = (p_p685_2019 - p_p685_1990)/(2019-1990)/p685_1990

********************************************
************* FIGURE 4.4 *******************
********************************************

twoway  connected p perc, lp(solid) lc(black) ms(none) || ///
		connected hc perc, lp(longdash) lc(sand) ms(none) || ///
		connected pg perc, lp(shortdash) lc(blue) ms(none) || ///
		connected sg  perc, lp(dash) lc(green) ms(none) || ///
		connected wa  perc, lp(shortdash_dot) lc(red) ms(none)  ///
		yline(0,lp(solid) lc(gray*0.5)) ///
		xlabel(,grid) ylabel(,grid format(%5.2f)) ///
		legend(row(1) pos(6) order(1 "{it:P}" 2 "FGT{subscript:0}" 3 "FGT{subscript:1}" ///
				4 "FGT{subscript:2}" 5 "Watts")) ///
		ytitle("Contribution to % Change" "in Poverty", xoffset(-3) size(medium)) ///
		xtitle("Global percentile, 1990", size(medium))		///
		scheme(lean1) name(welfare, replace)

	
graph combine welfare, iscale(*1.3) row(1) scheme(white_tableau) 
graph display, xsize(7) ysize(5)	
graph export "${outputpath}Figure 3_3.png", replace		

********************************************************************************
exit