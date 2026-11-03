* Raw-source preparation followed by the COMET16 regression template.
clear*
* Import the original OECD policy workbook.
import delimited "country_codes.csv", clear varnames(1) stringcols(_all)
tempfile country_codes euro_codes policy panel
save `country_codes'
preserve
keep if geo!=""
save `euro_codes'
restore

import excel "oecd_leave_history.xlsx", sheet("Time-Series") cellrange(A9) allstring clear
rename A country
rename B year
rename S total_all_raw
rename T total_paid_raw
keep country year total_all_raw total_paid_raw
destring year, replace force
keep if inrange(year,1970,2024)
merge m:1 country using `country_codes'
keep if _merge==3
drop _merge
isid iso year

* Apply the previously documented legal effective-date corrections.
generate timing_note = ""
replace total_paid_raw = "2.6" if iso=="FRA" & year==2014
replace timing_note = "PreParE effective 2015, not 2014" if iso=="FRA" & year==2014
replace total_paid_raw = "4" if iso=="IRL" & year==2019
replace timing_note = "Two weeks Parents Leave effective November 2019" if iso=="IRL" & year==2019
replace total_paid_raw = string(real(total_paid_raw)+13) if iso=="ITA" & year==2022
replace timing_note = "Three months reserved paid parental leave effective August 2022" if iso=="ITA" & year==2022

* Align annual snapshots to the legal years listed in the OECD annex.
foreach measure in all paid {
    generate snapshot = real(total_`measure'_raw)
    bysort iso: egen aligned = max(cond(year==2020,snapshot,.))
    replace total_`measure'_raw = string(aligned,"%18.10g") if iso=="AUT" & year==2019
    drop aligned
    bysort iso: egen aligned = max(cond(year==2021,snapshot,.))
    replace total_`measure'_raw = string(aligned,"%18.10g") if iso=="EST" & year==2020
    drop aligned
    bysort iso: egen aligned = max(cond(year==2011,snapshot,.))
    replace total_`measure'_raw = string(aligned,"%18.10g") if iso=="FIN" & year==2010
    drop aligned
    bysort iso: egen aligned = max(cond(year==2022,snapshot,.))
    replace total_`measure'_raw = string(aligned,"%18.10g") if iso=="GRC" & year==2021
    drop aligned snapshot
}
replace timing_note = "OECD annex: effective 2019; 2020 snapshot" if iso=="AUT" & year==2019
replace timing_note = "OECD annex: effective 2020; 2021 snapshot" if iso=="EST" & year==2020
replace timing_note = "OECD annex: effective 2010; 2011 snapshot" if iso=="FIN" & year==2010
replace timing_note = "OECD annex: effective 2021; 2022 snapshot" if iso=="GRC" & year==2021

* Retain slash-separated entitlement options instead of averaging them.
foreach measure in all paid {
    split total_`measure'_raw, parse("/") generate(`measure'_option)
    destring `measure'_option*, replace force
    egen `measure'_min = rowmin(`measure'_option*)
    egen `measure'_max = rowmax(`measure'_option*)
    egen `measure'_n = rownonmiss(`measure'_option*)
    generate known_`measure' = `measure'_n>0 & `measure'_min>=0
    bysort iso (year): generate same_`measure' = `measure'_n==`measure'_n[_n-1] & abs(`measure'_min-`measure'_min[_n-1])<=0.1 & abs(`measure'_max-`measure'_max[_n-1])<=0.1
    bysort iso (year): generate nondecrease_`measure' = same_`measure' | `measure'_min>=`measure'_max[_n-1]-0.1
    bysort iso (year): generate increase_`measure' = `measure'_min>`measure'_max[_n-1]+0.1
}
generate known_policy = known_all & known_paid
bysort iso (year): generate expansion = year==year[_n-1]+1 & known_policy & known_policy[_n-1]==1 & nondecrease_all & nondecrease_paid & (increase_all | increase_paid)
replace expansion = 0 if !inrange(year,2000,2024)
* Czech 2007 records a benefit change, not a verified new duration right.
replace expansion = 0 if iso=="CZE" & year==2007
bysort iso: egen reform_year = min(cond(expansion==1,year,.))
keep iso country year total_all_raw total_paid_raw known_policy reform_year timing_note
keep if inrange(year,2000,2024)
save `policy'

* Import the unchanged ILO source CSV, decompressed from the source archive.
import delimited "ilo_household_raw.csv", clear varnames(1) stringcols(_all)
rename ref_area iso
rename time year
destring year obs_value, replace force
keep if classif1=="HHT_AGGREGATE_K" & classif2=="CHL_AGET6_YES"
keep if inlist(sex,"SEX_M","SEX_F") & inrange(year,2000,2024)
bysort iso year: egen flagged = max(obs_status!="")
keep if flagged==0
generate sexcode = cond(sex=="SEX_M","M","F")
keep iso year sexcode obs_value
isid iso year sexcode
reshape wide obs_value, i(iso year) j(sexcode) string
rename obs_valueM male_rate
rename obs_valueF female_rate
generate source_flags = ""

* Merge raw outcomes with the policy history and apply the existing sample rule.
merge 1:1 iso year using `policy'
keep if _merge==3 & known_policy==1
drop _merge
drop if missing(male_rate,female_rate)
generate double employment_gap = male_rate-female_rate
generate treated = reform_year<=2024
encode iso, generate(country_id)
isid country_id year
sort country_id year
save `panel'
save "oecd_twfe.dta", replace
export delimited using "oecd_twfe.csv", replace

* Simple TWFE benchmark: COMET16 with country-specific reform years.
xtset country_id year, yearly
generate post = year>=reform_year
areg employment_gap 1.treated#1.post i.year, absorb(country_id)

* Event study: COMET16 section 16.5.
clear*
use `panel', clear
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
