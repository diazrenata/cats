SV report
================

Nsamples
--------

The maximum number of samples is 2500.

The minimum number of samples is 1.

![](mcdb_report_files/figure-markdown_github/show%20nsamples-1.png)

There's a considerable region of fewer than 2500 samples achieved. I think to have any confidence in results, we need to at least filter out those with fewer than 500.

Ntimesteps
----------

The maximum number of timesteps is 29.

The minimum number of timesteps is 1.

There are 671 sites with just one timestep. Removing those for this plot:

![](mcdb_report_files/figure-markdown_github/show%20ntimesteps-1.png)

The vast majority of the TS sites have fewer than 5 time steps. The one that doesn't is Portal.

![](mcdb_report_files/figure-markdown_github/plot%20ts-1.png)![](mcdb_report_files/figure-markdown_github/plot%20ts-2.png)
