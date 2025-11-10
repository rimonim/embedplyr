# Reduce the Dimensionality of Embeddings

Includes methods for dataframes (in the style of `dplyr`), embeddings
objects, and matrices.

## Usage

``` r
reduce_dimensionality(x, ...)

# S3 method for class 'data.frame'
reduce_dimensionality(
  x,
  cols,
  reduce_to = NULL,
  center = TRUE,
  scale = FALSE,
  tol = NULL,
  ...,
  custom_rotation = NULL,
  output_rotation = FALSE
)

# S3 method for class 'embeddings'
reduce_dimensionality(
  x,
  reduce_to = NULL,
  center = TRUE,
  scale = FALSE,
  tol = NULL,
  ...,
  custom_rotation = NULL,
  output_rotation = FALSE
)
```

## Arguments

- x:

  an
  [embeddings](https://rimonim.github.io/embedplyr/reference/embeddings.md)
  object or dataframe with one embedding per row, or a list of such
  objects

- ...:

  additional parameters to be passed to class-specific methods

- cols:

  tidyselect - columns that contain numeric embedding values

- reduce_to:

  number of dimensions to keep. The value is passed to
  [`stats::prcomp()`](https://rdrr.io/r/stats/prcomp.html) as `rank.`.

- center:

  logical. Should dimensions be shifted to be centered at zero?

- scale:

  logical. Should dimensions be scaled to have unit variance?

- tol:

  a value indicating a magnitude below which dimensions should be
  omitted. (Components are omitted if their standard deviations are less
  than or equal to tol times the standard deviation of the first
  component.) Value passed to
  [`stats::prcomp()`](https://rdrr.io/r/stats/prcomp.html).

- custom_rotation:

  optional rotation specification obtained by calling the function with
  `output_rotation = TRUE`. This will override `reduce_to`, `center`,
  and `scale`, and instead simply apply the custom rotation.

- output_rotation:

  `TRUE` outputs a rotation specification that can be applied to other
  embeddings

## Details

By default, `reduce_dimensionality()`, performs principle components
analysis (PCA) without column normalization, and outputs the rotated
data. If `center = FALSE` and `scale = FALSE`, this is equivalent to
singular value decomposition (SVD), \\X = U \Sigma V^{T}\\, where the
output columns are equal to the first `reduce_to` columns of \\U
\Sigma\\ that meet the criterion set by `tol`.

## Value

If `output_rotation = FALSE`, an object of the same class as x, with the
same number of rows but fewer columns. Reduced columns in the output
will be named "PC1", "PC2", etc.

If `output_rotation = TRUE`, a list with the following components:

- `rotation`: a rotation matrix

- `center`: a vector describing how much to offset each dimension to
  match the centering of `x`

- `scale`: a vector with the standard deviation of each column of `x`

If `x` is a list, the function will be called recursively and output a
list of the same length.

## Examples

``` r
glove_2d <- reduce_dimensionality(glove_twitter_25d, 2)
glove_2d
#> # 2-dimensional embeddings with 11925 rows
#>      PC1   PC2  
#> the  -3.51  0.93
#> of   -2.90  1.29
#> and  -3.35  1.15
#> to   -3.64  0.77
#> a    -3.77 -1.05
#> in   -3.16  0.37
#> for  -3.09  0.83
#> is   -3.52  0.99
#> on   -3.36  0.00
#> that -3.79  1.92

embeddings_list <- find_nearest(glove_twitter_25d, c("good", "bad"), each = TRUE)
embeddings_list_2d <- reduce_dimensionality(embeddings_list, 2)
embeddings_list_2d
#> $good
#> # 2-dimensional embeddings with 10 rows
#>        PC1   PC2  
#> good   -0.33 -0.02
#> too     0.36  0.78
#> day    -1.15 -1.07
#> well    0.81  0.38
#> nice   -1.04  1.22
#> better  0.85  0.15
#> fun    -1.45  0.07
#> much    0.91  0.21
#> this    0.39 -1.26
#> hope    0.64 -0.46
#> 
#> $bad
#> # 2-dimensional embeddings with 10 rows
#>       PC1   PC2  
#> bad   -0.03 -0.28
#> shit  -1.01  0.06
#> crazy -0.70  0.23
#> but    1.40  0.31
#> hell  -0.95  0.32
#> right  0.43  0.94
#> like   0.13  0.22
#> same   0.71 -1.33
#> damn  -1.12 -0.50
#> thing  1.13  0.03
#> 

library(tibble)
glove_tbl <- as_tibble(glove_twitter_25d, rownames = "token")
glove_tbl_2d <- glove_tbl |> reduce_dimensionality(dim_1:dim_25, 2)
glove_tbl_2d
#> # A tibble: 11,925 × 3
#>    token   PC1      PC2
#>  * <chr> <dbl>    <dbl>
#>  1 the   -3.51  0.926  
#>  2 of    -2.90  1.29   
#>  3 and   -3.35  1.15   
#>  4 to    -3.64  0.773  
#>  5 a     -3.77 -1.05   
#>  6 in    -3.16  0.370  
#>  7 for   -3.09  0.831  
#>  8 is    -3.52  0.987  
#>  9 on    -3.36  0.00238
#> 10 that  -3.79  1.92   
#> # ℹ 11,915 more rows
```
