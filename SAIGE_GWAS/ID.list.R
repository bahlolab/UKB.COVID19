phe <- read.table("./data/phe.txt", header=T, sep="\t")
ID.list <- cbind(phe$ID,phe$ID)
write.table(ID.list,"./data/ID.list",row.names=F,col.names=F,quote=F,sep="\t")
q()

