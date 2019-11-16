context("Check that sampling is okay")

test_that("sampling runs", {
  thisdat <- get_toy_bbs_data(route = 1, region = 11)
  spab <- make_spab(thisdat, datname = "bbs_data_rtrg_1_11")
  s_spab <- add_singletons_ts(spab)

  s_spab <- dplyr::filter(s_spab, timestep %in% c(2010, 1974), rank <= 20)

  expect_silent(fs_ts_wrapper(spab = s_spab, nsamples = 10, seed = 1))

  samples <- fs_ts_wrapper(spab = s_spab, nsamples = 10, seed = 1)

  expect_true(ncol(samples) == 15)
  expect_true(all(samples$skew_percentile ==0))
  expect_equivalent(signif(samples$skew, 3), c(2.47, 1.82, .529, .247))
  expect_equivalent(signif(samples$simpson, 3), c(.946, .945, .934, .933))
  expect_equivalent(samples$timestep, c(2010, 1974, 2010, 1974))
  expect_equivalent(samples$singletons, c(TRUE, TRUE, FALSE, FALSE))

})

