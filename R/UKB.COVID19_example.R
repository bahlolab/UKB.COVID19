### install R package
rm(list=ls())

# install required packages
# install.packages("questionr") # for association test OR
library(questionr) 
require(data.table)

### install R package option 1
# install.packages("devtools")
# devtools::install_github("bahlolab/UKB.COVID19")

### install R package option 2
# install.packages("remotes")
# remotes::install_github("bahlolab/UKB.COVID19",force = T)
library(UKB.COVID19)

### generate covariate file using risk.factor function
rm(list=ls())
setwd("~/hpc_home/CoVID-19/")
ukb.data <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/data/app36610/rawPheno/ukb42082.tab"
ABO.data <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20200814_covid19_misc.txt"
risk.factor(ukb.data, ABO.data)

### susceptibility
# set your work direroty
# setwd("/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/test/")

# UKB COVID-19 test result file location and name
setwd("~/hpc_home/CoVID-19/April/")
res.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210409_covid19_result.txt"
cov.file <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/covariate.txt"

# process UKB COVID-19 test result data for susceptibility analyses
# source("~/hpc_home/CoVID-19/susceptibility.R")
# source("~/hpc_home/CoVID-19/data.reform.R")
res <- COVID19.susceptibility(res.file, cov.file)
# output a list include two datasets for 
# definition 1. positive vs negative
# definition 2. positive vs population

