*******************************************************************************
// Download PIP country lineup indicators, and global and regional population data
*******************************************************************************

// country lineup data
pip, country(all) year(all) fillgaps $pipoptions clear
save "${rawdatapath}PIP_CountryLineupData_02012023.dta", replace

// country population data
pip tables, table(pop) $pipoptions clear
save "${rawdatapath}PIP_CountryPopulation_02012023.dta", replace

// Global data
pip wb, year(all) region(wld) $pipoptions clear
save "${rawdatapath}PIP_GlobalData_02012023.dta", replace

// regional population data
pip tables, table(pop_region) $pipoptions clear
save "${rawdatapath}PIP_RegionalPopulation_02012023.dta", replace

*******************************************************************************

exit