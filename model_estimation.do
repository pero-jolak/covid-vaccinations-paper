clear all

import excel "/Users/jolakoskip/Desktop/covid_vaccinations/estimation_data_wtypev.xlsx", sheet("Sheet1") firstrow

* generate variables
gen gdp = gdp_per_capita * population

gen lgdp = log(gdp)
gen lgdp_ppp_pc=log(gdp_ppp_pc)
gen lvaccinations=log(vi_per_hundred)
gen lcases=log(cases)
gen ldeaths = log(deaths)
gen lhealth = log(health_exp)
gen lpop = log(population)
gen lmilitary = log(military)
gen ltrade = log(trade)
gen lphysicians = log(physicians)
gen lpop65 = log(aged_65_older)
gen lgov_response = log(gov_response)
gen lexports = log(exports)

*outliers

foreach x in gdp gov_eff {
g `x'_out=0
egen `x'_5 = pctile(`x'), p(5)
egen `x'_95 = pctile(`x'), p(95)
replace `x'_out=1 if `x'>`x'_95
replace `x'_out=1 if `x'<`x'_5
}

foreach x in vi_per_hundred {
g `x'_out=0
egen `x'_95 = pctile(`x'), p(95)
replace `x'_out=1 if `x'>`x'_95
}


* first stage and second stage
heckman lvaccinations lcases days lgov_response i.oxford_az i.pfizer_biontech i.moderna, select(started_vi = lcases lgov_response) robust iter(20)
outreg2 using results_osnovni.doc, dec(3) ctitle(results_1) replace 

heckman lvaccinations lcases days gov_eff i.oxford_az i.pfizer_biontech i.moderna, select(started_vi = lcases i.soft_30) robust iter(20)
outreg2 using results_osnovni.doc, dec(3) ctitle(results_2) append 

heckman lvaccinations lcases days lgov_response lhealth lmilitary i.oxford_az i.pfizer_biontech i.moderna, select(started_vi = lcases lgov_response lexports lmilitary lhealth i.soft_30) robust iter(20)
outreg2 using results_osnovni.doc, dec(3) ctitle(results_3) append 

heckman lvaccinations lcases days lhealth lmilitary lgov_response gov_eff lgdp lpop65 i.oxford_az i.pfizer_biontech i.moderna, select(started_vi = lcases lgdp lgov_response lexports lmilitary lhealth i.soft_30) robust iter(20)
outreg2 using results_osnovni.doc, dec(3) ctitle(results_4) append 

* without outliers
heckman lvaccinations lcases days lgov_response i.oxford_az i.pfizer_biontech i.moderna if gdp_out==0 & gov_eff_out==0, select(started_vi = lcases lgov_response) robust iter(20)
outreg2 using results_outliers.doc, dec(3) ctitle(results_1) replace 

heckman lvaccinations lcases days gov_eff i.oxford_az i.pfizer_biontech i.moderna if gdp_out==0 & gov_eff_out==0, select(started_vi = lcases i.soft_30) robust iter(20)
outreg2 using results_outliers.doc, dec(3) ctitle(results_2) append 

heckman lvaccinations lcases days lgov_response lhealth lmilitary i.oxford_az i.pfizer_biontech i.moderna if gdp_out==0 & gov_eff_out==0, select(started_vi = lcases lgov_response lexports lmilitary lhealth i.soft_30) robust iter(20)
outreg2 using results_outliers.doc, dec(3) ctitle(results_3) append 

heckman lvaccinations lcases days lhealth lmilitary lgov_response gov_eff lgdp lpop65 i.oxford_az i.pfizer_biontech i.moderna if gdp_out==0 & gov_eff_out==0, select(started_vi = lcases lgdp lgov_response lexports lmilitary lhealth i.soft_30) robust iter(20)
outreg2 using results_outliers.doc, dec(3) ctitle(results_4) append 

* without outliers 2
heckman lvaccinations lcases days lgov_response i.oxford_az i.pfizer_biontech i.moderna if vi_per_hundred_out==0, select(started_vi = lcases lgov_response) robust iter(20)
outreg2 using results_outliers2.doc, dec(3) ctitle(results_1) replace 

heckman lvaccinations lcases days gov_eff i.oxford_az i.pfizer_biontech i.moderna if vi_per_hundred_out==0, select(started_vi = lcases i.soft_30) robust iter(20)
outreg2 using results_outliers2.doc, dec(3) ctitle(results_2) append 

heckman lvaccinations lcases days lgov_response lhealth lmilitary i.oxford_az i.pfizer_biontech i.moderna if vi_per_hundred_out==0, select(started_vi = lcases lgov_response lexports lmilitary lhealth i.soft_30) robust iter(20)
outreg2 using results_outliers2.doc, dec(3) ctitle(results_3) append 

heckman lvaccinations lcases days lhealth lmilitary lgov_response gov_eff lgdp lpop65 i.oxford_az i.pfizer_biontech i.moderna if vi_per_hundred_out==0, select(started_vi = lcases lgdp lgov_response lexports lmilitary lhealth i.soft_30) robust iter(20)
outreg2 using results_outliers2.doc, dec(3) ctitle(results_4) append 