# association test of susceptibility (positive vs negative) 
source("~/hpc_home/CoVID-19/asso.test.R")
table(res$tested$pos.neg)
log.cov(data=res$tested, phe.name="pos.neg", cov.name=c("sex","age","bmi"))
log.cov(data=res$tested, phe.name="pos.neg", cov.name=c("sex","age","bmi","O","AB","A"))
log.cov(data=res$tested, phe.name="pos.neg", cov.name=c("sex","age","bmi","black","asian","other.ppl","mixed"))
log.cov(data=res$tested, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES"))
log.cov(data=res$tested, phe.name="pos.neg", cov.name=c("sex","age","bmi","smoke"))
log.cov(data=res$tested, phe.name="pos.neg", cov.name=c("sex","age","bmi","inAgedCare"))
log.cov(data=res$tested, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","black","asian","other.ppl","O","inAgedCare"), asso.output = "pos.neg")

# test white British only 
tested <- res$tested
res.white <- tested[tested$white == 1 & !(is.na(tested$white)),]
table(res.white$pos.neg)
log.cov(data=res.white, phe.name="pos.neg", cov.name=c("sex","age","bmi"))
log.cov(data=res.white, phe.name="pos.neg", cov.name=c("sex","age","bmi","O","AB","A"))
log.cov(data=res.white, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES"))
log.cov(data=res.white, phe.name="pos.neg", cov.name=c("sex","age","bmi","smoke"))
log.cov(data=res.white, phe.name="pos.neg", cov.name=c("sex","age","bmi","inAgedCare"))
log.cov(data=res.white, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","O","AB","A","inAgedCare"))
log.cov(data=res.white, phe.name="pos.neg", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),asso.output = "white.pos.neg")

####################################################################################################################################
### mortality
rm(list=ls())
library(UKB.COVID19)
library(questionr) 
setwd("~/hpc_home/CoVID-19/April/")
res.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210409_covid19_result.txt"
death.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210408_death.txt"
death.cause.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210408_death_cause.txt"
cov.file <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/covariate.v0.txt"

# process test result data, death record data for mortality analyses
# source("~/hpc_home/CoVID-19/mortality.R")
# source("~/hpc_home/CoVID-19/data.reform.R")
mortality <- COVID19.mortality(res.file, death.file, death.cause.file, cov.file)

# association test
source("~/hpc_home/CoVID-19/asso.test.R")
table(mortality$mortality)
log.cov(data=mortality, phe.name="mortality", cov.name=c("sex","age","bmi"))
log.cov(data=mortality, phe.name="mortality", cov.name=c("sex","age","bmi","O","AB","A"))
log.cov(data=mortality, phe.name="mortality", cov.name=c("sex","age","bmi","black","asian","other.ppl","mixed"))
log.cov(data=mortality, phe.name="mortality", cov.name=c("sex","age","bmi","SES"))
log.cov(data=mortality, phe.name="mortality", cov.name=c("sex","age","bmi","smoke"))
log.cov(data=mortality, phe.name="mortality", cov.name=c("sex","age","bmi","inAgedCare"))

# test white British only 
mortality.white <- mortality[mortality$white == 1 & !(is.na(mortality$white)),]
table(mortality.white$mortality)
log.cov(data=mortality.white, phe.name="mortality", cov.name=c("sex","age","bmi"))
log.cov(data=mortality.white, phe.name="mortality", cov.name=c("sex","age","bmi","O","AB","A"))
log.cov(data=mortality.white, phe.name="mortality", cov.name=c("sex","age","bmi","SES"))
log.cov(data=mortality.white, phe.name="mortality", cov.name=c("sex","age","bmi","smoke"))
log.cov(data=mortality.white, phe.name="mortality", cov.name=c("sex","age","bmi","inAgedCare"))

log.cov(data=mortality.white, phe.name="mortality", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),  asso.output = "white.mortality1")

####################################################################################################################################
### severity
res.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210409_covid19_result.txt"
death.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210408_death.txt"
death.cause.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210408_death_cause.txt"
hesin.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210502_hesin.txt"
hesin_diag.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210502_hesin_diag.txt"
hesin_oper.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210502_hesin_oper.txt"
hesin_critical.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210222_hesin_critical.txt"
cov.file <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/covariate.v0.txt"
code.file <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/coding240.tsv"

# process test result data, death record data, hospitalization data for severity analyses
# source("~/hpc_home/CoVID-19/severity.R")
severity <- COVID19.severity(res.file, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, cov.file, code.file)
# four definitions of severity:
# 1. hospitalisation
# 2. ICU basic
# 3. ICU advanced
# 4. mortality

# association test of hospitalization
table(severity$hosp)
log.cov(data=severity, phe.name="hosp", cov.name=c("sex","age","bmi"))
log.cov(data=severity, phe.name="hosp", cov.name=c("sex","age","bmi","O","AB","A"))
log.cov(data=severity, phe.name="hosp", cov.name=c("sex","age","bmi","black","asian","other.ppl","mixed"))
log.cov(data=severity, phe.name="hosp", cov.name=c("sex","age","bmi","SES"))
log.cov(data=severity, phe.name="hosp", cov.name=c("sex","age","bmi","smoke"))
log.cov(data=severity, phe.name="hosp", cov.name=c("sex","age","bmi","inAgedCare"))

# association test of severity level 2
table(severity$severe.lev2)
log.cov(data=severity, phe.name="severe.lev2", cov.name=c("sex","age","bmi"))
log.cov(data=severity, phe.name="severe.lev2", cov.name=c("sex","age","bmi","O","AB","A"))
log.cov(data=severity, phe.name="severe.lev2", cov.name=c("sex","age","bmi","black","asian","other.ppl","mixed"))
log.cov(data=severity, phe.name="severe.lev2", cov.name=c("sex","age","bmi","SES"))
log.cov(data=severity, phe.name="severe.lev2", cov.name=c("sex","age","bmi","smoke"))
log.cov(data=severity, phe.name="severe.lev2", cov.name=c("sex","age","bmi","inAgedCare"))

# association test of severity level 3
table(severity$severe.lev3)
log.cov(data=severity, phe.name="severe.lev3", cov.name=c("sex","age","bmi"))
log.cov(data=severity, phe.name="severe.lev3", cov.name=c("sex","age","bmi","O","AB","A"))
log.cov(data=severity, phe.name="severe.lev3", cov.name=c("sex","age","bmi","black","asian","other.ppl","mixed"))
log.cov(data=severity, phe.name="severe.lev3", cov.name=c("sex","age","bmi","SES"))
log.cov(data=severity, phe.name="severe.lev3", cov.name=c("sex","age","bmi","smoke"))
log.cov(data=severity, phe.name="severe.lev3", cov.name=c("sex","age","bmi","inAgedCare"))

# test white British only
severity.white <- severity[severity$white == 1 & !(is.na(severity$white)),]
table(severity.white$hosp)
table(severity.white$severe.lev2)
table(severity.white$severe.lev3)

log.cov(data=severity.white, phe.name="hosp", cov.name=c("sex","age","bmi"))
log.cov(data=severity.white, phe.name="hosp", cov.name=c("sex","age","bmi","O","AB","A"))
log.cov(data=severity.white, phe.name="hosp", cov.name=c("sex","age","bmi","SES"))
log.cov(data=severity.white, phe.name="hosp", cov.name=c("sex","age","bmi","smoke"))
log.cov(data=severity.white, phe.name="hosp", cov.name=c("sex","age","bmi","inAgedCare"))
log.cov(data=severity.white, phe.name="hosp", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"), asso.output = "white.hosp")

log.cov(data=severity.white, phe.name="severe.lev2", cov.name=c("sex","age","bmi"))
log.cov(data=severity.white, phe.name="severe.lev2", cov.name=c("sex","age","bmi","O","AB","A"))
log.cov(data=severity.white, phe.name="severe.lev2", cov.name=c("sex","age","bmi","SES"))
log.cov(data=severity.white, phe.name="severe.lev2", cov.name=c("sex","age","bmi","smoke"))
log.cov(data=severity.white, phe.name="severe.lev2", cov.name=c("sex","age","bmi","inAgedCare"))
log.cov(data=severity.white, phe.name="severe.lev2", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"), asso.output = "white.sev.lev2")

log.cov(data=severity.white, phe.name="severe.lev3", cov.name=c("sex","age","bmi"))
log.cov(data=severity.white, phe.name="severe.lev3", cov.name=c("sex","age","bmi","O","AB","A"))
log.cov(data=severity.white, phe.name="severe.lev3", cov.name=c("sex","age","bmi","SES"))
log.cov(data=severity.white, phe.name="severe.lev3", cov.name=c("sex","age","bmi","smoke"))
log.cov(data=severity.white, phe.name="severe.lev3", cov.name=c("sex","age","bmi","inAgedCare"))
log.cov(data=severity.white, phe.name="severe.lev3", cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"), asso.output = "white.sev.lev3")

####################################################################################################################################
### co-morbidity
hesin.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210502_hesin.txt"
hesin_diag.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210502_hesin_diag.txt"
cov <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/covariate.v0.txt"
ICD10.file <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/ICD10.coding19.tsv"
# source("~/hpc_home/CoVID-19/comorbidity.R")
comorbidity.summary(hesin.file, hesin_diag.file, cov.file=cov, ICD10.file=ICD10.file, primary = F, Date.end="16/03/2020")
comorbidity.summary(hesin.file, hesin_diag.file, cov.file=cov, ICD10.file=ICD10.file, primary = F, Date.start="16/03/2020")
# generate two files: the hospital records before the pandemic and after the pandemic

# white British, severity vs co-morbidity
res.file <- "severity_2021-02-05.txt"
cormorbidity.file <- "comorbidity_1991-04-18_2020-03-16.RData"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="severe.lev2", output = "lev2_bf.csv")

cormorbidity.file <- "comorbidity_2020-03-16_2021-02-05.RData"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="severe.lev2", output = "lev2_af.csv")

cormorbidity.file <- "comorbidity_1991-04-18_2020-03-16.primary.RData"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="severe.lev2", output = "lev2_bf.primary.csv")

cormorbidity.file <- "comorbidity_2020-03-16_2021-02-05.primary.RData"
comorbidity.asso(res.file, cormorbidity.file, population="white", covars=c("sex","age","bmi","SES","smoke","inAgedCare"), phe.name="severe.lev2", output = "lev2_af.primary.csv")
