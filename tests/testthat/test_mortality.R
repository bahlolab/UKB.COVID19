
mortality <- COVID19.mortality(res.eng=covid_example("sim_result_england.txt.gz"), 
                               death.file=covid_example("sim_death.txt.gz"), 
                               death.cause.file=covid_example("sim_death_cause.txt.gz"), 
                               cov.file=covid_example("covariate.txt"),
                               out.name=paste0(covid_example("results"),"/mortality"))
