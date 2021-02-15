# UKB.COVID19
An R package to assist with the UK Biobank COVID-19 data processing and risk factor association tests.

See UKB.COVID19_example.R script for usage example.

Currently, `UKB.COVID19` is available as a beta release however is still under active development and subject to change. Please contact [Longfei Wang] (wang.lo@wehi.edu.au) if you would like to test the development version or to report any issues, feedback or feature requests.

## Installation

```r
remotes::install_github("bahlolab/UKB.COVID19")
```
OR
```r
devtools::install_github("bahlolab/UKB.COVID19")
```

## Examples

### Susceptibility


Specify UKB COVID-19 test result file location and name.
The covariate data is built in the R package. Please unzip it and specify the location.
```r
res.file <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20210120_covid19_result.txt"
cov.file <- "/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/data/covariate.v0.txt"
```

Process UKB COVID-19 test result data for susceptibility analyses
```r
res <- COVID19.susceptibility(res.file, cov.file)
```
Output: a list include two datasets for susceptibility
- definition 1. positive vs negative
- definition 2. positive vs population

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

Association test for white British only 
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
