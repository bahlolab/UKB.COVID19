require(data.table)
### comorbidity
comorbidity.summary <- function(hesin.file, hesin_diag.file, cov.file="./data/covariate.v0.txt", primary=FALSE, ICD10.file="./data/ICD10.coding19.tsv", Date.start=NULL, Date.end=NULL){
  cov <- read.table(cov.file,header = T,stringsAsFactors = F,sep = "\t")
  hesin_diag <- read.table(hesin_diag.file,header = T, sep = "\t",stringsAsFactors = F)
  hesin <- read.table(hesin.file,header = T, sep = "\t",stringsAsFactors = F)
  # select hesin data in a certain period by given start and end dates
  hesin$epistart <- as.Date(hesin$epistart, format="%d/%m/%Y")
  if(is.null(Date.start)) {
    Date.start <- min(hesin$epistart,na.rm = T)
  }else{
    Date.start <- as.Date(Date.start, format="%d/%m/%Y")
  }
  if(is.null(Date.end)) {
    Date.end <- max(hesin$epistart,na.rm = T)
  }else{
    Date.end <- as.Date(Date.end, format="%d/%m/%Y")
  }
  
  hesin.select <-subset(hesin, epistart >= Date.start & epistart <= Date.end)
  hesin.select$eid.index <- paste0(hesin.select$eid,"_",hesin.select$ins_index)
  hesin_diag$eid.index <- paste0(hesin_diag$eid,"_",hesin_diag$ins_index)
  hesin.select.diag <- hesin_diag[hesin_diag$eid.index %in% hesin.select$eid.index,]
  hesin.select.diag.l1 <- hesin.select.diag[hesin.select.diag$level==1,]
  
  code<-as.data.frame(fread(ICD10.file))
  for(i in 1:nrow(code)){
    name1 <- strsplit(code[i,1]," ")[[1]][2]
    name2 <- strsplit(name1,"[-]")[[1]]
    class <- substr(name2[1],1,1)
    if(class %in% c("O","P","R","S","T","U","V","W","X","Y","Z")) next
    sub.class <- seq(sub(".","",name2[1]),sub(".","",name2[2]))
    if(any(sub.class<10)) sub.class[sub.class<10] <- paste0("0",sub.class[sub.class<10])
    class.names <- paste0(class,sub.class)
    cov[,name1] <- 0
    if(primary){
      for(j in 1:length(class.names)) cov[cov$ID %in% unique(hesin.select.diag.l1[which(startsWith(hesin.select.diag.l1$diag_icd10,class.names[j])),"eid"]),name1] <- 1
    }else{
      for(j in 1:length(class.names)) cov[cov$ID %in% unique(hesin.select.diag[which(startsWith(hesin.select.diag$diag_icd10,class.names[j])),"eid"]),name1] <- 1
    }  
  }
 
  cov <- data.reform(cov, type = "comorbidity")
  
  if(primary) {
    outfile <- paste0("comorbidity_",Date.start,"_",Date.end,".primary.RData")
  }else{
    outfile <- paste0("comorbidity_",Date.start,"_",Date.end,".RData")
  }
  
  save(cov,file = outfile)
}

comorbidity.asso <- function(res.file, cormorbidity.file, population = "all", covars=c("sex","age","bmi"), phe.name, output=NULL){
  res <- read.table(res.file,header = T, stringsAsFactors = F, sep = "\t")
  if(any(c(population,covars) %in% (colnames(res)))) res <- res[,!(colnames(res) %in% c(population,covars))]
  load(file = cormorbidity.file)
  comorb.name <- colnames(cov)[-(1:19)]
  res.cov <- merge(res, cov, by.x = "ID", by.y="ID", all.x = T, sort = F)
  if(population == "all") res.cov <- res.cov
  if(population == "white") res.cov <- res.cov[res.cov$white == 1 & !(is.na(res.cov$white)),]
  if(population == "black") res.cov <- res.cov[res.cov$black == 1 & !(is.na(res.cov$black)),]
  if(population == "asian") res.cov <- res.cov[res.cov$asian == 1 & !(is.na(res.cov$asian)),]
  if(population == "mixed") res.cov <- res.cov[res.cov$mixed == 1 & !(is.na(res.cov$mixed)),]
  if(population == "other") res.cov <- res.cov[res.cov$other.ppl == 1 & !(is.na(res.cov$other.ppl)),]
  n.covars <- length(covars)
  n.comorb <- length(comorb.name)
  comorb.asso <- as.data.frame(matrix(NA, ncol=5, nrow = n.comorb))
  colnames(comorb.asso) <- c("Estimate","OR","2.5%","97.5%","p")
  rownames(comorb.asso) <- comorb.name
  for(j in 1:n.comorb){
    cov.name <- c(covars, comorb.name[j])
    if(any(table(res.cov[,comorb.name[j]])==0)){
      comorb.asso[j,] <- NA
    }else{
      comorb.asso[j,] <- log.cov(data=res.cov, phe.name, cov.name)[n.covars+2,]
    }
  }
  if(is.null(output)) output <- paste0(population,"_",phe.name, "_comorbidity_asso.csv")
  write.csv(comorb.asso, output)
}


