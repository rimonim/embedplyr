# Magnitude of Embeddings

The magnitude, norm, or length of a vector is its Euclidean distance
from the origin.

## Usage

``` r
magnitude(x, ...)

# S3 method for class 'numeric'
magnitude(x, ...)
```

## Arguments

- x:

  a numeric vector, embeddings object, or list of numeric or embeddings
  objects

- ...:

  additional parameters to be passed to methods

## Value

a numeric vector with one item per embedding in `x`. If `x` is a list,
the function will be called recursively and return a list.

## Examples

``` r
vec <- c(1, 4, 2)
magnitude(vec)
#> [1] 4.582576

valence_embeddings <- emb(glove_twitter_25d, c("good", "bad"))
magnitude(valence_embeddings)
#>     good      bad 
#> 6.005552 5.355951 

embeddings_list <- find_nearest(glove_twitter_25d, c("good", "bad"), each = TRUE)
magnitude(embeddings_list)
#> $good
#>     good      too      day     well     nice   better      fun     much 
#> 6.005552 5.813283 5.802194 5.721374 5.194440 5.865108 5.015976 5.993338 
#>     this     hope 
#> 6.427068 5.640379 
#> 
#> $bad
#>      bad     shit    crazy      but     hell    right     like     same 
#> 5.355951 6.304527 5.171107 6.335841 5.225420 5.881975 6.027912 5.545610 
#>     damn    thing 
#> 5.610414 5.674697 
#> 
```
