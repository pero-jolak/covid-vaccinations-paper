clear all

import excel "/Users/jolakoskip/Desktop/papers/covid_vaccinations/estimation_data_0401_euw.xlsx", sheet("Sheet1") firstrow

* generate variables
gen gdp = gdp_per_capita * population

gen lgdp = log(gdp)
gen lgdp_ppp_pc=log(GDPpercapitaPPPcurrentint)
gen lvaccinations=log(total_vaccinations_per_hundred)
gen lcases=log(total_cases_per_million)
gen ldeaths = log(total_deaths_per_million)
gen lhealth = log(Currenthealthexpenditureof)
gen lpop = log(population)
gen lmilitary = log(MilitaryexpenditureofGDP)
gen ltrade = log(TradeofGDP)
gen lphysicians = log(Physiciansper1000people)
gen lpop65 = log(aged_65_older)
gen lgov_response = log(gov_response)
gen lexports = log(exports)
gen lhealthpc = log(health_exp_pc)
gen lexportspc = log(exports_pc)
gen lmilitarypc = log(military_pc)
gen lexpeuw = log(exports_euw)
gen lgdpeuw = log(gdp_pc_euw)
gen lmileuw = log(mil_exp_euw)
gen lhealtheuw = log(health_exp_euw)
gen vi_per_hundred = total_vaccinations_per_hundred
gen lsoft_presence = log(soft_presence)
gen lglobal_presence = log(global_presence)

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


* baseline models: with soft_power for soft_30 or eu
heckman lvaccinations lcases days lgov_response, select(started_vi = lcases lgov_response lsoft_presence) robust iter(20)
outreg2 using rob_end_march.doc, dec(3) ctitle(results_1) replace 

heckman lvaccinations lcases days gov_eff, select(started_vi = lcases lsoft_presence) robust iter(20)
outreg2 using rob_end_march.doc, dec(3) ctitle(results_2) append 

heckman lvaccinations lcases days lgov_response lhealthpc lmilitarypc gov_eff, select(started_vi = lcases lgov_response lexportspc lmilitarypc lhealthpc lsoft_presence) robust iter(20)
outreg2 using rob_end_march.doc, dec(3) ctitle(results_3) append 

heckman lvaccinations lcases days lhealthpc lmilitarypc lgov_response gov_eff lgdp_ppp_pc lpop65, select(started_vi = lcases lgdp_ppp_pc lgov_response lexportspc lmilitarypc lhealthpc lsoft_presence) robust iter(20)
outreg2 using rob_end_march.doc, dec(3) ctitle(results_4) append 

* robustness with population weighted variables for eu countries
heckman lvaccinations lcases days, select(started_vi = lcases) robust iter(20)
outreg2 using results_wrobustness_eu1.doc, dec(3) ctitle(results_1) replace 

heckman lvaccinations lcases days gov_eff_euw, select(started_vi = lcases lsoft_presence) robust iter(20)
outreg2 using results_wrobustness_eu1.doc, dec(3) ctitle(results_2) append 

heckman lvaccinations lcases days lhealtheuw lmileuw gov_eff_euw, select(started_vi = lcases lexpeuw lmileuw lhealtheuw lsoft_presence) robust iter(20)
outreg2 using results_wrobustness_eu1.doc, dec(3) ctitle(results_3) append 

heckman lvaccinations lcases days lhealtheuw lmileuw gov_eff_euw lgdpeuw, select(started_vi = lcases lgdpeuw lexpeuw lmileuw lhealtheuw lsoft_presence) robust iter(20)
outreg2 using results_wrobustness_eu1.doc, dec(3) ctitle(results_4) append 

* robustness without China and Russia
heckman lvaccinations lcases days lgov_response if cty_out==1, select(started_vi = lcases lgov_response) robust iter(20)
outreg2 using results_rob_chnrus.doc, dec(3) ctitle(results_1) replace 

heckman lvaccinations lcases days gov_eff if cty_out==1, select(started_vi = lcases lsoft_presence) robust iter(20)
outreg2 using results_rob_chnrus.doc, dec(3) ctitle(results_2) append 

heckman lvaccinations lcases days lgov_response lhealthpc lmilitarypc gov_eff if cty_out==1, select(started_vi = lcases lgov_response lexportspc lmilitarypc lhealthpc lsoft_presence) robust iter(20)
outreg2 using results_rob_chnrus.doc, dec(3) ctitle(results_3) append 

heckman lvaccinations lcases days lhealthpc lmilitarypc lgov_response gov_eff lgdp_ppp_pc lpop65 if cty_out==1, select(started_vi = lcases lgov_response lexportspc lmilitarypc lhealthpc lsoft_presence) robust iter(20)
outreg2 using results_rob_chnrus.doc, dec(3) ctitle(results_4) append 

* robustness for april with over_20 == 1
heckman lvaccinations lcases days lgov_response, select(over_20 = lcases lgov_response lsoft_presence) robust iter(20)
outreg2 using rob_april_over20.doc, dec(3) ctitle(results_1) replace 

