---
title: 'embedplyr: Tools for Working With Text Embeddings'
tags:
  - R
  - natural language processing
  - embeddings
  - word embeddings
  - sentiment analysis
  - psychology
authors:
  - name: Louis Teitelbaum
    orcid: 0009-0001-9347-0145
    affiliation: 1
affiliations:
  - index: 1
    name: Ben-Gurion University of the Negev, Israel
date: 10 January 2025
year: 2025
bibliography: paper.bib
output:
  html_document:
    df_print: paged
csl: apa.csl
journal: JOSS
---



# Aims of the Package

Dense vector embeddings are the fundamental building block of modern natural language processing [@lauriola2022]. The ability to represent the meaning of texts as a continuous, high dimensional space underlies the recent successes of large language models (LLMs). Embeddings have also revolutionized research methods and inspired new theoretical frameworks in linguistics, psychology, sociology, and neuroscience [see e.g. @duran2019; @feuerriegel2025; @grand2022; @hamilton2018; @kjell2023; @kozlowski2019; @schrimpf2021]. As text embeddings become ubiquitous in the social and behavioral sciences, the need for flexible, easy-to-learn tools increases. Answering this need, **embedplyr** (pronounced "embe-DEE-plier") enables common operations with word and text embeddings within a **tidyverse** [@wickham2019] and/or **quanteda** [@benoit2018] workflow, as demonstrated in @teitelbaum2024. **embedplyr** is designed to facilitate the use of word and text embeddings in common data manipulation and text analysis workflows, without introducing new syntax or unfamiliar data structures to R users.

Existing tools for working with embeddings in R are generally specific to particular model architectures. For example, **word2vec** [@wijffels2023] provides access to word2vec models [@mikolov2013a; @mikolov2013b], **text2vec** [@selivanov2023] provides access to LDA, LSA, and GloVe models [@blei2003; @deerwester1990; @pennington2014], **fastText** [@mouselimis2024] provides access to fastText models [@facebook2016; @bojanowski2017a; @bojanowski2017b; @grave2018], and **text** [@kjell2023] provides access to transformers-based LLMs [@wolf2020]. While these tools are already invaluable in the social and behavioral sciences, using different syntax and separate data structures for each model architecture can be cumbersome. This is especially true given the prevalence of studies that make use of multiple model architectures in parallel analyses [e.g. @carrella2023; @hussain2024; @markus2024]. **embedplyr** fills this gap with a model agnostic approach; it can be used to work with embeddings from any model framework using syntax that will be familiar to any **tidyverse** user. While some existing tools focus on convenience functions for encouraging expert-recommended best practices [e.g. @kjell2023], **embedplyr** prioritizes flexibility---much like its namesake, **dplyr** [@wickham2023]. This approach yields simple, modular functions that are useful both for educating students [see @teitelbaum2024] and experimenting with novel methods.

# Features

## Loading Pretrained Token Embeddings

**embedplyr** does not include tools for training new embedding models, but it can load embeddings from a file or download them from online. This is especially useful for pretrained word embedding models like GloVe [@pennington2014], word2vec [@mikolov2013a; @mikolov2013b], HistWords [@hamilton2018], and fastText [@bojanowski2017a]. Hundreds of these models can be conveniently downloaded from online sources with `load_embeddings()`, forgoing the need to search for model files online and juggle incompatible file types. 

One particularly useful feature of `load_embeddings()` is the optional `words` parameter, which allows the user to specify a subset of words to load from the model. This allows users to work with large models, which are often too large to load into an interactive environment in their entirety. For example, a user may specify the set of unique tokens in their corpus of interest, and load only these from the model.


```r
# load 25d GloVe model trained on Twitter
glove_twitter_25d <- load_embeddings("glove.twitter.27B.25d")
```


```r
# load words from model trained on Google Books English Fiction 1800-1810
eng.fiction.all_sgns.1800 <- load_embeddings(
	"eng.fiction.all_sgns.1800",
	words = c("word", "token", "lemma")
	)
```

The output of `load_embeddings()` is an embeddings object. An embeddings object is simply a numeric matrix with fast hash table indexing by rownames (generally tokens). This means that it can be easily coerced to a dataframe or tibble, while also allowing special embeddings-specific methods and functions, such as `predict.embeddings()` and `find_nearest()`:


