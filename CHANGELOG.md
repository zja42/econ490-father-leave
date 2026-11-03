# Change history

## 2026-11-03

Initial GitHub research baseline. Removed the local stacked-comparison extension after the user requested the simple TWFE DiD model structure. Restored unique country-year observations, ordinary country/year effects and the approved country-specific reform-year exception. Retained employment-gap levels and broad father-specific leave coverage. Verified OECD26-country and European23-country TWFE results. Prior local case-study and stacked outputs are not presented as this baseline.

## 2026-11-03: raw-source Stata workflow

Moved every analysis-data preparation step into both Stata do-files: raw OECD workbook and employment-record imports, explicit legal effective-date corrections, option parsing, sample filters, reshape, country/year merges, gap and treatment construction. Added unchanged source archives/records and a lossless, unfiltered Eurostat JSON-to-CSV representation. The generated DTA/CSV files are outputs. Rebuilt the identical country-year samples and reform dates, with unchanged regression results. The main TWFE DiD model structure is retained.

## 2026-11-03: folder organization and public visibility

At the user's request, changed repository visibility to Public. Moved raw inputs, generated panels and policy/timing data into data/, and figures plus checked result tables/logs into results/. Updated both do-files' relative paths and the README. No data values, sample restrictions, treatment dates or model terms were changed.

## 2026-11-03: Use descriptive method names

Updated the README, instructions, audit notes, metadata, Stata comments and checked-output comment labels to name the TWFE DiD and event-study methods directly. Executable Stata statements, source data, sample selection and numeric results are unchanged. Updated file hashes.
