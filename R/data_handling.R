#' Make spab table from MATSS dataset
#'
#' @param matssdat dataset as imported from MATSS
#' @param datname name from drake
#'
#' @return spab table with cols dat site singletons source sim timestep rank species abund
#' @export
#'
#' @importFrom dplyr mutate filter arrange row_number ungroup
#' @importFrom tidyr gather
make_spab <- function(matssdat, datname) {

  dat <- unlist(strsplit(datname, split = "_data")[[1]][1])
  site <- unlist(strsplit(datname, split = "data_")[[1]][2])

  spab <- matssdat$abundance %>%
    dplyr::mutate(timestep = unlist(matssdat$covariates[, matssdat$metadata$timename])) %>%
    tidyr::gather(-timestep, key = "species", value = "abund") %>%
    dplyr::filter(abund > 0) %>%
    dplyr::group_by(timestep) %>%
    dplyr::arrange(abund) %>%
    dplyr::mutate(rank = dplyr::row_number()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(dat = dat,
                  site =site,
                  singletons = FALSE,
                  source = "observed",
                  sim = -99)

  return(spab)
}

#' Get statevars on a TS
#'
#' @param spab from make_spab
#'
#' @return dataframe with cols site singletons dat source sim timestep s0 n0
#' @export
#'
#' @importFrom dplyr group_by summarize n ungroup
get_statevars_ts <- function(spab) {

  sv <- spab %>%
    dplyr::group_by(site, singletons, dat, source, sim, timestep) %>%
    dplyr::summarize(s0 = dplyr::n(),
                     n0 = sum(abund)) %>%
    dplyr::ungroup()

  return(sv)
}


#' Add singletons to a dataset
#'
#' @param spab_ts the dataset over the timeseries, col timestep
#' @param use_max use max?
#'
#' @return dataset plus singletons
#' @export
#'
#' @importFrom dplyr filter bind_rows
#' @importFrom scadsanalysis add_singletons
add_singletons_ts <- function(spab_ts, use_max = TRUE) {

  timesteps <- as.list(unique(spab_ts$timestep))

  ts_dats <- lapply(timesteps, FUN = function(ts_name, dataset) return(dplyr::filter(spab_ts, timestep == ts_name)), dataset = spab_ts)

  ts_singletons <- lapply(ts_dats, FUN = function(ts_dat, use_max) return(dplyr::mutate(scadsanalysis::add_singletons(ts_dat, use_max), timestep = ts_dat$timestep[1])), use_max = use_max)

  ts_singletons <- dplyr::bind_rows(ts_singletons)

  spab_ts <- dplyr::bind_rows(spab_ts, ts_singletons)

  return(spab_ts)

}

#
# fs_ts_wrapper <- function(spab, nsamples, seed, p_table) {
#
# }