```r
moral_embeddings <- predict(glove_twitter_25d, c("good", "bad"))
moral_embeddings
```

```
## # 25-dimensional embeddings with 2 rows
```

```
##      dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
## good -0.54  0.60 -0.15 -0.02 -0.14  0.60  2.19  0.21 -0.52 -0.23 ...  
## bad   0.41  0.02  0.06 -0.01  0.27  0.71  1.64 -0.11 -0.26  0.11 ...
```

```r
find_nearest(glove_twitter_25d, "dog", 5L, method = "cosine")
```

```
## # 25-dimensional embeddings with 5 rows
```

```
##        dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
## dog    -1.24 -0.36  0.57  0.37  0.60 -0.19  1.27 -0.37  0.09  0.40 ...  
## cat    -0.96 -0.61  0.67  0.35  0.41 -0.21  1.38  0.13  0.32  0.66 ...  
## dogs   -0.63 -0.11  0.22  0.27  0.28  0.13  1.44 -1.18 -0.26  0.60 ...  
## horse  -0.76 -0.63  0.43  0.04  0.25 -0.18  1.08 -0.94  0.30  0.07 ...  
## monkey -0.96 -0.38  0.49  0.66  0.21 -0.09  1.28 -0.11  0.27  0.42 ...
```

Whereas indexing a regular matrix by rownames gets slower as the number of rows increases, **embedplyr**'s hash table indexing means that token embeddings can be retrieved in milliseconds even from models with millions of rows.

## Embed Texts of Interest

Given a tidy dataframe of texts, `embed_docs()` will generate embeddings by averaging the embeddings of tokens in each text [see @ethayarajh2019; @teitelbaum2024, chap. 18]. By default, `embed_docs()` uses a simple unweighted mean, but many other averaging methods are available.

The following example embeds three texts, which for the sake of the example I will consider to have been written by a participant diagnosed with depression, one diagnosed with anxiety, and one control. 


```r
library(dplyr)

psych_df <- tribble(
    ~id,           ~text,
    "control",     "yesterday I took my dog for a walk",
    "depression",  "I slept all day and cried in the evening",
    "anxiety",     "I kept thinking of all the things I needed to do"
    )

# add embeddings to data frame
psych_embeddings_df <- psych_df |> 
    embed_docs("text", glove_twitter_25d, id_col = "id", .keep_all = TRUE)
```

`embed_tokens()` is similar to `embed_docs()`, but returns the embedding of each individual token, rather than averaging within documents.

## Embed Dictionaries

I use Distributed Dictionary Representation (DDR) as a showcase for **embedplyr**'s functionality. DDR enables the application of validated psychometric lexicons [e.g. @boyd2022] to rich, embedding-based semantic representation [@garten2018]. This is achieved by retrieving pretrained word embeddings for each word in the dictionary, and averaging them to create a single vector---the DDR. The dictionary construct can then be measured by comparing text embeddings to the DDR.

DDR is ideal for studies of abstract constructs like emotions, that refer to the general gist of a text rather than particular words. The rich representation of word embeddings allows DDR to capture even the subtlest associations between words and constructs, and to precisely reflect the *extent* to which each word is associated with each construct. It can do this even for texts that do not contain any dictionary words. Because embeddings are continuous and calibrated by design to the probabilities of word use in language, DDR also avoids difficult statistical problems that arise due to the strange distributions of word counts [see @teitelbaum2024, chap. 16].

In the following example, I construct DDRs for high and low anxiety. For the sake of the example, I use made-up dictionaries. Once embeddings are produced for each word in the dictionary, they are averaged using `average_embedding()`. By default this is a simple mean, but `average_embedding()` also supports the geometric median [@cardot2022], weighted geometric median, and weighted mean, including weighting by word frequency or smooth inverse frequency [@arora2017].


```r
# positive and negative construct dictionaries
high_anx_dict <- c("anxious", "overwhelmed", "nervous", "stressed")
low_anx_dict <- c("relaxed", "calm", "mellow")

# embed dictionaries
high_anx_dict_embeddings <- predict(glove_twitter_25d, high_anx_dict)
low_anx_dict_embeddings <- predict(glove_twitter_25d, low_anx_dict)

# average embeddings to create DDR
high_anx_DDR <- average_embedding(high_anx_dict_embeddings)
low_anx_DDR <- average_embedding(low_anx_dict_embeddings)
```

