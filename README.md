
<!-- README.md is generated from README.Rmd. Please edit that file -->

# about

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/mrjoh3/about/branch/main/graph/badge.svg)](https://app.codecov.io/gh/mrjoh3/about?branch=main)
<!-- badges: end -->

The purpose of about is to read and write metadata. Specifically it can
read the metadata from any webpage and it can write arbitrary metadata
to the `YAML` header of an [Rmarkdown](https://rmarkdown.rstudio.com/)
or [Quarto](https://quarto.org/) file.

## Installation

You can install the development version of about from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mrjoh3/about")
```

## Example

### Reading Metadata from a URL

``` r
library(about)

read_metadata('https://www.w3.org/', output = 'data.frame')
#> # A tibble: 3 × 2
#>   property    content                                                           
#>   <chr>       <chr>                                                             
#> 1 viewport    width=device-width                                                
#> 2 description The World Wide Web Consortium (W3C) is an international community…
#> 3 og:title    World Wide Web Consortium (W3C)
```

### Adding Metadata to the YAML Header

``` r
create_document(
  title = 'My New Quarto with Metadata', 
  .fun = 'quarto', 
  security = 'confidential', 
  categories = c('metadata','create')
)
```

The code above will create a new Quarto file with the following yaml
header:

``` yaml
---
title: My New Quarto with Metadata
format: html
editor: visual
uuid: a5b32d65-cf7a-4d1b-a996-5d22f4d65359
draft: yes
security: confidential
categories:
  - metadata
  - create
---
```
