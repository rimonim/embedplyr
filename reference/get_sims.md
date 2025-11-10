# Row-wise Similarity and Distance Metrics

`get_sims(df, col1:col2, list(sim = vec2))` is essentially equivalent to
`mutate(rowwise(df), sim = cos_sim(c_across(col1:col2), vec2))`.
Includes methods for dataframes (in the style of `dplyr`), embeddings
objects, and matrices.

## Usage

``` r
get_sims(x, ...)

# S3 method for class 'embeddings'
get_sims(
  x,
  y,
  method = c("cosine", "cosine_squished", "euclidean", "minkowski", "dot_prod",
    "anchored"),
  ...
)

# S3 method for class 'data.frame'
get_sims(
  x,
  cols,
  y,
  method = c("cosine", "cosine_squished", "euclidean", "minkowski", "dot_prod",
    "anchored"),
  ...,
  .keep_all = "except.embeddings"
)
```

## Arguments

- x:

  an embeddings object, matrix, or dataframe with one embedding per row

- ...:

  additional parameters to be passed to method function

- y:

  a named list of vectors with the same dimensionality as embeddings
  in x. Each item will result in a column in the output, showing the
  similarity of each embedding in x to the vector specified in y. When
  `method = "anchored"`, each item of y should be a list with named
  vectors `pos` and `neg`.

- method:

  either the name of a method to compute similarity or distance, or a
  function that takes two vectors, `x` and `y`, and outputs a scalar,
  similar to those listed in [Similarity and Distance
  Metrics](https://rimonim.github.io/embedplyr/reference/sim_metrics.md)

- cols:

  tidyselect - columns that contain numeric embedding values

- .keep_all:

  If `TRUE`, all columns from input are retained in output. If `FALSE`,
  only similarity metrics will be included. If `"except.embeddings"`
  (the default), all columns except those used to compute the similarity
  will be retained.

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

- `anchored`: `x` is projected onto the range between two anchor points,
  such that vectors aligned with `pos` are given a score of 1 and those
  aligned with `neg` are given a score of 0. For more on anchored
  vectors, see [Data Science for Psychology: Natural Language, Chapter
  20](https://ds4psych.com/navigating-vectorspace#sec-dimension-projection).

When `method` is a custom function, operations are performed for each
row and may be slow for large inputs.

## Value

A tibble with columns `doc_id`, and similarity metrics. If
`.keep_all = TRUE` or `.keep_all = "except.embeddings"`, the new columns
will appear after existing ones.

## Examples

``` r
valence_embeddings <- emb(glove_twitter_25d, c("good", "bad"))
happy_vec <- emb(glove_twitter_25d, "happy")
sad_vec <- emb(glove_twitter_25d, "sad")

valence_embeddings |>
  get_sims(list(happy = happy_vec))
#> # A tibble: 2 × 2
#>   doc_id happy
#>   <chr>  <dbl>
#> 1 good   0.883
#> 2 bad    0.707
valence_embeddings |>
  get_sims(
    list(happy = list(pos = happy_vec, neg = sad_vec)),
    anchored_sim
    )
#> # A tibble: 2 × 2
#>   doc_id happy
#>   <chr>  <dbl>
#> 1 good   0.601
#> 2 bad    0.106
valence_embeddings |>
  get_sims(
    list(happy = happy_vec),
    method = function(x, y) sum(abs(x - y))
    )
#> # A tibble: 2 × 2
#>   doc_id happy
#>   <chr>  <dbl>
#> 1 good    9.70
#> 2 bad    17.0 

valence_df <- tibble::as_tibble(valence_embeddings, rownames = "token")
valence_df |> get_sims(
  dim_1:dim_25,
  list(happy = happy_vec, sad = sad_vec),
  .keep_all = TRUE
  )
#> # A tibble: 2 × 28
#>   token  dim_1  dim_2   dim_3   dim_4  dim_5 dim_6 dim_7  dim_8  dim_9 dim_10
#>   <chr>  <dbl>  <dbl>   <dbl>   <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>
#> 1 good  -0.544 0.603  -0.145  -0.0234 -0.138 0.601  2.19  0.208 -0.515 -0.231
#> 2 bad    0.414 0.0223  0.0565 -0.0105  0.274 0.713  1.64 -0.112 -0.262  0.108
#> # ℹ 17 more variables: dim_11 <dbl>, dim_12 <dbl>, dim_13 <dbl>, dim_14 <dbl>,
#> #   dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>, dim_18 <dbl>, dim_19 <dbl>,
#> #   dim_20 <dbl>, dim_21 <dbl>, dim_22 <dbl>, dim_23 <dbl>, dim_24 <dbl>,
#> #   dim_25 <dbl>, happy <dbl>, sad <dbl>
```
