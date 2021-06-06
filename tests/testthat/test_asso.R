
res <- read.table("./res_example.txt",header = T, sep = "\t")
log_cov(data=res, phe.name="hosp", cov.name=c("sex","age","bmi"))
