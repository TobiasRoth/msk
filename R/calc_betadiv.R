#' Calculate beta diversity (Simpson dissimilarity)
#'
#' Calculates pairwise Simpson dissimilarity between sampling events,
#' optionally grouped by a variable in the \code{event} table (e.g. year).
#' Returns summary statistics (mean, first and third quartile) of the
#' pairwise dissimilarity values.
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
#'   If \code{NULL} (the default), beta diversity is computed across all
#'   events without grouping.
#'
#' @return
#' A tibble with columns:
#' \describe{
#'   \item{(grouping variable)}{If \code{group_by_col} is provided.}
#'   \item{betadiv_mean}{Mean pairwise Simpson dissimilarity.}
#'   \item{betadiv_q25}{First quartile (25th percentile).}
#'   \item{betadiv_q75}{Third quartile (75th percentile).}
#' }
#'
#' @details
#' The Simpson dissimilarity index is computed for each pair of events as:
#'
#' \deqn{\beta_{sim} = \frac{\min(b, c)}{a + \min(b, c)}}
#'
#' where \code{a} is the number of shared taxa, \code{b} is the number of
#' taxa unique to the first event, and \code{c} is the number of taxa unique
#' to the second event. This index ranges from 0 (identical communities) to
#' 1 (completely different communities) and is independent of richness
#' differences between sites.
#'
#' This implementation matches \code{simba::sim(method = "simpson")} but
#' does not require the \pkg{simba} package.
#'
#' @importFrom dplyr left_join distinct
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#' # Overall beta diversity
#' calc_betadiv(dia)
#'
#' # Beta diversity per year
#' dat <- dia
#' dat$event$year <- as.integer(format(dat$event$eventDate, "%Y"))
#' calc_betadiv(dat, group_by_col = "year")
#'
calc_betadiv <- function(dat, group_by_col = NULL) {
  occ <- dat$occurrence %>%
    dplyr::left_join(dat$event, by = "eventID") %>%
    dplyr::distinct(eventID, taxonID, .keep_all = TRUE)

  if (is.null(group_by_col)) {
    vals <- .simpson_pairwise(occ)
    res <- tibble::tibble(
      betadiv_mean = mean(vals),
      betadiv_q25  = stats::quantile(vals, probs = 0.25, names = FALSE),
      betadiv_q75  = stats::quantile(vals, probs = 0.75, names = FALSE)
    )
  } else {
    groups <- unique(occ[[group_by_col]])
    res_list <- lapply(groups, function(g) {
      sub <- occ[occ[[group_by_col]] == g, ]
      vals <- .simpson_pairwise(sub)
      tibble::tibble(
        grp           = g,
        betadiv_mean  = mean(vals),
        betadiv_q25   = stats::quantile(vals, probs = 0.25, names = FALSE),
        betadiv_q75   = stats::quantile(vals, probs = 0.75, names = FALSE)
      )
    })
    res <- do.call(rbind, res_list)
    names(res)[1] <- group_by_col
  }
  return(res)
}

#' Compute pairwise Simpson dissimilarity (internal)
#'
#' @param occ A data frame with columns \code{eventID} and \code{taxonID}.
#' @return A numeric vector of pairwise Simpson dissimilarity values.
#' @noRd
.simpson_pairwise <- function(occ) {
  events <- unique(occ$eventID)
  n <- length(events)
  if (n < 2) return(numeric(0))

  # Build presence matrix: list of taxon sets per event
  taxa_by_event <- split(occ$taxonID, occ$eventID)

  vals <- numeric(n * (n - 1) / 2)
  k <- 1
  for (i in 1:(n - 1)) {
    si <- taxa_by_event[[events[i]]]
    for (j in (i + 1):n) {
      sj <- taxa_by_event[[events[j]]]
      a <- length(intersect(si, sj))
      b <- length(si) - a
      c_val <- length(sj) - a
      denom <- a + min(b, c_val)
      vals[k] <- if (denom == 0) 0 else min(b, c_val) / denom
      k <- k + 1
    }
  }
  return(vals)
}
