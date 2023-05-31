********************************************************************************
// Figure 4.5
// Trends in prosperity gap various thresholds
********************************************************************************
clear
tempfile datasofar
save 	`datasofar', emptyok

local povline "15 20 25 50"

foreach pl in `povline' {

	use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear									

	gen poor = welf < `pl' 									// indicator for poor

	// Sterck index with epsilons
	gen 	welf_adj = welf
	replace welf_adj = $welf_fl if welf<$welf_fl
	
	gen 	welf_w = welf_adj
		
	gen 	pg_w = `pl'/welf_w  							

	collapse pg_w [aw=pop], by(year)

	gen povline = `pl'

	append using `datasofar'
	save 		 `datasofar', replace

}

use `datasofar', clear
reshape wide pg_w, i(year) j(povline)

twoway  connected pg_w15 year, lp(shortdash_dot) ms(t) || ///
		connected pg_w20 year, lp(shortdash) ms(dh) || ///
		connected pg_w25 year, lp(solid) lc(black) ms(o) mc(black) || ///
		connected pg_w50 year, lp(solid) ms(oh)  ///
		ylabel(0(5)25) ///
		legend(row(1) pos(6) order(1 "$15/day" ///
				2 "$20/day" 3 "$25/day" 4 "$50/day")) ///
		ytitle("Prosperity Gap""{it:Average factor by which incomes must be}""{it:multiplied to reach prosperity standard}") xtitle("")		///
		scheme(white_tableau) name(fig1, replace)			
		
graph combine fig1, iscale(*1.2) scheme(white_tableau) 	
graph export "${outputpath}Figure 4_5.png", replace

********************************************************************************

exit