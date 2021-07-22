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
OR
```r
install.packages("UKB.COVID19")
library(UKB.COVID19)
```

## Risk Factor

This is a basic example which shows you how to creat a covariate file with risk factors using UKBB main tab data:

```r
library(UKB.COVID19)
covar <- risk.factor(ukb.data="ukb.tab", 
                         ABO.data="covid19_misc.txt",
                         hesin.file="hesin.txt",
                         res.eng="result_england.txt",
                         out.file="./results/covariate")
```

## Susceptibility

This is an example which shows you how to generate a file with COVID-19 susceptibility phenotypes:

```r
susceptibility <- makePhenotypes(ukb.data="ukb.tab",
                        res.eng="result_england.txt",
                        death.file="death.txt",
                        death.cause.file="death_cause.txt",
                        hesin.file="hesin.txt",
                        hesin_diag.file="hesin_diag.txt",
                        hesin_oper.file="hesin_oper.txt",
                        hesin_critical.file="hesin_critical.txt",
                        code.file="coding240.txt.gz",
                        pheno.type = "susceptibility",
                        out.name="./results/susceptibility")
```
code.file can be found in UKB.COVID19/inst/extdata/coding240.txt.gz.

## Mortality

This is an example which shows you how to generate a file with COVID-19 mortality phenotype:

```r
mortality <- makePhenotypes(ukb.data="ukb.tab",
                        res.eng="result_england.txt",
                        death.file="death.txt",
                        death.cause.file="death_cause.txt",
                        hesin.file="hesin.txt",
                        hesin_diag.file="hesin_diag.txt",
                        hesin_oper.file="hesin_oper.txt",
                        hesin_critical.file="hesin_critical.txt",
                        code.file="coding240.txt.gz",
                        pheno.type = "mortality",
                        out.name="./results/mortality")
```
code.file can be found in UKB.COVID19/inst/extdata/coding240.txt.gz.

## Severity

This is an example which shows you how to generate a file with COVID-19 severity phenotypes:

```r
severity <- makePhenotypes(ukb.data="ukb.tab",
                        res.eng="result_england.txt",
                        death.file="death.txt",
                        death.cause.file="death_cause.txt",
                        hesin.file="hesin.txt",
                        hesin_diag.file="hesin_diag.txt",
                        hesin_oper.file="hesin_oper.txt",
                        hesin_critical.file="hesin_critical.txt",
                        code.file="coding240.txt.gz",
                        pheno.type = "severity",
                        out.name="./results/severity")
```
code.file can be found in UKB.COVID19/inst/extdata/coding240.txt.gz.

## Co-morbidity Summary & Co-morbidity Association Tests

This is an example which shows you how to generate a file with all comorbidities in ICD-10 code and how to perform the association tests between comorbidities and COVID-19:

``` r
# generate comorbidity file
comorb <- comorbidity.summary(ukb.data="ukb.tab",
                              hesin.file="hesin.txt", 
                              hesin_diag.file="hesin_diag.txt", 
                              ICD10.file="ICD10.coding19.txt.gz",
                              primary = FALSE,
                              Date.start = "16/03/2020",
                              outfile="./results/comorbidity_2020-3-16.txt")

# association tests 
comorb.asso <- comorbidity.asso(pheno=susceptibility,
                                covariates=covar,
                                cormorbidity=comorb,
                                population="white",
                                cov.name=c("sex","age","bmi","SES","smoke","inAgedCare"),
                                phe.name="pos.neg",
                                ICD10.file="ICD10.coding19.txt.gz",
                                output = "cormorb_pos_neg_asso.csv")

```
ICD10.file can be found in UKB.COVID19/inst/extdata/ICD10.coding19.txt.gz.


