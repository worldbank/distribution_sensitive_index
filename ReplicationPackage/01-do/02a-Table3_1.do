*******************************************************************************
// Table 3.1
// Estimates of the various welfare, poverty and inequality measures
*******************************************************************************

use "${intermediatedatapath}GlobalData_Main.dta", clear

keep if inlist(year,1990,2019)
keep  year w685 ybar sen awi1 awi2 i gini atk1 atk2 c685 p685 fgt0_685 fgt1_685 fgt2_685 watt_685 c215 p215 fgt0_215 fgt1_215 fgt2_215 watt_215  
order year w685 ybar sen awi1 awi2 i gini atk1 atk2 c685 p685 fgt0_685 fgt1_685 fgt2_685 watt_685 c215 p215 fgt0_215 fgt1_215 fgt2_215 watt_215

xpose, clear varname
order _varname 

ren _varname indicator
ren v1 year1990
ren v2 year2019
drop in 1

replace year1990 = year1990/100 if ///
	inlist(indicator,"gini","atk1","atk2","fgt0_685","fgt1_685","fgt2_685","watt_685") ///
	| inlist(indicator,"fgt0_215","fgt1_215","fgt2_215","watt_215") 
		
replace year2019 = year2019/100 if ///
	inlist(indicator,"gini","atk1","atk2","fgt0_685","fgt1_685","fgt2_685","watt_685") ///
	| inlist(indicator,"fgt0_215","fgt1_215","fgt2_215","watt_215")

gen change = ln(year2019/year1990)/(2019 - 1990) * 100


*********************
*** save to excel ***
*********************

preserve												// W measure
keep in 1/5
mkmat year1990 year2019 change, mat(W)
restore

preserve												// I measure
keep in 6/9
gen id = _n
expand 2 in 2
sort id
foreach v of varlist year* change {
	replace `v' = . in 2
}
replace indicator = "" in 2
drop id
mkmat year1990 year2019 change, mat(I)
restore

preserve												// P at 6.85
keep in 10/15
mkmat year1990 year2019 change, mat(P685)
restore

preserve												// P at 2.15
keep in 16/21
mkmat year1990 year2019 change, mat(P215)
restore


putexcel set "${outputpath}Tables.xlsx", modify sheet(Table3_1, replace)

putexcel C1 = "1990", hcenter vcenter bold
putexcel D1 = "2019", hcenter vcenter bold
putexcel E1 = "Avg Annual Change, %", hcenter vcenter bold txtwrap
putexcel A2 = "Panel A: Welfare Measures (z = $6.85 per day)", bold
putexcel B3 = "W",  italic
putexcel B4 = "Mean"
putexcel B5 = "Sen"
putexcel B6 = "A1", italic
putexcel B7 = "A2", italic
putexcel C3 = matrix(W), nformat(number_d2)

putexcel H1 = "1990", hcenter vcenter bold
putexcel I1 = "2019", hcenter vcenter bold
putexcel J1 = "Avg Annual Change, %", hcenter vcenter bold txtwrap
putexcel G2 = "Panel B: Inequality Measures", bold
putexcel G3 = "I",  italic
putexcel G4 = ""
putexcel G5 = "Gini"
putexcel G6 = "AI1", italic
putexcel G7 = "AI2", italic
putexcel H3 = matrix(I), nformat(number_d2)

putexcel A8  = "Panel C: Poverty Measures", bold
putexcel B9  = "(i) z = $6.85 per day", 	bold
putexcel B10 = "C",  italic
putexcel B11 = "P",  italic
putexcel B12 = "FGT0", italic
putexcel B13 = "FGT1", italic
putexcel B14 = "FGT2", italic
putexcel B15 = "Watts"
putexcel C10 = matrix(P685), nformat(number_d2)

putexcel G9  = "(ii) z = $2.15 per day", 	bold
putexcel G10 = "C",  italic
putexcel G11 = "P",  italic
putexcel G12 = "FGT0", italic
putexcel G13 = "FGT1", italic
putexcel G14 = "FGT2", italic
putexcel G15 = "Watts"
putexcel H10 = matrix(P215), nformat(number_d2)

putexcel C4, nformat(#0.0)
putexcel D4, nformat(#0.0)

*******************************************************************************
exit
