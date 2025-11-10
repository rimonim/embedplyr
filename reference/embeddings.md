# Embeddings Objects

An embeddings object is a numeric matrix with fast indexing by rownames
(generally tokens).

## Usage

``` r
embeddings(data = NA, nrow = 1, ncol = 1, byrow = FALSE, dimnames = NULL)

as.embeddings(x, ...)

# Default S3 method
as.embeddings(x, ..., rowname_repair = TRUE, rebuild_token_index = TRUE)

# S3 method for class 'data.frame'
as.embeddings(x, id_col = NULL, ..., rowname_repair = TRUE)

is.embeddings(x, ...)
```

## Arguments

- data:

  an optional data vector (including a list or
  [`expression`](https://rdrr.io/r/base/expression.html) vector).
  Non-atomic classed R objects are coerced by
  [`as.vector`](https://rdrr.io/r/base/vector.html) and all attributes
  discarded.

- nrow:

  the desired number of rows.

- ncol:

  the desired number of columns.

- byrow:

  logical. If `FALSE` (the default) the matrix is filled by columns,
  otherwise the matrix is filled by rows.

- dimnames:

  a [`dimnames`](https://rdrr.io/r/base/dimnames.html) attribute for the
  matrix: `NULL` or a `list` of length 2 giving the row and column names
  respectively. An empty list is treated as `NULL`, and a list of length
  one as row names. The list can be named, and the list names will be
  used as names for the dimensions.

- x:

  A data frame to be converted into embeddings.

- ...:

  Additional arguments passed to or from other methods.

- rowname_repair:

  logical. If `TRUE` (the default), check that unique rownames are
  provided, and name rows "doc_1", "doc_2", etc. if not.

- rebuild_token_index:

  logical. If `TRUE`, the hash table index will be rebuilt even when `x`
  is an embeddings object.

- id_col:

  Optional name of a column to take row names from.

## Details

Fast row indexing is implemented using hash tables in native R
environments. The "token_index" attribute of an embeddings object stores
the environment that maps rownames to their corresponding indices.

If `dimnames` is not supplied, `embeddings` will automatically name rows
doc_1, doc_2, etc., and columns dim_1, dim_2, etc.

## Examples

``` r
random_mat <- matrix(
  sample(1:10, 20, replace = TRUE),
  nrow = 2,
  dimnames = list(c("happy", "sad"))
  )
random_embeddings <- as.embeddings(random_mat)
is.embeddings(random_embeddings[,2:5])
#> [1] TRUE

tibble::as_tibble(random_embeddings, rownames = "token")
#> # A tibble: 2 × 11
#>   token dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim_10
#>   <chr> <int> <int> <int> <int> <int> <int> <int> <int> <int>  <int>
#> 1 happy     5     8     7     5     6     2     9     7     6      6
#> 2 sad       5     2     5     2     4     3     6     5     9     10
```
