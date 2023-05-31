********************************************************************************
// Figure 4.1
// Trend in global prosperity gap
********************************************************************************

use "${intermediatedatapath}GlobalData_Main.dta", clear

twoway connected w25 year, lp(solid) lw(thick) ms(O) ///
	ylabel(4(1)12) ///
	xtitle("") ytitle("Prosperity Gap") ///
	ytitle("Prosperity Gap" "{it:Average factor by which incomes must be multiplied}" ///
		"{it:to reach prosperity standard of $25/day}", size(small)) ///
	scheme(white_tableau) name(f1,replace)
		
graph combine f1, iscale(*1.3) scheme(white_tableau) 	
graph export "${outputpath}Figure 4_1.png", replace	

********************************************************************************
exit	
