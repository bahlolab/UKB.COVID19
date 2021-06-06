#' Create phenotypes for COVID-19 "susceptibility"
#'
#' @param res.eng Latest covid result file/files for England.
#' @param res.wal Latest covid result file/files for Wales. Only available for downloads after April 2021.
#' @param res.sco Latest covid result file/files for Scotland. Only available for downloads after April 2021.
#' @param Date Date, ddmmyyyy, select the results until a certain date. By default, Date = NULL, the latest testing date. 
#' @param out.name Name of susceptibility file to be outputted. By default, out.name = NULL, “result_{Date}.txt”.
#' @keywords susceptibility, phenotype
#' @return Outputs susceptibility files: 1. positive vs negative; 2. positive vs population.
#' @export susceptibility.summary
#' @import data.table
#' @importFrom magrittr %>%
#' @import tidyverse

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
