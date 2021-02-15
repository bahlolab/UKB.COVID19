
library(questionr)

log.cov <- function(data, phe.name, cov.name = c("sex","age","bmi"), asso.output=NULL){
  y <- data[,c(phe.name,cov.name)]
  y <- na.omit(y)
  colnames(y)[1] <- "phe"
  m <- glm(phe ~ ., data=y, family="binomial")
  log.reg <- summary(m)
  OR <- odds.ratio(m)
  asso <- as.data.frame(cbind(log.reg$coefficients[,1],OR[,c(1:4)]))
  colnames(asso)[1] <- "Estimate"
  if(!(is.null(asso.output))) write.csv(asso,paste0(asso.output,".csv"),quote = F)
  return(asso)
}