#' Diatom data (events and occurrences)
#'
#' Dataset with sampling events and associated species occurrences
#' (diatoms) from the Swiss NAWA monitoring programme. The data are
#' stored as a list with two tibbles following the
#' \href{https://dwc.tdwg.org/terms/}{Darwin Core} standard:
#' \code{event} describes individual sampling events, \code{occurrence}
#' the observed taxa per event.
#'
#' @format A \code{list} with 2 elements:
#' \describe{
#'   \item{event}{A tibble with 454 rows and 2 variables:
#'     \describe{
#'       \item{eventID}{Character; unique identifier of the sampling event
#'         (e.g. \code{"100_2011"}).}
#'       \item{eventDate}{Date (\code{Date}); date of sampling.}
#'     }
#'   }
#'   \item{occurrence}{A tibble with 13,422 rows and 3 variables:
#'     \describe{
#'       \item{taxonID}{Numeric key of the recorded taxon.}
#'       \item{eventID}{Character; link to the corresponding
#'         entry in \code{event}.}
#'       \item{individualCount}{Numeric; number of individuals of the
#'         respective taxon in the event.}
#'     }
#'   }
#' }
#'
#' @details
#' The two tibbles are linked by \code{eventID}: each row in
#' \code{occurrence} refers to exactly one event in \code{event}.
#'
#' @examples
#' data("dia")
#' names(dia)
#' dplyr::glimpse(dia$event)
#' dplyr::glimpse(dia$occurrence)
#'
"dia"
