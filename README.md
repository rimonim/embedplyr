
<!-- README.md is generated from README.Rmd. Please edit that file -->

# embeddingplyr: Tools for Working With Text Embeddings

<!-- badges: start -->
<!-- badges: end -->

## About

Common operations with word and text embeddings within a
‘tidyverse’/‘quanteda’ workflow, as demonstrated in [Data Science for
Psychology: Natural Language](http://ds4psych.com). Includes simple
functions for calculating common similarity metrics, as well as higher
level functions for loading pretrained word embedding models
(e.g. ‘GloVe’), applying them to words, aggregating to produce text
embeddings, and reducing dimensionality.

## Installation

You can install the development version of embeddingplyr from
[GitHub](https://github.com/) with:

``` r
# devtools package required to install quanteda from Github 
remotes::install_github("rimonim/embeddingplyr") 
```

## Functionality

embeddingplyr is designed to facilitate the use of word and text
embeddings in common data manipulation and text analysis workflows,
without introducing new syntax or unfamiliar data structures.

embeddingplyr is model agnostic; it can be used to work with embeddings
from decontextualized models like
[GloVe](https://nlp.stanford.edu/projects/glove/) and
[word2vec](https://code.google.com/archive/p/word2vec/), or from
contextualized models like BERT or others made available through the
[text](https://r-text.org) package.

### Loading Pretrained Embeddings

embeddingplyr won’t help you train new embedding models, but it can load
embeddings from a file. This is especially useful for pretrained word
embedding models like GloVe and word2vec. These models can be downloaded
(generally in txt or bin format, respectively) and loaded with
`load_embeddings()`.

``` r
library(embeddingplyr)

glove_twitter_25d <- load_embeddings("~/Documents/data/glove/glove.twitter.27B.25d.txt")
```

The outcome is an “embeddings” object. An embeddings object is just a
numeric matrix with tokens as rownames. This means that it can be easily
coerced to a dataframe or tibble, while also allowing special
embeddings-specific methods and functions, such as
`predict.embeddings()` and `find_nearest()`:

``` r
moral_embeddings <- predict(glove_twitter_25d, c("good", "bad"))
moral_embeddings
#>         dim_1    dim_2     dim_3     dim_4    dim_5   dim_6  dim_7    dim_8
#> good -0.54403 0.602740 -0.145430 -0.023398 -0.13771 0.60137 2.1920  0.20804
#> bad   0.41388 0.022308  0.056536 -0.010503  0.27395 0.71342 1.6414 -0.11188
#>         dim_9   dim_10   dim_11  dim_12  dim_13   dim_14  dim_15   dim_16
#> good -0.51536 -0.23101 -0.80387 0.56901 -5.0234  0.26507 0.47891 -0.59854
#> bad  -0.26249  0.10783 -0.95191 0.40414 -4.6303 -0.18866 0.60344  0.24891
#>       dim_17   dim_18   dim_19   dim_20   dim_21  dim_22   dim_23  dim_24
#> good 0.56132 -1.09050 -0.52587  0.12506 -0.22624 0.24529 -0.45767 0.92619
#> bad  0.36794 -0.50313 -0.48655 -0.21142  0.38759 1.04110  0.42695 0.28660
#>        dim_25
#> good 0.022125
#> bad  0.023210

find_nearest(glove_twitter_25d, "dog", 5L)
#>           dim_1    dim_2   dim_3    dim_4   dim_5     dim_6  dim_7    dim_8
#> dog    -1.24200 -0.35980 0.57285 0.366750 0.60021 -0.188980 1.2729 -0.36921
#> cat    -0.96419 -0.60978 0.67449 0.351130 0.41317 -0.212410 1.3796  0.12854
#> dogs   -0.63063 -0.10835 0.21557 0.270090 0.27784  0.128710 1.4445 -1.18200
#> horse  -0.75571 -0.63379 0.43016 0.037627 0.24535 -0.179570 1.0830 -0.93601
#> monkey -0.95965 -0.37893 0.48925 0.655270 0.21425 -0.087631 1.2835 -0.11095
#>           dim_9   dim_10  dim_11   dim_12  dim_13   dim_14   dim_15     dim_16
#> dog     0.08908 0.403390 0.25130 -0.25548 -3.9209 -1.11000 -0.21308 -0.2384600
#> cat     0.31567 0.663250 0.33910 -0.18934 -3.3250 -1.14910 -0.41290  0.2195000
#> dogs   -0.26393 0.599420 0.37919 -0.59636 -3.3390 -0.73516 -0.31336 -0.0775700
#> horse   0.29962 0.068212 0.58125 -0.41726 -3.2628 -0.38092  0.28320 -0.0128760
#> monkey  0.27465 0.423450 0.36250  0.39578 -2.4668 -0.96128 -0.42935  0.0064115
#>         dim_17   dim_18      dim_19    dim_20    dim_21  dim_22  dim_23
#> dog    0.95322 -0.52750 -0.00078049 -0.357710  0.555820 0.77869 0.46874
#> cat    0.87060 -0.50616 -0.12781000 -0.066965  0.065761 0.43927 0.17580
#> dogs   0.62460 -0.95420  0.71383000 -0.420980  0.343070 0.38027 0.16883
#> horse  0.75628 -0.48559  0.16568000  0.163330 -0.349980 0.98785 0.47289
#> monkey 1.04710 -0.51975  0.38112000  0.721370  0.226490 0.68278 0.51848
#>          dim_24  dim_25
#> dog    -0.77803 0.78378
#> cat    -0.56058 0.13529
#> dogs   -1.25270 0.95083
#> horse  -1.12500 0.49828
#> monkey -0.73045 0.62930
```

### Similarity Metrics

### Tidy Workflow

### Quanteda Workflow
