# embedplyr

## Overview

embedplyr enables common operations with word and text embeddings within
a ‘tidyverse’ and/or ‘quanteda’ workflow, as demonstrated in [Data
Science for Psychology: Natural Language](http://ds4psych.com).

- [`load_embeddings()`](https://rimonim.github.io/embedplyr/reference/load_embeddings.md)
  loads pretrained [GloVe](https://nlp.stanford.edu/projects/glove/),
  [word2vec](https://code.google.com/archive/p/word2vec/),
  [HistWords](https://nlp.stanford.edu/projects/histwords/), [ConceptNet
  Numberbatch](https://github.com/commonsense/conceptnet-numberbatch),
  and [fastText](https://fasttext.cc) word embedding models from
  Internet sources or from your working directory
- [`embed_tokens()`](https://rimonim.github.io/embedplyr/reference/embed_tokens.md)
  returns the embedding for each token in a set of texts
- [`embed_docs()`](https://rimonim.github.io/embedplyr/reference/embed_docs.md)
  generates text embeddings for a set of documents
- [`get_sims()`](https://rimonim.github.io/embedplyr/reference/get_sims.md)
  calculates row-wise similarity metrics between a set of embeddings and
  a given reference
- [`average_embedding()`](https://rimonim.github.io/embedplyr/reference/average_embedding.md)
  calculates the (weighted) average of multiple embeddings
- [`reduce_dimensionality()`](https://rimonim.github.io/embedplyr/reference/reduce_dimensionality.md)
  reduces the dimensionality of embeddings
- [`align_embeddings()`](https://rimonim.github.io/embedplyr/reference/align_embeddings.md)
  rotates the embeddings from one model so that they can be compared
  with those from another
- [`normalize()`](https://rimonim.github.io/embedplyr/reference/normalize.md)
  and
  [`normalize_rows()`](https://rimonim.github.io/embedplyr/reference/normalize.md)
  normalize embeddings to the unit hypersphere
- and more…

## Installation

You can install the development version of embedplyr from
[GitHub](https://github.com/) with:

``` r
remotes::install_github("rimonim/embedplyr") 
```

## Functionality

embedplyr is designed to facilitate the use of word and text embeddings
in common data manipulation and text analysis workflows, without
introducing new syntax or unfamiliar data structures.

embedplyr is model agnostic; it can be used to work with embeddings from
decontextualized models like
[GloVe](https://nlp.stanford.edu/projects/glove/) and
[word2vec](https://code.google.com/archive/p/word2vec/), or from
contextualized models like BERT or others made available through the
‘[text](https://r-text.org)’ package.

``` r
library(embedplyr)
```

### Loading Pretrained Embeddings

embedplyr won’t help you train new embedding models, but it can load
embeddings from a file or download them from online. This is especially
useful for pretrained word embedding models like GloVe, word2vec, and
fastText. Hundreds of these models can be conveniently downloaded from
online sources with
[`load_embeddings()`](https://rimonim.github.io/embedplyr/reference/load_embeddings.md).

One particularly useful feature of
[`load_embeddings()`](https://rimonim.github.io/embedplyr/reference/load_embeddings.md)
is the optional `words` parameter, which allows the user to specify a
subset of words to load from the model. This allows users to work with
large models, which are often too large to load into an interactive
environment in their entirety. For example, a user may specify the set
of unique tokens in their corpus of interest, and load only these from
the model.

``` r
# load 25d GloVe model trained on Twitter
glove_twitter_25d <- load_embeddings("glove.twitter.27B.25d")

# load words from 300d model trained on Google Books English Fiction 1800-1810
eng.fiction.all_sgns.1800 <- load_embeddings(
    "eng.fiction.all_sgns.1800",
    words = c("word", "token", "lemma")
    )
```

The outcome is an embeddings object. An embeddings object is just a
numeric matrix with fast hash table indexing by rownames (generally
tokens). This means that it can be easily coerced to a dataframe or
tibble, while also allowing special embeddings-specific methods and
functions, such as
[`emb()`](https://rimonim.github.io/embedplyr/reference/emb.md) and
[`find_nearest()`](https://rimonim.github.io/embedplyr/reference/find_nearest.md):

``` r
moral_embeddings <- emb(glove_twitter_25d, c("good", "bad"))
moral_embeddings
#> # 25-dimensional embeddings with 2 rows
#>      dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
#> good -0.54  0.60 -0.15 -0.02 -0.14  0.60  2.19  0.21 -0.52 -0.23 ...  
#> bad   0.41  0.02  0.06 -0.01  0.27  0.71  1.64 -0.11 -0.26  0.11 ...

find_nearest(glove_twitter_25d, "dog", 5L, method = "cosine")
#> # 25-dimensional embeddings with 5 rows
#>        dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
#> dog    -1.24 -0.36  0.57  0.37  0.60 -0.19  1.27 -0.37  0.09  0.40 ...  
#> cat    -0.96 -0.61  0.67  0.35  0.41 -0.21  1.38  0.13  0.32  0.66 ...  
#> dogs   -0.63 -0.11  0.22  0.27  0.28  0.13  1.44 -1.18 -0.26  0.60 ...  
#> horse  -0.76 -0.63  0.43  0.04  0.25 -0.18  1.08 -0.94  0.30  0.07 ...  
#> monkey -0.96 -0.38  0.49  0.66  0.21 -0.09  1.28 -0.11  0.27  0.42 ...
```

Whereas indexing a regular matrix by rownames gets slower as the number
of rows increases, embedplyr’s hash table indexing means that token
embeddings can be retrieved in milliseconds even from models with
millions of rows (see the [performance
vignette](https://rimonim.github.io/embedplyr/vignettes/performance.md)).

### Similarity Metrics

Functions for similarity and distance metrics are as simple as possible;
each one takes in vectors and outputs a scalar.

``` r
vec1 <- c(1, 5, 2)
vec2 <- c(4, 2, 2)
vec3 <- c(-1, -2, -13)

dot_prod(vec1, vec2)                        # dot product
#> [1] 18
cos_sim(vec1, vec2)                         # cosine similarity
#> [1] 0.6708204
euc_dist(vec1, vec2)                        # Euclidean distance
#> [1] 4.242641
anchored_sim(vec1, pos = vec2, neg = vec3)  # projection to an anchored vector
#> [1] 0.9887218
```

### Example Tidy Workflow

Given a tidy dataframe of texts,
[`embed_docs()`](https://rimonim.github.io/embedplyr/reference/embed_docs.md)
will generate embeddings by averaging the embeddings of words in each
text (for more information on why this works well, see [Data Science for
Psychology, Chapter
18](https://ds4psych.com/decontextualized-embeddings#sec-embedding-magnitude)).
By default,
[`embed_docs()`](https://rimonim.github.io/embedplyr/reference/embed_docs.md)
uses a simple unweighted mean, but other averaging methods are
available.

``` r
library(dplyr)
valence_df <- tribble(
    ~id,        ~text,
    "positive", "happy awesome cool nice",
    "neutral",  "ok fine sure whatever",
    "negative", "sad bad horrible angry"
    )

valence_embeddings_df <- valence_df |> 
    embed_docs("text", glove_twitter_25d, id_col = "id", .keep_all = TRUE)
valence_embeddings_df
#> # A tibble: 3 × 27
#>   id       text       dim_1   dim_2    dim_3   dim_4   dim_5   dim_6 dim_7 dim_8
#>   <chr>    <chr>      <dbl>   <dbl>    <dbl>   <dbl>   <dbl>   <dbl> <dbl> <dbl>
#> 1 positive happy a… -0.584  -0.0810 -0.00361 -0.381   0.0786  0.646   1.66 0.543
#> 2 neutral  ok fine… -0.0293  0.169  -0.226   -0.175  -0.389  -0.0313  1.22 0.222
#> 3 negative sad bad…  0.296  -0.244   0.150    0.0809  0.155   0.728   1.51 0.122
#> # ℹ 17 more variables: dim_9 <dbl>, dim_10 <dbl>, dim_11 <dbl>, dim_12 <dbl>,
#> #   dim_13 <dbl>, dim_14 <dbl>, dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>,
#> #   dim_18 <dbl>, dim_19 <dbl>, dim_20 <dbl>, dim_21 <dbl>, dim_22 <dbl>,
#> #   dim_23 <dbl>, dim_24 <dbl>, dim_25 <dbl>
```

[`embed_docs()`](https://rimonim.github.io/embedplyr/reference/embed_docs.md)
can also be used to generate other types of embeddings. For example, we
can use the ‘[text](https://r-text.org)’ package to generate embeddings
using any model available from Hugging Face Transformers.

``` r
# add embeddings to data frame
valence_sbert_df <- valence_df |> 
    embed_docs(
        "text", text::textEmbed, id_col = "id", .keep_all = TRUE,
        model = "sentence-transformers/all-MiniLM-L12-v2"
        )
```

To quantify how good and how intense the texts are, we can compare them
to the embeddings for “good” and “intense” using
[`get_sims()`](https://rimonim.github.io/embedplyr/reference/get_sims.md).
Note that this step requires only a dataframe, tibble, or embeddings
object with numeric columns; the embeddings can come from any source.

``` r
good_vec <- emb(glove_twitter_25d, "good")
intense_vec <- emb(glove_twitter_25d, "intense")
valence_quantified <- valence_embeddings_df |> 
    get_sims(
        dim_1:dim_25, 
        list(
            good = good_vec, 
            intense = intense_vec
            )
        )
valence_quantified
#> # A tibble: 3 × 4
#>   id       text                     good intense
#>   <chr>    <chr>                   <dbl>   <dbl>
#> 1 positive happy awesome cool nice 0.958   0.585
#> 2 neutral  ok fine sure whatever   0.909   0.535
#> 3 negative sad bad horrible angry  0.848   0.747
```

### Example Quanteda Workflow

``` r
library(quanteda)

# corpus
valence_corp <- corpus(valence_df, docid_field = "id")
valence_corp
#> Corpus consisting of 3 documents.
#> positive :
#> "happy awesome cool nice"
#> 
#> neutral :
#> "ok fine sure whatever"
#> 
#> negative :
#> "sad bad horrible angry"

# dfm
valence_dfm <- valence_corp |> 
    tokens() |> 
    dfm()

# compute embeddings
valence_embeddings_df <- valence_dfm |> 
    textstat_embedding(glove_twitter_25d)
valence_embeddings_df
#> # A tibble: 3 × 26
#>   doc_id     dim_1   dim_2    dim_3   dim_4   dim_5   dim_6 dim_7 dim_8  dim_9
#>   <chr>      <dbl>   <dbl>    <dbl>   <dbl>   <dbl>   <dbl> <dbl> <dbl>  <dbl>
#> 1 positive -0.584  -0.0810 -0.00361 -0.381   0.0786  0.646   1.66 0.543 -0.830
#> 2 neutral  -0.0293  0.169  -0.226   -0.175  -0.389  -0.0313  1.22 0.222 -0.394
#> 3 negative  0.296  -0.244   0.150    0.0809  0.155   0.728   1.51 0.122 -0.588
#> # ℹ 16 more variables: dim_10 <dbl>, dim_11 <dbl>, dim_12 <dbl>, dim_13 <dbl>,
#> #   dim_14 <dbl>, dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>, dim_18 <dbl>,
#> #   dim_19 <dbl>, dim_20 <dbl>, dim_21 <dbl>, dim_22 <dbl>, dim_23 <dbl>,
#> #   dim_24 <dbl>, dim_25 <dbl>
```

### Other Functions

#### Reduce Dimensionality

It is sometimes useful to reduce the dimensionality of embeddings. This
is done with
[`reduce_dimensionality()`](https://rimonim.github.io/embedplyr/reference/reduce_dimensionality.md),
which by default performs PCA without column normalization.

``` r
valence_df_2d <- valence_embeddings_df |> 
    reduce_dimensionality(dim_1:dim_25, 2)
valence_df_2d
#> # A tibble: 3 × 3
#>   doc_id      PC1    PC2
#> * <chr>     <dbl>  <dbl>
#> 1 positive -1.47   0.494
#> 2 neutral   0.121 -1.13 
#> 3 negative  1.35   0.640
```

[`reduce_dimensionality()`](https://rimonim.github.io/embedplyr/reference/reduce_dimensionality.md)
can also be used to apply the same rotation to other embeddings not used
to find the principle components.

``` r
new_embeddings <- emb(glove_twitter_25d, c("new", "strange"))

# get rotation with `output_rotation = TRUE`
valence_rotation_2d <- valence_embeddings_df |> 
    reduce_dimensionality(dim_1:dim_25, 2, output_rotation = TRUE)

# apply the same rotation to new embeddings
new_with_valence_rotation <- new_embeddings |> 
    reduce_dimensionality(custom_rotation = valence_rotation_2d)
new_with_valence_rotation
#> # 2-dimensional embeddings with 2 rows
#>         PC1   PC2  
#> new     -2.38  0.24
#> strange  0.09  1.18
```

#### Align and Compare Embeddings Models

Aligning separately trained embeddings can be useful for tracking
semantic change over time or semantic differences between training
datasets. It can also be useful for comparing texts across languages.
`align_embeddings(x, y)` rotates the embeddings in `x` (and changes
their dimensionality if necessary) so that they can be compared with
those in `y`. Optionally, `matching` can be used to specify one-to-one
matching between embeddings in the two models (e.g. a bilingual
dictionary). See
[`align_embeddings()`](https://rimonim.github.io/embedplyr/reference/align_embeddings.md)
for full documentation.

Once aligned, groups of embeddings can be compared using
[`total_dist()`](https://rimonim.github.io/embedplyr/reference/total_dist.md)
or
[`average_sim()`](https://rimonim.github.io/embedplyr/reference/total_dist.md).
These can be used to quantify the overall distance or similarity between
two parallel embedding spaces.

#### Normalize (Scale Embeddings to the Unit Hypersphere)

[`normalize()`](https://rimonim.github.io/embedplyr/reference/normalize.md)
and
[`normalize_rows()`](https://rimonim.github.io/embedplyr/reference/normalize.md)
scale embeddings such that their magnitude is 1, while their angle from
the origin is unchanged.

``` r
normalize(good_vec)
#>        dim_1        dim_2        dim_3        dim_4        dim_5        dim_6 
#> -0.090587846  0.100363800 -0.024215926 -0.003896062 -0.022930449  0.100135678 
#>        dim_7        dim_8        dim_9       dim_10       dim_11       dim_12 
#>  0.364995604  0.034641280 -0.085813930 -0.038466074 -0.133854478  0.094747331 
#>       dim_13       dim_14       dim_15       dim_16       dim_17       dim_18 
#> -0.836459360  0.044137493  0.079744546 -0.099664447  0.093466849 -0.181581983 
#>       dim_19       dim_20       dim_21       dim_22       dim_23       dim_24 
#> -0.087563977  0.020824065 -0.037671809  0.040843874 -0.076207818  0.154222299 
#>       dim_25 
#>  0.003684091

normalize(moral_embeddings)
#> # 25-dimensional embeddings with 2 rows
#>      dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
#> good -0.09  0.10 -0.02 -0.00 -0.02  0.10  0.36  0.03 -0.09 -0.04 ...  
#> bad   0.08  0.00  0.01 -0.00  0.05  0.13  0.31 -0.02 -0.05  0.02 ...

valence_embeddings_df |> normalize_rows(dim_1:dim_25)
#> # A tibble: 3 × 26
#>   doc_id    dim_1   dim_2    dim_3   dim_4   dim_5    dim_6 dim_7  dim_8   dim_9
#>   <chr>     <dbl>   <dbl>    <dbl>   <dbl>   <dbl>    <dbl> <dbl>  <dbl>   <dbl>
#> 1 posit… -0.118   -0.0163 -7.26e-4 -0.0767  0.0158  0.130   0.334 0.109  -0.167 
#> 2 neutr… -0.00633  0.0365 -4.87e-2 -0.0377 -0.0839 -0.00675 0.262 0.0479 -0.0850
#> 3 negat…  0.0666  -0.0549  3.38e-2  0.0182  0.0347  0.164   0.339 0.0274 -0.132 
#> # ℹ 16 more variables: dim_10 <dbl>, dim_11 <dbl>, dim_12 <dbl>, dim_13 <dbl>,
#> #   dim_14 <dbl>, dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>, dim_18 <dbl>,
#> #   dim_19 <dbl>, dim_20 <dbl>, dim_21 <dbl>, dim_22 <dbl>, dim_23 <dbl>,
#> #   dim_24 <dbl>, dim_25 <dbl>
```

#### Magnitude

The magnitude, norm, or length of a vector is its Euclidean distance
from the origin.

``` r
magnitude(good_vec)
#> [1] 6.005552

magnitude(moral_embeddings)
#>     good      bad 
#> 6.005552 5.355951
```

## Contributor Guidelines

For issues, bug reports, and feature requests, [file a GitHub
issue](https://github.com/rimonim/embedplyr/issues). For support or
other inquiries, feel free to contact the maintainer by email at
<info@ds4psych.com>. However, the best way to get something changed is
to do it yourself. We welcome contributions! See the [contributor
guidelines](https://github.com/rimonim/embedplyr/wiki/Contributor-Guidelines)
for details.
