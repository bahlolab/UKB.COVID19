#' Sample QC for genetic analyses
#'
#' @param ukb.data tab delimited UK Biobank phenotype file, containing sample qc fields (with default UKBiobank codes as column names)
#' @param withdrawnFile csv file with withdrawn IDs from UK Biobank
#' @param ancestry specify "WhiteBritish" or "all" - defaults to "all"
#' @param software specify "SAIGE" or "plink" - defaults to "SAIGE"
#' @param outDir specify directory for sample QC file and inclusion/exclusion lists
#'
#' @return outputs sample QC file, and sample inclusion / exclusion lists for specified software
#' @export sampleQC
#' @import data.table
#' @importFrom magrittr %>%
#' @import tidyverse
#' @import here
#' @examples
#'
sampleQC <- function(ukb.data, withdrawnFile, ancestry="all", software="SAIGE", outDir) {

if(!(ancestry %in% c("all", "WhiteBritish"))) {
    stop("Please specify ancestry: \"all\" or \"WhiteBritish\"")
}

  if(!(software %in% c("plink", "SAIGE"))) {
    stop("Please specify GWAS software: \"plink\" or \"SAIGE\"")
  }

print(paste("Reading in Withdrawn IDs from",withdrawnFile))

withdrawnIDs <- fread(withdrawnFile) %>%
  .[[1]]

print(paste("Reading in Sample QC info from",ukb.data))

sampleQC <- fread(ukb.data,
                  select=c("f.eid", "f.31.0.0", "f.22001.0.0", "f.22028.0.0", "f.22029.0.0", "f.22030.0.0", "f.22006.0.0", "f.22027.0.0", "f.22021.0.0", "f.22019.0.0"), quote="")

setnames(sampleQC, c("eid", "sex", "geneticSex", "in_phasing_input_chr1_22", "in_phasing_input_chrx", "in_phasing_input_chrxy", "whiteBritish", "missingHetOutlier", "geneticKinship", "putative_sex_chromosome_aneuploidy"))

sampQC <- sampleQC %>%
  .[, withdrawn := case_when(eid %in% withdrawnIDs ~ 1,
                             T ~ 0)] %>%
  .[, sexMismatch := case_when(sex != geneticSex ~ 1,
                               T ~ 0)] %>%
  .[, excess_relatives := case_when(geneticKinship == 10 ~ 1,
                                    T ~ 0)] %>%
  .[, exclude := case_when(in_phasing_input_chr1_22==0 ~ 1,
                           sexMismatch==1 ~ 1,
                           excess_relatives==1 ~ 1,
                           putative_sex_chromosome_aneuploidy==1 ~ 1,
                           withdrawn==1 ~ 1,
                           T ~ 0)]

if(ancestry=="WhiteBritish") {
  sampQC[whiteBritish == 0, exclude := 1]
}

sampExclusion <- sampQC %>%
  .[, .(eid, in_phasing_input_chr1_22, in_phasing_input_chrx, in_phasing_input_chrxy, whiteBritish, sexMismatch, excess_relatives, putative_sex_chromosome_aneuploidy, withdrawn, exclude)]

print(paste("Outputting lists to",outDir))

# write table of exclusions and why
write.table(sampExclusion, file=here(outDir, "sampleGenoQC.csv"), row.names=F, col.names=T, quote=F, sep=",")

if(software=="Plink") {

  # write list of ids to exclude
  write.table(sampExclusion[exclude==1, .(eid, eid)], file=here(outDir, "sampleExclude_plink.txt"), row.names=F, col.names=F, quote=F)

  # write list of ids to include
  write.table(sampExclusion[exclude==0, .(eid, eid)], file=here(outDir, "sampleInclude_plink.txt"), row.names=F, col.names=F, quote=F)


}

if(software=="SAIGE") {

  # write list of ids to exclude
  write.table(sampExclusion[exclude==1, eid], file=here(outDir, "sampleExclude_SAIGE.txt"), row.names=F, col.names=F, quote=F)
  write.table(sampExclusion[exclude==1, .(eid, eid)], file=here(outDir, "sampleExclude_plink.txt"), row.names=F, col.names=F, quote=F)

  # write list of ids to include
  write.table(sampExclusion[exclude==0, eid], file=here(outDir, "sampleInclude_SAIGE.txt"), row.names=F, col.names=F, quote=F)
  write.table(sampExclusion[exclude==0, .(eid, eid)], file=here(outDir, "sampleInclude_plink.txt"), row.names=F, col.names=F, quote=F)


}

}
