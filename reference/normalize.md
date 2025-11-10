# Scale Embeddings to the Unit Hypersphere

Normalize embeddings such that their magnitude is 1, while their angle
from the origin is unchanged.

## Usage

``` r
normalize(x, ...)

# S3 method for class 'numeric'
normalize(x, ...)

normalize_rows(x, ...)

# Default S3 method
normalize_rows(x, ...)

# S3 method for class 'data.frame'
normalize_rows(x, cols, ...)
```

## Arguments

- x:

  for `normalize()`, a numeric vector, embeddings object, or list of
  numeric or embeddings objects. For `normalize_rows()`, a matrix or
  dataframe with one embedding per row.

- ...:

  additional parameters to be passed to methods

- cols:

  tidyselect - columns that contain numeric embedding values

## Value

An object of the same class and dimensionality as x

## Examples

``` r
vec <- c(1, 4, 2)
normalize(vec)
#> [1] 0.2182179 0.8728716 0.4364358

valence_embeddings <- emb(glove_twitter_25d, c("good", "bad"))
normalize(valence_embeddings)
#> # 25-dimensional embeddings with 2 rows
#>      dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
#> good -0.09  0.10 -0.02 -0.00 -0.02  0.10  0.36  0.03 -0.09 -0.04 ...  
#> bad   0.08  0.00  0.01 -0.00  0.05  0.13  0.31 -0.02 -0.05  0.02 ...  

embeddings_list <- find_nearest(glove_twitter_25d, c("good", "bad"), each = TRUE)
normalize(embeddings_list)
#> $good
#> # 25-dimensional embeddings with 10 rows
#>        dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
#> good   -0.09  0.10 -0.02 -0.00 -0.02  0.10  0.36  0.03 -0.09 -0.04 ...  
#> too    -0.08  0.07  0.02 -0.00 -0.04  0.08  0.29  0.01 -0.13  0.01 ...  
#> day    -0.16  0.09  0.06 -0.07 -0.01 -0.03  0.39  0.04 -0.08 -0.03 ...  
#> well   -0.01  0.04 -0.02 -0.11 -0.12  0.03  0.29 -0.05 -0.14  0.02 ...  
#> nice   -0.15 -0.02 -0.01 -0.03  0.03  0.19  0.26  0.00 -0.17  0.02 ...  
#> better -0.02  0.12 -0.02 -0.05 -0.06  0.11  0.27 -0.04 -0.06 -0.07 ...  
#> fun    -0.13  0.10  0.03 -0.10  0.06  0.15  0.41 -0.03 -0.10 -0.00 ...  
#> much   -0.04  0.03 -0.04  0.02 -0.06  0.03  0.31 -0.03 -0.25 -0.02 ...  
#> this   -0.03  0.06  0.01 -0.05 -0.01 -0.06  0.33 -0.02 -0.09 -0.03 ...  
#> hope   -0.14  0.14  0.00 -0.04 -0.23 -0.06  0.32  0.03 -0.15 -0.04 ...  
#> 
#> $bad
#> # 25-dimensional embeddings with 10 rows
#>       dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
#> bad    0.08  0.00  0.01 -0.00  0.05  0.13  0.31 -0.02 -0.05  0.02 ...  
#> shit   0.11  0.12  0.07  0.02  0.05  0.11  0.20 -0.04 -0.11  0.07 ...  
#> crazy -0.02  0.06  0.10 -0.05  0.07  0.17  0.33  0.00 -0.15 -0.04 ...  
#> but    0.03 -0.00 -0.05 -0.03 -0.09  0.03  0.28 -0.10 -0.08  0.02 ...  
#> hell   0.04  0.09  0.09  0.01 -0.05  0.06  0.29 -0.05 -0.11  0.09 ...  
#> right -0.07  0.02  0.00 -0.02 -0.01 -0.01  0.30 -0.08 -0.08  0.08 ...  
#> like   0.01  0.02  0.10  0.06 -0.05  0.07  0.29 -0.00 -0.11  0.03 ...  
#> same   0.09  0.05  0.09 -0.00 -0.00  0.06  0.24 -0.01 -0.03  0.12 ...  
#> damn   0.04  0.13  0.11 -0.01  0.00  0.13  0.28  0.00 -0.12  0.11 ...  
#> thing  0.03 -0.00  0.04  0.01  0.07 -0.01  0.39 -0.11 -0.10 -0.03 ...  
#> 

valence_df <- tibble::as_tibble(valence_embeddings, rownames = "token")
valence_df |> normalize_rows(dim_1:dim_25)
#> # A tibble: 2 × 26
#>   token   dim_1   dim_2   dim_3    dim_4   dim_5 dim_6 dim_7   dim_8   dim_9
#>   <chr>   <dbl>   <dbl>   <dbl>    <dbl>   <dbl> <dbl> <dbl>   <dbl>   <dbl>
#> 1 good  -0.0906 0.100   -0.0242 -0.00390 -0.0229 0.100 0.365  0.0346 -0.0858
#> 2 bad    0.0773 0.00417  0.0106 -0.00196  0.0511 0.133 0.306 -0.0209 -0.0490
#> # ℹ 16 more variables: dim_10 <dbl>, dim_11 <dbl>, dim_12 <dbl>, dim_13 <dbl>,
#> #   dim_14 <dbl>, dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>, dim_18 <dbl>,
#> #   dim_19 <dbl>, dim_20 <dbl>, dim_21 <dbl>, dim_22 <dbl>, dim_23 <dbl>,
#> #   dim_24 <dbl>, dim_25 <dbl>
```
