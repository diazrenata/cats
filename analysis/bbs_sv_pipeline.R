library(MATSS)
library(drake)
library(cats)

expose_imports(cats)

bbs_dats <- build_bbs_datasets_plan(data_subset = NULL)
sv_plan <- drake_plan(
  spab = target(make_spab(dat, datname),
                transform = map(dat=!!rlang::syms(bbs_dats$target),
                                datname = !!bbs_dats$target)),
  s = target(add_singletons_ts(spab_ts = spab),
             transform = map(spab)),
  sv = target(get_statevars_ts(s),
              transform = map(s)),
  all_sv = target(dplyr::bind_rows(sv),
                  transform = combine(sv)))

all <- dplyr::bind_rows(bbs_dats, sv_plan)

## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analysis", "drake", "drake-cache-bbs-sv.sqlite"))
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
       cache_log_file = here::here("analysis", "drake", "cache_log_bbs-sv.txt"),
       verbose = 2,
       parallelism = "clustermq",
       jobs = 20,
       caching = "master",
       memory_strategy = "autoclean") # Important for DBI caches!
} else {
  library(clustermq)
  options(clustermq.scheduler = "multicore")
  # Run the pipeline on multiple local cores
  system.time(make(all, cache = cache, cache_log_file = here::here("analysis", "drake", "cache_log_bbs-sv.txt"), parallelism = "clustermq", jobs = 2))
}

DBI::dbDisconnect(db)
rm(cache)
print("Completed OK")
