* Simple TWFE benchmark: COMET16, country-specific reform years.
clear*
use "oecd_twfe.dta", clear
xtset country_id year, yearly

generate post = year>=reform_year
areg employment_gap 1.treated#1.post i.year, absorb(country_id)

* Event study.
clear*
use "oecd_twfe.dta", clear

capture drop time_entering_treatment
generate time_entering_treatment = reform_year if treated==1
replace time_entering_treatment = . if treated==0

capture drop event_time
generate event_time = year - time_entering_treatment
tabulate event_time, missing
replace event_time = -1 if treated==0
replace event_time = -2 if event_time<-2 & treated==1
replace event_time = 2 if event_time>2 & treated==1
tabulate event_time
tabulate event_time, gen(event_time_dummy)

areg employment_gap event_time_dummy1 event_time_dummy3 event_time_dummy4 event_time_dummy5 i.year, absorb(country_id)
coefplot, keep(event_time_*) vertical graphregion(color(white)) yline(0) ///
    rename(event_time_dummy1="k=-2" event_time_dummy3="k=0" event_time_dummy4="k=+1" event_time_dummy5="k=+2")
graph export "oecd_twfe_event_study.jpg", as(jpg) replace
