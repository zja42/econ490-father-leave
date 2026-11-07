# OECD parental leave panel replication

Run OECD_WEEK_LENGTH_TEST7.do from this folder in Stata with etable support and the xttest3 and xtserial packages installed. The script reads the six bundled input files in data and writes the log and HIC Word table to results.

The outcome is the male employment rate minus the female employment rate for couples aged 25–54 with children under six. The key regressor is paid father-specific leave weeks. Include the OECD wage replacement percentage centered at 100 and its interaction with weeks. Controls are public maternity and parental leave spending as a share of GDP, paid maternity weeks, lagged log real GDP per capita, and lagged real GDP growth, with country and year fixed effects. Historical policy records are matched by country and year using the supplied script. Keep the bundled WDI snapshot for replication.

The Test7 sequence is fixed effects, year-effects test, repeated fixed effects, heteroskedasticity and serial-correlation diagnostics, AR(1) PCSE, quadratic weeks, 1st/99th-percentile winsorization of the outcome and lagged log GDP per capita, then full-sample and HIC winsorized quadratic models. Preserve the existing estimation commands and options. The Word table reports the HIC model. The log reports the full-sample estimates as well.

Replication targets: 20 countries and 77 country-year observations overall, and 74 observations in HIC. UMC contains Colombia with three observations. LMC and LIC are empty. The full-sample interaction coefficient is -0.016093 (p=0.084) under ordinary FE and -0.0161357 (p=0.002 as printed by Stata) under linear AR(1) PCSE. The AR(1) week coefficient at 100% replacement is 0.3862485 (p=0.126). The interaction describes how the estimated week-length slope varies with the pay rate. Stata reports bounding the estimated AR(1) parameter in the OECD run.

## Files

- `OECD_WEEK_LENGTH_TEST7.do` imports the supplied inputs, constructs the sample and runs the models. Run it with the repository root as Stata's working directory.
- `data/` contains the OECD PF2.1 historical table extracts for father-specific and maternity leave, the OECD SOCX national-currency workbook, the ILOSTAT household employment extract, the World Development Indicators snapshot and the country lookup.
- `results/stata_output.txt` contains the checked Stata session output. The run creates a fresh `results/oecd_test7.log`.
- `results/oecd_Test7table.docx` contains the checked HIC table.
