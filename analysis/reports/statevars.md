SV report
================

Maxima
------

``` r
sv_maxima <- all_sv %>%
  group_by(site, singletons) %>%
  summarize(max_s0 = max(s0),
            max_n0 = max(n0)) %>%
  ungroup()

maxima_plot <- ggplot(data = sv_maxima, aes(x = max_s0, y = max_n0, color = site)) + 
  geom_point() +
  theme_bw() + 
  xlim(0, max(all_sv$s0) + 5) +
  ylim(0, max(all_sv$n0) + 5) +
  scale_color_viridis_d(end =.9) +
  facet_wrap(vars(singletons)) +
  theme(legend.position = "none")
  
maxima_plot
```

![](statevars_files/figure-markdown_github/plot%20maxima-1.png)

``` r
print(max(sv_maxima$max_s0))
```

    ## [1] 179

``` r
print(max(sv_maxima$max_n0))
```

    ## [1] 9248
