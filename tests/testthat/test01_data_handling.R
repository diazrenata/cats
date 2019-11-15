context("Check that data handling is okay")

test_that("load_dataset", {
    thisdat <- MATSS::get_bbs_route_region_data(route = 1, region = 11)
    spab <- make_spab(thisdat, datname = "bbs_data_rtrg_1_11")
    expect_true(is.data.frame(spab))
    expect_true(ncol(spab) == 9)
    expect_true(all(
      mode(spab$rank) == "numeric",
      mode(spab$abund) == "numeric",
      mode(spab$site) == "character",
      mode(spab$dat) == "character",
      mode(spab$singletons) == "logical",
      mode(spab$sim) == "numeric",
      mode(spab$source) == "character",
      mode(spab$timestep) == "numeric",
      mode(spab$species) == "character"
    ))
    expect_false(anyNA(spab))

})

test_that("add_singletons", {
  thisdat <- MATSS::get_bbs_route_region_data(route = 1, region = 11)
  spab <- make_spab(thisdat, datname = "bbs_data_rtrg_1_11")
  s_spab <- add_singletons_ts(spab)

  expect_equivalent(unique(s_spab$timestep), unique(spab$timestep))

  s_spab <- dplyr::filter(s_spab, timestep ==1968, singletons == TRUE)
  spab <- dplyr::filter(spab, timestep == 1968)

  expect_true(nrow(s_spab) > nrow(spab))
  expect_true(max(s_spab$rank) > max(spab$rank))

  expect_true(sum(s_spab$abund) == sum(spab$abund) + (nrow(s_spab) - nrow(spab)))

})


test_that("get statevars", {
  thisdat <- MATSS::get_bbs_route_region_data(route = 1, region = 11)
  spab <- make_spab(thisdat, datname = "bbs_data_rtrg_1_11")
  s_spab <- add_singletons_ts(spab)

  sv <- get_statevars_ts(s_spab)

  expect_true(ncol(sv) == 8)
  expect_true(all(
    mode(sv$site) == "character",
    mode(sv$dat) == "character",
    mode(sv$singletons) == "logical",
    mode(sv$sim) == "numeric",
    mode(sv$source) == "character",
    mode(sv$s0) == "numeric",
    mode(sv$n0) == "numeric",
    mode(sv$timestep) == "numeric"
  ))
  expect_false(anyNA(sv))

  expect_true(
    dplyr::filter(sv, site == "rtrg_1_11", singletons == FALSE, timestep == 1967)$n0 == sum(dplyr::filter(s_spab, site == "rtrg_1_11", singletons == FALSE, timestep == 1967)$abund)
  )

  expect_true(
    dplyr::filter(sv, site == "rtrg_1_11", singletons == FALSE, timestep == 1967)$s0 == nrow(dplyr::filter(s_spab, site == "rtrg_1_11", singletons == FALSE, timestep == 1967))
  )

  expect_true(
    dplyr::filter(sv, site == "rtrg_1_11", singletons == TRUE, timestep == 1967)$n0 == sum(dplyr::filter(s_spab, site == "rtrg_1_11", singletons == TRUE, timestep == 1967)$abund)
  )

  expect_true(
    dplyr::filter(sv, site == "rtrg_1_11", singletons == TRUE, timestep == 1967)$s0 == nrow(dplyr::filter(s_spab, site == "rtrg_1_11", singletons == TRUE, timestep == 1967))
  )

})
