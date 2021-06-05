#' Perform association tests between phenotype and covariates
#'
#' This function formats and outputs a covariate file, used for input for other functions.
#' @param data Data generated from COVID19.susceptibility, COVID19.severity or COVID19.mortality.
#' @param phe.name Phenotype name in the data.
#' @param cov.name Selected covariate names in the data. By default, cov.name=c("sex","age","bmi").
#' @param asso.output Name of association test result file to be outputted. By default, asso.output=NULL, it returns results but doesn't generate any files.
#' @keywords association test
#' @export log.cov
#' @return Outputs association test results with OR, 95% CI, and p-value.
#' @import questionr
#' @examples
#' log.cov(data=res$tested, phe.name="pos.neg", cov.name=c("sex","age","bmi"))

log.cov <- function(data, phe.name, cov.name = c("sex","age","bmi"), asso.output=NULL){
  y <- data[,c(phe.name,cov.name)]
  y <- na.omit(y)
  colnames(y)[1] <- "phe"
  m <- glm(phe ~ ., data=y, family="binomial")
  log.reg <- summary(m)
  OR <- odds.ratio(m)
  asso <- as.data.frame(cbind(log.reg$coefficients[,1],OR[,c(1:4)]))
  colnames(asso)[1] <- "Estimate"
  if(!(is.null(asso.output))) write.csv(asso,paste0(asso.output,".csv"),quote = F)
  return(asso)
}
