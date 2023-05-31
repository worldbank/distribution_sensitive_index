
This document explains the steps necessary to replicate the data, figures, and tables used in Kraay r al. (2023). 
[version PRWP May 30, 2023]


Operating System: 	Microsoft Windows 10 Enterprise (v. 21H2)
Progamming Language: 	Stata MP v17.0
Runtime (approximate):	1-2 hour 		


Empirics folder path: "\Kraayetal_ReplicationPackage\"

Empirics folder structure: 	00-Master.do		[Reference to all folder paths and globals and packages neccessary to run the individual do files.] 
							[Update the global dir (line #22) to the local folder path.]
				01-dofiles		[do files; see detail below]
				02-rawdata		[input data files; see detail below]
				03-intermediate		[datasets for figures and tables]
				04-output		[final figures and tables]


******************************************************
****************** INPUT DATA FILES ******************
******************************************************

Input data folder path: "\Kraayetal_ReplicationPackage\02-rawdata\"


1. Global dataset with 1000 bins per country
	- Source: 	https://datacatalog.worldbank.org/int/search/dataset/0064304/1000_binned_global_distribution
	- Filename:     GlobalDist1000bins_1990-2019.dta
	- Description:  Welfare data for 218 World Bank economies, each with 1000 bins
			Years included -- 1990-2019
			ID variables   -- code, year
			Variable list  -- code; year; region_code (PIP-regions); welf (average daily welfare of bin in 2017 PPP US$); pop (population in millions) 
	- Note: 	Welfare values are average incomes of each bin; file also includes population in each bin. The distribution is at the national level for all countries. 

2. PIP poverty and population estimates (see also file "00b-PIPdata.do" in the Do Files section below to generate these data files)
	- Filename: PIP_CountryLineupData_02012023.dta  -- contains country headcounts at $2.15, lineup means, and population for all lineup years
	- Filename: PIP_CountryPopulation_02012023.dta  -- contains country populations for all WB economies 1977-2020
	- Filename: PIP_GlobalData_02012023.dta	 -- contains global headcounts at $2.15, mean, and population for 1981-2019
	- Filename: PIP_RegionalPopulation_02012023.dta -- contains regional population 1977-2020

3. Shared prosperity dataset
	- Source: 	https://pip.worldbank.org/shared-prosperity
	- Filename: 	PSPR ShP Final.dta
	- Description:  Global database for shared prosperity (10th edition). 
	 		countains overall mean of the distribution and mean of the bottom 40 percent for a set of comparable surveys
			Year: 	c.2014--2019

4. CLASS.dta
	- Source: 	https://github.com/PovcalNet-Team/Class
	- Description:  Historical and current country classifications by income, IDA, IBRD, FCS



******************************************************
********************** DO FILES **********************
******************************************************

Do files folder path: "\Kraayetal_ReplicationPackage\01-do\"

*** Note all do files can be run from the "00-Master.do". ***

********************** MAIN DATA **********************

00b-PIPdata.do
	Query PIP lineup indicators and population data for 1990-2019 by country, region, and global.
	
	OUTPUT: saved in "02-rawdata" folder
		i.   PIP_CountryLineupData_02012023.dta
		ii.  PIP_CountryPopulation_02012023.dta
		iii. PIP_GlobalData_02012023.dta
		iv.  PIP_RegionalPopulation_02012023

00c-GlobalBinnedData.do		
	Downloads binned global distribution from Mahler r al. (2022).

01a-Global-Data-Main.do
	Estimates welfare, poverty, and inequality estimates at the global level for years 1990-2019. 
	
	OUTPUT: saved in "03-intermediatedata" folder 
		i. GlobalData_Main.dta

01b-Country-Data-Main.do
	Estimates welfare, poverty, and inequality estimates at the country level for user selected year. 
	
	OUTPUT: saved in "03-intermediatedata" folder 
		i. CountryData_Main`year'.dta
		(years data saved 1990, 2011-2019)

01c-Region-Data-Main.do
	Estimates welfare, poverty, and inequality estimates at the regional level for user selected year. 
	
	OUTPUT: saved in "03-intermediatedata" folder 
		i. RegionData_Main`year'.dta
		(years data saved 1990,2000,2010,2019)

01d-IncomeGroup-Data-Main.do
	Estimates welfare, poverty, and inequality estimates at the WB income group level for user selected year. 
	
	OUTPUT: saved in "03-intermediatedata" folder 
		i. IncGroupData_Main`year'.dta
		(years data saved 2019)


********************** TABLES **********************

*** Note: The numbers in the filename of the tables and figures correspond to the numbers in the paper ***

Tables do files folder path: "\Kraayetal_ReplicationPackage\01-do\"


02a-Table 3_1.do
	Compares global trends of various welfare, poverty, and inequality measures for years 1990, 2000, 2010, and 2019. 

02b-Table 3_2.do
	Compares country trends above for select countries in the last survey year.

02c-Table 4_1.do
	Calculates prosperity gap values in 2019 by region and income groups and for select countries. 


OUTPUT: all tables saved in Excel file in folder "\Kraayetal_ReplicationPackage\04-output\"


********************** FIGURES **********************

Figures do files folder path: "\Kraayetal_ReplicationPackage\01-do\"

03a-Figure 3_1.do
	Plots the global GIC for the 1990-2019 period (Panel A) and the elasticities of the W measure and comparators (Panel B). 

03b-Figure 3_2.do
	Plots the global GIC for the 1990-2019 period (Panel A) and the elasticities of the P measure and comparators (Panel B).

03c-Figure 3_3.do
	Plots the contribution of each global percentile to the change in the P measure and comparators using $6.85 threshold.

03d-Figure 4_1.do
	Trend in the global prosperity gap.

03e-Figure 4_2.do
	Regional decomposition of the global prosperity gap for years 1990, 2000, 2010, and 2019.

03f-Figure 4_3.do
	Comparison of cross-country growth in the prosperity gap, mean, and the mean of the bottom 40 percent for 
		Panel A: 1990-2019 period, and 
		Panel B: most recent comparable spells. 

03g-Figure 4_4.do
	HIC threshold as the justification for $25/day prosperity gap threshold.

03h-Figure 4_5.do
	Trends in the global prosperity gap using various poverty thresholds.

04a-Figure C.1.do
	Cumulative contribution of each percentile to total W and mean. 

04a-Figure C.2.do
	Cumulative contribution of each percentile to total P and comparator measures.

04a-Figure E.1.do
	Elasticities of the P measure and comparators using $2.15/day threshold.

04a-Figure E.2.do
	Contribution of each percentile to the change in P measure and comparators using $2.15/day threshold.


05-VariousStats.do
	Replicates stats not included in tables and figures but used in the paper.

OUTPUT: all figures saved in folder "\Kraayetal_ReplicationPackage\04-output\"
