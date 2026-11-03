# Father specific leave and the employment gender gap

ECON 490 research baseline using the simple TWFE and event-study templates in [COMET16](https://ubcecon.github.io/comet-open/docs/5_Research/econ490-pystata/16_Diff_in_Diff.html). The approved timing adaptation gives each country its own recorded reform year. This is an exploratory TWFE benchmark, not a modern staggered-adoption causal ATT estimate.

## Current specification

Each original country-year occurs once. There are no comparison stacks or comparison-specific fixed effects. The outcome is the male employment rate minus the female employment rate, in percentage points, calculated inside each do-file from the raw employment records.

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

Open this folder as Stata's working directory, then run `OECD_TWFE.do` or `EUROPE_TWFE.do`. Both scripts start by importing raw sources; neither starts from an existing analysis DTA. The DTA and CSV panels in `data/` are generated outputs and may be rebuilt. Figures and checked result tables/logs are in `results/`. `coefplot`, used by COMET16, must already be installed.

Each script imports the original OECD workbook, retains the father-specific total paid/unpaid and total paid entitlement strings, applies the documented legal-year corrections, handles slash-separated options without averaging, identifies each country's first qualifying expansion, imports raw employment records, applies the existing quality/sample rules, merges by country/year, calculates male minus female employment rates, and creates the panel identifiers and treatment variables. The regression and event-study sections retain the approved COMET16 template. The user expressly requested the additional data-preparation commands; the earlier restriction on adding model extensions still applies.

Raw inputs supplied in `data/`:

- `data/oecd_leave_history.xlsx`: unchanged OECD PF2.5 workbook; imported directly with `import excel`.
- `data/ilo_household_raw.csv`: unchanged source CSV after byte-preserving decompression of the ILO archive; every source row and column retained.
- `data/eurostat_employment_raw.json`: unchanged archived Eurostat API response.
- `data/eurostat_employment_raw.csv`: lossless tabular decoding of all 124,529 reported numeric observations in that JSON, with every dimension, value and observation flag. No country, population or sex filtering, rate construction or treatment coding occurs in this storage-format conversion. All those operations occur in the Stata do-file. Missing combinations remain absent; no values are imputed.
- `data/country_codes.csv`: static OECD country-name/ISO dictionary. Its nonempty Eurostat codes explicitly retain the established 23-country European sample; this is not all geographically European OECD members. No country is added or removed in this revision.

`data/raw_sources.json` records source URLs, hashes and conversion notes. The existing annex/timing audits explain legal-year corrections. The scripts were rerun from these sources: OECD477 rows/26 countries and Europe295 rows/23 countries, identical country-years and treatment dates to the previous version; employment-gap differences are below1e-10 percentage points. The policy coefficients and p-values are unchanged. `results/stata_output.txt` contains the actual new run output with the Stata license startup omitted. No prebuilt panel is required as an input.

## Sources

- [COMET16 teaching template](https://ubcecon.github.io/comet-open/docs/5_Research/econ490-pystata/16_Diff_in_Diff.html)
- [OECD PF2.5 definitions](https://webfs.oecd.org/els-com/Family_Database/PF2_5_Trends_in_leave_entitlements_around_childbirth.pdf)
- [OECD country policy annex](https://webfs.oecd.org/els-com/Family_Database/PF2_5_Trends_in_leave_entitlements_around_childbirth_annex.pdf)
- [OECD membership](https://www.oecd.org/en/about/members-partners.html)

This repository started privately with the corrected, unstacked chapter-template baseline on2026-11-03. Later authorized research revisions should update code, data, audits and results together and preserve the change history.

## Folder layout

```text
econ490-father-leave/
  OECD_TWFE.do
  EUROPE_TWFE.do
  data/       # Raw records, country lookup, generated panels and policy audits
  results/    # Event-study JPGs, regression table, checked Stata output and verification
```

Run both do-files with the repository root as the working directory. Their input and output paths use these folders. This is a public repository as requested on2026-11-03. The folder changes do not alter data, country selection, policy timing or the model.
