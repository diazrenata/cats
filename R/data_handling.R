#' Get toy BBS data
#'
#' Load one of 3 BBS route-regions packaged with `cats`. For tests and method development, avoids needing MATSS fully functional.
#'
#' Currently, the options are (rt/rg): 1/11, 268/8, 314/27. These are datasets 1, 410, and 1977 if you run MATSS::build_bbs_datasets_plan. Those are arbitrary numbers chosen to be memorable and disperseed throughout the database (1, our parking space, the first year of Portal).
#'
#' @param route int route
#' @param region int region
#' @param from_retriever t/f
#'
#' @return MATSS packaged dataset
#' @export
#' @importFrom MATSS get_bbs_route_region_data
get_toy_bbs_data <- function(route = 1, region = 11, from_retriever = F) {
  if(from_retriever) {
    dat <- MATSS::get_bbs_route_region_data(route, region)
  } else {
    inst_path = file.path(system.file(package= "cats"), "toy_bbs_data")
    dat <- readRDS(file.path(inst_path, paste0("route", route, "_region", region, ".Rds")))
  }
  return(dat)
}


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
                  sim = -99) %>%
    dplyr::select(-species)

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

