#' Create a phenotype for COVID-19 mortality
#'
#' @param res.eng Latest covid result file/files for England.
#' @param res.wal Latest covid result file/files for Wales. Only available for downloads after April 2021.
#' @param res.sco Latest covid result file/files for Scotland. Only available for downloads after April 2021.
#' @param death.file Latest death register file.
#' @param death.cause.file Latest death cause file.
#' @param Date Date, ddmmyyyy, select the results until a certain date. By default, Date = NULL, the latest death register date. 
#' @param out.name Name of mortality file to be outputted. By default, out.name = NULL, “mortality_{Date}.txt”.
#' @keywords mortality, phenotype
#' @return Outputs a mortality summary file with mortality phenotype.
#' @export mortality.summary
#' @import data.table
#' @importFrom magrittr %>%
#' @import tidyverse

### summarize result & death file
mortality.summary <- function(res.eng, res.wal=NULL, res.sco=NULL, death.file, death.cause.file, Date=NULL, out.name=NULL){

  inFiles <- c(get0("res.eng"), get0("res.wal"), get0("res.sco"))
  
  
  result <- lapply(inFiles, fread, select=c("eid", "specdate", "result")) %>%
    rbindlist %>%
    as.data.frame
  
  result$specdate <- as.Date(result$specdate, format= "%d/%m/%Y")
  death <- read.table(death.file, header = T, sep = "\t")
  death_cause <- read.table(death.cause.file, header = T, sep = "\t")
  death$date_of_death <- as.Date(death$date_of_death, format= "%d/%m/%Y")
  if(is.null(Date)) Date <- min(max(death$date_of_death), max(result$specdate))
  result.date <- result[result$specdate <= Date,]
  death.date <- death[death$date_of_death <= Date,]
  sampleID <- unique(result.date$eid)
  N <- length(sampleID)
  print(paste0(N," participants got tested until ",Date, "."))
  
  pos <- result.date$eid[result.date$result == 1] %>% unique
  res <- data.frame(ID = unique(result.date$eid))
  res$result <- ifelse(res$ID %in% pos, 1, 0)
  
  print(paste0(sum(res$result)," participants got positive test results."))
  
  death.id <- unique(death.date[,"eid"]) 
  death.U071.id <- unique(death_cause[death_cause$cause_icd10 == "U071" & death_cause$eid %in% death.id,"eid"])
  miss.id <- death.U071.id[!(death.U071.id %in% res$ID)]
  print(paste0(length(miss.id)," deaths with COVID-19 but didn't get tested. Added them into mortality data."))
  res.add <- as.data.frame(cbind(miss.id,1))
  colnames(res.add) <- colnames(res)
  res <- rbind(res,res.add)
  tested.death.id <- unique(res[res$ID %in% death.id,"ID"]) 
  tested.death.cause <- death_cause[death_cause$eid %in% tested.death.id,]
  covid.death.id <- tested.death.cause[tested.death.cause$cause_icd10 == "U071","eid"]
  primary.covid.death.id <- tested.death.cause[tested.death.cause$cause_icd10 == "U071" & tested.death.cause$level==1,"eid"]
  res$death.U071 <- 0; res[res$ID %in% covid.death.id,"death.U071"] <- 1
  res$mortality <- 0; res[res$ID %in% primary.covid.death.id,"mortality"] <- 1
  error <- res[res$death.U071==1 & res$result == 0,"ID"] 
  print(paste0(length(error)," deaths with COVID-19 but got negative test results. Modified their test results."))
  res[res$death.U071==1,"result"] <-1
  print(paste0("There are ",sum(res$result==1 & res$death.U071==1)," deaths with COVID-19. ",length(primary.covid.death.id)," of them, the primary death cause is COVID-19."))
  mortality <- res[res$result == 1, ]
  print(paste0("There are ",nrow(mortality), " individuals are included in mortality analysis."))
  if(is.null(out.name)) out.name <- "mortality"
  write.table(mortality, paste0(out.name,"_",Date,".txt"), row.names = F, quote = F, sep = "\t")
  return(mortality)
}

