# Father specific leave and the employment gender gap

ECON 490 research baseline using the simple TWFE and event-study templates in [COMET16](https://ubcecon.github.io/comet-open/docs/5_Research/econ490-pystata/16_Diff_in_Diff.html). The approved timing adaptation gives each country its own recorded reform year. This is an exploratory TWFE benchmark, not a modern staggered-adoption causal ATT estimate.

## Current specification

Each original country-year occurs once. There are no comparison stacks or comparison-specific fixed effects. The outcome is the male employment rate minus the female employment rate, in percentage points, prepared in the input data.

```stata
generate post = year>=reform_year
areg employment_gap 1.treated#1.post i.year, absorb(country_id)
```

The event study follows COMET16 section16.5, with the same four dummy variables, reference category -1, endpoint bins -2 and +2, ordinary calendar-year effects and country effects. No extra controls, trends, weights, alternative covariance option, polynomial, winsorization or extra diagnostic command is added. The do-files have short English comments and no hypothesis-explanation blocks. `template_audit.md` records the permitted substitutions and the removed extensions.

## Data and treatment definition

|Sample|Country-year rows|Countries|Period|
|---|---:|---:|---|
|OECD|477|26|2000-2024|
|European OECD|295|23|2006-2019|

The OECD outcome retains the original couple-with-child-under-six definition. The Eurostat outcome concerns people whose youngest child is under six, without a couple-household restriction. Differences between these samples are not purely geographic.

The policy catalogue covers total father-specific paid and unpaid leave and total paid father-specific leave, including paternity and reserved parental/homecare rights. It does not assign all transferable household leave to fathers. The treatment year is the first source-recorded, non-reducing qualifying expansion in a common2000-2024 catalogue, not first-ever access to leave. The same country's catalogue date is used across both samples. Later expansions remain in its post period rather than being separately identified. `treated=0` means no mapped expansion within the sample horizon, not that fathers have no leave. Source gaps and legal-date adjustments are documented in the policy and country audit files; no unknown entitlement is filled with zero.

Some countries have only pre-reform or only post-reform observations. Canada has one observed year. They remain visible in the country audit and are not presented as contributing a within-country treatment switch. The source-recorded catalogue is not a comprehensive reconstruction of every historical legal change. Country timing audits list pre/post support explicitly.

## Results

|Simple TWFE|Coefficient, percentage points|Default standard error|Default p-value|
|---|---:|---:|---:|
|OECD|+0.727431|0.740031|0.326178|
|European OECD|+0.899024|0.674035|0.183447|

Neither specification finds evidence of a reduction in the employment gender gap. Default inference is retained to match the lesson. COMET16 warns that different treatment dates can make a simple TWFE coefficient differ from the desired average causal effect. These estimates should not be described as robust causal effects. An insignificant event-study pre-coefficient does not prove parallel trends.

Earlier local stacked-model p-values are not the results of these do-files and are not the baseline being uploaded here.

## Running

Use Stata17 or later with this repository root as the working directory. Open and run `OECD_TWFE.do` or `EUROPE_TWFE.do`. The DTA inputs sit next to the scripts. The two JPG event-study outputs are saved in the same directory. `coefplot`, used in COMET16, must already be installed; it is installed on the author's computer. No installation code is added to the do-files.

The scripts were run in Stata, their coefficients and standard errors independently checked within1e-6, and both figures visually checked. `verified_results.csv` and `stata_output.txt` contain actual results; local machine paths have been shortened in the text output. Input CSVs, DTA files, timing audits and source policy records are all versioned.

## Sources

- [COMET16 teaching template](https://ubcecon.github.io/comet-open/docs/5_Research/econ490-pystata/16_Diff_in_Diff.html)
- [OECD PF2.5 definitions](https://webfs.oecd.org/els-com/Family_Database/PF2_5_Trends_in_leave_entitlements_around_childbirth.pdf)
- [OECD country policy annex](https://webfs.oecd.org/els-com/Family_Database/PF2_5_Trends_in_leave_entitlements_around_childbirth_annex.pdf)
- [OECD membership](https://www.oecd.org/en/about/members-partners.html)

This private repository starts with the corrected, unstacked chapter-template baseline on2026-11-03. Later authorized research revisions should update code, data, audits and results together and preserve the change history.
