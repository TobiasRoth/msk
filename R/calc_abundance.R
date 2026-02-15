#' Calculate total abundance per sampling event
#'
#' This function calculates the total abundance (sum of
#' \code{individualCount}) for each sampling event based on the
#' \code{occurrence} table, and attaches the result as a new column
#' \code{abundance} to the \code{event} table.
#'
#' @param dat A list with at least two elements:
#'   \itemize{
#'     \item \code{event}: a data frame (or tibble) with one row per sampling
#'       event and a column \code{eventID}.
#'     \item \code{occurrence}: a data frame (or tibble) with at least the
#'       columns \code{eventID} and \code{individualCount}.
#'   }
#'
#' @return
#' The input list \code{dat} with its \code{event} component modified:
#' a numeric column \code{abundance} is added, giving the total number of
#' individuals recorded for each \code{eventID}. Events with no
#' occurrences receive \code{abundance = 0}.
#'
#' @details
#' Total abundance is computed as the sum of \code{individualCount}
#' values per \code{eventID} in \code{dat$occurrence}. The resulting
#' values are left-joined to \code{dat$event} by \code{eventID}.
#'
#' @importFrom dplyr left_join group_by summarise
#' @importFrom tidyr replace_na
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#' dat <- calc_abundance(dia)
#' head(dat$event)
#'
calc_abundance <- function(dat) {
  dat$event <- dat$event %>%
    left_join(
      dat$occurrence %>%
        dplyr::group_by(eventID) %>%
        dplyr::summarise(abundance = sum(individualCount, na.rm = TRUE)),
      by = "eventID"
    ) %>%
    tidyr::replace_na(list(abundance = 0))
  return(dat)
}
