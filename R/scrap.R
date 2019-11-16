ds <- MATSS::build_bbs_datasets_plan(data_subset = c(1, 410, 1977))
ds$target

d1 <- MATSS::get_bbs_route_region_data(route = 1, region = 11)
d2 <- MATSS::get_bbs_route_region_data(route = 268, region = 8)
d3 <- MATSS::get_bbs_route_region_data(route = 314, region = 27)

inst_path = file.path(system.file(package= "cats"), "toy_bbs_data")

saveRDS(d1, file.path(inst_path, paste0("route", 1, "_region", 11, ".Rds")))
