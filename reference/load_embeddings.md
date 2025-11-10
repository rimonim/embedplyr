# Load Pretrained GloVe, word2vec, and fastText Embeddings

Loads pretrained word embeddings. If the specified model has already
been downloaded, it is read from file with a call to
[`read_embeddings()`](https://rimonim.github.io/embedplyr/reference/read_embeddings.md).
If not, the model is retrieved from online sources and, by default,
saved.

## Usage

``` r
load_embeddings(
  model,
  dir = NULL,
  words = NULL,
  save = TRUE,
  format = "original"
)
```

## Arguments

- model:

  the name of a supported model

- dir:

  directory in which the model is or should be saved when `save = TRUE`.
  The default is the working directory,
  [`getwd()`](https://rdrr.io/r/base/getwd.html). Dir can be set more
  permanently using `options(embeddings.model.path = dir)`.

- words:

  optional list of words for which to retrieve embeddings.

- save:

  logical. Should the model be saved to `dir` if it does not already
  exist there?

- format:

  the format in which the model should be saved if it does not exist
  already. `"original"` (the default) saves the file as is. Other
  options are `"csv"` or `"rds"`. Note that `format = "original"` will
  always save the full file, even if `words` is specified.

## Details

The following are supported models for download. Note that some models
are very large. Listed file sizes are those of the full file to be
downloaded. If you know in advance which word embeddings you will need
(e.g. the set of unique tokens in your corpus), consider specifying this
with the `words` parameter to save memory and processing time.

### GloVe

- `glove.42B.300d`: Common Crawl (42B tokens, 1.9M vocab, uncased, 300d,
  1.88 GB). Downloaded from https://huggingface.co/stanfordnlp/glove.
  This file is a zip archive and must temporarily be downloaded in its
  entirety even when `words` is specified.

- `glove.840B.300d`: Common Crawl (840B tokens, 2.2M vocab, cased, 300d,
  2.18 GB). Downloaded from https://huggingface.co/stanfordnlp/glove.
  This file is a zip archive and must temporarily be downloaded in its
  entirety even when `words` is specified.

- `glove.6B.50d`: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab,
  uncased, 50d, 862 MB). Downloaded from
  https://github.com/piskvorky/gensim-data

- `glove.6B.100d`: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab,
  uncased, 100d, 862 MB). Downloaded from
  https://github.com/piskvorky/gensim-data

- `glove.6B.200d`: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab,
  uncased, 200d, 862 MB). Downloaded from
  https://github.com/piskvorky/gensim-data

- `glove.6B.300d`: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab,
  uncased, 300d, 862 MB). Downloaded from
  https://github.com/piskvorky/gensim-data

- `glove.twitter.27B.25d`: Twitter (2B tweets, 27B tokens, 1.2M vocab,
  uncased, 25d, 1.52 GB). Downloaded from
  https://github.com/piskvorky/gensim-data

- `glove.twitter.27B.50d`: Twitter (2B tweets, 27B tokens, 1.2M vocab,
  uncased, 50d, 1.52 GB). Downloaded from
  https://github.com/piskvorky/gensim-data

- `glove.twitter.27B.100d`: Twitter (2B tweets, 27B tokens, 1.2M vocab,
  uncased, 100d, 1.52 GB). Downloaded from
  https://github.com/piskvorky/gensim-data

- `glove.twitter.27B.200d`: Twitter (2B tweets, 27B tokens, 1.2M vocab,
  uncased, 200d, 1.52 GB). Downloaded from
  https://github.com/piskvorky/gensim-data

### word2vec

Note that reading word2vec bin files may be slower than other formats.
If read time is a concern, consider setting `format = "csv"` or
`format = "rds"`.

- `GoogleNews.vectors.negative300`: Trained with skip-gram on Google
  News (~100B tokens, 3M vocab, cased, 300d, 1.66 GB). Downloaded from
  https://github.com/piskvorky/gensim-data

