#' Get EDDI data
#'
#' This function searches for EDDI data on a specific date, returning a
#' \code{Raster*} object.
#'
#' The Evaporative Demand Drought Index is available for each day from 1980 to
#' present, usually with a ~5 day lag to the current date. It is available at
#' multiple timescales, including the 1 to 12 week and 1 to 12 months scales.
#' For more information see \url{https://www.esrl.noaa.gov/psd/eddi/}
#'
#' @param date An object of class Date or a character string formatted as
#' %Y-%m-%d (e.g., "2016-04-01") which specifies the date(s) for which data
#' are to be acquired. To specify a time interval or date range, date can be
#' a vector of class Date such as produced by \code{seq.Date}.
#' @param timescale A string that specifies the timescale for EDDI, e.g.,
#' "1 week", "12 month". The \code{get_eddi} function assumes that a space
#' separates the number for the timescale (e.g., "1", "12") from the units
#' (e.g., "week", "month"). Fractional timescales are not supported, and will
#' be rounded to the nearest integer (e.g., "1.1 week" will be converted to
#' "1 week").
#' @return A Raster* object containing EDDI data. Each layer in this object
#' corresponds to data for one date.
#'
#' @examples
#' \dontrun{
#' # looking for data on one day:
#' get_eddi(date = "2018-01-01", lag_value = 12, lag_units = "months")
#'
#' # searching across a date range
#' start_date <- as.Date("2015-06-01")
#' end_date <- as.Date("2015-06-14")
#' date_sequence <- seq(start_date, end_date, by = 1)
#' get_eddi(date = date_sequence, lag_value = 1, lag_units = "week")
#' }
#'
#' @importFrom raster raster
#' @export
get_eddi <- function(date, timescale) {
  parsed_date <- parse_date(date)
  parsed_timescale <- parse_timescale(timescale)

  param_combos <- expand.grid(year = format(parsed_date, '%Y'),
                              date_string = format(parsed_date, '%Y%m%d'),
                              timescale_number = parsed_timescale[["number"]],
                              timescale_units = parsed_timescale[["units"]])

  # TODO: generate URLs to data files
}


parse_date <- function(date) {
  if (class(date) != "Date") {
    tryCatch(date <- as.Date(date),
             error = function(c) {
               stop(paste("Couldn't coerce date(s) to a Date object.",
                          "Try formatting date(s) as: %Y-%m-%d,",
                          "or use Date objects for the date argument",
                          "(see ?Date)."))
             }
    )
  }
  todays_date <- format(Sys.time(), "%Y-%m-%d")
  if (any(date > todays_date)) {
    stop("All provided dates must be <= the current date.")
  }
  date
}


parse_timescale <- function(timescale) {
  if (length_timescale != 1) {
    stop("The timescale argument must have length one, e.g., '1 week'.")
  }

  timescale_components <- unlist(strsplit(timescale, split = " "))
  if (length(timescale_components != 2)) {
    stop("The timescale argument must have exactly one space, e.g., '1 week'.")
  }

  timescale_int <- as.integer(timescale_components[1])
  if (timescale_int < 1 | timescale_int > 12) {
    stop('The number in the timescale must be an integer between 1 and 12.')
  }
  timescale_number <- sprintf("%02d", timescale_int)

  timescale_units <- timescale_components[2]
  if (timescale_units != "week" | timescale_units != "month") {
    stop("Timescale units must be one of 'week' or 'month', e.g., '6 week' or
         '10 month'")
  }
  list(number = timescale_number, units = timescale_units)
}