`average_embedding()` could be used in a similar manner to construct contextualized construct representations [@atari2023].

## Calculate Similarity Metrics

To complete the DDR analysis, I compare the embeddings of each the corpus texts to that of the DDR. This could be done by computing cosine similarity between each text and `high_anx_DDR` (`"cosine"` is the default method for `get_sims()`). In this case however, I use an anchored vector to quantify the extent to which these texts reflect high anxiety _as opposed to low anxiety_. `method = "anchored"` gives the position of each embedding on the spectrum between two anchor points, where vectors aligned with `pos` are given a score of 1 and those aligned with `neg` are given a score of 0. This approach is also known as semantic projection [@grand2022]. 


```r
anxiety_scores_df <- psych_embeddings_df |> 
  get_sims(
    dim_1:dim_25, 
    list(anxiety = list(pos = high_anx_DDR, neg = low_anx_DDR)),
    method = "anchored"
    )
anxiety_scores_df
```

```
## # A tibble: 3 x 3
##   id         text                                             anxiety
##   <chr>      <chr>                                              <dbl>
## 1 control    yesterday I took my dog for a walk                 0.210
## 2 depression I slept all day and cried in the evening           0.338
## 3 anxiety    I kept thinking of all the things I needed to do   0.354
```

Note that `get_sims()` requires only a dataframe, tibble, or embeddings object with numeric columns; the embeddings can come from any source. 

## Other Functions

### Loading Other Embeddings

Embeddings can come from many sources. Accordingly, **embedplyr** provides versatile tools to read embeddings from a variety of different formats. For example, @meng2019 provide spherical text embeddings pretrained on Wikipedia, formatted as text files. After downloading one of these files, it can be loaded using `read_embeddings()`. `read_embeddings()` can read GloVe text format, fastText text format, word2vec binary format, and most tabular formats (csv, tsv, etc.).


```r
spherical_mod <- read_embeddings("~/Downloads/jose_50d.txt")
```

Various R data types can also be converted to embeddings objects using `as.embeddings()`.

### Arbitrary Embedding Functions

In addition to embedding documents by averaging static word embeddings, `embed_docs()` can be used to wrap arbitrary embedding functions. For example, the **text** package [@kjell2023] can be used to generate embeddings using any model available from Hugging Face Transformers [@wolf2020]. This ability to wrap arbitrary functions is useful for analyses which require multiple corpora to be embedded in the same manner.


```r
# add embeddings to data frame
valence_sbert_df <- valence_df |> 
	embed_docs("text", text::textEmbed, id_col = "id", .keep_all = TRUE)
```

### Quanteda Compatibility

The examples above used a **tidyverse** approach with tibbles as the primary data structure, but **embedplyr** functions can be used similarly within a **quanteda** workflow. In the example below, I reproduce the text embedding shown above using `textstat_embedding()` (following **quanteda** naming standards) as opposed to `embed_docs()`.


```r
library(quanteda)

# corpus
psych_embeddings_corp <- corpus(psych_embeddings_df, docid_field = "id")

# dfm
psych_embeddings_dfm <- psych_embeddings_corp |> 
	tokens() |> 
	dfm()

# compute embeddings
psych_embeddings_df <- psych_embeddings_dfm |> 
	textstat_embedding(glove_twitter_25d)
```

### Similarity Metrics

Functions for similarity and distance metrics are as simple as possible; each one takes in vectors and outputs a scalar. In addition to cosine similarity, Euclidean distance, and dot product, **embedplyr** functions also support projection to anchored vectors [@grand2022], as shown in the examples above.


```r
dot_product <- dot_prod(vec1, vec2)
cosine_similarity <- cos_sim(vec1, vec2)
euclidean_distance <- euc_dist(vec1, vec2)
semantic_projection <- anchored_sim(vec1, pos = vec2, neg = vec3)
```

### Reduce Dimensionality

It is sometimes useful to reduce the dimensionality of embeddings. This is done with `reduce_dimensionality()`, which by default performs PCA without column normalization. Reducing the dimensionality to two or three dimensions can be useful for visualization.


