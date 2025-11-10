# Compare Two Embedding Models

Given two alternative embeddings of a set of tokens or documents,
`total_dist()` computes a global metric of the distance between the
alternatives (by default the Wasserstein distance).

## Usage

``` r
total_dist(
  x,
  y,
  matching = NULL,
  method = c("euclidean", "minkowski", "cosine", "cosine_squished", "dot_prod"),
  average = FALSE,
  se = FALSE,
  ...
)

average_sim(
  x,
  y,
  matching = NULL,
  method = "cosine",
  average = TRUE,
  se = FALSE,
  ...
)
```

## Arguments

- x:

  an embeddings object

- y:

  an embeddings object. If `matching = NULL`, `y` must contain at least
  a few rownames matching those of `x`.

- matching:

  (optional) a named character vector specifying a one-to-one matching
  between rownames of `x` (names) and rownames of `y` (values)

- method:

  either the name of a method to compute similarity or distance, or a
  function that takes two vectors, `x` and `y`, and outputs a scalar,
  similar to those listed in [Similarity and Distance
  Metrics](https://rimonim.github.io/embedplyr/reference/sim_metrics.md)

- average:

  logical. Should the rowwise distances be averaged as opposed to
  summed?

- se:

  logical. If true, return the standard error as an attribute.

- ...:

  additional parameters to be passed to method function

## Details

`total_dist()` computes the distance or similarity between the
embeddings in `x` and their direct counterparts in `y`. `average = TRUE`
returns the mean of these values, while `average = FALSE` (the default)
returns the sum.

For more information on available methods, see
[`get_sims()`](https://rimonim.github.io/embedplyr/reference/get_sims.md).

`method = "euclidean"` and `average = FALSE` (the default for
`total_dist()`) results in the [Wasserstein
distance](https://en.wikipedia.org/wiki/Wasserstein_metric), if
embeddings are taken as equally weighted point masses.

`average_sim()` is identical to `total_dist()`, but with different
defaults.
