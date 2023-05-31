********************************************************************************
// Figure 4.4 
// Trends in prosperity gap various thresholds
********************************************************************************
pip, country(all) year(all) $pipoptions clear									// pip survey mean incomes and gdp
keep if reporting_level=="national"
keep country_code country_name welfare_type year mean population gdp
ren country_code code
tempfile pipdata
save 	`pipdata'

wbopendata, indicator(NY.GNP.PCAP.PP.KD; NY.GDP.PCAP.PP.KD; NE.CON.PRVT.PP.KD; SP.POP.TOTL) long clear //wdi gdp in 2017 PPP $ 
gen hfcepc2017ppp = ne_con_prvt_pp_kd/sp_pop_totl
ren ny_gnp_pcap_pp_kd gnipc2017ppp
ren ny_gdp_pcap_pp_kd gdppc2017ppp 
ren countrycode code 

merge 1:m code year using `pipdata', keep(3) keepusing(mean population) nogen

gen lgdp  	= log(gdppc2017ppp)
gen lmean 	= log(mean)


local vline1 = log(14977)  							// 107.7/118.4 * 16465=$14977  (From Hamadeh et al., convert 2021 US$ to 2017 US$)
local vline2 = log(21599)							// 107.7/118.4 * 23745		   (From Hamadeh et al. convert 2021 US$ to 2017 US$)
local hline1 = log(16)
local hline2 = log(23)

twoway (scatter lmean lgdp, ms(x) mc(navy*0.5)) (lfit lmean lgdp, lc(maroon)), ///
	xlabel(5.298 "200" 6.2 "500" 6.908 "1,000" 7.6 "2,000" 8.517 "5,000" `vline1' "15,000" `vline2' "21,600" 10.82 "50,000", format(%5.0f) angle(45)) ///
	ylabel(.765 "2.15" 1.294 "3.65" 1.924 "6.85" 2.302 "10.00" `hline1' "16.00" `hline2' "23.00" 3.912 "50.00" 4.605 "100.00", format(%5.0f) angle(0) nogrid) /// 
	xtitle("Real GDP per Capita, $2017 PPP") ytitle("Household Survey Mean" "$2017 PPP Per Day") /// 
	xline(`vline1', lp(shortdash) lc(red)) xline(`vline2', lp(shortdash) lc(red)) yline(`hline1', lp(shortdash) lc(red)) yline(`hline2', lp(shortdash) lc(red)) legend(off) ///
	text(1.294 9.5 "IBRD graduation threshold", orientation(vertical) size(vsmall)) text(1.294 9.9 "High income threshold", orientation(vertical) size(vsmall)) ///
	graphregion(color(white) lwidth(large))  name(fig1, replace)		
	
		
graph combine fig1, iscale(*1.2) scheme(white_tableau) xsize(10) ysize(8)
graph export "${outputpath}Figure 4_4.png", replace

********************************************************************************

exit
