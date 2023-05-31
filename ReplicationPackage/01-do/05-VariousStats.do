********************************************************************************
// VARIOUS STATS USED IN THE PAPER
********************************************************************************

********************************************************************************
*** PIP POPULATION COVERAGE BY INCOME/CONSUMPTION AGGREGATE IN GLOBAL LINEUP ***
********************************************************************************

pip tables, table(country_coverage) $pipoptions clear

bys year welfare_type: egen double tpop = total(pop)							// population by income/consumption each year
bys year: 			   egen double gpop = total(pop)							// total global population each year
gen double share = tpop/gpop * 100												// share of global population from income/consumption surveys
collapse share, by(welfare_type year)

encode welfare_type, gen(aggregate)
replace aggregate = 0 if missing(aggregate)										// population of missing countries in PIP
drop welfare_type
reshape wide share, i(year) j(aggregate)
format share* %5.1f
sum share* if year>=1990


*************************************
*** SHARE OF INCOMES BOTTOM CODED ***
*************************************

pip tables, table(country_coverage) $pipoptions clear
keep if inlist(year,1990,2019) & inlist(pop_data_level,"national","urban")		// China, india, and indonesia have rural/urban observations so dropping one
drop if missing(welfare_type)
keep country_code year welfare_type
ren country_code code
tempfile countrywelfare
save 	`countrywelfare'

use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear

merge m:1 code year using `countrywelfare', nogen keep(3)						// keep only countries with data in PIP for years 1990 and 2019 only

gen botcode = (welf<0.5)														// generate tag for bottom coded bins

bys year welfare_type: egen totalpop_welfare = total(pop)

collapse totalpop_welfare (rawsum) pop [aw=pop], by(year welfare_type botcode)

gen share = pop/totalpop_welfare * 100											// share bottom coded of each welfare_type

format %5.1f share

br


*********************************************************************************
*** SHARE IN GLOBAL BOTTOM 40 (TOP 60) AND ALSO IN COUNTRY TOP 60 (BOTTOM 40) *** 
*********************************************************************************

use "${rawdatapath}GlobalDist1000bins_1990-2019.dta", clear

keep if year==2019

xtile perc = welf [aw=pop], n(100) 												// global percentile

gen b40 = obs<=400																// indicator for country bottom 40%
gen t60 = obs>400																// indicator for country top 60%
sum b40 [aw=pop] if perc>40														// country b40 and in global top 60
sum t60 [aw=pop] if perc<=40													// country t60 and in global bottom 40


*********************************************************************
*** DECOMPOSITION OF TOTAL INEQUALITY (I) INTO WITHIN AND BETWEEN *** 
*********************************************************************

use "${intermediatedatapath}GlobalData_Main.dta", clear							// global inequality measure (I)
ren i wld_I
keep year wld_I
keep if inlist(year,1990,2019)
tempfile globali
save 	`globali'

use 		 "${intermediatedatapath}CountryData_Main2019.dta", clear			// Country/within I
append using "${intermediatedatapath}CountryData_Main1990.dta"

gen  			w_i 	= pop/ybar												// generate the weights
bys year: egen 	sum_w_i = total(w_i)
gen  			weight  = w_i/sum_w_i

gen				I_g = weight * i
bys year: egen 	sum_I_g = total(I_g)
keep code year I_g sum_I_g

merge m:1 year using `globali', nogen

gen w_I     = sum_I_g															// within inequality
gen b_I		= wld_I/w_I															// between inequality

collapse wld_I w_I b_I, by(year)

format %5.1f *_I
br

********************************************************************************

exit