heckman lvaccinations lcases days gov_eff, select(over_20 = lcases lsoft_presence) robust iter(20)
outreg2 using rob_april_over20.doc, dec(3) ctitle(results_2) append 

heckman lvaccinations lcases days lgov_response lhealthpc lmilitarypc gov_eff, select(over_20 = lcases lgov_response lexportspc lmilitarypc lhealthpc lsoft_presence) robust iter(20)
outreg2 using rob_april_over20.doc, dec(3) ctitle(results_3) append 

heckman lvaccinations lcases days lhealthpc lmilitarypc lgov_response gov_eff lgdp_ppp_pc lpop65, select(over_20 = lcases lgdp_ppp_pc lgov_response lexportspc lmilitarypc lhealthpc lsoft_presence) robust iter(20)
outreg2 using rob_april_over20.doc, dec(3) ctitle(results_4) append 

* robustness with gov_eff lower and upper bounds

heckman lvaccinations lcases days lgov_response lhealthpc lmilitarypc gov_eff_lower, select(started_vi = lcases lexportspc lmilitarypc lhealthpc lsoft_presence) robust iter(20)
outreg2 using rob_geff_bounds.doc, dec(3) ctitle(results_3) replace 

heckman lvaccinations lcases days lhealthpc lmilitarypc lgov_response gov_eff_lower lpop65, select(started_vi = lcases lgdp_ppp_pc lgov_response lexportspc lmilitarypc lhealthpc lsoft_presence) robust iter(20)
outreg2 using rob_geff_bounds.doc, dec(3) ctitle(results_4) append 

heckman lvaccinations lcases days lgov_response lhealthpc lmilitarypc gov_eff_upper, select(started_vi = lcases lexportspc lmilitarypc lhealthpc lsoft_presence) robust iter(20)
outreg2 using rob_geff_bounds.doc, dec(3) ctitle(results_3) append 

heckman lvaccinations lcases days lhealthpc lmilitarypc lgov_response gov_eff_upper lpop65, select(started_vi = lcases lgdp_ppp_pc lgov_response lexportspc lmilitarypc lhealthpc lsoft_presence) robust iter(20)
outreg2 using rob_geff_bounds.doc, dec(3) ctitle(results_4) append 







* without outliers
heckman lvaccinations lcases days lgov_response i.OxfordAstraZeneca i.PfizerBioNTech i.Moderna if gdp_out==0 & gov_eff_out==0, select(started_vi = lcases lgov_response) robust iter(20)
outreg2 using results_outliers.doc, dec(3) ctitle(results_1) replace 

heckman lvaccinations lcases days gov_eff i.OxfordAstraZeneca i.PfizerBioNTech i.Moderna if gdp_out==0 & gov_eff_out==0, select(started_vi = lcases i.soft_30) robust iter(20)
outreg2 using results_outliers.doc, dec(3) ctitle(results_2) append 

heckman lvaccinations lcases days lgov_response lhealthpc lmilitarypc i.OxfordAstraZeneca i.PfizerBioNTech i.Moderna if gdp_out==0 & gov_eff_out==0, select(started_vi = lcases lgov_response lexportspc lmilitarypc lhealthpc i.soft_30) robust iter(20)
outreg2 using results_outliers.doc, dec(3) ctitle(results_3) append 

heckman lvaccinations lcases days lhealthpc lmilitarypc lgov_response gov_eff lgdp lpop65 i.OxfordAstraZeneca i.PfizerBioNTech i.Moderna if gdp_out==0 & gov_eff_out==0, select(started_vi = lcases lgdp lgov_response lexportspc lmilitarypc lhealthpc i.soft_30) robust iter(20)
outreg2 using results_outliers.doc, dec(3) ctitle(results_4) append 

* without outliers 2
heckman lvaccinations lcases days lgov_response i.OxfordAstraZeneca i.PfizerBioNTech i.Moderna if vi_per_hundred_out==0, select(started_vi = lcases lgov_response) robust iter(20)
outreg2 using results_outliers2.doc, dec(3) ctitle(results_1) replace 

heckman lvaccinations lcases days gov_eff i.OxfordAstraZeneca i.PfizerBioNTech i.Moderna if vi_per_hundred_out==0, select(started_vi = lcases i.soft_30) robust iter(20)
outreg2 using results_outliers2.doc, dec(3) ctitle(results_2) append 

heckman lvaccinations lcases days lgov_response lhealthpc lmilitarypc i.OxfordAstraZeneca i.PfizerBioNTech i.Moderna if vi_per_hundred_out==0, select(started_vi = lcases lgov_response lexportspc lmilitarypc lhealthpc i.soft_30) robust iter(20)
outreg2 using results_outliers2.doc, dec(3) ctitle(results_3) append 

heckman lvaccinations lcases days lhealthpc lmilitarypc lgov_response gov_eff lgdp lpop65 i.OxfordAstraZeneca i.PfizerBioNTech i.Moderna if vi_per_hundred_out==0, select(started_vi = lcases lgdp lgov_response lexportspc lmilitarypc lhealthpc i.soft_30) robust iter(20)
outreg2 using results_outliers2.doc, dec(3) ctitle(results_4) append 
