# Parallel Similarity and Distance

These functions compute parallel [similarity
metrics](https://rimonim.github.io/embedplyr/reference/sim_metrics.md)
between each row of a matrix and its corresponding row in another
matrix.

## Usage

``` r
dot_prod_parallel(x, y)

cos_sim_parallel(x, y)

cos_sim_squished_parallel(x, y)

euc_dist_parallel(x, y)

minkowski_dist_parallel(x, y, p = 1)
```

## Arguments

- x:

  a numeric matrix or embeddings object

- y:

  a numeric matrix or embeddings object with the same dimensions as `x`

- p:

  [p-norm](https://en.wikipedia.org/wiki/Lp_space#The_p-norm_in_finite_dimensions)
  used to compute the Minkowski distance

## Value

A named numeric vector of length `nrow(x)`
