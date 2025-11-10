# Methods for Embeddings Objects

Functions that modify the rownames or indices of embeddings objects
(e.g. `unique`, `rbind`, `rownames<-` etc.) will behave as usual for
matrices while automatically updating the hash table as necessary.
Functions that coerce embeddings objects to other data types (e.g.
`as.matrix`) will strip the hash table attribute, leaving a clean,
familiar object.

## Usage

``` r
# S3 method for class 'embeddings'
rownames(x) <- value

# S3 method for class 'embeddings'
dimnames(x) <- value

# S3 method for class 'embeddings'
unique(x, incomparables = FALSE, MARGIN = 1, fromLast = FALSE, ...)

# S3 method for class 'embeddings'
t(x)

# S3 method for class 'embeddings'
rbind(..., deparse.level = 1)

# S3 method for class 'embeddings'
as.matrix(x, ...)

# S3 method for class 'embeddings'
as_tibble(x, ..., rownames = NULL)
```

## Arguments

- x:

  an embeddings object

- value:

  a valid value for that component of
  [`dimnames`](https://rdrr.io/r/base/dimnames.html)`(x)`. For a matrix
  or array this is either `NULL` or a character vector of non-zero
  length equal to the appropriate dimension.

- incomparables:

  a vector of values that cannot be compared. `FALSE` is a special
  value, meaning that all values can be compared, and may be the only
  value accepted for methods other than the default. It will be coerced
  internally to the same type as `x`.

- MARGIN:

  the array margin to be held fixed: a single integer.

- fromLast:

  logical indicating if duplication should be considered from the last,
  i.e., the last (or rightmost) of identical elements will be kept. This
  only matters for [`names`](https://rdrr.io/r/base/names.html) or
  [`dimnames`](https://rdrr.io/r/base/dimnames.html).

- ...:

  for `rbind`, embeddings objects or other objects that will be coerced
  to embeddings. Otherwise, arguments for particular methods.

- deparse.level:

  integer controlling the construction of labels in the case of
  non-matrix-like arguments (for the default method):  
  `deparse.level = 0` constructs no labels;  
  the default `deparse.level = 1` typically and `deparse.level = 2`
  always construct labels from the argument names, see the ‘Value’
  section below.

- rownames:

  How to treat existing row names of a data frame or matrix:

  - `NULL`: remove row names. This is the default.

  - `NA`: keep row names.

  - A string: the name of a new column. Existing rownames are
    transferred into this column and the `row.names` attribute is
    deleted. No name repair is applied to the new column name, even if
    `x` already contains a column of that name. Use
    `as_tibble(rownames_to_column(...))` to safeguard against this case.

  Read more in
  [rownames](https://tibble.tidyverse.org/reference/rownames.html).
