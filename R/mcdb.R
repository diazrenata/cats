#' Prepare MCDB data
#'
#' @param from_MATSS use import_retriever_data?
#' @param save save to inst?
#'
#' @return if save = F, returns MCDB communities prepped
#' @export
#' @importFrom MATSS import_retriever_data
#' @importFrom dplyr filter left_join select rename mutate arrange group_by ungroup row_number
prep_mcdb_data <- function(from_MATSS = FALSE, save = FALSE) {

  if(from_MATSS) {
    mcdb <- MATSS:::import_retriever_data("mammal-community-db")
    mcdb_sites <-  mcdb$mammal_community_db_sites
    mcdb_communities <- mcdb$mammal_community_db_communities
  } else {
    inst_path = file.path(system.file(package= "cats"), "mcdb", "mcdb-raw")
    mcdb_sites <- read.csv(file.path(inst_path, "mammal_community_db_sites.csv"), stringsAsFactors = F)
    mcdb_communities <- read.csv(file.path(inst_path, "mammal_community_db_communities.csv"), stringsAsFactors = F)
  }

  mcdb_sites <- mcdb_sites %>%
    dplyr::filter(abundance_data_present == "all", abundance_data_format == "raw")

  mcdb_communities <- mcdb_communities %>%
    dplyr::filter(site_id %in% mcdb_sites$site_id,
                  presence_only != 1,
                  !is.na(initial_year)) %>%
    dplyr::left_join(dplyr::select(mcdb_sites, site_id, time_series), by = "site_id")

  mcdb_communities <- mcdb_communities %>%
    dplyr::rename(site = site_id,
                  timestep = initial_year,
                  species = species_id,
                  abund = abundance) %>%
    dplyr::select(-presence_only, -mass, -time_series, -species) %>%
    dplyr::mutate(dat = "mcdb",
                  singletons = FALSE,
                  sim = -99,
                  source = "observed") %>%
    dplyr::group_by(site, timestep) %>%
    dplyr::arrange(abund) %>%
    dplyr::mutate(rank = dplyr::row_number()) %>%
    dplyr::ungroup()

  if(save) {
    inst_path = file.path(system.file(package= "cats"), "mcdb", "mcdb-prepped")
    write.csv(mcdb_communities, file.path(inst_path, "mcdb_spab.csv"), row.names = F)
    return(TRUE)

  } else {
    return(mcdb_communities)
  }
}

#' List MCDB sites
#'
#' @return list of sites
#' @export
#'
list_mcdb_sites <- function() {

  mcdb_communities <- prep_mcdb_data(save = FALSE)

  mcdb_sites <- unique(mcdb_communities$site)

  return(mcdb_sites)
}

#' Load spab table for a MCDB site
#'
#' @param mcdb_site which site
#'
#' @return spab table
#' @export
#'
#' @importFrom dplyr filter
get_mcdb_spab <- function(mcdb_site) {

  mcdb_communities <- prep_mcdb_data(save = FALSE)

  return(dplyr::filter(mcdb_communities, site == mcdb_site))

}


