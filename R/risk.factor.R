# rm(list=ls())
# setwd("/stornext/Home/data/allstaff/w/wang.lo/hpc_home/CoVID-19/")
# ukb.data <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/data/app36610/rawPheno/ukb42082.tab"
# ABO.data <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/phenotypes/20200814_covid19_misc.txt"
# inAgedCare.data <- "/wehisan/bioinf/lab_bahlo/projects/misc/UKBiobank/COVID19/AnalysisVEJ/APOE/apoe_careHome_pheno.txt"
risk.factor <- function(ukb.data, ABO.data, inAgedCare.data, out.file = NULL){
  db <- read.table(ukb.data, header = T, sep = "\t")
  # sex: 1- male, 0- female
  phe <- db[,c("f.eid","f.31.0.0")]
  colnames(phe) <- c("ID","sex")
  
  # age: 2020 - year of birth
  phe$age <- 2020-db$f.34.0.0
  
  # Body mass index (BMI): the lastest
  bmi <- db[,startsWith(colnames(db),"f.21001.")]
  for(i in 2:ncol(bmi)){
    bmi[!(is.na(bmi[,i])),1] <- bmi[!(is.na(bmi[,i])),i]
  }
  phe$bmi <- bmi[,1]
  
  # Ethnic background
  ethnic <- db[,startsWith(colnames(db),"f.21000.")]
  for(i in 2:ncol(ethnic)){
    ethnic[!(is.na(ethnic[,i])),1] <- ethnic[!(is.na(ethnic[,i])),i]
  }
  if(any(ethnic[,1] <0 & !(is.na(ethnic[,1])))) ethnic[ethnic[,1] <0 & !(is.na(ethnic[,1])),1] <- NA
  phe$ethnic <- ethnic[,1]
  
  phe$white <-  phe$mixed <- phe$asian <- phe$black <- phe$other.ppl <- 0
  phe[phe$ethnic %in% c(1001:1003,1) & !(is.na(phe$ethnic)),"white"] <- 1
  phe[phe$ethnic %in% c(2001:2004,2) & !(is.na(phe$ethnic)),"mixed"] <- 1
  phe[phe$ethnic %in% c(3001:3004,3,5) & !(is.na(phe$ethnic)),"asian"] <- 1
  phe[phe$ethnic %in% c(4001:4003,4) & !(is.na(phe$ethnic)),"black"] <- 1
  phe[phe$ethnic == 6 & !(is.na(phe$ethnic)),"other.ppl"] <- 1
  phe[phe$ethnic %in% c(-1,-3),c("white","black","asian","mixed","other.ppl")] <- NA
  
  ### batch effect
  array <-db[,'f.22000.0.0']
  phe$array <- NA
  phe[which(array<0 & !(is.na(array))),'array'] <-0
  phe[which(array>0 & !(is.na(array))),'array'] <-1
  
  ### SES
  phe$SES <- db[,startsWith(colnames(db),"f.189.")]
  
  ### smoking
  smoke <- db[,startsWith(colnames(db),"f.20161.")]
  for(i in 2:ncol(smoke)){
    smoke[!(is.na(smoke[,i])),1] <- smoke[!(is.na(smoke[,i])),i]
  }
  smoke[is.na(smoke[,1]),1] <- 0
  phe$smoke <- smoke[,1]
  
  ABO <- read.table(ABO.data,header = T, sep = "\t",stringsAsFactors = F)
  phe <- merge(phe,ABO,by.x = "ID", by.y = "eid",all = T)
  phe$A <- phe$B <- phe$AB <- phe$O <- 0
  phe[phe$blood_group %in% c("AA","AO") & !(is.na(phe$blood_group)),"A"] <- 1
  phe[phe$blood_group %in% c("BB","BO") & !(is.na(phe$blood_group)),"B"] <- 1
  phe[phe$blood_group == "AB" & !(is.na(phe$blood_group)),"AB"] <- 1
  phe[phe$blood_group == "OO" & !(is.na(phe$blood_group)),"O"] <- 1
  phe[is.na(phe$blood_group),c("A","B","AB","O")] <- NA
  
  care.home <- read.table(inAgedCare.data,header = T)[,c(1,3)]
  phe <- merge(phe,care.home,by.x = "ID", by.y = "ID",all = T)
  
  if(is.null(out.file)) out.file <- "covariate"
  write.table(phe,paste0(out.file,".txt"),row.names = F, quote = F, sep = "\t")
}