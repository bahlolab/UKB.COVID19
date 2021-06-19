#' Combine COVID-19 "susceptibility" phenotype and covariates
#'
#' @param res.eng Latest covid result file/files for England.
#' @param res.wal Latest covid result file/files for Wales. Only available for downloads after April 2021.
#' @param res.sco Latest covid result file/files for Scotland. Only available for downloads after April 2021.
#' @param cov.file Covariate file generated using risk.factor function.
#' @param Date Date, ddmmyyyy, select the results until a certain date. By default, Date = NULL, the latest testing date. 
#' @param out.name Name of susceptibility file to be outputted. By default, out.name = NULL, “susceptibility.tested.txt” and “susceptibility.population.txt”.
#' @keywords susceptibility, phenotype, covariates
#' @return Outputs susceptibility files with phenotypes and covariates.
#' @export COVID19.susceptibility
#' @examples
#' res <- COVID19.susceptibility(res.eng=covid_example("sim_result_england.txt.gz"), 
#' cov.file=covid_example("covariate.txt"),
#' out.name=paste0(covid_example("results"),"/susceptibility"))
#' 


# add covariates
COVID19.susceptibility <- function(res.eng, res.wal=NULL, res.sco=NULL, cov.file, Date=NULL, out.name=NULL){
  # covariates
  cov <- read.table(cov.file,header = T,stringsAsFactors = F,sep = "\t")
  # test results
  res <- susceptibility.summary(res.eng, res.wal, res.sco, Date, out.name)
  # merge test result and covariates
  res.cov <- merge(res,cov,by.x = "ID",by.y="ID",all = T,sort = F)
  # add phenotype: population v C19+
  res.cov$ppl.result <- 0; res.cov[res.cov$result == 1 & !(is.na(res.cov$result)),"ppl.result"] <- 1
  # reform variables
  res.reform <- data.reform(res.cov, type = "susceptibility")
  # rename phenotype: C19+ v C19-
  colnames(res.reform)[colnames(res.reform) == "result"] <- "pos.neg"
  # rename phenoytpe: C19+ v population
  colnames(res.reform)[colnames(res.reform) == "ppl.result"] <- "pos.ppl"
  # data 1: C19+ v population
  pos.ppl <- res.reform
  # data 2: C19+ v C19-
  pos.neg <- pos.ppl[!(is.na(pos.ppl$pos.neg)),]
  if(is.null(out.name)) out.name <- "susceptibility"
  write.table(pos.ppl, paste0(out.name, ".population.txt"), row.names = F, quote = F, sep = "\t")
  write.table(pos.neg, paste0(out.name, ".tested.txt"), row.names = F, quote = F, sep = "\t")
  suscept <- list(tested = pos.neg, population = pos.ppl)
  return(suscept)
}
