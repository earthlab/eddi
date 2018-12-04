context("get_eddi")

test_that("Invalid date inputs raise errors", {
  expect_error(get_eddi('Not a date', timescale = "1 week"),
               regexp = "coerce")
})

test_that("Dates later than today raise errors", {
  expect_error(get_eddi("3099-01-01", timescale = "1 week"),
               regexp = "must be <=")
})

test_that("Dates prior to 1980 raise errors", {
  expect_error(get_eddi("1979-12-31", timescale = "1 week"),
               regexp = "not available prior to 1980")
})

test_that("Multiple timescales raise errors", {
  expect_error(get_eddi("1999-01-01", c("1 week", "2 week")),
               regexp = "must have length one")
})

test_that("More than one space in timescale will raise an error", {
  expect_error(get_eddi("1990-01-01", timescale = "1 week please"),
               regexp = "exactly one space")
})

test_that("Invalid numbers in timescales raise errors", {
  expect_error(get_eddi("1991-01-01", timescale = "134 week"),
               regexp = "between 1 and 12")
  expect_error(get_eddi("1991-01-01", timescale = "0 month"),
               regexp = "between 1 and 12")
})

test_that("Timescale units other than 'week' or 'month' raise errors", {
  expect_error(get_eddi("1991-01-01", timescale = "2 weeks"),
               regexp = "one of 'week' or 'month'")
})

test_that("Single dates return RasterStacks", {
  r <- get_eddi(date = "2018-11-29", timescale = "1 month")
  expect_is(r, "RasterStack")
  expect_equal(raster::nlayers(r), 1)
})

test_that("Multiple dates return RasterStacks", {
  dates <- seq(as.Date("2017-12-31"), as.Date("2018-01-01"), by = 1)
  r <- get_eddi(date = dates, timescale = "1 month")
  expect_is(r, "RasterStack")
  expect_equal(raster::nlayers(r), 2)
})
