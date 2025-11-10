# Extract or Subset Parts of Embeddings Objects

Extraction, replacement, and subsetting nearly identically matches the
behavior of matrices, with one exception: If a character item in `i`
matches multiple rownames in `x`, the *last* match will be returned.

## Usage

``` r
# S3 method for class 'embeddings'
x[i, j, drop = TRUE]

# S3 method for class 'embeddings'
x[i, j] <- value

# S3 method for class 'embeddings'
subset(x, subset, ...)
```

## Arguments

- x:

  object to be subsetted.

- i:

  row index or indices to extract or replace. Can be `numeric` or
  `character`.

- j:

  column index or indeces to extract or replace. Can be `numeric` or
  `character`.

- drop:

  logical. If `TRUE` (the default) and the result is one-dimensional
  (e.g. a single row), the output will be a (named) vector.

- value:

  typically a numeric vector, matrix, or embeddings object.

- subset:

  logical expression indicating elements or rows to keep: missing values
  are taken as false.

- ...:

  further arguments to be passed to or from other methods.

## Details

The difference between `embeddings[i,]` and
[`emb(embeddings, i)`](https://rimonim.github.io/embedplyr/reference/emb.md)
is that the former will throw an error when items of `i` are not valid
indices, whereas the latter will handle it gracefully (at the cost of a
few more milliseconds if `i` is long).

## Examples

``` r
glove_twitter_25d["this",]
#>     dim_1     dim_2     dim_3     dim_4     dim_5     dim_6     dim_7     dim_8 
#> -0.178950  0.384060  0.073035 -0.323630 -0.092441 -0.407670  2.100000 -0.113630 
#>     dim_9    dim_10    dim_11    dim_12    dim_13    dim_14    dim_15    dim_16 
#> -0.587840 -0.170340 -0.643300  0.723880 -5.783900 -0.104060  0.521520 -0.113140 
#>    dim_17    dim_18    dim_19    dim_20    dim_21    dim_22    dim_23    dim_24 
#>  0.595540 -0.475870 -0.455100  0.084431 -0.458200 -0.167270  0.545940  0.035478 
#>    dim_25 
#> -0.160730 
glove_twitter_25d[c("this", "that"),]
#> # 25-dimensional embeddings with 2 rows
#>      dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
#> this -0.18  0.38  0.07 -0.32 -0.09 -0.41  2.10 -0.11 -0.59 -0.17 ...  
#> that  0.21  0.22 -0.07  0.24 -0.36 -0.23  1.86 -0.46 -0.41 -0.06 ...  

glove_twitter_25d[1,]
#>      dim_1      dim_2      dim_3      dim_4      dim_5      dim_6      dim_7 
#> -0.0101670  0.0201940  0.2147300  0.1728900 -0.4365900 -0.1468700  1.8429000 
#>      dim_8      dim_9     dim_10     dim_11     dim_12     dim_13     dim_14 
#> -0.1575300  0.1818700 -0.3178200  0.0683900  0.5177600 -6.3371000  0.4806600 
#>     dim_15     dim_16     dim_17     dim_18     dim_19     dim_20     dim_21 
#>  0.1377700 -0.4856800  0.3900000 -0.0019506 -0.1021800  0.2126200 -0.8614600 
#>     dim_22     dim_23     dim_24     dim_25 
#>  0.1726300  0.1878300 -0.8425000 -0.3120800 
glove_twitter_25d[1:10,]
#> # 25-dimensional embeddings with 10 rows
#>      dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
#> the  -0.01  0.02  0.21  0.17 -0.44 -0.15  1.84 -0.16  0.18 -0.32 ...  
#> of    0.33 -0.09 -0.15  0.43 -0.09 -0.18  1.28 -0.60 -0.28 -0.05 ...  
#> and  -0.81 -0.29  0.06 -0.04 -0.61 -0.16  1.62 -0.43  0.20 -0.19 ...  
#> to    0.28  0.02  0.12 -0.39 -1.05 -0.54  1.14 -0.34  0.81 -0.47 ...  
#> a     0.21  0.31  0.18  0.87  0.07  0.59 -0.10  1.59 -0.43 -1.37 ...  
#> in   -0.33 -0.16  0.11 -0.40 -0.49 -0.18  0.23 -0.49 -0.07  0.84 ...  
#> for  -0.22  0.45 -0.23 -0.28 -0.07 -0.64  1.12 -0.38  0.19 -0.51 ...  
#> is   -0.13 -0.20 -0.13 -0.57 -0.30 -0.03  1.18 -0.15 -0.71 -0.12 ...  
#> on    0.21 -0.24 -0.57  0.34 -0.86 -0.18  0.87 -0.11  0.53 -0.00 ...  
#> that  0.21  0.22 -0.07  0.24 -0.36 -0.23  1.86 -0.46 -0.41 -0.06 ...  

glove_twitter_25d[1]
#> [1] -0.010167
glove_twitter_25d[1,1:10]
#>     dim_1     dim_2     dim_3     dim_4     dim_5     dim_6     dim_7     dim_8 
#> -0.010167  0.020194  0.214730  0.172890 -0.436590 -0.146870  1.842900 -0.157530 
#>     dim_9    dim_10 
#>  0.181870 -0.317820 

duplicate_tokens <- embeddings(
  1:15,
  nrow = 3,
  dimnames = list(c("this", "that", "this"))
  )
duplicate_tokens["this",]
#> dim_1 dim_2 dim_3 dim_4 dim_5 
#>     3     6     9    12    15 
```
