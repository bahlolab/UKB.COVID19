#' Variant QC for Genetic Analyses
#'
#' @param snpQC file containing SNP QC info (ukb_snp_qc.txt)
#' @param mfiDir directory where the per chromosome UKBiobank MAF/INFO files (ukb_mfi_chr*_v3.txt) are located
#' @param mafFilt minor allele frequency filter - default 0.001
#' @param infoFilt imputation quality (INFO) score filter - default 0.5
#' @param outDir output directory
#'
#' @return outputs SNP inclusion lists (SNPID and rsID formats) for given MAF/INFO filters. Also outputs list of SNPs to be used for genetic Relatedness Matrix (GRM) calculations.
#' @export variantQC
#' @import data.table
#' @importFrom magrittr %>%
#' @import tidyverse
#' @import here
#'
#' @examples
variantQC <- function(snpQC, mfiDir, mafFilt=0.001, infoFilt=0.5, outDir) {

print(paste0("Reading in SNP MAF INFO data from ",mfiDir,"/ukb_mfi_chr*_v3.txt"))

# Read in MAFs and imputation quality
chr <- c(1:22,"X","XY")
infoFreq <- lapply(chr, function(x) {
  paste0("ukb_mfi_chr",x,"_v3.txt") %>%
    here(mfiDir,.) %>%
    fread(.) %>%
    setnames(., c("SNP", "rsid", "POS", "Allele1", "Allele2", "MAF", "MinorAllele", "INFO")) %>%
    .[, CHR := x] %>%
    .[, .(SNP, rsid, CHR, POS, MAF, INFO)]
}) %>%
  rbindlist

print(paste("writing list of variants to include under different filters to",outDir))
## Different filters
filtSNPID <- infoFreq[MAF>=mafFilt & INFO>=infoFilt, SNP]
filtRSID <- infoFreq[MAF>=mafFilt & INFO>=infoFilt, rsid]

write.table(filt1, file=here(outDir, paste0("snpIncludeSNPIDs_minMaf",mafFilt,",_minInfo,",infoFilt,".txt")), row.names=F, col.names=F, quote=F)
write.table(filt1rsid, file=here(outDir, paste0("snpIncludeRSIDs_minMaf",mafFilt,",_minInfo,",infoFilt,".txt")), row.names=F, col.names=F, quote=F)

print(paste("writing list of variants to use for genetic relatedness matrix (grm) to",outDir))
# Identify suset of SNPs used in relatedness calculations - these to be used for glm.
# Use rsIDs here
snpQC <- fread(snpQcFile) %>%
  .[in_PCA==1, rs_id]

write.table(snpQC, file=here(outDir, "snpsIncludeRSIDs_GRM.txt"), row.names=F, col.names=F, quote=F)


}
