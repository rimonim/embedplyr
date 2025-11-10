# Distributed Dictionary Representation (DDR)

``` r
library(dplyr)
library(embedplyr)
```

Psychology researchers have been constructing, validating, and
publicizing dictionaries (lists of words associated with a given
construct) for decades. But these dictionaries are designed for word
counting—How do we apply them to a embedding-based analysis? Garten et
al. (2018) propose a simple solution: Get word embeddings for each word
in the dictionary, and average them together to create a single
Distributed Dictionary Representation (DDR). The dictionary construct
can then be measured by comparing text embeddings to the DDR.

DDR is ideal for studies of abstract constructs like emotions, that
refer to the general gist of a text rather than particular words. The
rich representation of word embeddings allows DDR to capture even the
subtlest associations between words and constructs, and to precisely
reflect the *extent* to which each word is associated with each
construct. It can do this even for texts that do not contain any
dictionary words. Because embeddings are continuous and already
calibrated to the probabilities of word use in language, DDR also avoids
the difficult statistical problems that arise due to the strange
distributions of word counts (see [DS4Psych, Chapter
16](https://ds4psych.com/word-counting-improvements)).

### Load Word Embedding Model

``` r
glove_twitter_25d <- load_embeddings("glove.twitter.27B.25d")
```

### Embed Texts of Interest

We have three example texts, which we can imagine were written by a
participant diagnosed with depression, one diagnosed with anxiety, and
one control. We will analyze to what extent these texts reflect high vs
low anxiety.

``` r
psych_df <- tribble(
    ~id,           ~text,
    "control",     "yesterday I took my dog for a walk",
    "depression",  "I slept all day and cried in the evening",
    "anxiety",     "I just kept thinking of all the things I needed to do"
    )

psych_embeddings_df <- psych_df |> 
    embed_docs("text", glove_twitter_25d, id_col = "id", .keep_all = TRUE)
#> Warning in emb(model, feats, .keep_missing = TRUE): 1 items in `newdata` are
#> not present in the embeddings object.

psych_embeddings_df
#> # A tibble: 3 × 27
#>   id        text    dim_1 dim_2 dim_3   dim_4  dim_5   dim_6 dim_7  dim_8  dim_9
#>   <chr>     <chr>   <dbl> <dbl> <dbl>   <dbl>  <dbl>   <dbl> <dbl>  <dbl>  <dbl>
#> 1 control   yest… -0.597  0.381 0.564  0.0372 -0.198 -0.143   1.11 -0.121 -0.290
#> 2 depressi… I sl… -0.547  0.195 0.472 -0.201  -0.372 -0.184   1.32 -0.270 -0.409
#> 3 anxiety   I ju… -0.0358 0.482 0.319 -0.105  -0.300 -0.0249  1.32 -0.471 -0.246
#> # ℹ 16 more variables: dim_10 <dbl>, dim_11 <dbl>, dim_12 <dbl>, dim_13 <dbl>,
#> #   dim_14 <dbl>, dim_15 <dbl>, dim_16 <dbl>, dim_17 <dbl>, dim_18 <dbl>,
#> #   dim_19 <dbl>, dim_20 <dbl>, dim_21 <dbl>, dim_22 <dbl>, dim_23 <dbl>,
#> #   dim_24 <dbl>, dim_25 <dbl>
```

### Load and Embed Dictionaries

Many quality dictionaries are available from
[quanteda.sentiment](https://github.com/quanteda/quanteda.sentiment) and
other sources (see [DS4Psych, Chapter
14](https://ds4psych.com/word-counting#sec-dictionary-sources)). For the
sake of this example, we will use made-up dictionaries.

``` r
# positive and negative construct dictionaries
high_anx_dict <- c("anxious", "overwhelmed", "exhausted", "nervous", "stressed")
low_anx_dict <- c("relaxed", "calm", "mellow")

# embed dictionaries
high_anx_dict_embeddings <- emb(glove_twitter_25d, high_anx_dict)
#> Warning in emb(glove_twitter_25d, high_anx_dict): 3 items in `newdata` are not
#> present in the embeddings object.
low_anx_dict_embeddings <- emb(glove_twitter_25d, low_anx_dict)
#> Warning in emb(glove_twitter_25d, low_anx_dict): 1 items in `newdata` are not
#> present in the embeddings object.

# average embeddings to create DDR
high_anx_DDR <- average_embedding(high_anx_dict_embeddings)
low_anx_DDR <- average_embedding(low_anx_dict_embeddings)
```

### Calculate Similarity Metrics

To complete the process, we compare the embeddings of each of our texts
to that of the DDR. This could be done by computing cosine similarity
between each text and `high_anx_DDR`. But since we want to know the
extent to which these texts reflect high anxiety *as opposed to low
anxiety*, we will use an anchored vector. This approach is also known as
semantic projection (Grand et al., 2022).

``` r
anxiety_scores_df <- psych_embeddings_df |> 
  get_sims(
    dim_1:dim_25, 
    list(anxiety = list(pos = high_anx_DDR, neg = low_anx_DDR)),
    method = "anchored"
    )
anxiety_scores_df
#> # A tibble: 3 × 3
#>   id         text                                                  anxiety
#>   <chr>      <chr>                                                   <dbl>
#> 1 control    yesterday I took my dog for a walk                      0.127
#> 2 depression I slept all day and cried in the evening                0.162
#> 3 anxiety    I just kept thinking of all the things I needed to do   0.272
```

It seems that both the depression and anxiety texts reflect quite a bit
more anxiety than the control.

### Weighted DDR

Garten et al. (2018) found that DDR works best with smaller dictionaries
of only the words most directly connected to the construct being
measured (around 30 words worked best in their experiments). Word
embeddings work by overvaluing informative words (see [DS4Psych, Chapter
18](https://ds4psych.com/decontextualized-embeddings#sec-embedding-magnitude))—a
desirable property for raw texts, in which uninformative words tend to
be very frequent. But dictionaries only include one of each word. In
longer dictionaries with more infrequent, tangentially connected words,
averaging word embeddings will therefore *overvalue* those infrequent
words and skew the DDR. This can be fixed with Garten et al.’s method of
picking out only the most informative words. Alternatively, it could be
fixed by measuring the frequency of each dictionary word in a corpus and
weighting the average embedding by that frequency. This method is
consistent with the way most dictionaries are validated, by counting the
frequencies of dictionary words in text (see [DS4Psych, Chapter
14](https://ds4psych.com/word-counting)).

In the absence of reliable frequency data from our own corpus (or from
the corpus on which the dictionaries were validated), we can set
`w = "trillion_word"` to weight words by their frequencies in the Google
Trillion Word corpus.

``` r
# weighted averages
high_anx_DDR_w <- average_embedding(high_anx_dict_embeddings, w = "trillion_word")
low_anx_DDR_w <- average_embedding(low_anx_dict_embeddings, w = "trillion_word")

# calculate similarity scores
anxiety_scores_df <- psych_embeddings_df |> 
  get_sims(
    dim_1:dim_25, 
    list(anxiety = list(pos = high_anx_DDR_w, neg = low_anx_DDR_w)),
    method = "anchored"
    )
anxiety_scores_df
#> # A tibble: 3 × 3
#>   id         text                                                  anxiety
#>   <chr>      <chr>                                                   <dbl>
#> 1 control    yesterday I took my dog for a walk                     0.0110
#> 2 depression I slept all day and cried in the evening               0.0909
#> 3 anxiety    I just kept thinking of all the things I needed to do  0.123
```

## References

Garten, J., Hoover, J., Johnson, K. M., Boghrati, R., Iskiwitch, C., &
Dehghani, M. (2018). [Dictionaries and distributions: Combining expert
knowledge and large scale textual data content analysis: Distributed
dictionary representation](https://doi.org/10.3758/s13428-017-0875-9).
*Behavior Research Methods, 50*, 344–361.

Grand, G., Blank, I. A., Pereira, F., & Fedorenko, E. (2022). [Semantic
projection recovers rich human knowledge of multiple object features
from word embeddings](https://doi.org/10.1038/s41562-022-01316-8).
*Nature Human Behaviour, 6*(7), 975–987.
