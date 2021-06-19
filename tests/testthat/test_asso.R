
res <- read.table(covid_example("res_example.txt.gz"),header = T, sep = "\t")
log_cov(data=res, phe.name="hosp", cov.name=c("sex","age","bmi"))
