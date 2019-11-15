#' TS Sampling wrapper
#'
#' @param spab df
#' @param nsamples nsamples
#' @param seed set a seed
#' @param p_table path to p table
#'
#' @return df of dis of obs vectors
#' @export
#'
#' @importFrom dplyr filter mutate bind_rows
#' @importFrom scadsanalysis sample_fs add_dis pull_di
#' @importFrom feasiblesads fill_ps
fs_ts_wrapper <- function(spab, nsamples = 10, seed = 1, p_table = NULL) {

  if(is.null(spab)) {
    return(NA)
  }

  if(nrow(spab) == 0) {
    return(NA)
  }

  if(!is.null(seed)) {
    set.seed(seed)
  }

  timesteps <- as.list(unique(spab$timestep))

  max_s = max(spab$rank)
  max_n = sum(spab$abund)


  if(is.null(p_table)) {
    p_table <- feasiblesads::fill_ps(max_s, max_n, storeyn = F)
  }

  ts_subsets_T <- lapply(timesteps, FUN = function(dat, ts) return(dplyr::filter(dat, timestep == ts, singletons == TRUE)), dat = spab)
  ts_subsets_F <- lapply(timesteps, FUN = function(dat, ts) return(dplyr::filter(dat, timestep == ts, singletons == FALSE)), dat = spab)
  ts_subsets <- c(ts_subsets_T, ts_subsets_F)
  rm(ts_subsets_T)
  rm(ts_subsets_F)

  ts_samples <- lapply(ts_subsets, FUN = function(ts_subset, nsamples, p_table) return(dplyr::mutate(scadsanalysis::sample_fs(dataset = ts_subset, nsamples = nsamples, p_table = p_table), timestep =ts_subset$timestep[1])), nsamples = nsamples, p_table = p_table)

  rm(ts_subsets)

  ts_dis <- lapply(ts_samples, FUN = scadsanalysis::add_dis)

  rm(ts_samples)

  ts_dis_obs <- lapply(ts_dis, FUN = scadsanalysis::pull_di)

  rm(ts_dis)

  ts_dis_obs <- dplyr::bind_rows(ts_dis_obs)

  return(ts_dis_obs)

}
