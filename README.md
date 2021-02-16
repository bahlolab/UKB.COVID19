# UKB.COVID19
An R package to assist with the UK Biobank (UKB) COVID-19 data processing, risk factor association tests and to generate [SAIGE](https://github.com/weizhouUMICH/SAIGE) GWAS phenotype file.

See UKB.COVID19_example.R script for usage example.

Currently, `UKB.COVID19` is available as a beta release however it is still under active development and subject to change. Please contact [Longfei Wang](wang.lo@wehi.edu.au) if you would like to test the development version or to report any issues, feedback or feature requests.

Note: for the UKB COVID-19 test result data and the other UKB data, you can download the datasets after applying for them on UKB website.

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
```

## Susceptibility

Function: `COVID19.susceptibility(res.file, cov.file =  "./data/covariate.v0.txt", 
Date = NULL, out.name = NULL)`

Definitions of COVID-19 susceptibility: 
- pos.neg: COVID-19 positive vs negative; 
- pos.ppl: COVID-19 positive vs population, all the other participants in UKB, including those who got negative test results and people who didn’t get tested yet.

Arguments:
- `res.file`: the name of the test result file from UKB.
- `cov.file`: provided by the package, includes the potential non-genetic risk factors of all UKB participants: sex, age, BMI, ethnic background, array, socioeconomic status (SES), smoking, blood group, and if the participant is living in an aged care home. We will keep updating this file and keep including more risk factors. All the multi-category variables, such as, ethnic background and blood group, have been converted to multiple dummy variables for the association tests. By default, it’s under {work directory}/data/. The file needs to be unzipped first.
- `Date`:  select the results until a certain date. By default, Date = NULL, the latest testing date. The date format has to be %d/%m/%Y. For example, by setting Date = 01/10/2020, the function will select the test results by the 1st of Oct 2020, inclusive. 
- `out.name`: output file name. By default, out.name = NULL, “result_{Date}.txt”.
output files:
  - Positive vs negative + covariates.
  - Positive vs population + covariates.

The output also returns a list including both of the datasets. The output files can be used for SAIGE GWAS analyses directly. 

#### Example
```r
res.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210120_covid19_result.txt"
cov.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/covariate.v0.txt"
res <- COVID19.susceptibility(res.file, cov.file)
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

## Mortality

Function: `COVID19.mortality(res.file, death.file, death.cause.file, cov.file= "./data/covariate.v0.txt", Date=NULL, out.name=NULL)`

The definition of mortality: participants with COVID-19 as primary death cause vs the other participants with positive COVID-19 test results.

Arguments:
- `res.file`: the file name of the COVID-19 test result date from UKB.
- `death.file`: the file name of the death records from UKB.
- `death.cause.file`: the file name of the death cause data from UKB.
- `cov.file`: the file name of the covariate data built in the R package.
- `Date`:  select the results until a certain date. The date shouldn’t be later than the latest testing date or the latest death information date. By default, Date = NULL, the latest testing date if the death information date is more recent, and vice versa. For example, the latest testing date is 18/01/2021 and the latest death information released date is 18/12/2020. If we set Date = NULL, the function will select both data generated until 18/12/2020. Since all data are updated at the different frequency. To combine different datasets, we need to make sure the time period consistent. The date format has to be %d/%m/%Y.
- `out.name`: output file name. By default, out.name = NULL, “mortality_{Date}.txt”.

#### Example

```r
res.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210120_covid19_result.txt"
death.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210121_death.txt"
death.cause.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210121_death_cause.txt"
cov.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/covariate.v0.txt"

mortality <- COVID19.mortality(res.file, death.file, death.cause.file, cov.file)
```

Association test
```r
log.cov(data=mortality, phe.name="mortality",
  cov.name=c("sex","age","bmi","SES","smoke","black","inAgedCare"), 
  asso.output = "mortality1")
```

Association test for white British only 
```r
mortality.white <- mortality[mortality$white == 1 & !(is.na(mortality$white)),]
log.cov(data=mortality.white, phe.name="mortality", 
  cov.name=c("sex","age","bmi","smoke","inAgedCare"),  
  asso.output = "white.mortality1")
```

## Severity

Function: `COVID19.severity(res.file, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, cov.file= "./data/covariate.v0.txt", code.file= "./data/coding240.tsv", Date=NULL, out.name=NULL)`

Four definitions of severity:
- hospitalization
- severity level 2
- severity level 3

Arguments:
- `res.file`: the file name of the COVID-19 test result date from UKB.
- `death.file`: the file name of the death records from UKB.
- `death.cause.file`: the file name of the death cause data from UKB.
- `hesin.file`: the file name of the HES inpatient core dataset from UKB.
- `hesin_diag.file`: the file name of the HES inpatient diagnosis date from UKB.
- `hesin_oper.file`: the file name of the HES inpatient operation date from UKB.
- `hesin_critical.file`: the file name of the HES inpatient critical care data from UKB.
- `cov.file`: the name of the covariate file.
- `code.file`: the name of the coding 240 file for operation catagory.
- `Date`:  select the results until a certain date. The date shouldn’t be later than the latest testing date, the latest death information date or the latest hospitalisation information date. By default, Date = NULL, the latest date for all release datasets. The date format has to be %d/%m/%Y.
- `out.name`: output file name. By default, out.name = NULL, “mortality_{Date}.txt”.

#### Example

```r
res.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210120_covid19_result.txt"
death.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210121_death.txt"
death.cause.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210121_death_cause.txt"
hesin.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210122_hesin.txt"
hesin_diag.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210122_hesin_diag.txt"
hesin_oper.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210122_hesin_oper.txt"
hesin_critical.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210122_hesin_critical.txt"
cov.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/covariate.v0.txt"
code.file <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/coding240.tsv"


severity <- COVID19.severity(res.file, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, cov.file, code.file)
```

Association test of hospitalizatiopn
```r
log.cov(data=severity, phe.name="hosp", 
  cov.name=c("sex","age","bmi","SES","smoke","black","asian"), 
  asso.output = "hosp")
```

Association test of severity level 2
```r
log.cov(data=severity, phe.name="severe.lev2", 
  cov.name=c("sex","age","bmi","SES","smoke","black","asian","inAgedCare"), 
  asso.output = "sev.lev2")
```

Association test of severity level 3
```r
log.cov(data=severity, phe.name="severe.lev3", 
  cov.name=c("sex","age","bmi","smoke","black","asian"), 
  asso.output = "sev.lev3")
```

Association test for white British only
```r
severity.white <- severity[severity$white == 1 & !(is.na(severity$white)),]
log.cov(data=severity.white, phe.name="hosp", 
  cov.name=c("sex","age","bmi","SES","smoke"), 
  asso.output = "white.hosp")
log.cov(data=severity.white, phe.name="severe.lev2", 
  cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"), 
  asso.output = "white.sev.lev2")
log.cov(data=severity.white, phe.name="severe.lev3", 
  cov.name=c("sex","age","bmi","smoke"), 
  asso.output = "white.sev.lev3")
```

## Co-morbidity

Function: `comorbidity.summary(hesin.file, hesin_diag.file, cov.file="./data/covariate.v0.txt", primary=FALSE, ICD10.file="./data/ICD10.coding19.tsv", Date.start=NULL, Date.end=NULL)`

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
