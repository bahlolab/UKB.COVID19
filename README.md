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
log.cov(data=res$tested, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","O","inAgedCare"), asso.output = "pos.neg")
```

Association test for white British only 
```r
tested <- res$tested
res.white <- tested[tested$white == 1 & !(is.na(tested$white)),]
table(res.white$pos.neg)
log.cov(data=res.white, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),asso.output = "white.pos.neg")
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
log.cov(data=mortality, phe.name="mortality", cov.name=c("sex","age","bmi","O","AB","A"))
log.cov(data=mortality, phe.name="mortality", cov.name=c("sex","age","bmi","black","asian","other.ppl","mixed"))
```

Association test for white British only 
```r
mortality.white <- mortality[mortality$white == 1 & !(is.na(mortality$white)),]
table(mortality.white$mortality)
log.cov(data=mortality.white, phe.name="mortality", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),  asso.output = "white.mortality")
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
log.cov(data=severity, phe.name="hosp", cov.name=c("sex","age","bmi","inAgedCare"))
```

Association test of severity level 2
```r
table(severity$severe.lev2)
log.cov(data=severity, phe.name="severe.lev2", cov.name=c("sex","age","bmi","O","AB","A"))
```

Association test of severity level 3
```r
table(severity$severe.lev3)
log.cov(data=severity, phe.name="severe.lev3", cov.name=c("sex","age","bmi","SES"))
```

Association test for white British only
```r
severity.white <- severity[severity$white == 1 & !(is.na(severity$white)),]
table(severity.white$hosp)
table(severity.white$severe.lev2)
table(severity.white$severe.lev3)

log.cov(data=severity.white, phe.name="hosp", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"), asso.output = "white.hosp")

log.cov(data=severity.white, phe.name="severe.lev2", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"), asso.output = "white.sev.lev2")

log.cov(data=severity.white, phe.name="severe.lev3", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"), asso.output = "white.sev.lev3")
```

## Co-morbidity

Function: `comorbidity.summary(hesin.file, hesin_diag.file, cov.file, primary=FALSE, ICD10.file="./data/ICD10.coding19.tsv", Date.start=NULL, Date.end=NULL)`

Summarise co-morbidity information based on HES data and the given time period. 

Arguments:
- `hesin.file`: the file name of the HES inpatient core dataset from UKB.
- `hesin_diag.file`: the file name of the HES inpatient diagnosis date from UKB.
- `cov.file`: the file name of the covariate data.
- `primary`: if only the primary diagnoses will be included in the analysis. By default, primary=FALSE, all diagoses will be inlcuded.
- `ICD10.file`: ICD10 coding file for the diagnosis data.
- `Date.start`: the start date of the selcted time period.
- `Date.end`: the end date of the selecte time period.

#### Example

```r
hesin.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210122_hesin.txt"
hesin_diag.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210122_hesin_diag.txt"
cov <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/covariate.v0.txt"
ICD10 <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/ICD10.coding19.tsv"

comorbidity.summary(hesin.file, hesin_diag.file, cov.file=cov, ICD10.file=ICD10, Date.end="01/04/2019")
# set the end of Date as the first test day, to exclude the morbidities caused by CoVID-19
```

Function: `comorbidity.asso(res.file, comorbidity.file, population = "all", covars=c("sex","age","bmi"), phe.name, output=NULL)`

Association tests between each co-morbidity and given phenotype (susceptibility, mortality or severity) with the adjustment of covariates. 

Arguments:
- `res.file`: the test results file name.
- `comorbidity.file`: the comorbidity file generated from function `comorbidity.summary`.
- `population`: the selected population/ethnic group. By default, population="all", include all ethnic groups.
- `covars`: the covariates included in the analysis.
- `phe.name`: phenotype name.
- `output`: the output file name. By default, output=NULL, it is {population}_{phenotype name}_comorbidity_asso.csv.

#### Example

white British, severity vs co-morbidity
```r
res.file <- "severity_2020-12-09.txt"
cormorbidity.file <- "comorbidity_1991-04-18_2019-04-01.RData"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="hosp")
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="severe.lev2")
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="severe.lev3")
```

white British, susceptibility vs co-morbidity
```r
cormorbidity.file <- "comorbidity_1991-04-18_2019-04-01.RData"
res.file <- "/stornext/HPCScratch/home/wang.lo/CoVID-19/test/result_2021-01-18.txt"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="result")
res.file <- "/stornext/HPCScratch/home/wang.lo/CoVID-19/test/susceptibility.tested.txt"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="pos.neg")
res.file <- "/stornext/HPCScratch/home/wang.lo/CoVID-19/test/susceptibility.population.txt"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="pos.ppl")
```

white British, mortality vs co-morbidity
```r
cormorbidity.file <- "comorbidity_1991-04-18_2019-04-01.RData"
res.file <- "/stornext/HPCScratch/home/wang.lo/CoVID-19/test/mortality_2020-12-18.txt"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="mortality")
```
## Association Test

Function: `log.cov(data, phe.name, cov.name = c("sex","age","bmi"), asso.output = NULL)`

Association tests using logistic regression model.

Arguments:
- `data`: the output from COVID19.susceptibility, COVID19.mortality, or COVID19.severity.
- `phe.name`: "pos.neg", "pos.ppl", "mortality", "hosp", "severe.lev2", or "severe.lev3".
- `cov.name`: select among: "sex", "age", "bmi", "SES", "black", "asian", "other.ppl", "mixed", "O", "AB", "A", "inAgedCare". "black", "asian", "other.ppl", "mixed" are dummy variables comparing to white British. "O", "AB", "A" are dummy variables comparing to blood group B. By default, cov.name = c("sex","age","bmi"), covariates include sex, age and BMI.
- `asso.ouput`: generate a csv file including association test results (estimate, odds ratio and p-value). by default, asso.output=NULL, it doesn’t generate an output file. 

Note: participants with missing values in the result or the covariates included in the association test will be omitted.

#### Example

Association test of susceptibility (positive vs negative) 
```r
log.cov(data=res$tested, phe.name="pos.neg", 
  cov.name=c("sex","age","bmi","SES","smoke","asian","other.ppl","inAgedCare"), 
  asso.output = "pos.neg")
```

Association test of susceptibility (positive vs population) 
```r
log.cov(data=res$population, phe.name="pos.ppl", 
  cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","A","inAgedCare"), 
  asso.output = "pos.ppl")
```

Association test of susceptibility for white British only 
```r
tested <- res$tested
res.white <- tested[tested$white == 1 & !(is.na(tested$white)),]
log.cov(data=res.white, phe.name="pos.neg", 
  cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),
  asso.output = "white.pos.neg")

ppl <- res$population
ppl.white <- ppl[ppl$white == 1 & !(is.na(ppl$white)),]
log.cov(data=ppl.white, phe.name="pos.neg", 
  cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),
  asso.output = "white.pos.ppl")
```

