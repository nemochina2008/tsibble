# Unlike zoo::yearmon and zoo::yearqtr based on numerics,
# tsibble::yearmth and tsibble::yearqtr are based on the "Date" class.

#' Represent year-month, year-quarter and year objects
#'
#' @param x A vector of date-time, date.
#'
#' @return Year-month (`yearmth`), year-quarter (`yearqtr`) and year (`year`)
#' objects.
#' @details It's a known issue that these attributes will be dropped when using
#' [group_by] and [mutate] together.
#'
#' @export
#' @rdname period
#'
#' @examples
#' x <- seq(as.Date("2016-01-01"), as.Date("2016-12-31"), by = 30)
#' yearmth(x)
#' yearqtr(x)
#' year(x)
yearmth <- function(x) {
  UseMethod("yearmth")
}

#' @export
yearmth.POSIXt <- function(x) {
  posix <- split_POSIXt(x)
  result <- as.Date(paste(posix$year, posix$mon, "01", sep = "-"))
  structure(result, class = c("yearmth", "Date"))
}

#' @export
yearmth.Date <- yearmth.POSIXt

#' @export
yearmth.yearmth <- function(x) {
  structure(x, class = c("yearmth", "Date"))
}

#' @export
yearmth.numeric <- function(x) {
  year <- trunc(x)
  month <- formatC((x %% 1) * 12 + 1, flag = 0, width = 2)
  result <- as.Date(paste(year, month, "01", sep = "-"))
  structure(result, class = c("yearmth", "Date"))
}

#' @export
format.yearmth <- function(x, format = "%Y %b", ...) {
  format.Date(x, format = format, ...)
}

#' @export
print.yearmth <- function(x, format = "%Y %b", ...) {
  print(format(x, format = format, ...))
  invisible(x)
}

#' @rdname period
#' @export
yearqtr <- function(x) {
  UseMethod("yearqtr")
}

#' @export
yearqtr.POSIXt <- function(x) {
  posix <- split_POSIXt(x)
  qtrs <- posix$mon - (posix$mon - 1) %% 3
  result <- as.Date(paste(posix$year, qtrs, "01", sep = "-"))
  structure(result, class = c("yearqtr", "Date"))
}

#' @export
yearqtr.Date <- yearqtr.POSIXt

#' @export
yearqtr.yearmth <- yearqtr.POSIXt

#' @export
yearqtr.yearqtr <- function(x) {
  structure(x, class = c("yearqtr", "Date"))
}

#' @export
yearqtr.numeric <- function(x) {
  year <- trunc(x)
  last_month <- trunc((x %% 1) * 4 + 1) * 3
  first_month <- last_month - 2
  quarter <- formatC(first_month, flag = 0, width = 2)
  result <- as.Date(paste(year, quarter, "01", sep = "-"))
  structure(result, class = c("yearqtr", "Date"))
}

#' @export
format.yearqtr <- function(x, format = "%Y Q%q", ...) {
  year <- lubridate::year(x)
  year_sym <- "%Y"
  if (grepl("%y", format)) {
    year <- sprintf("%02d", year %% 100)
    year_sym <- "%y"
  } else if (grepl("%C", format)) {
    year <- year %/% 100
    year_sym <- "%C"
  }
  qtr <- lubridate::quarter(x)
  qtr_sub <- purrr::map_chr(qtr, ~ gsub("%q", ., x = format))
  year_sub <- purrr::map2_chr(year, qtr_sub, ~ gsub(year_sym, .x, x = .y))
  year_sub
}

#' @export
print.yearqtr <- function(x, format = "%Y Q%q", ...) {
  print(format.yearqtr(x, format = format))
  invisible(x)
}

#' @rdname period
#' @export
year <- function(x) {
  UseMethod("year")
}

# I'd like to implement the underlying "year" is an integer instead of Date.
# But it's a known issue that dplyr::mutate coupled with dplyr::group_by drops
# extra attributes.

#' @export
year.POSIXt <- function(x) {
  posix <- split_POSIXt(x)
  as.integer(posix$year)
}

#' @export
year.Date <- year.POSIXt

#' @export
year.yearmth <- year.POSIXt

#' @export
year.yearqtr <- year.POSIXt

#' @export
year.integer <- function(x) {
  as.integer(x)
}

#' @export
year.numeric <- year.integer

split_POSIXt <- function(x) {
  posix <- as.POSIXlt(x, tz = lubridate::tz(x))
  posix$mon <- posix$mon + 1
  posix$year <- posix$year + 1900
  posix
}
