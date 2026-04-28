# Global variables used in dplyr pipelines (to avoid R CMD check NOTEs)
# See: https://r-pkgs.org/dependencies-in-practice.html#how-to-not-use-a-package-in-imports
utils::globalVariables(c(
  "..eventID",
  "eventID",
  "indCount",
  "individualCount",
  "taxonID"
))

#' @importFrom rlang .data
NULL