```r
valence_df_2d <- psych_embeddings_df |> 
	reduce_dimensionality(dim_1:dim_25, 2)
valence_df_2d
```

```
## # A tibble: 3 x 3
##   doc_id        PC1    PC2
## * <chr>       <dbl>  <dbl>
## 1 control     0.111  0.636
## 2 depression -0.782 -0.245
## 3 anxiety     0.671 -0.391
```

`reduce_dimensionality()` can also be used to apply the same rotation to other embeddings not used to find the principle components. 


```r
new_embeddings <- predict(glove_twitter_25d, c("new", "strange"))

# get rotation with `output_rotation = TRUE`
valence_rotation_2d <- psych_embeddings_df |> 
	reduce_dimensionality(dim_1:dim_25, 2, output_rotation = TRUE)

# apply the same rotation to new embeddings
new_with_valence_rotation <- new_embeddings |> 
	reduce_dimensionality(custom_rotation = valence_rotation_2d)
new_with_valence_rotation
```

```
## # 2-dimensional embeddings with 2 rows
```

```
##         PC1   PC2  
## new      0.73 -0.34
## strange  0.43 -1.50
```

### Align and Compare Embeddings Models

Aligning separately trained embeddings can be useful for tracking semantic change over time or semantic differences between training datasets. It can also be useful for comparing texts across languages. `align_embeddings(x, y)` rotates the embeddings in `x` (and changes their dimensionality if necessary) so that they can be compared with those in `y` [@schonemann1966]. Optionally, `matching` can be used to specify one-to-one matching between  embeddings in the two models (e.g. a bilingual dictionary).

Once aligned, groups of embeddings can be compared using `total_dist()` or `average_sim()`. These can be used to quantify the overall distance or similarity between two parallel embedding spaces.

### Normalize (Scale Embeddings to the Unit Hypersphere)

`normalize()` and `normalize_rows()` scale embeddings such that their magnitude is 1, while their angle from the origin is unchanged.


```r
normalize(1:10)
```

```
##  [1] 0.05096472 0.10192944 0.15289416 0.20385888 0.25482360 0.30578831
##  [7] 0.35675303 0.40771775 0.45868247 0.50964719
```

```r
normalize(moral_embeddings)
```

```
## # 25-dimensional embeddings with 2 rows
```

```
##      dim_1 dim_2 dim_3 dim_4 dim_5 dim_6 dim_7 dim_8 dim_9 dim..      
## good -0.09  0.10 -0.02 -0.00 -0.02  0.10  0.36  0.03 -0.09 -0.04 ...  
## bad   0.08  0.00  0.01 -0.00  0.05  0.13  0.31 -0.02 -0.05  0.02 ...
```

```r
psych_embeddings_normalized <- psych_embeddings_df |>
	normalize_rows(dim_1:dim_25)
```

### Magnitude

The magnitude, norm, or length of a vector is its Euclidean distance from the origin.


```r
magnitude(1:10)
```

```
## [1] 19.62142
```

```r
magnitude(moral_embeddings)
```

```
##     good      bad 
## 6.005552 5.355951
```

### Similarity Matrix

Given an embeddings object or data frame of embeddings, `sim_matrix()` calculates a matrix of similarity scores between the rows of the input. This can be useful for analyzing distributional properties of groups of documents [see e.g. @markus2024] or of groups of tokens [see e.g. @choi2024].


```r
text <- c("lions and tigers and bears", "curious green ideas")

text |> 
	embed_tokens(glove_twitter_25d, output_embeddings = TRUE) |> 
	sim_matrix(method = "euclidean")
```

```
## $text1
##            lions       and    tigers       and
## and    0.6551348                              
## tigers 0.9412290 0.5718049                    
## and    0.6551348 1.0000000 0.5718049          
## bears  0.9272744 0.7349675 0.9095890 0.7349675
## 
## $text2
##         curious     green
## green 0.5011005          
## ideas 0.5823782 0.5410122
```

# Licensing and Availability

**embedplyr** is licensed under the GNU General Public License (v3.0). All of its source code is stored publicly on Github (https://github.com/rimonim/embedplyr), with a corresponding issue tracker.

# References
