#' Provide working directory for UKB.COVID19 example files.
#'
#' @param path path to file
#'
#' @examples
#' covid_example('covariate.txt')
#'
#' @export

covid_example <- function(path) {
  system.file("extdata", path, package = "UKB.COVID19", mustWork = TRUE)
}
