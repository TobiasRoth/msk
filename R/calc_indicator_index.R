#' Normalize indicator values to a reference (base = 100)
#'
#' Takes a summary table (e.g. output of \code{\link{calc_gammadiv}}) and
#' normalizes a value column relative to a reference group, producing an
#' index where the reference equals 100.
#'
#' @param data A data frame or tibble containing the indicator values.
#' @param value_col Character string naming the column with indicator values
#'   to normalize (e.g. \code{"gammadiv"}).
#' @param group_col Character string naming the grouping column
#'   (e.g. \code{"year"}).
#' @param ref_value The value of \code{group_col} to use as the reference
#'   (e.g. \code{2012}). The indicator value for this group becomes 100.
#'
#' @return
#' The input data frame with an additional column \code{index}, where
#' each value is \code{(value / reference_value) * 100}.
#'
#' @details
#' This is a simple normalization commonly used to compare temporal changes
#' in biodiversity indicators. The reference group (e.g. the first survey
#' year) is set to 100 and all other values are expressed relative to it.
#'
#' @export
#'
#' @examples
#' dat <- dia
#' dat$event$year <- as.integer(format(dat$event$eventDate, "%Y"))
#' gamma <- calc_gammadiv(dat, group_by_col = "year")
#' calc_indicator_index(gamma, "gammadiv", "year", ref_value = 2011)
#'
calc_indicator_index <- function(data, value_col, group_col, ref_value) {
  ref_row <- data[[group_col]] == ref_value
  if (!any(ref_row)) {
    stop("ref_value '", ref_value, "' not found in column '", group_col, "'.")
  }
  ref_val <- data[[value_col]][which(ref_row)[1]]
  if (is.na(ref_val) || ref_val == 0) {
    stop("Reference value is NA or zero; cannot compute index.")
  }
  data$index <- (data[[value_col]] / ref_val) * 100
  return(data)
}
