#' Create phenotypes for COVID-19 "susceptibility"
#'
#' @param res.eng Latest covid result file/files for England.
#' @param res.wal Latest covid result file/files for Wales. Only available for downloads after April 2021.
#' @param res.sco Latest covid result file/files for Scotland. Only available for downloads after April 2021.
#' @param cov.file Covariate file generated using risk.factor function.
#' @param Date Date, ddmmyyyy, select the results until a certain date. By default, Date = NULL, the latest testing date. 
#' @param out.name Name of susceptibility file to be outputted.
#' @keywords susceptibility, phenotype
#' @return Outputs susceptibility files: 1. positive vs negative; 2. positive vs population.
#' @export COVID19.susceptibility
#' @import data.table
#' @importFrom magrittr %>%
#' @import tidyverse
#' @import questionr
#' @examples
#' res <- COVID19.susceptibility(res.eng, res.wal, res.sco, cov.file)

### summarize result file
susceptibility.summary <- function(res.eng, res.wal=NULL, res.sco=NULL, Date=NULL, out.name=NULL){
  
  
  inFiles <- c(get0("res.eng"), get0("res.wal"), get0("res.sco"))
  
  
  result <- lapply(inFiles, fread, select=c("eid", "specdate", "result")) %>%
    rbindlist %>%
    as.data.frame
  
  result$specdate <- as.Date(result$specdate, format= "%d/%m/%Y")
  if(is.null(Date)) Date <- max(result$specdate)
  result.date <- result[result$specdate <= Date,]
  
  sampleID <- unique(result.date$eid)
  N <- length(sampleID)
  print(paste0(N," participants got tested until ", Date, "."))
  
  pos <- result.date$eid[result.date$result == 1] %>% unique
  res <- data.frame(ID = unique(result.date$eid))
  res$result <- ifelse(res$ID %in% pos, 1, 0)
  
  print(paste0(sum(res$result)," participants got positive test results."))
  if(is.null(out.name)) out.name <- paste0("result_",Date,".txt")
  write.table(res, out.name, row.names = F, quote = F, sep = "\t")
  return(res)
}

# add covariates
COVID19.susceptibility <- function(res.eng, res.wal, res.sco, cov.file, Date=NULL, out.name=NULL){
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
