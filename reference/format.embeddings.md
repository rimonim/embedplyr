# Formatting and Printing for Embeddings Objects

Since the numerical content of embeddings is generally not very
informative to the naked eye, the default formatting of matrices is
often cumbersome. As such, embeddings objects print in a format that
allows quick visualization of dimensionality and row names.

## Usage

``` r
# S3 method for class 'embeddings'
format(x, ..., n = NULL, round = 2L)
```

## Arguments

- x:

  the embeddings object to be formatted

- ...:

  arguments to be passed to methods

- n:

  integer. How many rows should be printed? Defaults to 10. This value
  can be permanently customized by setting
  `options(embeddings.print.n = n)`.

- round:

  integer. the number of decimal places to be displayed

## Examples

``` r
print(glove_twitter_25d, n = 5)
#> # 25-dimensional embeddings with 11925 rows
#>     dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
#> the -0.01  0.02  0.21  0.17 -0.44 -0.15  1.84 -0.16  0.18 -0.32 ...  
#> of   0.33 -0.09 -0.15  0.43 -0.09 -0.18  1.28 -0.60 -0.28 -0.05 ...  
#> and -0.81 -0.29  0.06 -0.04 -0.61 -0.16  1.62 -0.43  0.20 -0.19 ...  
#> to   0.28  0.02  0.12 -0.39 -1.05 -0.54  1.14 -0.34  0.81 -0.47 ...  
#> a    0.21  0.31  0.18  0.87  0.07  0.59 -0.10  1.59 -0.43 -1.37 ...  
```