### HistWords

By-decade skip-gram embeddings trained on Google Books and Corpus of
Historical American English (COHA). To specify a decade, replace
`[decade]` with the first year of that decade (e.g. `eng.all_sgns.1800`,
`eng.all_sgns.1990`). Originally downloaded from
https://nlp.stanford.edu/projects/histwords/

- `coha.word_sgns.[decade]`: Trained on Corpus of Historical American
  English (Genre-Balanced American English, 1830s-2000s, 3-35 MB).

- `coha.lemma_sgns.[decade]`: Same as above, with lemmas rather than
  words (3-28 MB).

- `eng.all_sgns.[decade]`: Trained on Google N-Grams eng-all (All
  English, 1800s-1990s, 31-164 MB).

- `eng.fiction.all_sgns.[decade]`: Trained on Google N-Grams
  eng-fiction-all (English Fiction, 1800s-1990s, 3-56 MB).

- `chi.sim.all_sgns.[decade]`: Trained on Google N-Grams chi-sim-all
  (Simplified Chinese, 1950-1990s, 3-33 MB).

- `fre.all_sgns.[decade]`: Trained on Google N-Grams fre-all (French,
  1800s-1990s, 26-62 MB).

- `ger.all_sgns.[decade]`: Trained on Google N-Grams ger-all (German,
  1800s-1990s, 3-46 MB).

### ConceptNet Numberbatch

Multilingual word embeddings trained using an ensemble that combines
data from word2vec, GloVe, OpenSubtitles, and the ConceptNet common
sense knowledge database. Tokens are prefixed with language codes. For
example, the English word "token" is labeled "/c/en/token". Downloaded
from https://github.com/commonsense/conceptnet-numberbatch

- `numberbatch.19.08`: Multilingual (9.2M vocab, uncased, 300d, 3.19 GB)

### fastText

50-1500 MB. Downloaded from
https://fasttext.cc/docs/en/crawl-vectors.html

