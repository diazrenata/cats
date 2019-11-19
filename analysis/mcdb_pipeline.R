library(drake)
library(cats)
library(MATSS)

expose_imports(cats)

ndraws = 2500
set.seed(1977)


mcdb_sites <- list_mcdb_sites()

all <- drake_plan(
  spab = target(get_mcdb_spab(mcdb_site = site),
                transform = map(site = !!mcdb_sites)),
  s = target(add_singletons_ts(spab_ts = spab),
             transform = map(spab), hpc = T),
  mamm_p = target(readRDS(here::here("analysis", "masterp_mamm.Rds"))),
  results = target(fs_ts_wrapper(spab = s, nsamples = ndraws, seed = sample.int(10^4, size = 1), p_table = mamm_p),
                   transform = map(s),
                   hpc = T),
  all_results = target(dplyr::bind_rows(results),
                        transform = combine(results))
  )


## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analysis", "drake", "drake-cache-mcdb.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)

## View the graph of the plan
if (interactive())
{
  config <- drake_config(all, cache = cache)
  sankey_drake_graph(config, build_times = "none")  # requires "networkD3" package
  vis_drake_graph(config, build_times = "none")     # requires "visNetwork" package
}

## Run the pipeline
nodename <- Sys.info()["nodename"]
if(grepl("ufhpc", nodename)) {
  print("I know I am on the HiPerGator!")
  library(clustermq)
  options(clustermq.scheduler = "slurm", clustermq.template = "slurm_clustermq.tmpl")
  ## Run the pipeline parallelized for HiPerGator
  make(all,
       force = TRUE,
       cache = cache,
       cache_log_file = here::here("analysis", "drake", "cache_log_mcdb.txt"),
       verbose = 2,
       parallelism = "clustermq",
       jobs = 20,
       caching = "master",
       memory_strategy = "autoclean") # Important for DBI caches!
} else {
  library(clustermq)
  options(clustermq.scheduler = "multicore")
  # Run the pipeline on multiple local cores
  system.time(make(all, cache = cache, cache_log_file = here::here("analysis", "drake", "cache_log_mcdb.txt"), parallelism = "clustermq", jobs = 2))
}

DBI::dbDisconnect(db)
rm(cache)
print("Completed OK")
