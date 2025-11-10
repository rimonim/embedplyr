# Similarity and Distance Between A Matrix and a Vector

These functions are equivalent to calling [vector similarity
metrics](https://rimonim.github.io/embedplyr/reference/sim_metrics.md)
on each row of a matrix, but use matrix operations and are therefore
much faster.

## Usage

``` r
dot_prod_mat_vec(x, y)

cos_sim_mat_vec(x, y)

cos_sim_squished_mat_vec(x, y)

euc_dist_mat_vec(x, y)

minkowski_dist_mat_vec(x, y, p = 1)

anchored_sim_mat_vec(x, pos, neg)
```

## Arguments

- x:

  a numeric matrix or embeddings object

- y:

  a numeric vector of length `ncol(x)`

- p:

  [p-norm](https://en.wikipedia.org/wiki/Lp_space#The_p-norm_in_finite_dimensions)
  used to compute the Minkowski distance

## Value

A named numeric vector of length `nrow(x)`
