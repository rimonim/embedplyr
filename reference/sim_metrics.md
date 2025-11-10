# Similarity and Distance Metrics

Metrics for measuring relationships between vector embeddings.

## Usage

``` r
dot_prod(x, y)

cos_sim(x, y)

euc_dist(x, y)

minkowski_dist(x, y, p = 1)

anchored_sim(x, pos, neg)
```

## Arguments

- x:

  a numeric vector

- y:

  a numeric vector the same length as x

- p:

  [p-norm](https://en.wikipedia.org/wiki/Lp_space#The_p-norm_in_finite_dimensions)
  used to compute the Minkowski distance

- pos, neg:

  a pair of numeric vectors the same length as x; the positive and
  negative ends of the anchored vector

## Details

`dot_prod` gives the dot product. `cos_sim` gives the cosine similarity
(i.e. the dot product of two normalized vectors). `euc_dist` gives the
Euclidean distance. `anchored_sim` gives the position of `x` on the
spectrum between two anchor points, where vectors aligned with `pos` are
given a score of 1 and those aligned with `neg` are given a score of 0.
For more on anchored vectors, see [Data Science for Psychology: Natural
Language, Chapter
20](https://ds4psych.com/navigating-vectorspace#sec-dimension-projection).
Note that, for a given set of values of `x`, `anchored_sim(x, pos, neg)`
will be perfectly correlated with `dot_prod(x, pos - neg)`.

## Examples

``` r
vec1 <- c(1, 5, 2)
vec2 <- c(4, 2, 2)
vec3 <- c(1, -2, -13)

dot_prod(vec1, vec2)
#> [1] 18
cos_sim(vec1, vec2)
#> [1] 0.6708204
euc_dist(vec1, vec2)
#> [1] 4.242641
anchored_sim(vec1, vec2, vec3)
#> [1] 1.012
```
