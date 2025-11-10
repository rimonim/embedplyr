# Align Two Embeddings Models

Rotates the embeddings in `x` so that they can be compared with those in
`y`.

## Usage

``` r
align_embeddings(x, y, matching = NULL)
```

## Arguments

- x:

  an embeddings object

- y:

  an embeddings object. If `matching = NULL`, `y` must contain at least
  a few rownames matching those of `x`.

- matching:

  (optional) a named character vector specifying a one-to-one matching
  between rownames of `x` (names) and rownames of `y` (values)

## Details

Computes orthogonal Procrustes as described by Schönemann (1966). This
computation is based only on rows with names that appear in both `x` and
`y` (or on rows specified by `matching`), but the output includes all
rows of `x`.

## Value

An embeddings object with the same rownames and number of rows as `x`,
rotated (and with reduced or increased dimensionality, if need be) to
align with `y`.

## References

Schönemann, P. H. (1966). A generalized solution of the orthogonal
procrustes problem. Psychometrika, 31(1), 1–10.
https://doi.org/10.1007/BF02289451