- `cc.[language].300`: 300-dimensional word vectors for 157 languages,
  trained with CBOW on Common Crawl and Wikipedia. To specify a
  language, replace `[language]` with one of the following language
  codes: `af` (Afrikaans), `sq` (Albanian), `als` (Alemannic), `am`
  (Amharic), `ar` (Arabic), `an` (Aragonese), `hy` (Armenian), `as`
  (Assamese), `ast` (Asturian), `az` (Azerbaijani), `ba` (Bashkir), `eu`
  (Basque), `bar` (Bavarian), `be` (Belarusian), `bn` (Bengali), `bh`
  (Bihari), `bpy` (Bishnupriya Manipuri), `bs` (Bosnian), `br` (Breton),
  `bg` (Bulgarian), `my` (Burmese), `ca` (Catalan), `ceb` (Cebuano),
  `bcl` (Central Bicolano), `ce` (Chechen), `zh` (Chinese), `cv`
  (Chuvash), `co` (Corsican), `hr` (Croatian), `cs` (Czech), `da`
  (Danish), `dv` (Divehi), `nl` (Dutch), `pa` (Eastern Punjabi), `arz`
  (Egyptian Arabic), `eml` (Emilian-Romagnol), `en` (English), `myv`
  (Erzya), `eo` (Esperanto), `et` (Estonian), `hif` (Fiji Hindi), `fi`
  (Finnish), `fr` (French), `gl` (Galician), `ka` (Georgian), `de`
  (German), `gom` (Goan Konkani), `el` (Greek), `gu` (Gujarati), `ht`
  (Haitian), `he` (Hebrew), `mrj` (Hill Mari), `hi` (Hindi), `hu`
  (Hungarian), `is` (Icelandic), `io` (Ido), `ilo` (Ilokano), `id`
  (Indonesian), `ai` (Interlingua), `ga` (Irish), `it` (Italian), `ja`
  (Japanese), `jv` (Javanese), `kn` (Kannada), `pam` (Kapampangan), `kk`
  (Kazakh), `km` (Khmer), `ky` (Kirghiz), `ko` (Korean), `ku` (Kurdish:
  Kurmanji), `ckb` (Kurdish: Sorani), `la` (Latin), `lv` (Latvian), `li`
  (Limburgish), `lt` (Lithuanian), `lmo` (Lombard), `nds` (Low Saxon),
  `lb` (Luxembourgish), `mk` (Macedonian), `mai` (Maithili), `mg`
  (Malagasy), `ms` (Malay), `ml` (Malayalam), `mt` (Maltese), `gv`
  (Manx), `mr` (Marathi), `mzn` (Mazandarani), `mhr` (Meadow Mari),
  `min` (Minangkabau), `xmf` (Mingrelian), `mwl` (Mirandese), `mn`
  (Mongolian), `nah` (Nahuatl), `nap` (Neapolitan), `ne` (Nepali), `new`
  (Newar), `frr` (North Frisian), `nso` (Northern Sotho), `no`
  (Norwegian: Bokmål), `nn` (Norwegian: Nynorsk), `oc` (Occitan), `or`
  (Oriya), `os` (Ossetian), `pfl` (Palatinate German), `ps` (Pashto),
  `fa` (Persian), `pms` (Piedmontese), `pl` (Polish), `pt` (Portuguese),
  `qu` (Quechua), `ro` (Romanian), `rm` (Romansh), `ru` (Russian), `sah`
  (Sakha), `sa` (Sanskrit), `sc` (Sardinian), `sco` (Scots), `gd`
  (Scottish Gaelic), `sr` (Serbian), `sh` (Serbo-Croatian), `scn`
  (Sicilian), `sd` (Sindhi), `si` (Sinhalese), `sk` (Slovak), `sl`
  (Slovenian), `so` (Somali), `azb` (Southern Azerbaijani), `es`
  (Spanish), `su` (Sundanese), `sw` (Swahili), `sv` (Swedish), `tl`
  (Tagalog), `tg` (Tajik), `ta` (Tamil), `tt` (Tatar), `te` (Telugu),
  `th` (Thai), `bo` (Tibetan), `tr` (Turkish), `tk` (Turkmen), `uk`
  (Ukrainian), `hsb` (Upper Sorbian), `ur` (Urdu), `ug` (Uyghur), `uz`
  (Uzbek), `vec` (Venetian), `vi` (Vietnamese), `vo` (Volapük), `wa`
  (Walloon), `war` (Waray), `cy` (Welsh), `vls` (West Flemish), `fy`
  (West Frisian), `pnb` (Western Punjabi), `yi` (Yiddish), `yu`
  (Yoruba), `diq` (Zazaki), `zea` (Zeelandic)

## Value

An embeddings object (a numeric matrix with tokens as rownames)

## References

Bojanowski, P., Grave, E., Joulin, A., and Mikolov, T. (2016). Enriching
Word Vectors with Subword Information. arXiv preprint.
https://arxiv.org/abs/1607.04606

Hamilton, W. L., Leskovec, J., and Jurafsky, D. (2016). Diachronic Word
Embeddings Reveal Statistical Laws of Semantic Change. In Proceedings of
the 54th Annual Meeting of the ACL. https://aclanthology.org/P16-1141/

Mikolov, T., Chen, K., Corrado, G., and Dean, J. (2013). Efficient
Estimation of Word Representations in Vector Space. In Proceedings of
Workshop at ICLR. https://arxiv.org/pdf/1301.3781

Pennington, J., Socher, R., and Manning, C. D. (2014). GloVe: Global
Vectors for Word Representation.
https://nlp.stanford.edu/projects/glove/

Speer, R., Chin, J., and Havasi, C. (2017). ConceptNet 5.5: An Open
Multilingual Graph of General Knowledge. In proceedings of AAAI 2017.
http://aaai.org/ocs/index.php/AAAI/AAAI17/paper/view/14972
