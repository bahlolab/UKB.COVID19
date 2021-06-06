#' Create comorbidity summary file
#' 
#' summarises disease history records of each individual from the hospital inpatient diagnosis data.
#' @param hesin.file Latest hospital inpatient master file.
#' @param hesin_diag.file Latest hospital inpatient diagnosis file.
#' @param cov.file Covariate file generated using risk.factor function.
#' @param primary TRUE: include primary diagnosis only; FALSE: include all diagnoses.
#' @param ICD10.file The ICD10 code file, which is included in the package, and also can be download from https://github.com/bahlolab/UKB.COVID19/blob/main/data/ICD10.coding19.tsv.
#' @param Date.start Date, ddmmyyyy, select the start date of hospital inpatient record period. 
#' @param Date.end Date, ddmmyyyy, select the end date of hospital inpatient record period. 
#' @keywords comorbidity
#' @return Outputs comorbidity summary file, named comorbidity_<Date.start>_<Date.end>.RData, including phenotype, non-genetic risk factors and all comorbidities, which will be used in the comorbidity association tests.
#' @export comorbidity.summary

### comorbidity
comorbidity.summary <- function(hesin.file, hesin_diag.file, cov.file, primary=FALSE, ICD10.file, Date.start=NULL, Date.end=NULL){
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

