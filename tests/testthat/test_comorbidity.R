comorbidity.summary(hesin.file=covid_example("sim_hesin.txt.gz"), 
                    hesin_diag.file=covid_example("sim_hesin_diag.txt.gz"), 
                    cov.file=covid_example("covariate.txt"), 
                    ICD10.file=covid_example("ICD10.coding19.txt.gz"),
                    primary = FALSE,
                    outfile=paste0(covid_example("results"),"/comorbidity.RData"))
