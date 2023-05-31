*******************************************************************************
/*
This do file downloads the global binned dataset from Mahler r al (2022).
*/
*******************************************************************************

use "https://datacatalogfiles.worldbank.org/ddh-published/0064304/DR0091199/GlobalDist1000bins_1990-2019.dta", clear

save "${rawdatapath}GlobalDist1000bins_1990-2019.dta", replace

*******************************************************************************

exit