#' Perform association tests between phenotype and covariates
#'
#' @param pheno phenotype dataframe - output from makePheno function
#' @param covariates covariate dataframe - output from risk.factor function.
#' @param phe.name Phenotype name in the data.
#' @param cov.name Selected covariate names in the data. By default, cov.name=c("sex","age","bmi"), covariates include sex, age and BMI.
#' @param asso.output Name of association test result file to be outputted. By default, asso.output=NULL, it returns results but doesn't generate any files.
#' @keywords association test
#' @export log_cov
#' @return Outputs association test results with OR, 95% CI, and p-value.
#' @import questionr
#' @import stats
#' @examples
#' res <- read.table(covid_example("res_example.txt.gz"),header = TRUE, sep = "\t")
#' log_cov(data=res, phe.name="hosp", cov.name=c("sex","age","bmi"))
#'


log_cov <- function(pheno, covariates, phe.name, cov.name = c("sex","age","bmi"), asso.output=NULL){
  data <- inner_join(pheno, covariates, on="ID")
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
