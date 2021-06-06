#' Generate comorbiity association result file
#'
#' Association tests between each co-morbidity and given phenotype (susceptibility, mortality or severity) with the adjustment of covariates. 
#' @param res.file Result summary file generated from COVID19.susceptibility, COVID19.severity or COVID19.mortality.
#' @param cormorbidity.file Comorbidity summary file generated from comorbidity.summary.
#' @param population Choose self-report population/ethnic background group from "all", white", "black", "asian", "mixed", or "other". By default, population="all", include all ethnic groups.
#' @param covars Selected covariates names. By default, covars=c("sex","age","bmi"), covariates are sex age and BMI.
#' @param phe.name Phenotype name.
#' @param output Name of comorbidity association test result file to be outputted. By default, output=NULL, it is {population}_{phenotype name}_comorbidity_asso.csv.
#' @keywords comorbidity, association test.
#' @return Outputs a comorbidity association test result file with OR, 95% CI and p-value.
#' @export comorbidity.asso
#' @import questionr

comorbidity.asso <- function(res.file, cormorbidity.file, population = "all", covars=c("sex","age","bmi"), phe.name, output=NULL){
  res <- read.table(res.file,header = T, stringsAsFactors = F, sep = "\t")
  if(any(c(population,covars) %in% (colnames(res)))) res <- res[,!(colnames(res) %in% c(population,covars))]
  load(file = cormorbidity.file)
  comorb.name <- colnames(cov)[-(1:19)]
  res.cov <- merge(res, cov, by.x = "ID", by.y="ID", all.x = T, sort = F)
  if(population == "all") res.cov <- res.cov
  if(population == "white") res.cov <- res.cov[res.cov$white == 1 & !(is.na(res.cov$white)),]
  if(population == "black") res.cov <- res.cov[res.cov$black == 1 & !(is.na(res.cov$black)),]
  if(population == "asian") res.cov <- res.cov[res.cov$asian == 1 & !(is.na(res.cov$asian)),]
  if(population == "mixed") res.cov <- res.cov[res.cov$mixed == 1 & !(is.na(res.cov$mixed)),]
  if(population == "other") res.cov <- res.cov[res.cov$other.ppl == 1 & !(is.na(res.cov$other.ppl)),]
  n.covars <- length(covars)
  n.comorb <- length(comorb.name)
  comorb.asso <- as.data.frame(matrix(NA, ncol=5, nrow = n.comorb))
  colnames(comorb.asso) <- c("Estimate","OR","2.5%","97.5%","p")
  rownames(comorb.asso) <- comorb.name
  for(j in 1:n.comorb){
    cov.name <- c(covars, comorb.name[j])
    if(any(table(res.cov[,comorb.name[j]])==0) | length(table(res.cov[,comorb.name[j]]))==1){
      comorb.asso[j,] <- NA
    }else{
      comorb.asso[j,] <- log_cov(data=res.cov, phe.name, cov.name)[n.covars+2,]
    }
  }
  if(is.null(output)) output <- paste0(population,"_",phe.name, "_comorbidity_asso.csv")
  write.csv(comorb.asso, output)
}


