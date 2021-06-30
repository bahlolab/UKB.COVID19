#' Generate COVID-19  phenotypes
#'
#' @param ukb.data tab delimited UK Biobank phenotype file.
#' @param res.eng Latest covid result file/files for England.
#' @param res.wal Latest covid result file/files for Wales. Only available for downloads after April 2021.
#' @param res.sco Latest covid result file/files for Scotland. Only available for downloads after April 2021.
#' @param death.file Latest death register file.
#' @param death.cause.file Latest death cause file.
#' @param hesin.file Latest hospital inpatient master file.
#' @param hesin_diag.file Latest hospital inpatient diagnosis file.
#' @param hesin_oper.file Latest hospital inpatient operation file.
#' @param hesin_critical.file Latest hospital inpatient critical care file.
#' @param code.file The operation code file, which is included in the package.
#' @param Date Date, ddmmyyyy, select the results until a certain date. By default, Date = NULL, the latest hospitalization date.
#' @param out.name Name of files to be outputted. By default, out.name = NULL, “phenotypes.txt”.
#' @keywords severity, hospitalization, critical care, phenotype, covariates
#' @return Returns data.frame and outputs a phenotype file with phenotypes for COVID-10 susceptibility, severity and mortality.
#' @import data.table
#' @importFrom magrittr %>%
#' @import tidyverse
#' @export makePhenotypes
#' @examples
#' severity <- makePhenotypes(res.eng=covid_example("sim_result_england.txt.gz"),
#' death.file=covid_example("sim_death.txt.gz"),
#' death.cause.file=covid_example("sim_death_cause.txt.gz"),
#' hesin.file=covid_example("sim_hesin.txt.gz"),
#' hesin_diag.file=covid_example("sim_hesin_diag.txt.gz"),
#' hesin_oper.file=covid_example("sim_hesin_oper.txt.gz"),
#' hesin_critical.file=covid_example("sim_hesin_critical.txt.gz"),
#' code.file=covid_example("coding240.txt.gz"),
#' out.name=paste0(covid_example("results"),"/severity"))
#'

makePhenotypes <- function(ukb.data, res.eng, res.wal=NULL, res.sco=NULL, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, code.file, Date=NULL, out.name=NULL){

    pheno <- severity.summary(res.eng, res.wal, res.sco, death.file, death.cause.file, hesin.file, hesin_diag.file, hesin_oper.file, hesin_critical.file, code.file, Date, out.name)


 ## merge with full list of IDs
    ids <- fread(ukb.data, header = T, select = "f.eid", data.table = F, quote="", col.names="ID")
    res <- full_join(pheno, ids, by="ID")

  ## update susceptibility phenotypes
  # add phenotype: population v C19+
  res$ppl.result <- 0; res[res$result == 1 & !(is.na(res$result)),"ppl.result"] <- 1

  # reform  variables
  res <- data.reform(res, type = "severity")
  res <- data.reform(res, type = "mortality")
  res <- data.reform(res, type = "susceptibility")

  # rename phenotype: C19+ v C19-
  colnames(res)[colnames(res) == "result"] <- "pos.neg"
  # rename phenoytpe: C19+ v population
  colnames(res)[colnames(res) == "ppl.result"] <- "pos.ppl"

  ##ouptut file
  if(is.null(out.name)) out.name <-"phenotypes"

  print(paste0("Outputting file: ", out.name,".txt"))
  write.table(res,paste0(out.name,".txt"),row.names = F, quote = F, sep = "\t")

  ## return dataframe
  return(res)
}


