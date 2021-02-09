require(data.table)
### summarize result file
severity.summary <- function(res.file, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, code.file="./data/coding240.tsv", Date=NULL, out.name=NULL){
  result <- read.table(res.file, header = T, sep = "\t")
  result$specdate <- as.Date(result$specdate, format= "%d/%m/%Y")
  death <- read.table(death.file,header = T, sep = "\t")
  death_cause <- read.table(death.cause.file,header = T, sep = "\t")
  death$date_of_death <- as.Date(death$date_of_death, format= "%d/%m/%Y")
  hesin <- read.table(hesin.file,header = T, sep = "\t",stringsAsFactors = F)
  hesin$epiend <- as.Date(hesin$epiend, format = "%d/%m/%Y")
  hesin_diag <- read.table(hesin_diag.file,header = T, sep = "\t",stringsAsFactors = F)
  hesin_oper <- read.table(hesin_oper.file,header = T, sep = "\t",stringsAsFactors = F)
  hesin_critical <- read.table(hesin_critical.file,header = T, sep = "\t",stringsAsFactors = F)
  
  if(is.null(Date)) Date <- min(max(death$date_of_death), max(result$specdate), max(hesin$epiend,na.rm=T))
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
  print(paste0(sum(res$result)," participants got positive test results until ",Date, "."))
  death.id <- unique(death.date[,"eid"]) 
  death.U071.id <- unique(death_cause[death_cause$cause_icd10 == "U071" & death_cause$eid %in% death.id,"eid"])
  miss.id <- death.U071.id[!(death.U071.id %in% res$ID)]
  print(paste0(length(miss.id)," deaths with COVID-19 but didn't get tested. Added them into severity data."))
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
  print(paste0("There are ",sum(res$result==1 & res$death.U071==1)," deaths with COVID-19. ",length(primary.covid.death.id)," of them primary death cause is COVID-19."))

  hesin_u071 <- hesin_diag[hesin_diag$diag_icd10 == "U071",]  
  hesin_u071.id <- unique(hesin_u071$eid) #832
  print(paste0(length(hesin_u071.id)," patients admitted to hospital were diagnosed as COVID-19 until ",Date, "."))
  
  hesin_u071.1 <- hesin_diag[hesin_diag$diag_icd10 == "U071" & hesin_diag$level == 1,] 
  hesin_u071.1.id <-unique(hesin_u071.1$eid) #703
  print(paste0(length(hesin_u071.1.id)," patients' primary diagnosis is COVID-19."))
  
  miss.id <- hesin_u071.id[!(hesin_u071.id %in% res$ID)] #27
  print(paste0(length(miss.id)," hospitalizations with COVID-19 diagnosis were not in the test result file. Added them into severity data."))
  res.add <- as.data.frame(cbind(miss.id,1,0,0,0))
  colnames(res.add) <- colnames(res)
  res <- rbind(res.add,res)
  
  res$hesin.U071 <- 0; res[res$ID %in% hesin_u071.id,"hesin.U071"] <- 1 
  res$hesin.U071.1 <- 0; res[res$ID %in% hesin_u071.1.id,"hesin.U071.1"] <- 1 
  error <- res[res$hesin.U071==1 & res$result == 0,"ID"] 
  print(paste0(length(error)," patients in hospitalization with COVID-19 diagnosis but show negative in the result file. Modified their test results."))
  res[res$hesin.U071==1,"result"] <-1

  # operation of covid-19 patients got
  oper4.code <- as.data.frame(fread(code.file))
  hesin.oper.u071 <- merge(hesin_u071,hesin_oper,by.x = c("eid","ins_index","arr_index"),by.y = c("eid","ins_index","arr_index"))
  hesin.oper.u071.1 <- hesin.oper.u071[hesin.oper.u071$level.x==1,]
  hesin.oper.u071.1.id <- unique(hesin.oper.u071.1$eid)
  n.heisin.oper <- length(hesin.oper.u071.1.id)
  oper4.u071 <- as.data.frame(cbind(hesin.oper.u071.1.id,NA))
  for(i in 1:n.heisin.oper){
    sampID <- hesin.oper.u071.1.id[i]
    oper.name <- unique(hesin.oper.u071.1[hesin.oper.u071.1$eid == sampID,"oper4"])
    if(length(oper.name)==1) {
      oper4.u071[i,2] <- oper.name
    }else{
      if("X998" %in% oper.name) {
        oper4.u071[i,2] <- paste(oper.name[!(oper.name == "X998")],collapse = ",")
      }else{
        oper4.u071[i,2] <- paste(oper.name,collapse = ",")
      }
    }
  }
  colnames(oper4.u071) <- c("eid","hesin.oper4")
  res <- merge(res,oper4.u071,by.x = "ID",by.y = "eid",all.x=T)

  ### critical data
  hesin.c.u071 <- merge(hesin_u071,hesin_critical,by.x = c("eid","ins_index","arr_index"),by.y = c("eid","ins_index","arr_index"))
  hesin.c.u071$L2 <- hesin.c.u071$L3 <- 0
  hesin.c.u071[hesin.c.u071$cclev2days>0 & !(is.na(hesin.c.u071$cclev2days)),"L2"] <- 1
  hesin.c.u071[hesin.c.u071$cclev3days>0 & !(is.na(hesin.c.u071$cclev3days)),"L3"] <- 1
  hesin.c.u071[hesin.c.u071$L2==0 & hesin.c.u071$L3==0,]
  hesin.res <- hesin.c.u071[,c("eid","L2","L3")]
  l2.id <- unique(hesin.res[hesin.res$L2==1,"eid"]) #92
  l3.id <- unique(hesin.res[hesin.res$L3==1,"eid"]) #85
  res$critical.care <- NA
  res[res$result==1,"critical.care"] <-0
  res[res$hesin.U071.1 ==1,"critical.care"] <-1
  res[res$ID %in% l2.id,"critical.care"] <-2
  res[res$ID %in% l3.id,"critical.care"] <-3
  res[res$U071.1==1,"critical.care"] <-4
  check <- res[res$critical.care==1 & !(is.na(res$critical.care)) & res$hesin.oper4 != "X998",]
  # table(check[check$critical.care==1,"hesin.oper4"])
  lev2.add <- lev3.add <- c()
  for(ii in 1:nrow(check)){
    oper1 <- strsplit(check[ii,"hesin.oper4"],",")[[1]]
    if("E423" %in% oper1 | "E851" %in% oper1) lev3.add <- c(lev3.add,check[ii,"ID"])
    if("E852" %in% oper1 | "E856" %in% oper1) lev2.add <- c(lev2.add,check[ii,"ID"])
  }
  res[res$ID %in% lev2.add,"critical.care"] <- 2
  res[res$ID %in% lev3.add,"critical.care"] <- 3
  
  ### severe
  res$hosp <- res$severe.lev2 <- res$severe.lev3 <- NA
  res[res$result ==1,"hosp"] <- res[res$result ==1,"severe.lev2"] <- res[res$result ==1,"severe.lev3"] <-0
  res[res$critical.care >0 & !(is.na(res$critical.care)),"hosp"] <-1 #833/854
  res[res$critical.care >1 & !(is.na(res$critical.care)),"severe.lev2"] <-1 #439/1248
  res[res$critical.care >2 & !(is.na(res$critical.care)),"severe.lev3"] <-1 #397/1290
  severity <- res[res$result == 1, ]
  
  if(is.null(out.name)) out.name <- "severity"
  write.table(severity, paste0(out.name,"_",Date,".txt"), row.names = F, quote = F, sep = "\t")
  return(severity)
}

COVID19.severity <- function(res.file, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, cov.file= "./data/covariate.v0.txt", code.file= "./data/coding240.tsv", Date=NULL, out.name=NULL){
  cov <- read.table(cov.file,header = T,stringsAsFactors = F,sep = "\t")
  res <- severity.summary(res.file, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, code.file, Date, out.name)
  # merge test result and covariates
  res.cov <- merge(res,cov,by.x = "ID",by.y="ID",all.x = T,sort = F)
  # add updated aged care information
  res.cov[res.cov$ch==1 & !(is.na(res.cov$ch)),"inAgedCare"] <- 1
  # reform variables
  res.severity <- data.reform(res.cov, type = "severity")
  if(is.null(out.name)) out.name <- "severity"
  write.table(res.severity,paste0(out.name,".cov.txt"),row.names = F, quote = F, sep = "\t")
  return(res.severity)
}


