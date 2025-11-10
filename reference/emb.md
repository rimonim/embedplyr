# Retrieve Token Embeddings

Retrieve Token Embeddings

## Usage

``` r
emb(x, newdata, drop = TRUE, .keep_missing = FALSE)
```

## Arguments

- x:

  an embeddings object made by
  [`load_embeddings()`](https://rimonim.github.io/embedplyr/reference/load_embeddings.md)
  or
  [`as.embeddings()`](https://rimonim.github.io/embedplyr/reference/embeddings.md)

- newdata:

  a character vector of tokens

- drop:

  logical. If `TRUE` (the default) and the result is one-dimensional
  (e.g. a single row), the output will be a (named) vector.

- .keep_missing:

  logical. What should be done about items in `newdata` that are not
  present in the embeddings object? If `FALSE` (the default), they will
  be ignored. If `TRUE`, they will be returned as `NA`.

## Details

Duplicated items in `newdata` will result in duplicated rows in the
output. If an item in `newdata` matches multiple rows in `x`, the last
one will be returned.

## Value

Either an embeddings object with a row for each item in `newdata`, or,
when `newdata` is of length 1, a named numeric vector.

## Examples

``` r
words <- c("happy", "sad")

texts_embeddings <- emb(glove_twitter_25d, words)
texts_embeddings
#> # 25-dimensional embeddings with 2 rows
#>       dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
#> happy -1.23  0.48  0.14 -0.03 -0.65 -0.19  2.10  1.75 -1.30 -0.32 ...  
#> sad    0.04 -0.19  0.44 -0.15 -0.60  0.05  1.47  0.14 -0.72  0.43 ...  
```
