#' Calculate gamma diversity
#'
#' Calculates gamma diversity (total number of distinct taxa) across all
#' sampling events, optionally grouped by a variable in the \code{event}
#' table (e.g. year).
#'
#' @param dat A list with at least two elements:
#'   \itemize{
#'     \item \code{event}: a data frame (or tibble) with one row per sampling
#'       event and a column \code{eventID}.
#'     \item \code{occurrence}: a data frame (or tibble) with at least the
#'       columns \code{eventID} and \code{taxonID}.
#'   }
#' @param group_by_col An optional character string giving the name of a
#'   column in \code{dat$event} to group by (e.g. \code{"year"}).
#'   If \code{NULL} (the default), gamma diversity is computed across all
#'   events without grouping.
#'
#' @return
#' A tibble. If \code{group_by_col} is provided, the tibble contains one
#' row per group with columns for the grouping variable and \code{gammadiv}.
#' If \code{group_by_col} is \code{NULL}, a single-row tibble with
#' \code{gammadiv}.
#'
#' @details
#' Gamma diversity is the total number of distinct \code{taxonID} values
#' observed across all events (or within each group). Events are first
#' joined with occurrences by \code{eventID}, then distinct taxa are
#' counted per group.
#'
#' @importFrom dplyr left_join group_by summarise n_distinct
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#' # Overall gamma diversity
#' calc_gammadiv(dia)
#'
#' # Gamma diversity per year (requires a year column in event)
#' dat <- dia
#' dat$event$year <- as.integer(format(dat$event$eventDate, "%Y"))
#' calc_gammadiv(dat, group_by_col = "year")
#'
calc_gammadiv <- function(dat, group_by_col = NULL) {
  occ <- dat$occurrence %>%
    dplyr::left_join(dat$event, by = "eventID")

  if (is.null(group_by_col)) {
    res <- occ %>%
      dplyr::summarise(gammadiv = dplyr::n_distinct(taxonID))
  } else {
    res <- occ %>%
      dplyr::group_by(.data[[group_by_col]]) %>%
      dplyr::summarise(gammadiv = dplyr::n_distinct(taxonID))
  }
  return(res)
}
