clear*
cd "."
capture log close
log using "results/oecd_test7.log", text replace

import delimited using "data/country_codes.csv", varnames(1) clear
save "data/country_codes.dta", replace

import delimited using "data/pf21_table_records.csv", varnames(1) stringcols(_all) clear
generate country = country_raw
replace country = substr(country,1,strpos(country," (")-1) if strpos(country," (")>0
replace country = "Israel" if substr(country,1,6)=="Israel"
replace country = "Czechia" if country=="Czech Republic"
replace country = "Türkiye" if country=="Turkey"
merge m:1 country using "data/country_codes.dta"
keep if _merge==3
drop _merge
generate year = real(caption_year)
keep if year!=2020
replace year = 2017 if year==2018 & countrycode=="CHL"
replace year = 2017 if year==2018 & countrycode=="CRI"
generate weeks = real(total_weeks)
generate pay_pct = real(total_rate)
generate suspect = 0
replace suspect = 1 if real(parental_weeks)>0 & real(parental_rate)==0
replace suspect = 1 if real(paternity_weeks)>0 & real(paternity_rate)==0
replace suspect = 1 if abs(weeks-real(paternity_weeks)-real(parental_weeks))>0.15
generate known_policy = weeks>=0 & weeks<. & pay_pct>=0 & pay_pct<=100.5 & suspect==0
keep countrycode year weeks pay_pct known_policy suspect
save "data/policy.dta", replace

import delimited using "data/maternal_table_records.csv", varnames(1) stringcols(_all) clear
generate country = country_raw
replace country = substr(country,1,strpos(country," (")-1) if strpos(country," (")>0
replace country = "Israel" if substr(country,1,6)=="Israel"
replace country = "Czechia" if country=="Czech Republic"
replace country = "Türkiye" if country=="Turkey"
merge m:1 country using "data/country_codes.dta"
keep if _merge==3
drop _merge
generate year = real(caption_year)
keep if year!=2020
replace year = 2017 if year==2018 & countrycode=="CHL"
replace year = 2017 if year==2018 & countrycode=="CRI"
generate maternal_weeks = real(maternity_weeks)
keep countrycode year maternal_weeks
save "data/maternal.dta", replace

import excel "data/SOCX2025-All-nat-cur.xlsx", sheet("SOCX_NatCur") allstring clear
keep if G=="10" & H=="5" & I=="1" & J=="2" & K=="0"
rename A country
rename C seriescode
replace country = "Israel" if country=="Israel "
keep country seriescode L-BC
rename L spend1980
rename M spend1981
rename N spend1982
rename O spend1983
rename P spend1984
rename Q spend1985
rename R spend1986
rename S spend1987
rename T spend1988
rename U spend1989
rename V spend1990
rename W spend1991
rename X spend1992
rename Y spend1993
rename Z spend1994
rename AA spend1995
rename AB spend1996
rename AC spend1997
rename AD spend1998
rename AE spend1999
rename AF spend2000
rename AG spend2001
rename AH spend2002
rename AI spend2003
rename AJ spend2004
rename AK spend2005
rename AL spend2006
rename AM spend2007
rename AN spend2008
rename AO spend2009
rename AP spend2010
rename AQ spend2011
rename AR spend2012
rename AS spend2013
rename AT spend2014
rename AU spend2015
rename AV spend2016
rename AW spend2017
rename AX spend2018
rename AY spend2019
rename AZ spend2020
rename BA spend2021
rename BB spend2022
rename BC spend2023
reshape long spend, i(seriescode) j(year)
generate leave_million = real(spend)
keep if year>=2000 & year<=2023
merge m:1 country using "data/country_codes.dta"
keep if _merge==3
drop _merge
keep countrycode year spend leave_million
save "data/spending.dta", replace

import delimited using "data/ilo_household_raw.csv", varnames(1) clear
rename ref_area countrycode
rename time year
keep if classif1=="HHT_AGGREGATE_K"
keep if classif2=="CHL_AGET6_YES"
keep if year>=2000 & year<=2024
keep if obs_status==""
save "data/oecd_employment.dta", replace
keep if sex=="SEX_M"
keep countrycode year obs_value
rename obs_value male_rate
save "data/oecd_male.dta", replace
use "data/oecd_employment.dta", clear
keep if sex=="SEX_F"
keep countrycode year obs_value
rename obs_value female_rate
merge 1:1 countrycode year using "data/oecd_male.dta"
keep if _merge==3
drop _merge

