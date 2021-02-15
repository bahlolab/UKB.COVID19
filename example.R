### install R package
rm(list=ls())

# install required packages
# install.packages("questionr") # for association test OR
# library(questionr) 
# require(data.table)

### install R package option 1
# install.packages("devtools")
devtools::install_github("bahlolab/UKB.COVID19")

### install R package option 2
# install.packages("remotes")
remotes::install_github("bahlolab/UKB.COVID19",force = T)
library(UKB.COVID19)

### susceptibility
# set your work direroty
# setwd("/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/test/")

# UKB COVID-19 test result file location and name
# covariate file built in R package. Please unzip it and specify the location
res.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210120_covid19_result.txt"
cov.file <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/covariate.v0.txt"

# process UKB COVID-19 test result data for susceptibility analyses
res <- COVID19.susceptibility(res.file, cov.file)
# output a list include two datasets for 
# definition 1. positive vs negative
# definition 2. positive vs population

# association test of susceptibility (positive vs negative) 
log.cov(data=res$tested, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","mixed","O","AB","A","inAgedCare"))
log.cov(data=res$tested, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","asian","other.ppl","inAgedCare"), asso.output = "pos.neg")

# association test of susceptibility (positive vs population) 
log.cov(data=res$population, phe.name="pos.ppl", cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","mixed","O","AB","A","inAgedCare"))
log.cov(data=res$population, phe.name="pos.ppl", cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","A","inAgedCare"), asso.output = "pos.ppl")

# test white British only 
tested <- res$tested
res.white <- tested[tested$white == 1 & !(is.na(tested$white)),]
log.cov(data=res.white, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","O","AB","A","inAgedCare"))
log.cov(data=res.white, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),asso.output = "white.pos.neg")

ppl <- res$population
ppl.white <- ppl[ppl$white == 1 & !(is.na(ppl$white)),]
log.cov(data=ppl.white, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","O","AB","A","inAgedCare"))
log.cov(data=ppl.white, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),asso.output = "white.pos.ppl")


### mortality
res.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210120_covid19_result.txt"
death.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210121_death.txt"
death.cause.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210121_death_cause.txt"
cov.file <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/covariate.v0.txt"

# process test result data, death record data for mortality analyses
mortality <- COVID19.mortality(res.file, death.file, death.cause.file, cov.file)

# association test
log.cov(data=mortality, phe.name="mortality", cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","mixed","O","AB","A","inAgedCare"))
log.cov(data=mortality, phe.name="mortality", cov.name=c("sex","age","bmi","SES","smoke","black","inAgedCare"), asso.output = "mortality1")

# test white British only 
mortality.white <- mortality[mortality$white == 1 & !(is.na(mortality$white)),]
log.cov(data=mortality.white, phe.name="mortality", cov.name=c("sex","age","bmi","smoke","inAgedCare"),  asso.output = "white.mortality1")

### severity
res.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210120_covid19_result.txt"
death.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210121_death.txt"
death.cause.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210121_death_cause.txt"
hesin.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210122_hesin.txt"
hesin_diag.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210122_hesin_diag.txt"
hesin_oper.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210122_hesin_oper.txt"
hesin_critical.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210122_hesin_critical.txt"
cov.file <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/covariate.v0.txt"
code.file <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/coding240.tsv"

# process test result data, death record data, hospitalization data for severity analyses
severity <- COVID19.severity(res.file, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, cov.file, code.file)
# four definitions of severity:
# 1. hospitalization
# 2. severity level 2
# 3. severity level 3
# 4. mortality

# association test of hospitalizatiopn
log.cov(data=severity, phe.name="hosp", cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","mixed","O","AB","A","inAgedCare"))
log.cov(data=severity, phe.name="hosp", cov.name=c("sex","age","bmi","SES","smoke","black","asian"), asso.output = "hosp")

# association test of severity level 2
log.cov(data=severity, phe.name="severe.lev2", cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","mixed","O","AB","A","inAgedCare"))
log.cov(data=severity, phe.name="severe.lev2", cov.name=c("sex","age","bmi","SES","smoke","black","asian","inAgedCare"), asso.output = "sev.lev2")

# association test of severity level 3
log.cov(data=severity, phe.name="severe.lev3", cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","mixed","O","AB","A","inAgedCare"))
log.cov(data=severity, phe.name="severe.lev3", cov.name=c("sex","age","bmi","smoke","black","asian"), asso.output = "sev.lev3")

# association test of mortality
log.cov(data=severity, phe.name="mortality", cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","mixed","O","AB","A","inAgedCare"))
log.cov(data=severity, phe.name="mortality", cov.name=c("sex","age","bmi","SES","smoke","black","inAgedCare"), asso.output = "mortality2")

# test white British only
severity.white <- severity[severity$white == 1 & !(is.na(severity$white)),]
log.cov(data=severity.white, phe.name="hosp", cov.name=c("sex","age","bmi","SES","smoke"), asso.output = "white.hosp")
log.cov(data=severity.white, phe.name="severe.lev2", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"), asso.output = "white.sev.lev2")
log.cov(data=severity.white, phe.name="severe.lev3", cov.name=c("sex","age","bmi","smoke"), asso.output = "white.sev.lev3")
log.cov(data=severity.white, phe.name="mortality", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"), asso.output = "white.mortality2")

### co-morbidity
hesin.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210122_hesin.txt"
hesin_diag.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210122_hesin_diag.txt"
cov <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/covariate.v0.txt"
ICD10 <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/ICD10.coding19.tsv"
comorbidity.summary(hesin.file, hesin_diag.file, cov.file=cov, ICD10.file=ICD10, Date.end="01/04/2019")
# set the end of Date as the first test day, to exclude the morbidities caused by CoVID-19

# white British, severity vs co-morbidity
res.file <- "severity_2020-12-09.txt"
cormorbidity.file <- "comorbidity_1991-04-18_2019-04-01.RData"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="hosp")
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="severe.lev2")
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="severe.lev3")
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="mortality")

# white British, susceptibility vs co-morbidity
cormorbidity.file <- "comorbidity_1991-04-18_2019-04-01.RData"
res.file <- "/stornext/HPCScratch/home/wang.lo/CoVID-19/test/result_2021-01-18.txt"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="result")
res.file <- "/stornext/HPCScratch/home/wang.lo/CoVID-19/test/susceptibility.tested.txt"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="pos.neg")
res.file <- "/stornext/HPCScratch/home/wang.lo/CoVID-19/test/susceptibility.population.txt"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="pos.ppl")

# white British, mortality vs co-morbidity
cormorbidity.file <- "comorbidity_1991-04-18_2019-04-01.RData"
res.file <- "/stornext/HPCScratch/home/wang.lo/CoVID-19/test/mortality_2020-12-18.txt"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="mortality")

# output file: association test results for each co-morbidity