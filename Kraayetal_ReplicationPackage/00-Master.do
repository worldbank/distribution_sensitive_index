********************************************************************************
*** Master File ***
/* 
	This file runs all the do files and produces the tables and charts for 
	Kraay r al. (2023) - version Policy Research Working Paper June 1, 2023
	https://documents.worldbank.org/en/publication/documents-reports/documentdetail/099934305302318791
*/	
********************************************************************************
clear all
set more off

*** Package installations ***
local packages pip apoverty ineqdeco egenmore wbopendata schemepack
foreach package in `packages' {
	capture which `package'
		if _rc == 111 {
		ssc install `package', replace
	}
}

*** Global paths ***
global dir 						"\Kraayetal_ReplicationPackage\"				/* CHANGE THIS */

global dopath 					"${dir}01-do\"
global rawdatapath				"${dir}02-rawdata\"
global intermediatedatapath 	"${dir}03-intermediatedata\"
global outputpath 				"${dir}04-output\"

*** PIP ado installation and vintage selection ***
cap ssc install pip
pip cleanup
global pipoptions "version(20220909_2017_01_02_PROD)"

********************************************************************************
*** INPUT PARAMETERS ***
global povl1  "2.15"	// POVERTY THRESHOLDS AT $2.15/DAY
global povl2  "3.65"	// POVERTY THRESHOLDS AT $3.65/DAY
global povl3  "6.85"	// POVERTY THRESHOLDS AT $6.85/DAY
global povl4  "25"		// HIGHER POVERTY THRESHOLDS AT $25/DAY

global welf_fl "0.5"	// WELFARE FLOOR SET AT $0.50/DAY

*** country (cyr), region (ryr), and income group (iyr) years data to save ***
global cyr	   "1990 2000 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019"
global ryr	   "1990 2000 2010 2019"
global iyr	   "2019"

********************************************************************************

*** PIP and global binned data download ***
do "${dopath}00b-PIPdata.do"
do "${dopath}00c-GlobalBinnedData.do"

*** Setup the necessary data ***
do "${dopath}01a-Global-Data-Main.do"
do "${dopath}01b-Country-Data-Main.do"
do "${dopath}01c-Region-Data-Main.do"
do "${dopath}01d-IncomeGroup-Data-Main.do"

*** Tables ***
do "${dopath}02a-Table3_1.do"
do "${dopath}02b-Table3_2.do"
do "${dopath}02c-Table4_1.do"

*** Figures ***
do "${dopath}03a-Figure3_1.do"
do "${dopath}03b-Figure3_2.do"
do "${dopath}03c-Figure3_3.do"
do "${dopath}03d-Figure4_1.do"
do "${dopath}03e-Figure4_2.do"
do "${dopath}03f-Figure4_3.do"
do "${dopath}03g-Figure4_4.do"
do "${dopath}03h-Figure4_5.do"

*** Appendix Figures ***
do "${dopath}04a-FigureC1.do"
do "${dopath}04b-FigureC2.do"
do "${dopath}04c-FigureE1.do"
do "${dopath}04d-FigureE2.do"

*** Various stats used in the paper ***
do "${dopath}05-VariousStats.do"

********************************************************************************
exit