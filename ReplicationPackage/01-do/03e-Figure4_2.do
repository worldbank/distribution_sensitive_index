********************************************************************************
// Figure 4.2
// Regional decomposition of the global Prosperity Gap
********************************************************************************

use 		 "${intermediatedatapath}RegionData_Main2019.dta", clear
append using "${intermediatedatapath}RegionData_Main1990.dta"
append using "${intermediatedatapath}RegionData_Main2000.dta"
append using "${intermediatedatapath}RegionData_Main2010.dta"

ren pop popreg
merge m:1 year using "${intermediatedatapath}GlobalData_Main.dta", nogen keepusing(pop) keep(3)

gen pg_w_share = w25 * popreg/pop												// regional share of global PG

keep year region pg_w_share*

reshape wide pg_w_share, i(year) j(region) string


// redefining the size of groups for the chart
egen pg_global 					= rowtotal(pg_w_share*)
egen pg_eap_sas 				= rowtotal(pg_w_shareEAP pg_w_shareSAS)
egen pg_eap_sas_ssa 			= rowtotal(pg_w_shareEAP pg_w_shareSAS pg_w_shareSSA)
egen pg_eap_sas_ssa_lac 		= rowtotal(pg_w_shareEAP pg_w_shareSAS pg_w_shareSSA pg_w_shareLAC)
egen pg_eap_sas_ssa_lac_eca 	= rowtotal(pg_w_shareEAP pg_w_shareSAS pg_w_shareSSA pg_w_shareLAC pg_w_shareECA)
egen pg_eap_sas_ssa_lac_eca_mna = rowtotal(pg_w_shareEAP pg_w_shareSAS pg_w_shareSSA pg_w_shareLAC pg_w_shareECA pg_w_shareMNA)

gen rwi = pg_global - pg_eap_sas_ssa 											// labels for LAC + MNA + ECA + OHI 
sum rwi if year==1990
local rwi_90 = `r(max)'
local rwi_90 : display %4.1f `rwi_90'
sum rwi if year==2000
local rwi_00 = `r(max)'
local rwi_00 : display %4.1f `rwi_00'
sum rwi if year==2010
local rwi_10 = `r(max)'
local rwi_10 : display %4.1f `rwi_10'
sum rwi if year==2019
local rwi_19 = `r(max)'
local rwi_19 : display %4.1f `rwi_19'

format pg_* %5.1f

	
tw  bar pg_global year, barw(5) 			 || bar pg_eap_sas_ssa_lac_eca_mna year, barw(5) || ///
	bar pg_eap_sas_ssa_lac_eca year, barw(5) || bar pg_eap_sas_ssa_lac year, barw(5) 		 || ///
	bar pg_eap_sas_ssa year, barw(5) 		 || bar pg_eap_sas year, barw(5) 				 || ///
	bar pg_w_shareEAP year, barw(5) 		 || 												///
	scatter pg_w_shareEAP year, ms(none) mlab(pg_w_shareEAP) mlabposition(bottom)  || ///
	scatter pg_eap_sas year, ms(none) mlab(pg_w_shareSAS) mlabposition(bottom) 	   || ///
	scatter pg_eap_sas_ssa year, ms(none) mlab(pg_w_shareSSA) mlabposition(bottom) || ///
	scatter pg_global year, ms(none) mlab(pg_global) mlabposition(top) 	 	 	  	  ///
	text(10.2 1993													///						/*BRACES*/
        "`=ustrunescape("\u23AB")'" /* RCB UPPER HOOK   */			///
        "`=ustrunescape("\u23AC")'" /* RCB MIDDLE PIECE */			///
        "`=ustrunescape("\u23AD")'" /* RCB LOWER HOOK   */  		///
        , size(2.4) color(black) ) 									///	
	text(10.1 1993.7 "`rwi_90'", size(vsmall))							///					/*LABELS NEXT TO BRACES*/	
	text(8.6 2003													///
        "`=ustrunescape("\u23AB")'" /* RCB UPPER HOOK   */			///
        "`=ustrunescape("\u23AC")'" /* RCB MIDDLE PIECE */			///
        "`=ustrunescape("\u23AD")'" /* RCB LOWER HOOK   */  		///
        , size(2.4) color(black) ) 									///	
	text(8.6 2003.7 "`rwi_00'", size(vsmall))							///
	text(6.1 2013													///
        "`=ustrunescape("\u23AB")'" /* RCB UPPER HOOK   */			///
        "`=ustrunescape("\u23AC")'" /* RCB MIDDLE PIECE */			///
        "`=ustrunescape("\u23AD")'" /* RCB LOWER HOOK   */  		///
        , size(1.7) color(black) ) 									///	
	text(6.1 2013.7 "`rwi_10'", size(vsmall))							///
	text(4.6 2016													///
        "`=ustrunescape("\u23A7")'" /* LCB UPPER HOOK   */			///
        "`=ustrunescape("\u23A8")'" /* LCB MIDDLE PIECE */			///
        "`=ustrunescape("\u23A9")'" /* LCB LOWER HOOK   */			///
        , size(1.7) color(black) ) 									///	
	text(4.6 2015.3 "`rwi_19'", size(vsmall))	///
	xlabel(1990 "1990" 2000 "2000" 2010 "2010" 2019 "2019")	ylabel(0(2)11) ///
	xtitle("") ytitle("Prosperity Gap") ///
	legend(pos(6) row(3) order(7 "East Asia & Pacific" 6 "South Asia" 5 "Sub-Saharan Africa" ///
		4 "Latin America & Caribbean" 3 "Europe & Central America" 2 "Middle East & North Africa" ///
		1 "Rest of the World") size(vsmall)) scheme(white_tableau) name(fig2,replace)
		
graph combine fig2, iscale(*1.2) scheme(white_tableau) 	
graph export "${outputpath}Figure 4_2.png", replace	


********************************************************************************
exit	
