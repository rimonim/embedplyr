# Average Embeddings

Calculate the (weighted) average of multiple embeddings.

## Usage

``` r
average_embedding(x, w = NULL, method = "mean", ...)
```

## Arguments

- x:

  an embeddings object or list of embeddings objects

- w:

  optional weighting for rows in x. This can be an unnamed numeric
  vector with one item per row of x, a named numeric vector of any
  length with names that match the row names of x, `"trillion_word"`
  (125,000 English word frequencies from [Peter Norvig's
  compilation](https://norvig.com/ngrams/count_1w.txt), derived from the
  Google Web Trillion Word Corpus), or `"trillion_word_sif"` for smooth
  inverse frequencies (SIF) calculated using the same list.

- method:

  method to use for averaging. `"mean"` (the default) is the standard
  arithmetic mean. `"median"` is the geometric median (also called
  spatial median or L1-median), computed using
  [`Gmedian::Gmedian()`](https://rdrr.io/pkg/Gmedian/man/Gmedian.html)
  or, if weights are provided,
  [`Gmedian::Weiszfeld()`](https://rdrr.io/pkg/Gmedian/man/Weiszfeld.html).
  `"sum"` is the (weighted) sum.

- ...:

  additional arguments to be passed to the averaging function

## Details

For `w = "trillion_word"` or `w = "trillion_word_sif"`, tokens that do
not appear in the word frequency list are treated as if they appeared as
often as the least frequent word in the list. If `w` is a named vector,
rows that do not match any items in the vector will be assigned the
minimum value of that vector.

## Value

A named numeric vector. If `x` is a list, the function will be called
recursively and output a list of the same length.

## Examples

``` r
happy_dict <- c("happy", "joy", "smile", "enjoy")
happy_dict_embeddings <- emb(glove_twitter_25d, happy_dict)

happy_dict_vec <- average_embedding(happy_dict_embeddings)
happy_dict_vec_weighted <- average_embedding(happy_dict_embeddings, w = "trillion_word")

happy_dict_list <- find_nearest(glove_twitter_25d, happy_dict, each = TRUE)
happy_dict_vec_list <- average_embedding(happy_dict_list)
```
