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
#' @param dir Directory to for downloaded EDDI data. By default this will be
#' a temporary directory. This should be a file path specified as a string.
#' @param overwrite Boolean to indicate whether to overwrite EDDI data that
#' already exist locally in \code{dir}. Defaults to FALSE.
#' @return A Raster* object containing EDDI data. Each layer in this object
#' corresponds to data for one date.
#'
#' @examples
#' \donttest{
#' # note that downloads may take a while, depending on internet connection
#' get_eddi(date = "2018-01-01", timescale = "1 month")
#' }
#' 
#' @export
get_eddi <- function(date, timescale, dir = tempdir(), overwrite = FALSE) {
  parsed_date <- parse_date(date)
  parsed_timescale <- parse_timescale(timescale)
  ts_unit_abbrev <- ifelse(parsed_timescale[['units']] == 'week', 'wk', 'mn')

  url <- paste0(
    "ftp://ftp.cdc.noaa.gov/Projects/EDDI/CONUS_archive/data/",
    format(parsed_date, "%Y"), "/",
    "EDDI_ETrs_", parsed_timescale[["number"]], ts_unit_abbrev,
    "_", format(parsed_date, "%Y%m%d"), ".asc"
  )
  local_path <- file.path(dir, basename(url))
  for (i in seq_along(url)) {
    if (overwrite | !file.exists(local_path[i])) {
      utils::download.file(url[i], local_path[i])
    }
  }

  r <- raster::stack(local_path)
  raster::crs(r) <- "+init=epsg:4326"
  r
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
  if (any(date <= as.Date('1980-01-01'))) {
    stop("EDDI data are not available prior to 1980.")
  }
  date
}


parse_timescale <- function(timescale) {
  if (length(timescale) != 1) {
    stop("The timescale argument must have length one, e.g., '3 month'")
  }

  timescale_components <- unlist(strsplit(timescale, split = " "))
  if (length(timescale_components) != 2) {
    stop("The timescale argument must have exactly one space, e.g., '1 week'.")
  }

  timescale_int <- as.integer(timescale_components[1])
  if (timescale_int < 1 | timescale_int > 12) {
    stop('The number in the timescale must be an integer between 1 and 12.')
  }
  timescale_number <- sprintf("%02d", timescale_int)

  timescale_units <- timescale_components[2]
  valid_units <- c('week', 'month')
  if (!(timescale_units %in% valid_units)) {
    stop("Timescale units must be one of 'week' or 'month', e.g., '6 week' or
         '10 month'")
  }
  list(number = timescale_number, units = timescale_units)
}
