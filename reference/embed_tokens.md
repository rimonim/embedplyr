# Get Embeddings of Tokens in a Text or Corpus

Given a character vector or 'quanteda' object
([tokens](https://quanteda.io/reference/tokens.html),
[dfm](https://quanteda.io/reference/dfm.html), or
[corpus](https://quanteda.io/reference/corpus.html)) and a word
embeddings model in the form of an
[embeddings](https://rimonim.github.io/embedplyr/reference/embeddings.md)
object, `embed_tokens()` returns the embedding for each token.

## Usage

``` r
embed_tokens(x, ...)

# Default S3 method
embed_tokens(
  x,
  model,
  ...,
  .keep_missing = FALSE,
  tolower = TRUE,
  output_embeddings = FALSE
)

# S3 method for class 'data.frame'
embed_tokens(
  x,
  text_col,
  model,
  id_col = NULL,
  ...,
  .keep_missing = FALSE,
  .keep_all = FALSE,
  tolower = TRUE,
  output_embeddings = FALSE
)
```

## Arguments

- x:

  a character vector of texts, a data frame, a 'quanteda'
  [tokens](https://quanteda.io/reference/tokens.html) object, or a
  'quanteda' [corpus](https://quanteda.io/reference/corpus.html)

- ...:

  additional parameters to pass to
  [`quanteda::tokens()`](https://quanteda.io/reference/tokens.html)

- model:

  a word embeddings model in the form of an
  [embeddings](https://rimonim.github.io/embedplyr/reference/embeddings.md)
  object

- .keep_missing:

  logical. What should be done about tokens in `x` that are not present
  in `model`? If `FALSE` (the default), they will be ignored. If `TRUE`,
  they will be returned as `NA`.

- tolower:

  logical. Convert all text to lowercase?

- output_embeddings:

  `FALSE` (the default) returns a tibble. `TRUE` returns a list of
  embeddings objects. See 'Value' for details.

- text_col:

  string. a column of texts to be tokenized and converted to embeddings

- id_col:

  optional string. column of unique document ids

- .keep_all:

  logical. Keep all columns from input? Ignored if
  `output_embeddings = TRUE`.

## Value

If `output_embeddings = FALSE`, a tibble with columns `doc_id`, `token`,
and embedding dimension names. If `.keep_all = TRUE`, the new columns
will appear after existing ones, and the class of the input will be
maintained. If `output_embeddings = TRUE`, a named list of embeddings
objects with tokens as rownames.

## See also

[`embed_docs()`](https://rimonim.github.io/embedplyr/reference/embed_docs.md)

## Examples

``` r
texts <- c("this says one thing", "and this says another")
texts_token_embeddings <- embed_tokens(texts, glove_twitter_25d)
texts_token_embeddings
#> # A tibble: 8 × 27
#>   doc_id token     dim_1   dim_2    dim_3   dim_4   dim_5   dim_6 dim_7  dim_8
#>   <chr>  <chr>     <dbl>   <dbl>    <dbl>   <dbl>   <dbl>   <dbl> <dbl>  <dbl>
#> 1 text1  this    -0.179   0.384   0.0730  -0.324  -0.0924 -0.408  2.1   -0.114
#> 2 text1  says     0.0671  0.149  -0.0720  -0.278  -0.379  -1.40   0.968 -0.250
#> 3 text1  one      0.397   0.157   0.507   -0.0400 -0.118  -0.0116 1.77   0.335
#> 4 text1  thing    0.170  -0.0206  0.212    0.0643  0.392  -0.0448 2.23  -0.615
#> 5 text2  and     -0.812  -0.286   0.0625  -0.0369 -0.611  -0.156  1.62  -0.426
#> 6 text2  this    -0.179   0.384   0.0730  -0.324  -0.0924 -0.408  2.1   -0.114
#> 7 text2  says     0.0671  0.149  -0.0720  -0.278  -0.379  -1.40   0.968 -0.250
#> 8 text2  another -0.232   0.942  -0.00565  0.205   0.0913 -0.0198 1.63  -0.147
#> # ℹ 17 more variables: dim_9 <dbl>, dim_10 <dbl>, dim_11 <dbl>, dim_12 <dbl>,
#> #   dim_13 <dbl>, dim_14 <dbl>, dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>,
#> #   dim_18 <dbl>, dim_19 <dbl>, dim_20 <dbl>, dim_21 <dbl>, dim_22 <dbl>,
#> #   dim_23 <dbl>, dim_24 <dbl>, dim_25 <dbl>

# quanteda workflow
library(quanteda)
texts_tokens <- tokens(texts)
texts_token_embeddings <- embed_tokens(texts_tokens, glove_twitter_25d)
texts_token_embeddings
#> # A tibble: 8 × 27
#>   doc_id token     dim_1   dim_2    dim_3   dim_4   dim_5   dim_6 dim_7  dim_8
#>   <chr>  <chr>     <dbl>   <dbl>    <dbl>   <dbl>   <dbl>   <dbl> <dbl>  <dbl>
#> 1 text1  this    -0.179   0.384   0.0730  -0.324  -0.0924 -0.408  2.1   -0.114
#> 2 text1  says     0.0671  0.149  -0.0720  -0.278  -0.379  -1.40   0.968 -0.250
#> 3 text1  one      0.397   0.157   0.507   -0.0400 -0.118  -0.0116 1.77   0.335
#> 4 text1  thing    0.170  -0.0206  0.212    0.0643  0.392  -0.0448 2.23  -0.615
#> 5 text2  and     -0.812  -0.286   0.0625  -0.0369 -0.611  -0.156  1.62  -0.426
#> 6 text2  this    -0.179   0.384   0.0730  -0.324  -0.0924 -0.408  2.1   -0.114
#> 7 text2  says     0.0671  0.149  -0.0720  -0.278  -0.379  -1.40   0.968 -0.250
#> 8 text2  another -0.232   0.942  -0.00565  0.205   0.0913 -0.0198 1.63  -0.147
#> # ℹ 17 more variables: dim_9 <dbl>, dim_10 <dbl>, dim_11 <dbl>, dim_12 <dbl>,
#> #   dim_13 <dbl>, dim_14 <dbl>, dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>,
#> #   dim_18 <dbl>, dim_19 <dbl>, dim_20 <dbl>, dim_21 <dbl>, dim_22 <dbl>,
#> #   dim_23 <dbl>, dim_24 <dbl>, dim_25 <dbl>

# dplyr workflow
texts_df <- data.frame(text = texts)
texts_token_embeddings <- texts_df |> embed_tokens("text", glove_twitter_25d)
texts_token_embeddings
#> # A tibble: 8 × 27
#>   doc_id token     dim_1   dim_2    dim_3   dim_4   dim_5   dim_6 dim_7  dim_8
#>   <chr>  <chr>     <dbl>   <dbl>    <dbl>   <dbl>   <dbl>   <dbl> <dbl>  <dbl>
#> 1 text1  this    -0.179   0.384   0.0730  -0.324  -0.0924 -0.408  2.1   -0.114
#> 2 text1  says     0.0671  0.149  -0.0720  -0.278  -0.379  -1.40   0.968 -0.250
#> 3 text1  one      0.397   0.157   0.507   -0.0400 -0.118  -0.0116 1.77   0.335
#> 4 text1  thing    0.170  -0.0206  0.212    0.0643  0.392  -0.0448 2.23  -0.615
#> 5 text2  and     -0.812  -0.286   0.0625  -0.0369 -0.611  -0.156  1.62  -0.426
#> 6 text2  this    -0.179   0.384   0.0730  -0.324  -0.0924 -0.408  2.1   -0.114
#> 7 text2  says     0.0671  0.149  -0.0720  -0.278  -0.379  -1.40   0.968 -0.250
#> 8 text2  another -0.232   0.942  -0.00565  0.205   0.0913 -0.0198 1.63  -0.147
#> # ℹ 17 more variables: dim_9 <dbl>, dim_10 <dbl>, dim_11 <dbl>, dim_12 <dbl>,
#> #   dim_13 <dbl>, dim_14 <dbl>, dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>,
#> #   dim_18 <dbl>, dim_19 <dbl>, dim_20 <dbl>, dim_21 <dbl>, dim_22 <dbl>,
#> #   dim_23 <dbl>, dim_24 <dbl>, dim_25 <dbl>
```
