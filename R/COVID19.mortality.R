#' Combine COVID-19 mortality phenotype and covariates
#'
#' @param res.eng Latest covid result file/files for England.
#' @param res.wal Latest covid result file/files for Wales. Only available for downloads after April 2021.
#' @param res.sco Latest covid result file/files for Scotland. Only available for downloads after April 2021.
#' @param cov.file Covariate file generated using risk.factor function.
#' @param death.file Latest death register file.
#' @param death.cause.file Latest death cause file.
#' @param Date Date, ddmmyyyy, select the results until a certain date. By default, Date = NULL, the latest death register date. 
#' @param out.name Name of mortality file to be outputted. By default, out.name = NULL, “mortality.cov.txt”.
#' @keywords mortality, covariates, phenotype
#' @return Outputs a mortality file with phenotype and covariates.
#' @export COVID19.mortality
#' @import utils

COVID19.mortality <- function(res.eng, res.wal=NULL, res.sco=NULL, death.file, death.cause.file, cov.file, Date=NULL, out.name=NULL){
  cov <- read.table(cov.file,header = T,stringsAsFactors = F,sep = "\t")
  mortality <- mortality.summary(res.eng, res.wal, res.sco, death.file, death.cause.file, Date, out.name)
  # merge test result and covariates
  res.cov <- merge(mortality, cov, by.x = "ID", by.y="ID", all.x = T, sort = F)
  # reform variables
  res.mortality <- data.reform(res.cov, type = "mortality")
  if(is.null(out.name)) out.name <- "mortality"
  write.table(res.mortality,paste0(out.name,".cov.txt"),row.names = F, quote = F, sep = "\t")
  return(res.mortality)
}


