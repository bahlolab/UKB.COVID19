### summarize result & death file
mortality.summary <- function(res.file, death.file, death.cause.file, Date=NULL, out.name=NULL){
  result <- read.table(res.file, header = T, sep = "\t")
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
  res <- as.data.frame(matrix(NA, nrow=N, ncol=2))
  colnames(res) <- c("ID","result")
  for(i in 1:N){
    sample <- result.date[result.date$eid == sampleID[i],]
    res[i,] <- c(sampleID[i], as.numeric(any(sample$result == 1)))
  }
  agedcare.id <- unique(result[result$reqorg == 9,"eid"]) 
  res$ch <- 0; res[res$ID %in% agedcare.id,"ch"] <- 1
  print(paste0(sum(res$result)," participants got positive test results."))
  death.id <- unique(death.date[,"eid"]) 
  death.U071.id <- unique(death_cause[death_cause$cause_icd10 == "U071" & death_cause$eid %in% death.id,"eid"])
  miss.id <- death.U071.id[!(death.U071.id %in% res$ID)]
  print(paste0(length(miss.id)," deaths with COVID-19 but didn't get tested. Added them into mortality data."))
  res.add <- as.data.frame(cbind(miss.id,1,0))
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
  if(is.null(out.name)) out.name <- "mortality"
  write.table(mortality, paste0(out.name,"_",Date,".txt"), row.names = F, quote = F, sep = "\t")
  return(mortality)
}

COVID19.mortality <- function(res.file, death.file, death.cause.file, cov.file= "./data/covariate.v0.txt", Date=NULL, out.name=NULL){
  cov <- read.table(cov.file,header = T,stringsAsFactors = F,sep = "\t")
  mortality <- mortality.summary(res.file, death.file, death.cause.file, Date, out.name)
  # merge test result and covariates
  res.cov <- merge(mortality, cov, by.x = "ID", by.y="ID", all.x = T, sort = F)
  # add updated aged care information
  res.cov[res.cov$ch==1 & !(is.na(res.cov$ch)),"inAgedCare"] <- 1
  # reform variables
  res.mortality <- data.reform(res.cov, type = "mortality")
  write.table(res.mortality,"mortality.cov.txt",row.names = F, quote = F, sep = "\t")
  return(res.mortality)
}


