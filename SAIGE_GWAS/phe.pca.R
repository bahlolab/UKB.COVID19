phe <- read.table("./data/phe.txt", header=T, sep="\t")
pca <- read.table("./data/grmSNPsSubset/pca.20.eigenvec", header=F)[,-1]
colnames(pca) <- c("ID",paste0("PC",1:20))
phe.pca <- merge(phe,pca,by.x="ID",by.y="ID")
ID.list <- cbind(phe.pca$ID,phe.pca$ID)
write.table(phe.pca,"./data/phe.pca.txt",row.names = F, quote = F, sep = "\t")
write.table(ID.list,"./data/ID.list.new",row.names = F, col.names = F, quote = F, sep = "\t")
q()

