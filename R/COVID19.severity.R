#' Combine COVID-19 severity phenotypes and covariates
#'
#' @param res.eng Latest covid result file/files for England.
#' @param res.wal Latest covid result file/files for Wales. Only available for downloads after April 2021.
#' @param res.sco Latest covid result file/files for Scotland. Only available for downloads after April 2021.
#' @param cov.file Covariate file generated using risk.factor function.
#' @param death.file Latest death register file.
#' @param death.cause.file Latest death cause file.
#' @param hesin.file Latest hospital inpatient master file.
#' @param hesin_diag.file Latest hospital inpatient diagnosis file.
#' @param hesin_oper.file Latest hospital inpatient operation file.
#' @param hesin_critical.file Latest hospital inpatient critical care file.
#' @param code.file The operation code file, which is included in the package, and also can be download from https://github.com/bahlolab/UKB.COVID19/blob/main/data/coding240.tsv.
#' @param Date Date, ddmmyyyy, select the results until a certain date. By default, Date = NULL, the latest hospitalization date. 
#' @param out.name Name of severity files to be outputted. By default, out.name = NULL, “severity.cov.txt”.
#' @keywords severity, hospitalization, critical care, phenotype, covariates
#' @return Outputs a severity file with phenotypes for hospitalization, critical care and advanced critical care with covariates.
#' @export COVID19.severity

COVID19.severity <- function(res.eng, res.wal=NULL, res.sco=NULL, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, cov.file= "./data/covariate.v0.txt", code.file= "./data/coding240.tsv", Date=NULL, out.name=NULL){
  cov <- read.table(cov.file,header = T,stringsAsFactors = F,sep = "\t")
  res <- severity.summary(res.eng, res.wal, res.sco, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, code.file, Date, out.name)
  # merge test result and covariates
  res.cov <- merge(res,cov,by.x = "ID",by.y="ID",all.x = T,sort = F)
  # reform variables
  res.severity <- data.reform(res.cov, type = "severity")
  if(is.null(out.name)) out.name <- "severity"
  write.table(res.severity,paste0(out.name,".cov.txt"),row.names = F, quote = F, sep = "\t")
  return(res.severity)
}


