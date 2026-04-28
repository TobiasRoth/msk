#' Calculate abundance per sampling event
#'
#' Calculates abundance for each sampling event and attaches the result
#' as a new column to the \code{event} table. Two methods are available:
#' total abundance (sum of all individuals) or mean abundance per taxon
#' (mean of per-taxon individual counts).
#'
#' @param dat A list with at least two elements:
#'   \itemize{
#'     \item \code{event}: a data frame (or tibble) with one row per sampling
#'       event and a column \code{eventID}.
#'     \item \code{occurrence}: a data frame (or tibble) with at least the
#'       columns \code{eventID}, \code{taxonID}, and \code{individualCount}.
#'   }
#' @param method Character string specifying the abundance metric:
#'   \itemize{
#'     \item \code{"total"} (default): sum of \code{individualCount} per event.
#'       Result column: \code{abundance}.
#'     \item \code{"mean_per_taxon"}: mean of per-taxon individual counts per
#'       event. Counts are first summed within each taxon (to handle multiple
#'       rows per taxon), then averaged across taxa. Result column:
#'       \code{abundance_mean}. Less sensitive to dominant taxa than
#'       \code{"total"}.
#'   }
#'
#' @return
#' The input list \code{dat} with its \code{event} component modified.
#' A numeric column is added (\code{abundance} or \code{abundance_mean},
#' depending on \code{method}). Events with no occurrences receive \code{0}.
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
#' dat <- calc_abundance(dia, method = "mean_per_taxon")
#' head(dat$event)
#'
calc_abundance <- function(dat, method = "total") {
  method <- match.arg(method, c("total", "mean_per_taxon"))

  if (method == "total") {
    summary <- dat$occurrence %>%
      dplyr::group_by(eventID) %>%
      dplyr::summarise(abundance = sum(individualCount, na.rm = TRUE),
                       .groups = "drop")
    dat$event <- dat$event %>%
      left_join(summary, by = "eventID") %>%
      tidyr::replace_na(list(abundance = 0))
  } else {
    summary <- dat$occurrence %>%
      dplyr::group_by(eventID, taxonID) %>%
      dplyr::summarise(indCount = sum(individualCount, na.rm = TRUE),
                       .groups = "drop") %>%
      dplyr::group_by(eventID) %>%
      dplyr::summarise(abundance_mean = mean(indCount, na.rm = TRUE),
                       .groups = "drop")
    dat$event <- dat$event %>%
      left_join(summary, by = "eventID") %>%
      tidyr::replace_na(list(abundance_mean = 0))
  }
  return(dat)
}