save "data/oecd_rates.dta", replace

use "data/wdi_raw.dta", clear
keep countrycode year ny_gdp_pcap_kd ny_gdp_mktp_kd_zg ny_gdp_mktp_cn incomelevel
merge m:1 countrycode using "data/country_codes.dta"
keep if _merge==3
drop _merge

merge 1:1 countrycode year using "data/oecd_rates.dta"
drop if _merge==2
drop _merge
merge 1:1 countrycode year using "data/policy.dta"
drop if _merge==2
drop _merge
merge 1:1 countrycode year using "data/maternal.dta"
drop if _merge==2
drop _merge
merge 1:1 countrycode year using "data/spending.dta"
drop if _merge==2
drop _merge
keep if year>=1999 & year<=2024
encode countrycode, generate(ccode)
tsset ccode year
generate lngdp = ln(ny_gdp_pcap_kd)
generate gdp_growth = ny_gdp_mktp_kd_zg
generate lag_lngdp = L1.lngdp
generate lag_gdp_growth = L1.gdp_growth
generate employment_gap = male_rate-female_rate
generate leave_gdp = 100*leave_million*1000000/ny_gdp_mktp_cn
generate pay_c = pay_pct-100
generate week_pay = weeks*pay_c
generate usable = employment_gap!=. & known_policy==1 & weeks!=. & pay_pct!=. & leave_million>=0 & leave_million<. & ny_gdp_mktp_cn>0 & ny_gdp_mktp_cn<. & leave_gdp!=. & maternal_weeks>=0 & maternal_weeks<. & lag_lngdp!=. & lag_gdp_growth!=.
bysort ccode: egen usable_years = total(usable)
save "results/oecd_before_selection.dta", replace
keep if usable_years>=2 & usable==1
tsset ccode year
save "results/oecd_panel.dta", replace

xtreg employment_gap lag_lngdp leave_gdp maternal_weeks lag_gdp_growth c.weeks##c.pay_c i.year i.ccode, fe
testparm i.year

xtreg employment_gap lag_lngdp leave_gdp maternal_weeks lag_gdp_growth c.weeks##c.pay_c i.year i.ccode, fe
xttest3

capture noisily xtserial employment_gap leave_gdp maternal_weeks lag_gdp_growth weeks pay_c week_pay

xtpcse employment_gap lag_lngdp leave_gdp maternal_weeks lag_gdp_growth c.weeks##c.pay_c i.year i.ccode, het corr(ar1)

xtpcse employment_gap lag_lngdp leave_gdp maternal_weeks lag_gdp_growth c.weeks##c.pay_c c.weeks#c.weeks i.year i.ccode, het corr(ar1)

su employment_gap, detail
generate employment_gap_winsor = employment_gap
replace employment_gap_winsor = r(p1) if employment_gap_winsor < r(p1) & employment_gap_winsor != .
replace employment_gap_winsor = r(p99) if employment_gap_winsor > r(p99) & employment_gap_winsor != .

su lag_lngdp, detail
generate lag_lngdp_winsor = lag_lngdp
replace lag_lngdp_winsor = r(p1) if lag_lngdp_winsor < r(p1) & lag_lngdp_winsor != .
replace lag_lngdp_winsor = r(p99) if lag_lngdp_winsor > r(p99) & lag_lngdp_winsor != .

xtpcse employment_gap_winsor lag_lngdp_winsor leave_gdp maternal_weeks lag_gdp_growth c.weeks##c.pay_c c.weeks#c.weeks i.year i.ccode, het corr(ar1)

xtpcse employment_gap_winsor lag_lngdp_winsor leave_gdp maternal_weeks lag_gdp_growth c.weeks##c.pay_c c.weeks#c.weeks i.year i.ccode if incomelevel == "HIC", het corr(ar1)
estimates store model1
etable, estimates(model1) mstat(N) mstat(r2) showstars showstarsnote export(results/oecd_Test7table.docx, replace)

capture log close
