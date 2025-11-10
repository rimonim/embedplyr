# Similarity and Distance Matrices

These functions compute pairwise [similarity
metrics](https://rimonim.github.io/embedplyr/reference/sim_metrics.md)
between each row of a matrix.

## Usage

``` r
dot_prod_matrix(x, tidy_output = FALSE)

cos_sim_matrix(x, tidy_output = FALSE)

cos_sim_squished_matrix(x, tidy_output = FALSE)

euc_dist_matrix(x, tidy_output = FALSE)

minkowski_dist_matrix(x, p = 1, tidy_output = FALSE)
```

## Arguments

- x:

  a numeric matrix or embeddings object

- tidy_output:

  logical. If `FALSE` (the default), output a
  [stats::dist](https://rdrr.io/r/stats/dist.html) object. If `TRUE`,
  output a tibble with columns `doc_id_1`, `doc_id_2`, and the
  similarity or distance metric.

- p:

  [p-norm](https://en.wikipedia.org/wiki/Lp_space#The_p-norm_in_finite_dimensions)
  used to compute the Minkowski distance

## Value

A named numeric vector of length `nrow(x)`
