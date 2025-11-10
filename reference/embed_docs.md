# Get Text Embeddings by Averaging Word Embeddings

`textstat_embedding()` takes a 'quanteda'
[dfm](https://quanteda.io/reference/dfm.html). `embed_docs()` is a more
versatile function for which acts directly on either a character vector
or a column of texts in a dataframe.

## Usage

``` r
embed_docs(x, ...)

# Default S3 method
embed_docs(
  x,
  model,
  w = NULL,
  method = "mean",
  ...,
  tolower = TRUE,
  output_embeddings = FALSE
)

# S3 method for class 'data.frame'
embed_docs(
  x,
  text_col,
  model,
  id_col = NULL,
  w = NULL,
  method = "mean",
  ...,
  .keep_all = FALSE,
  tolower = TRUE,
  output_embeddings = FALSE
)

textstat_embedding(
  dfm,
  model,
  w = NULL,
  method = "mean",
  output_embeddings = FALSE
)
```

## Arguments

- x:

  a character vector, a data frame, or data frame extension (e.g. a
  tibble)

- ...:

  additional parameters to pass to
  [`quanteda::tokens()`](https://quanteda.io/reference/tokens.html) or
  to the user-specified modeling function

- model:

  an
  [embeddings](https://rimonim.github.io/embedplyr/reference/embeddings.md)
  object. For `embed_docs()`, `model` can alternatively be a function
  that takes a character vector and outputs a dataframe with a row for
  each element of the input.

- w:

  optional weighting for embeddings in `model` if `model` is an
  embeddings object. See
  [`average_embedding()`](https://rimonim.github.io/embedplyr/reference/average_embedding.md).

- method:

  method to use for averaging. See
  [`average_embedding()`](https://rimonim.github.io/embedplyr/reference/average_embedding.md).
  Note that `method = "median"` does not use matrix operations and may
  therefore be slow for datasets with many documents.

- tolower:

  logical. Convert all text to lowercase? If `model` is an embeddings
  object, this value is passed to
  [`quanteda::dfm()`](https://quanteda.io/reference/dfm.html).

- output_embeddings:

  `FALSE` (the default) returns a tibble. `TRUE` returns an embeddings
  object. See 'Value' for details.

- text_col:

  string. a column of texts for which to compute embeddings

- id_col:

  optional string. column of unique document ids

- .keep_all:

  logical. Keep all columns from input? Ignored if
  `output_embeddings = TRUE`.

- dfm:

  a quanteda [dfm](https://quanteda.io/reference/dfm.html)

## Value

If `output_embeddings = FALSE`, a tibble with columns `doc_id`, and
`dim_1`, `dim_2`, etc. or similar. If `.keep_all = TRUE`, the new
columns will appear after existing ones. If `output_embeddings = TRUE`,
an embeddings object with document ids as rownames.

## See also

[`embed_tokens()`](https://rimonim.github.io/embedplyr/reference/embed_tokens.md)

## Examples

``` r
texts <- c("this says one thing", "and this says another")
texts_embeddings <- embed_docs(texts, glove_twitter_25d)
texts_embeddings
#> # A tibble: 2 × 26
#>   doc_id  dim_1 dim_2  dim_3  dim_4   dim_5  dim_6 dim_7  dim_8   dim_9  dim_10
#>   <chr>   <dbl> <dbl>  <dbl>  <dbl>   <dbl>  <dbl> <dbl>  <dbl>   <dbl>   <dbl>
#> 1 text1   0.114 0.167 0.180  -0.144 -0.0492 -0.465  1.77 -0.161 -0.414  -0.0989
#> 2 text2  -0.289 0.297 0.0145 -0.108 -0.248  -0.495  1.58 -0.234 -0.0946 -0.177 
#> # ℹ 15 more variables: dim_11 <dbl>, dim_12 <dbl>, dim_13 <dbl>, dim_14 <dbl>,
#> #   dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>, dim_18 <dbl>, dim_19 <dbl>,
#> #   dim_20 <dbl>, dim_21 <dbl>, dim_22 <dbl>, dim_23 <dbl>, dim_24 <dbl>,
#> #   dim_25 <dbl>

# quanteda workflow
library(quanteda)
#> Package version: 4.3.1
#> Unicode version: 15.1
#> ICU version: 74.2
#> Parallel computing: disabled
#> See https://quanteda.io for tutorials and examples.
texts_dfm <- dfm(tokens(texts))

texts_embeddings <- textstat_embedding(texts_dfm, glove_twitter_25d)
texts_embeddings
#> # A tibble: 2 × 26
#>   doc_id  dim_1 dim_2  dim_3  dim_4   dim_5  dim_6 dim_7  dim_8   dim_9  dim_10
#>   <chr>   <dbl> <dbl>  <dbl>  <dbl>   <dbl>  <dbl> <dbl>  <dbl>   <dbl>   <dbl>
#> 1 text1   0.114 0.167 0.180  -0.144 -0.0492 -0.465  1.77 -0.161 -0.414  -0.0989
#> 2 text2  -0.289 0.297 0.0145 -0.108 -0.248  -0.495  1.58 -0.234 -0.0946 -0.177 
#> # ℹ 15 more variables: dim_11 <dbl>, dim_12 <dbl>, dim_13 <dbl>, dim_14 <dbl>,
#> #   dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>, dim_18 <dbl>, dim_19 <dbl>,
#> #   dim_20 <dbl>, dim_21 <dbl>, dim_22 <dbl>, dim_23 <dbl>, dim_24 <dbl>,
#> #   dim_25 <dbl>

# dplyr workflow
texts_df <- data.frame(text = texts)
texts_embeddings <- texts_df |> embed_docs("text", glove_twitter_25d)
texts_embeddings
#> # A tibble: 2 × 26
#>   doc_id  dim_1 dim_2  dim_3  dim_4   dim_5  dim_6 dim_7  dim_8   dim_9  dim_10
#>   <chr>   <dbl> <dbl>  <dbl>  <dbl>   <dbl>  <dbl> <dbl>  <dbl>   <dbl>   <dbl>
#> 1 text1   0.114 0.167 0.180  -0.144 -0.0492 -0.465  1.77 -0.161 -0.414  -0.0989
#> 2 text2  -0.289 0.297 0.0145 -0.108 -0.248  -0.495  1.58 -0.234 -0.0946 -0.177 
#> # ℹ 15 more variables: dim_11 <dbl>, dim_12 <dbl>, dim_13 <dbl>, dim_14 <dbl>,
#> #   dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>, dim_18 <dbl>, dim_19 <dbl>,
#> #   dim_20 <dbl>, dim_21 <dbl>, dim_22 <dbl>, dim_23 <dbl>, dim_24 <dbl>,
#> #   dim_25 <dbl>
```
