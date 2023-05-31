********************************************************************************
/* Figure 4.3
	Growth in the PG, mean, and B40 mean
 	(a) for the 1990-2019 lineup spell
	(b) for the latest shared prosperity spell c.2014-2019
*/ 
********************************************************************************


*********************
*** (a) 1990-2019 ***
*********************

// PIP countries with microdata or binned data (no grouped data) and a survey in 
// 1990s or 2010s.
pip tables, table(country_coverage) $pipoptions clear
keep if coverage=="TRUE"														// keep only those that satisfy coverage rule (+/- 3 years)
gen firstdecade = inrange(year,1990,1999) 
gen lastdecade  = inrange(year,2010,2019)

pip, country(all) year(all) $pipoptions clear
keep if inrange(year,1990,1999) | inrange(year,2010,2019)
gen firstdecade = inrange(year,1990,1999) 
gen lastdecade  = inrange(year,2010,2019)
duplicates drop country_code firstdecade lastdecade, force						// keep one obs per first and second spell			
bys country_code: gen num = _N													// drop countries with survey in only one spell
drop if num==1
keep country_code
duplicates drop
ren country_code code
tempfile countrylist
save 	`countrylist'

use 		 "${intermediatedatapath}CountryData_Main1990.dta", clear
append using "${intermediatedatapath}CountryData_Main2019.dta"

keep code year w25 ybar ybar_b40
merge m:1 code using `countrylist', nogen keep(3)										

// growth rates 
bys code (year): gen gpg_w  		= ( ln(w25/w25[_n-1]) / (year - year[_n-1]) ) * 100 
bys code (year): gen gybar	 		= ( ln(ybar/ybar[_n-1]) / (year - year[_n-1]) ) * 100
bys code (year): gen gybarb40 		= ( ln(ybar_b40/ybar_b40[_n-1]) / (year - year[_n-1]) ) * 100

drop if missing(gpg_w)

gen gpg_w_neg 	 = -1 * gpg_w


twoway 	scatter gybarb40 gpg_w_neg if inrange(gybarb40,-5,5) & inrange(gpg_w_neg,-5,5), ///
			ms(none) mlab(code) mlabposition(0) mlabc(black) || ///
		line gybarb40 gybarb40 if inrange(gybarb40,-5,5), ///
		xline(0, lp(shortdash) lc(gray)) yline(0, lp(shortdash) lc(gray)) ///
		xlabel(-5(1)5) ylabel(-5(1)5) ///
		title("(a) Growth Spell 1990-2019", size(medium)) ///
		ytitle("Growth in the mean of bottom 40%") xtitle("-1 x Growth of the Prosperity Gap") ///
		legend(off) scheme(white_tableau) name(g2_full, replace)	



************************************
*** (B) SHARED PROSPERITY SPELLS ***
************************************

use "${rawdatapath}PSPR22 ShP Final.dta", clear									// latest shared prosperity spells from PSPR2022
drop if surveyt2>=2020
keep code countryname period type survey* 
reshape long survey, i(code countryname period type) j(year) string
drop year
ren survey year
replace year = floor(year)
tempfile spspells
save 	`spspells'

use "${intermediatedatapath}CountryData_Main2019.dta", clear
forval yr = 2011/2018 {
	append using "${intermediatedatapath}CountryData_Main`yr'.dta"
}		

keep code year w25 ybar ybar_b40
merge m:1 code year using `spspells', keep(3) nogen

// growth rates 
bys code (year): gen gpg_w  		= ( ln(w25/w25[_n-1]) / (year - year[_n-1]) ) * 100 
bys code (year): gen gybar	 		= ( ln(ybar/ybar[_n-1]) / (year - year[_n-1]) ) * 100
bys code (year): gen gybarb40 		= ( ln(ybar_b40/ybar_b40[_n-1]) / (year - year[_n-1]) ) * 100

drop if missing(gpg_w)

gen gpg_w_neg 	 = -1 * gpg_w
		
twoway 	scatter gybarb40 gpg_w_neg if inrange(gybarb40,-5,5) & inrange(gpg_w_neg,-5,5), ///
			ms(none) mlab(code) mlabposition(0) mlabc(black) || ///
		line gybarb40 gybarb40 if inrange(gybarb40,-5,5), lc(orange) ///
		xline(0, lp(shortdash) lc(gray)) yline(0, lp(shortdash) lc(gray)) ///
		xlabel(-5(1)5) ylabel(-5(1)5) ///
		title("(b) Growth Spell c.2014-2019", size(medium)) ///
		ytitle("Growth in the mean of bottom 40%") xtitle("-1 x Growth of the Prosperity Gap") ///
		legend(off) scheme(white_tableau) name(g2_sub, replace)		
		
graph combine g2_full g2_sub, row(1) scheme(white_tableau) xsize(15) ysize(8) iscale(*1.3)

graph export "${outputpath}Figure 4_3.png", replace	

********************************************************************************
exit


		
		
