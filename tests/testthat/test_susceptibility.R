
res <- COVID19.susceptibility(res.eng=covid_example("sim_result_england.txt.gz"), 
                              cov.file=covid_example("covariate.txt"),
                              out.name=paste0(covid_example("results"),"/susceptibility"))
