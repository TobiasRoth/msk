#' Calculate alpha diversity per sampling event
#'
#' This function calculates alpha diversity (number of distinct taxa) for
#' each sampling event based on the \code{occurrence} table, and attaches the
#' result as a new column \code{alphadiv} to the \code{event} table.
#'
#' @param dat A list with at least two elements:
#'   \itemize{
#'     \item \code{event}: a data frame (or tibble) with one row per sampling
#'       event and a column \code{eventID}.
#'     \item \code{occurrence}: a data frame (or tibble) with at least the
#'       columns \code{eventID} and \code{taxonID}, where each row represents
#'       the occurrence of a taxon in an event.
#'   }
#'
#' @return
#' The input list \code{dat} with its \code{event} component modified:
#' a numeric column \code{alphadiv} is added, giving the number of distinct
#' taxa (\code{taxonID}) recorded for each \code{eventID}. Events with no
#' occurrences receive \code{alphadiv = 0}.
#'
#' @details
#' Alpha diversity is computed as the count of distinct \code{taxonID}
#' values per \code{eventID} in \code{dat$occurrence}. The resulting
#' values are left-joined to \code{dat$event} by \code{eventID}.
#'
#' @importFrom dplyr left_join group_by summarise n_distinct
#' @importFrom tidyr replace_na
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#' dat <- calc_alphadiv(mzb)
#' head(dat$event)
#'
calc_alphadiv <- function(dat) {
  dat$event <- dat$event %>%
    left_join(
      dat$occurrence %>%
        dplyr::group_by(eventID) %>%
        dplyr::summarise(alphadiv = n_distinct(taxonID)),
      by = "eventID"
    ) %>%
    tidyr::replace_na(list(alphadiv = 0))
  return(dat)
}
