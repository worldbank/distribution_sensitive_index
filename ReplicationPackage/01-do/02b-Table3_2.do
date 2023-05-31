*******************************************************************************
// Table 3.2 
// Country comparisons
*******************************************************************************

use 		 "${intermediatedatapath}CountryData_Main2019.dta", clear
append using "${intermediatedatapath}CountryData_Main2018.dta" 					// BFA and MLI surveys are from 2018		

keep if inlist(code,"FRA","USA","COL","PER","BFA","MLI")
drop if inlist(code,"BFA","MLI") 			 & year!=2018
drop if inlist(code,"FRA","USA","COL","PER") & year!=2019

gen 	w = w215 if inlist(code,"BFA","MLI")
replace w = w685 if inlist(code,"COL","PER")
replace w = w25  if inlist(code,"FRA","USA")

gen 	c = c215 if inlist(code,"BFA","MLI")
replace c = c685 if inlist(code,"COL","PER")
replace c = c25  if inlist(code,"FRA","USA")

gen 	p = p215 if inlist(code,"BFA","MLI")
replace p = p685 if inlist(code,"COL","PER")
replace p = p25  if inlist(code,"FRA","USA")

gen 	h = fgt0_215/100 if inlist(code,"BFA","MLI")
replace h = fgt0_685/100 if inlist(code,"COL","PER")
replace h = fgt0_25/100  if inlist(code,"FRA","USA")

sort code
encode code, gen(cntr)
list code cntr, nolab
keep  cntr year w ybar i c p h
order cntr year w ybar i c p h

xpose, clear varname
order _varname 

*********************
*** save to excel ***
*********************

ren v1 burkinafaso
ren v2 colombia
ren v3 france
ren v4 mali
ren v5 peru
ren v6 us

drop if _varname=="cntr"
order _varname burkinafaso mali colombia peru france us

preserve																		// low-income panel A
keep in 2/4
mkmat burkinafaso mali, mat(low_A)
restore

preserve																		// low-income panel B
keep in 5/7
mkmat burkinafaso mali, mat(low_B)
restore

preserve																		// middle-income panel A
keep in 2/4
mkmat colombia peru, mat(mid_A)
restore

preserve																		// middle-income panel B
keep in 5/7
mkmat colombia peru, mat(mid_B)
restore

preserve																		// high-income panel A
keep in 2/4
mkmat france us, mat(hig_A)
restore

preserve																		// high-income panel B
keep in 5/7
mkmat france us, mat(hig_B)
restore

putexcel set "${outputpath}Tables.xlsx", modify sheet(Table3_2, replace)

putexcel A4 = "Panel A"
putexcel A5 = "W", 		italic hcenter
putexcel A6 = "Mean", 	hcenter
putexcel A7 = "I", 		italic hcenter
putexcel A8 = "Panel B"
putexcel A9 = "C", 		italic hcenter
putexcel A10 = "P", 	italic hcenter
putexcel A11 = "FGT0", 	italic hcenter

putexcel B1:C1 = "Low-income, consumption", merge hcenter vcenter bold underline
putexcel E1:F1 = "Middle-income, income", 	merge hcenter vcenter bold underline
putexcel H1:I1 = "High-income, income", 	merge hcenter vcenter bold underline
putexcel B2 = "Burkina Faso", bold hcenter
putexcel C2 = "Mali", 		  bold hcenter
putexcel E2 = "Colombia", 	  bold hcenter
putexcel F2 = "Peru", 		  bold hcenter
putexcel H2 = "France", 	  bold hcenter
putexcel I2 = "United States",bold hcenter
putexcel B3 = "2018", 		  bold hcenter
putexcel C3 = "2018", 		  bold hcenter
putexcel E3 = "2019", 		  bold hcenter
putexcel F3 = "2019", 		  bold hcenter
putexcel H3 = "2019", 		  bold hcenter
putexcel I3 = "2019", 		  bold hcenter
putexcel B4:C4 = "z = $2.15 per day",  merge hcenter vcenter bold underline
putexcel E4:F4 = "z = $6.85 per day",  merge hcenter vcenter bold underline
putexcel H4:I4 = "z = $25 per day",    merge hcenter vcenter bold underline

putexcel B5 = matrix(low_A), nformat(number_d2)
putexcel B9 = matrix(low_B), nformat(number_d2)
putexcel E5 = matrix(mid_A), nformat(number_d2)
putexcel E9 = matrix(mid_B), nformat(number_d2)
putexcel H5 = matrix(hig_A), nformat(number_d2)
putexcel H9 = matrix(hig_B), nformat(number_d2)

putexcel E6, nformat(#0.#)														// change formating for some cells
putexcel F6, nformat(#0.#)
putexcel H6, nformat(#0.#)
putexcel I6, nformat(#0.#)

*******************************************************************************
exit
