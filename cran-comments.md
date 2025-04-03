
## Resubmission (3º)

**Reviewer**: 
  Please add \value to .Rd files regarding exported methods and explain
  the functions results in the documentation. Please write about the
  structure of the output (class) and also what the output means.
**Response**: 
  \value tags were added to .Rd files using the @returns tag using roxygen2
  to render .Rd files.

**Reviewer**:
  \dontrun{} should only be used if the example really cannot be executed
  (e.g. because of missing additional software, missing API keys, ...) by
  the user. That's why wrapping examples in \dontrun{} adds the comment
  ("# Not run:") as a warning for the user. Does not seem necessary.
  Please replace \dontrun with \donttest.
  
  Please unwrap the examples if they are executable in < 5 sec, or replace
  dontrun{} with \donttest{}.
**Response**: 
  Examples in boot_RRi_parameters.R were changed from \dontrun with \donttest
  as suggested.

#> ── R CMD check results  CardioCurveR 1.0───
#> Duration: 35.4s
#> 
#> 0 errors ✔ | 0 warnings ✔ | 0 notes ✔
#> 
#> R CMD check succeeded

#> sessionInfo()
#> R version 4.4.1 (2024-06-14)
#> Platform: aarch64-apple-darwin20
#> Running under: macOS Sonoma 14.5
#> 
#> Matrix products: default
#> BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib 
#> LAPACK: /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.0
#> 
#> locale:
#> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
#> 
#> time zone: America/Punta_Arenas
#> tzcode source: internal
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] CardioCurveR_1.0.0 usethis_3.1.0     
#> 
#> loaded via a namespace (and not attached):
#>  [1] R6_2.5.1          signal_1.8-1      tidyselect_1.2.1  magrittr_2.0.3    gtable_0.3.6     
#>  [6] glue_1.8.0        gridExtra_2.3     tibble_3.2.1      pkgconfig_2.0.3   generics_0.1.3   
#> [11] dplyr_1.1.4       lifecycle_1.0.4   ggplot2_3.5.1     cli_3.6.3         scales_1.3.0     
#> [16] grid_4.4.1        vctrs_0.6.5       data.table_1.16.4 rsconnect_1.3.3   compiler_4.4.1   
#> [21] purrr_1.0.2       rstudioapi_0.17.1 tools_4.4.1       pillar_1.10.1     munsell_0.5.1    
#> [26] colorspace_2.1-1  rlang_1.1.4       fs_1.6.5          MASS_7.3-63 
