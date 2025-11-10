# Pairwise Similarity or Distance Matrix

Calculate a matrix of similarity scores between the rows of the input.

## Usage

``` r
sim_matrix(x, ...)

# S3 method for class 'data.frame'
sim_matrix(
  x,
  cols,
  method = c("cosine", "cosine_squished", "euclidean", "minkowski", "dot_prod",
    "anchored"),
  ...,
  tidy_output = FALSE
)
```

## Arguments

- x:

  an embeddings object, matrix, or dataframe with one embedding per row

- ...:

  additional parameters to be passed to method function

- cols:

  tidyselect - columns that contain numeric embedding values

- method:

  either the name of a method to compute similarity or distance, or a
  function that takes two vectors, `x` and `y`, and outputs a scalar,
  similar to those listed in [Similarity and Distance
  Metrics](https://rimonim.github.io/embedplyr/reference/sim_metrics.md)

- tidy_output:

  logical. If `FALSE` (the default), output a
  [stats::dist](https://rdrr.io/r/stats/dist.html) object. If `TRUE`,
  output a tibble with columns `doc_id_1`, `doc_id_2`, and the
  similarity or distance metric.

## Details

### Available Methods

When `method` is the name of one of the following supported methods,
computations are done with matrix operations and are therefore blazing
fast.

- `cosine`: cosine similarity

- `cosine_squished`: cosine similarity, rescaled to range from 0 to 1

- `euclidean`: Euclidean distance

- `minkowski`: Minkowski distance; requires parameter `p`. When `p = 1`
  (the default), this is the Manhattan distance. When `p = 2`, it is the
  Euclidean distance. When `p = Inf`, it is the Chebyshev distance.

- `dot_prod`: Dot product

When `method` is a custom function, operations are performed for each
row and may be slow for large inputs.

## Value

If `tidy_output = FALSE` (the default), a
[stats::dist](https://rdrr.io/r/stats/dist.html) object. If
`tidy_output = TRUE`, a tibble with columns `doc_id_1`, `doc_id_2`, and
the similarity or distance metric.

## Examples

``` r
emb <- emb(glove_twitter_25d, c("table", "chair", "cat"))

sim_matrix(emb)
#>           table     chair
#> chair 0.8680218          
#> cat   0.7297673 0.7455769
sim_matrix(emb, method = "euclidean")
#>          table    chair
#> chair 2.421414         
#> cat   3.300149 3.286518
sim_matrix(emb, method = function(x, y) sum(abs(x - y)))
#>          table    chair
#> chair 10.33815         
#> cat   13.02696 13.05754

valence_df <- tibble::as_tibble(emb, rownames = "token")
valence_df |> sim_matrix(dim_1:dim_25, tidy_output = TRUE)
#> # A tibble: 3 × 3
#>   doc_id_1 doc_id_2 cosine   
#>      <int>    <int> <dist>   
#> 1        1        2 0.8680218
#> 2        1        3 0.7297673
#> 3        2        3 0.7455769
```
