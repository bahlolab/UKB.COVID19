# UKB.COVID19
An R package to assist with the [UK Biobank (UKB) COVID-19 data](https://biobank.ndph.ox.ac.uk/showcase/exinfo.cgi?src=COVID19) processing, risk factor association tests and to generate [SAIGE](https://github.com/weizhouUMICH/SAIGE) GWAS phenotype file.

See UKB.COVID19_example.R script for usage example.

Currently, `UKB.COVID19` is available as a beta release however it is still under active development and subject to change. Please contact [Longfei Wang](wang.lo@wehi.edu.au) if you would like to test the development version or to report any issues, feedback or feature requests.

Note: to access the UKB datasets, you need to register as an UKB researcher. If you are already an approved UKB researcher with a project underway, and wish to receive these datasets for COVID-19 research purposes, you can register to receive these data by logging into the [Access Management System (AMS)](https://bbams.ndph.ox.ac.uk/ams/resApplications).


## Installation

```r
install.packages("remotes")
remotes::install_github("bahlolab/UKB.COVID19")
```
OR
```r
install.packages("devtools")
devtools::install_github("bahlolab/UKB.COVID19")
```

```r
library(UKB.COVID19)
library(questionr) # for odd ratio calculation in association test 
require(data.table)
library(tidyverse)
library(magrittr)
```

## Risk Factor

Function: `risk.factor(ukb.data, ABO.data, hesin.file, res.eng, res.wal = NULL, res.sco = NULL, fields = NULL, field.names = NULL, out.file = NULL)`

This function formats and outputs a covariate file, used for input for other functions.

Arguments:
- `ukb.data`: tab delimited UK Biobank phenotype file.
- `ABO.data`: Latest yyyymmdd_covid19_misc.txt file.
- `res.eng`: Latest covid result file/files for England.
- `res.wal`: Latest covid result file/files for Wales. Only available for downloads after April 2021.
- `res.sco`: Latest covid result file/files for Scotland. Only available for downloads after April 2021.
- `out.file`: Name of covariate file to be outputted. By default, out.file = NULL, “covariate.txt”.

Outputs covariate file, used for input for other functions. Automatically returns sex, age at birthday in 2020, SES, self-reported ethnicity, most recently reported BMI, most recently reported pack-years, whether they reside in aged care (based on hospital admissions data, and covid test data) and blood type. Function also allows user to specify fields of interest (field codes, provided by UK Biobank), and allows the users to specify more intuitive names, for selected fields.

#### Example
```r
ukb.data <- "ukb42082.tab"
ABO.data <- "20200814_covid19_misc.txt"
hesin.file <- "20210502_hesin.txt"
res.eng <- "20210426_covid19_result_england.txt"
res.wal <- "20210426_covid19_result_wales.txt"
res.sco <- "20210426_covid19_result_scotland.txt"

risk.factor(ukb.data, ABO.data, hesin.file, res.eng, res.wal, res.sco)
```

## Susceptibility

Function: `COVID19.susceptibility(res.eng, res.wal=NULL, res.sco=NULL, cov.file, Date=NULL, out.name=NULL)`

Definitions of COVID-19 susceptibility: 
- pos.neg: COVID-19 positive vs negative; 
- pos.ppl: COVID-19 positive vs population, all the other participants in UKB, including those who got negative test results and people who didn’t get tested yet.

Arguments:
- `res.eng`: Latest covid result file/files for England.
- `res.wal`: Latest covid result file/files for Wales. Only available for downloads after April 2021.
- `res.sco`: Latest covid result file/files for Scotland. Only available for downloads after April 2021.
- `cov.file`: Covariate file generated using risk.factor function.
- `Date`:  Date, ddmmyyyy, select the results until a certain date. By default, Date = NULL, the latest testing date. 
- `out.name`: Name of susceptibility file to be outputted. By default, out.name = NULL, “result_{Date}.txt”.
output files:
  - Positive vs negative + covariates.
  - Positive vs population + covariates.

The output also returns a list including both of the datasets. The output files can be used for SAIGE GWAS analyses directly. 

#### Example
```r
res.eng <- "20210426_covid19_result_england.txt"
res.wal <- "20210426_covid19_result_wales.txt"
res.sco <- "20210426_covid19_result_scotland.txt"
cov.file <- "covariate.txt"

res <- COVID19.susceptibility(res.eng, res.wal, res.sco, cov.file)
```

Association test
```r
table(res$tested$pos.neg)
log_cov(data=res$tested, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","O","inAgedCare"), asso.output = "pos.neg")
```

Association test for white British only 
```r
tested <- res$tested
res.white <- tested[tested$white == 1 & !(is.na(tested$white)),]
table(res.white$pos.neg)
log_cov(data=res.white, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),asso.output = "white.pos.neg")
```

## Mortality

Function: `COVID19.mortality(res.eng, res.wal=NULL, res.sco=NULL, death.file, death.cause.file, cov.file, Date=NULL, out.name=NULL)`

The definition of mortality: participants with COVID-19 as primary death cause vs the other participants with positive COVID-19 test results.

Arguments:
- `res.eng`: Latest covid result file/files for England.
- `res.wal`: Latest covid result file/files for Wales. Only available for downloads after April 2021.
- `res.sco`: Latest covid result file/files for Scotland. Only available for downloads after April 2021.
- `death.file`: Latest death register file.
- `death.cause.file`: Latest death cause file
- `cov.file`: Covariate file generated using risk.factor function.
- `Date`:  Date, ddmmyyyy, select the results until a certain date. By default, Date = NULL, the latest death register date.  
- `out.name`: Name of mortality file to be outputted. By default, out.name = NULL, “mortality_{Date}.txt”.

#### Example

```r
res.eng <- "20210426_covid19_result_england.txt"
res.wal <- "20210426_covid19_result_wales.txt"
res.sco <- "20210426_covid19_result_scotland.txt"
cov.file <- "covariate.txt"
death.file <- "20210408_death.txt"
death.cause.file <- "20210408_death_cause.txt"

mortality <- COVID19.mortality(res.eng, res.wal, res.sco, death.file, death.cause.file, cov.file)
```

Association test
```r
table(mortality$mortality)
log_cov(data=mortality, phe.name="mortality", cov.name=c("sex","age","bmi","O","AB","A"))
log_cov(data=mortality, phe.name="mortality", cov.name=c("sex","age","bmi","black","asian","other.ppl","mixed"))
```

Association test for white British only 
```r
mortality.white <- mortality[mortality$white == 1 & !(is.na(mortality$white)),]
table(mortality.white$mortality)
log_cov(data=mortality.white, phe.name="mortality", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),  asso.output = "white.mortality")
```

## Severity

Function: `COVID19.severity(res.eng, res.wal=NULL, res.sco=NULL, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, cov.file= "./data/covariate.v0.txt", code.file= "./data/coding240.tsv", Date=NULL, out.name=NULL)`

Four definitions of severity:
- hospitalization
- critial care
- advanced critical care

Arguments:
- `res.eng`: Latest covid result file/files for England.
- `res.wal`: Latest covid result file/files for Wales. Only available for downloads after April 2021.
- `res.sco`: Latest covid result file/files for Scotland. Only available for downloads after April 2021.
- `death.file`: Latest death register file.
- `death.cause.file`: Latest death cause file
- `hesin.file`: Latest hospital inpatient master file.
- `hesin_diag.file`: Latest hospital inpatient diagnosis file.
- `hesin_oper.file`: Latest hospital inpatient operation file.
- `hesin_critical.file`: Latest hospital inpatient critical care file.
- `code.file`: The operation code file, which is included in the package, and also can be download from https://github.com/bahlolab/UKB.COVID19/blob/main/data/coding240.tsv.
- `cov.file`: Covariate file generated using risk.factor function.
- `Date`:  Date, ddmmyyyy, select the results until a certain date. By default, Date = NULL, the latest hospitalization date.  
- `out.name`: Name of severity files to be outputted. By default, out.name = NULL, “severity_{Date}.txt”.


#### Example

```r
res.eng <- "20210426_covid19_result_england.txt"
res.wal <- "20210426_covid19_result_wales.txt"
res.sco <- "20210426_covid19_result_scotland.txt"
death.file <- "20210408_death.txt"
death.cause.file <- "20210408_death_cause.txt"
hesin.file <- "20210502_hesin.txt"
hesin_diag.file <- "20210502_hesin_diag.txt"
hesin_oper.file <- "20210502_hesin_oper.txt"
hesin_critical.file <- "20210222_hesin_critical.txt"
cov.file <- "covariate.txt"
code.file <- "coding240.tsv"

severity <- COVID19.severity(res.eng, res.wal, res.sco, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, cov.file, code.file)
```

Association test of hospitalizatiopn
```r
table(severity$hosp)
log_cov(data=severity, phe.name="hosp", cov.name=c("sex","age","bmi","inAgedCare"))
```

Association test of severity level 2
```r
table(severity$severe.lev2)
log_cov(data=severity, phe.name="severe.lev2", cov.name=c("sex","age","bmi","O","AB","A"))
```

Association test of severity level 3
```r
table(severity$severe.lev3)
log_cov(data=severity, phe.name="severe.lev3", cov.name=c("sex","age","bmi","SES"))
```

Association test for white British only
```r
severity.white <- severity[severity$white == 1 & !(is.na(severity$white)),]
table(severity.white$hosp)
table(severity.white$severe.lev2)
table(severity.white$severe.lev3)

log_cov(data=severity.white, phe.name="hosp", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"), asso.output = "white.hosp")

log_cov(data=severity.white, phe.name="severe.lev2", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"), asso.output = "white.sev.lev2")

log_cov(data=severity.white, phe.name="severe.lev3", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"), asso.output = "white.sev.lev3")
```

## Co-morbidity Summary

Function: `comorbidity.summary(hesin.file, hesin_diag.file, cov.file, primary=FALSE, ICD10.file, Date.start=NULL, Date.end=NULL)`

Summarise co-morbidity information based on HESIN data and the given time period. 

Arguments:
- `hesin.file`: Latest hospital inpatient master file.
- `hesin_diag.file`: Latest hospital inpatient diagnosis file.
- `cov.file`: Covariate file generated using risk.factor function.
- `primary`: TRUE: include primary diagnosis only; FALSE: include all diagnoses.
- `ICD10.file`: The ICD10 code file, which is included in the package, and also can be download from https://github.com/bahlolab/UKB.COVID19/blob/main/data/ICD10.coding19.tsv.
- `Date.start`: Date, ddmmyyyy, select the start date of hospital inpatient record period. 
- `Date.end`: Date, ddmmyyyy, select the end date of hospital inpatient record period. 

Outputs comorbidity summary file, named comorbidity_<Date.start>_<Date.end>.RData, including phenotype, non-genetic risk factors and all comorbidities, which will be used in the comorbidity association tests.

#### Example

```r
hesin.file <- "20210502_hesin.txt"
hesin_diag.file <- "20210502_hesin_diag.txt"
cov <- "covariate.txt"
ICD10.file <- "ICD10.coding19.tsv"

comorbidity.summary(hesin.file, hesin_diag.file, cov.file=cov, ICD10.file=ICD10.file, primary = F, Date.end="16/03/2020")
comorbidity.summary(hesin.file, hesin_diag.file, cov.file=cov, ICD10.file=ICD10.file, primary = F, Date.start="16/03/2020")
```

## Co-morbidity Association Tests

Function: `comorbidity.asso(res.file, cormorbidity.file, population = "all", covars=c("sex","age","bmi"), phe.name, output=NULL)`

Association tests between each co-morbidity and given phenotype (susceptibility, mortality or severity) with the adjustment of covariates. 

Arguments:
- `res.file`: Result summary file generated from `COVID19.susceptibility`, `COVID19.severity` or `COVID19.mortality`.
- `comorbidity.file`: Comorbidity summary file generated from `comorbidity.summary`. 
- `population`: Choose self-report population/ethnic background group from "all", white", "black", "asian", "mixed", or "other". By default, population="all", include all ethnic groups.
- `covars`: Selected covariates names. By default, covars=c("sex","age","bmi"), covariates are sex age and BMI.
- `phe.name`: Phenotype name.
- `output`: Name of comorbidity association test result file to be outputted. By default, output=NULL, it is {population}_{phenotype name}_comorbidity_asso.csv.

#### Example

```r
res.file <- "severity_2021-02-05.txt"
cormorbidity.file <- "comorbidity_1991-04-18_2020-03-16.RData"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="severe.lev2", output = "lev2_bf.csv")

cormorbidity.file <- "comorbidity_2020-03-16_2021-02-05.RData"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="severe.lev2", output = "lev2_af.csv")
```

## Association Test

Function: `log_cov(data, phe.name, cov.name = c("sex","age","bmi"), asso.output=NULL)`

Association tests using logistic regression model.

Arguments:
- `data`: Data generated from `COVID19.susceptibility`, `COVID19.severity` or `COVID19.mortality`.
- `phe.name`: Phenotype name in the data.
- `cov.name`: Selected covariate names in the data. By default, cov.name = c("sex","age","bmi"), covariates include sex, age and BMI.
- `asso.ouput`: Name of association test result file to be outputted. By default, asso.output=NULL, it returns results but doesn't generate any files. 

Note: participants with missing values in the result or the covariates included in the association test will be omitted.

#### Example

Association test of susceptibility (positive vs negative) 
```r
log_cov(data=res$tested, phe.name="pos.neg", 
  cov.name=c("sex","age","bmi","SES","smoke","asian","other.ppl","inAgedCare"), 
  asso.output = "pos.neg")
```

Association test of susceptibility (positive vs population) 
```r
log_cov(data=res$population, phe.name="pos.ppl", 
  cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","A","inAgedCare"), 
  asso.output = "pos.ppl")
```

Association test of susceptibility for white British only 
```r
tested <- res$tested
res.white <- tested[tested$white == 1 & !(is.na(tested$white)),]
log_cov(data=res.white, phe.name="pos.neg", 
  cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),
  asso.output = "white.pos.neg")

ppl <- res$population
ppl.white <- ppl[ppl$white == 1 & !(is.na(ppl$white)),]
log_cov(data=ppl.white, phe.name="pos.neg", 
  cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),
  asso.output = "white.pos.ppl")
```

