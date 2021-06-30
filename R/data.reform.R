#' Reform variables
#'
#' @param res Merged data of phenotype from susceptibility.summary, severity.summary, mortality.summary or comorbidity.summary and covariates from covariate file.
#' @param type Data type: susceptibility, severity, mortality or comorbidity.
#' @keywords reform
#' @return Reformed data for association tests using logistic regression models.
#' @export data.reform

# reform data
data.reform <- function(res, type){
if(type == "cov"){
   res$ID <- as.character(res$ID)
  res$sex <- as.factor(res$sex)
  res$ethnic <- as.factor(res$ethnic)
  res$other.ppl <- as.factor(res$other.ppl)
  res$black <- as.factor(res$black)
  res$asian <- as.factor(res$asian)
  res$mixed <- as.factor(res$mixed)
  res$white <- as.factor(res$white)
#  res$array <- as.factor(res$array)
  res$blood_group <- as.factor(res$blood_group)
  res$O <- as.factor(res$O)
  res$AB <- as.factor(res$AB)
  res$A <- as.factor(res$A)
  res$B <- as.factor(res$B)
  res$inAgedCare <- as.factor(res$inAgedCare)
  res[is.na(res$ethnic),c("other.ppl","black","asian","mixed","white")] <- NA
  res[is.na(res$inAgedCare),"inAgedCare"] <- 0
}

  if(type == "susceptibility"){
    res$ppl.result <- as.factor(res$ppl.result)
    res$result <- as.factor(res$result)
  }

  if(type == "mortality") res$mortality <- as.factor(res$mortality)

  if(type == "severity") {
    res$mortality <- as.factor(res$mortality)
    res$hosp <- as.factor(res$hosp)
    res$severe.lev2 <- as.factor(res$severe.lev2)
    res$severe.lev3 <- as.factor(res$severe.lev3)
  }

  if(type == "comorbidity") {
    comorb.name <- colnames(res)[-(1:19)]
    for(j in 1:length(comorb.name)) res[,comorb.name[j]] <- as.factor(res[,comorb.name[j]])
  }

  return(res)
}
