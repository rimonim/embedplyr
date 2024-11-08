
<!-- README.md is generated from README.Rmd. Please edit that file -->

# embeddingplyr: Tools for Working With Text Embeddings

<!-- badges: start -->
<!-- badges: end -->

## About

embeddingplyr enables common operations with word and text embeddings
within a ‘tidyverse’/‘quanteda’ workflow, as demonstrated in [Data
Science for Psychology: Natural Language](http://ds4psych.com). Includes
simple functions for calculating common similarity metrics, as well as
higher level functions for loading pretrained word embedding models
(e.g. [GloVe](https://nlp.stanford.edu/projects/glove/)), applying them
to words, aggregating to produce text embeddings, and reducing
dimensionality.

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
‘[text](https://r-text.org)’ package.

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

The outcome is an embeddings object. An embeddings object is just a
numeric matrix with tokens as rownames. This means that it can be easily
coerced to a dataframe or tibble, while also allowing special
embeddings-specific methods and functions, such as
`predict.embeddings()` and `find_nearest()`:

``` r
moral_embeddings <- predict(glove_twitter_25d, c("good", "bad"))
moral_embeddings
#> # 25-dimensional embeddings with 2 rows
#>      dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim_10    
#> good -0.54  0.6  -0.15 -0.02 -0.14  0.6   2.19  0.21 -0.52 -0.23  ...
#> bad   0.41  0.02  0.06 -0.01  0.27  0.71  1.64 -0.11 -0.26  0.11  ...

find_nearest(glove_twitter_25d, "dog", 5L, sim_func = cos_sim)
#> # 25-dimensional embeddings with 5 rows
#>        dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim_10    
#> dog    -1.24 -0.36  0.57  0.37  0.6  -0.19  1.27 -0.37  0.09  0.4   ...
#> cat    -0.96 -0.61  0.67  0.35  0.41 -0.21  1.38  0.13  0.32  0.66  ...
#> dogs   -0.63 -0.11  0.22  0.27  0.28  0.13  1.44 -1.18 -0.26  0.6   ...
#> horse  -0.76 -0.63  0.43  0.04  0.25 -0.18  1.08 -0.94  0.3   0.07  ...
#> monkey -0.96 -0.38  0.49  0.66  0.21 -0.09  1.28 -0.11  0.27  0.42  ...
```

### Similarity Metrics

Functions for similarity and distance metrics are as simple as possible:

``` r
vec1 <- c(1, 5, 2)
vec2 <- c(4, 2, 2)
vec3 <- c(1, -2, -13)

dot_prod(vec1, vec2)            # dot product
#> [1] 18
cos_sim(vec1, vec2)             # cosine similarity
#> [1] 0.6708204
euc_dist(vec1, vec2)            # Euclidean distance
#> [1] 4.242641
anchored_sim(vec1, vec2, vec3)  # projection to an anchored vector
#> [1] 1.012
```

### Tidy Workflow

### Quanteda Workflow
