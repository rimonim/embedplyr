# Read Embeddings From a Text or Binary File

Reads GloVe text format, fastText text format, word2vec binary format,
and most tabular formats (csv, tsv, etc.)

## Usage

``` r
read_embeddings(path, words = NULL)
```

## Arguments

- path:

  a file path or url

- words:

  optional list of words for which to retrieve embeddings.

## Details

If using a custom tabular format, the file must have tokens in the first
column and numbers in all other columns.

## Value

An embeddings object (a numeric matrix with tokens as rownames)
