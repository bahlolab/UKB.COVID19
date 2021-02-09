### summarize result file
susceptibility.summary <- function(file.name, Date=NULL, out.name=NULL){
  result <- read.table(file.name, header = T, sep = "\t")
  result$specdate <- as.Date(result$specdate, format= "%d/%m/%Y")
  if(is.null(Date)) Date <- max(result$specdate)
  result.date <- result[result$specdate <= Date,]
  sampleID <- unique(result.date$eid)
  N <- length(sampleID)
  print(paste0(N," participants got tested until ", Date, "."))
  res <- as.data.frame(matrix(NA, nrow=N, ncol=2))
  colnames(res) <- c("ID","result")
  for(i in 1:N){
    sample <- result[result$eid == sampleID[i],]
    res[i,] <- c(sampleID[i],as.numeric(any(sample$result == 1)))
  }
  agedcare.id <- unique(result[result$reqorg == 9,"eid"]) 
  res$ch <- 0; res[res$ID %in% agedcare.id,"ch"] <- 1
  print(paste0(sum(res$result)," participants got positive test results."))
  if(is.null(out.name)) out.name <- paste0("result_",Date,".txt")
  write.table(res, out.name, row.names = F, quote = F, sep = "\t")
  return(res)
}

# add covariates
COVID19.susceptibility <- function(res.file, cov.file= "./data/covariate.v0.txt", Date=NULL, out.name=NULL){
  # covariates
  cov <- read.table(cov.file,header = T,stringsAsFactors = F,sep = "\t")
  # test results
  res <- susceptibility.summary(res.file, Date, out.name)
  # merge test result and covariates
  res.cov <- merge(res,cov,by.x = "ID",by.y="ID",all = T,sort = F)
  # add updated aged care information
  res.cov[res.cov$ch==1 & !(is.na(res.cov$ch)),"inAgedCare"] <- 1
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

