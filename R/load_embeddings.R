#' Load Pretrained GloVe, word2vec, and fastText Embeddings
#'
#' Loads pretrained word embeddings. If the specified model has already been
#' downloaded, it is read from file with a call to [read_embeddings()]. If not,
#' the model is retrieved from online sources and, by default, saved.
#'
#' @param model the name of a supported model
#' @param dir directory in which the model is or should be saved when `save = TRUE`.
#' The default is the working directory, [getwd()]. Dir can be set more
#' permanently using `options(embeddings.model.path = dir)`.
#' @param words optional list of words for which to retrieve embeddings.
#' @param save logical. Should the model be saved to `dir` if it does not
#' already exist there?
#' @param format the format in which the model should be saved if it does not
#' exist already. `"original"` (the default) saves the file as is.
#' Other options are `"csv"` or `"rds"`. Note that `format = "original"` will
#' always save the full file, even if `words` is specified.
#'
#' @details
#' The following are supported models for download. Note that some models are very large.
#' Listed file sizes are those of the full file to be downloaded.
#' If you know in advance which word embeddings you will need (e.g. the set of unique
#' tokens in your corpus), consider specifying this with the `words` parameter to save
#' memory and processing time.
#' ## GloVe
#' \itemize{
#'   \item `glove.42B.300d`: Common Crawl (42B tokens, 1.9M vocab, uncased, 300d, 1.88 GB). Downloaded from https://huggingface.co/stanfordnlp/glove.
#'   This file is a zip archive and must temporarily be downloaded in its entirety even when `words` is specified.
#'   \item `glove.840B.300d`: Common Crawl (840B tokens, 2.2M vocab, cased, 300d, 2.18 GB). Downloaded from https://huggingface.co/stanfordnlp/glove.
#'   This file is a zip archive and must temporarily be downloaded in its entirety even when `words` is specified.
#'   \item `glove.6B.50d`: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, uncased, 50d, 862 MB). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.6B.100d`: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, uncased, 100d, 862 MB). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.6B.200d`: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, uncased, 200d, 862 MB). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.6B.300d`: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, uncased, 300d, 862 MB). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.twitter.27B.25d`: Twitter (2B tweets, 27B tokens, 1.2M vocab, uncased, 25d, 1.52 GB). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.twitter.27B.50d`: Twitter (2B tweets, 27B tokens, 1.2M vocab, uncased, 50d, 1.52 GB). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.twitter.27B.100d`: Twitter (2B tweets, 27B tokens, 1.2M vocab, uncased, 100d, 1.52 GB). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.twitter.27B.200d`: Twitter (2B tweets, 27B tokens, 1.2M vocab, uncased, 200d, 1.52 GB). Downloaded from https://github.com/piskvorky/gensim-data
#' }
#' ## word2vec
#' Note that reading word2vec bin files may be slower than other formats. If
#' read time is a concern, consider setting `format = "csv"` or `format = "rds"`.
#' \itemize{
#'   \item `GoogleNews.vectors.negative300`: Trained with skip-gram on Google News (~100B tokens, 3M vocab, cased, 300d, 1.66 GB). Downloaded from https://github.com/piskvorky/gensim-data
#' }
#' ## HistWords
#' By-decade skip-gram embeddings trained on Google Books and Corpus of Historical
#' American English (COHA). To specify a decade, replace `[decade]` with the first
#' year of that decade (e.g. `eng.all_sgns.1800`, `eng.all_sgns.1990`).
#' Originally downloaded from https://nlp.stanford.edu/projects/histwords/
#' \itemize{
#'   \item `coha.word_sgns.[decade]`: Trained on Corpus of Historical American English (Genre-Balanced American English, 1830s-2000s, 3-35 MB).
#'   \item `coha.lemma_sgns.[decade]`: Same as above, with lemmas rather than words (3-28 MB).
#'   \item `eng.all_sgns.[decade]`: Trained on Google N-Grams eng-all (All English, 1800s-1990s, 31-164 MB).
#'   \item `eng.fiction.all_sgns.[decade]`: Trained on Google N-Grams eng-fiction-all (English Fiction, 1800s-1990s, 3-56 MB).
#'   \item `chi.sim.all_sgns.[decade]`: Trained on Google N-Grams chi-sim-all (Simplified Chinese, 1950-1990s, 3-33 MB).
#'   \item `fre.all_sgns.[decade]`: Trained on Google N-Grams fre-all (French, 1800s-1990s, 26-62 MB).
#'   \item `ger.all_sgns.[decade]`: Trained on Google N-Grams ger-all (German, 1800s-1990s, 3-46 MB).
#' }
#' ## ConceptNet Numberbatch
#' Multilingual word embeddings trained using an ensemble that combines data from
#' word2vec, GloVe, OpenSubtitles, and the ConceptNet common sense knowledge database.
#' Tokens are prefixed with language codes. For example, the English word "token" is
#' labeled "/c/en/token".
#' Downloaded from https://github.com/commonsense/conceptnet-numberbatch
#' \itemize{
#'   \item `numberbatch.19.08`: Multilingual (9.2M vocab, uncased, 300d, 3.19 GB)
#' }
#' ## fastText
#' 50-1500 MB. Downloaded from https://fasttext.cc/docs/en/crawl-vectors.html
#' \itemize{
#'   \item `cc.[language].300`: 300-dimensional word vectors for 157 languages,
#'   trained with CBOW on Common Crawl and Wikipedia. To specify a language,
#'   replace `[language]` with one of the following language codes:
#'   `af` (Afrikaans), `sq` (Albanian), `als` (Alemannic), `am` (Amharic), `ar`
#'   (Arabic), `an` (Aragonese), `hy` (Armenian), `as` (Assamese), `ast`
#'   (Asturian), `az` (Azerbaijani), `ba` (Bashkir), `eu` (Basque), `bar`
#'   (Bavarian), `be` (Belarusian), `bn` (Bengali), `bh` (Bihari), `bpy`
#'   (Bishnupriya Manipuri), `bs` (Bosnian), `br` (Breton), `bg` (Bulgarian),
#'   `my` (Burmese), `ca` (Catalan), `ceb` (Cebuano), `bcl` (Central Bicolano),
#'   `ce` (Chechen), `zh` (Chinese), `cv` (Chuvash), `co` (Corsican), `hr`
#'   (Croatian), `cs` (Czech), `da` (Danish), `dv` (Divehi), `nl` (Dutch), `pa`
#'   (Eastern Punjabi), `arz` (Egyptian Arabic), `eml` (Emilian-Romagnol), `en`
#'   (English), `myv` (Erzya), `eo` (Esperanto), `et` (Estonian), `hif`
#'   (Fiji Hindi), `fi` (Finnish), `fr` (French), `gl` (Galician), `ka`
#'   (Georgian), `de` (German), `gom` (Goan Konkani), `el` (Greek), `gu`
#'   (Gujarati), `ht` (Haitian), `he` (Hebrew), `mrj` (Hill Mari), `hi` (Hindi),
#'   `hu` (Hungarian), `is` (Icelandic), `io` (Ido), `ilo` (Ilokano), `id`
#'   (Indonesian), `ai` (Interlingua), `ga` (Irish), `it` (Italian), `ja`
#'   (Japanese), `jv` (Javanese), `kn` (Kannada), `pam` (Kapampangan), `kk`
#'   (Kazakh), `km` (Khmer), `ky` (Kirghiz), `ko` (Korean), `ku`
#'   (Kurdish: Kurmanji), `ckb` (Kurdish: Sorani), `la` (Latin), `lv` (Latvian),
#'   `li` (Limburgish), `lt` (Lithuanian), `lmo` (Lombard), `nds` (Low Saxon),
#'   `lb` (Luxembourgish), `mk` (Macedonian), `mai` (Maithili), `mg` (Malagasy),
#'   `ms` (Malay), `ml` (Malayalam), `mt` (Maltese), `gv` (Manx), `mr` (Marathi),
#'   `mzn` (Mazandarani), `mhr` (Meadow Mari), `min` (Minangkabau), `xmf`
#'   (Mingrelian), `mwl` (Mirandese), `mn` (Mongolian), `nah` (Nahuatl), `nap`
#'   (Neapolitan), `ne` (Nepali), `new` (Newar), `frr` (North Frisian), `nso`
#'   (Northern Sotho), `no` (Norwegian: Bokmål), `nn` (Norwegian: Nynorsk), `oc`
#'   (Occitan), `or` (Oriya), `os` (Ossetian), `pfl` (Palatinate German), `ps`
#'   (Pashto), `fa` (Persian), `pms` (Piedmontese), `pl` (Polish), `pt`
#'   (Portuguese), `qu` (Quechua), `ro` (Romanian), `rm` (Romansh), `ru`
#'   (Russian), `sah` (Sakha), `sa` (Sanskrit), `sc` (Sardinian), `sco` (Scots),
#'   `gd` (Scottish Gaelic), `sr` (Serbian), `sh` (Serbo-Croatian), `scn`
#'   (Sicilian), `sd` (Sindhi), `si` (Sinhalese), `sk` (Slovak), `sl`
#'   (Slovenian), `so` (Somali), `azb` (Southern Azerbaijani), `es` (Spanish),
#'   `su` (Sundanese), `sw` (Swahili), `sv` (Swedish), `tl` (Tagalog), `tg`
#'   (Tajik), `ta` (Tamil), `tt` (Tatar), `te` (Telugu), `th` (Thai), `bo`
#'   (Tibetan), `tr` (Turkish), `tk` (Turkmen), `uk` (Ukrainian), `hsb`
#'   (Upper Sorbian), `ur` (Urdu), `ug` (Uyghur), `uz` (Uzbek), `vec` (Venetian),
#'   `vi` (Vietnamese), `vo` (Volapük), `wa` (Walloon), `war` (Waray), `cy`
#'   (Welsh), `vls` (West Flemish), `fy` (West Frisian), `pnb` (Western Punjabi),
#'   `yi` (Yiddish), `yu` (Yoruba), `diq` (Zazaki), `zea` (Zeelandic)
#' }
#'
#' @section Value:
#' An embeddings object (a numeric matrix with tokens as rownames)
#'
#' @references
#' Bojanowski, P., Grave, E., Joulin, A., and Mikolov, T. (2016). Enriching Word Vectors with Subword Information. arXiv preprint. https://arxiv.org/abs/1607.04606
#'
#' Hamilton, W. L., Leskovec, J., and Jurafsky, D. (2016). Diachronic Word Embeddings Reveal Statistical Laws of Semantic Change. In Proceedings of the 54th Annual Meeting of the ACL. https://aclanthology.org/P16-1141/
#'
#' Mikolov, T., Chen, K., Corrado, G., and Dean, J. (2013). Efficient Estimation of Word Representations in Vector Space. In Proceedings of Workshop at ICLR. https://arxiv.org/pdf/1301.3781
#'
#' Pennington, J., Socher, R., and Manning, C. D. (2014). GloVe: Global Vectors for Word Representation. https://nlp.stanford.edu/projects/glove/
#'
#' Speer, R., Chin, J., and Havasi, C. (2017). ConceptNet 5.5: An Open Multilingual Graph of General Knowledge. In proceedings of AAAI 2017. http://aaai.org/ocs/index.php/AAAI/AAAI17/paper/view/14972
#'
#' @importFrom rlang %||%
#' @export
load_embeddings <- function(model, dir = NULL, words = NULL, save = TRUE, format = "original"){
  stopifnot("Unrecognized model. Please specify a supported model." = model %in% supported_model_names)
  dir <- dir %||% getOption("embeddings.model.path", ".")
  # Check if model has already been downloaded
  model_path <- list.files(dir, model, full.names = TRUE)
  new_download <- length(model_path) == 0
  if(length(model_path) > 1){
    warning("More than one file matches `model`. Using the first one.",
            "\nTo specify a specific file path, use `read_embeddings().`",
            call. = FALSE)
    model_path <- model_path[1]
  }
  # Relevant parameters for later
  saved_format <- substring(model_path, regexpr("\\.([[:alnum:]]+)$", model_path) + 1L)
  save_last <- save && (format != "original") && (new_download || !new_download & format != saved_format)
  # Download if needed
  if (new_download) {
    histwords_models <- c("coha.word_sgns.", "coha.lemma_sgns.", "eng.all_sgns.", "eng.fiction.all_sgns.", "chi.sim.all_sgns.", "fre.all_sgns.", "ger.all_sgns.")
    if ((model_repo <- substring(model, 1L, 3L)) == "cc.") {
      download_link <- supported_models[[model_repo]]
      download_link <- paste0(download_link, model, ".vec.gz")
    }else if ((model_repo <- substring(model, 1L, nchar(model) - 4L)) %in% histwords_models) {
      download_link <- supported_models[[model_repo]]
      download_link <- paste0(download_link, model, ".rds")
    }else{
      download_link <- supported_models[[model]]
    }
    if (save_last || !save) {
      message("Reading file from the Internet...")
      out <- read_embeddings(download_link, words = words)
    }else{
      message("Downloading from the Internet...")
      download_format <- substring(download_link, regexpr("\\.([[:alnum:]]+)$", download_link) + 1L)
      if (model == "GoogleNews.vectors.negative300") download_format <- "bin.gz"
      if (model == "numberbatch.19.08") download_format <- "txt.gz"
      if (substring(model, 1L, 2L) == "cc") download_format <- "vec.gz"
      model_path <- file.path(dir, paste0(model, ".", download_format))
      if (save && format == "original" && is.character(words)) warning("Saving only a subset of words is not supported for original format. Saving full model file. To save only a subset of words, set `format` to 'csv' or 'rds'.")
      utils::download.file(download_link, model_path, mode = "wb")
    }
  }
  # Read from file if downloaded
  if (!new_download || !(save_last || !save)) {
    message("Reading model from file...")
    if (!new_download && saved_format == "rds") {
      out <- readRDS(model_path)
      if (is.character(words)) out <- emb(out, words)
    }else{
      out <- read_embeddings(model_path, words)
    }
  }
  # Delete downloaded file if save not requested
  if (new_download && !save) {
    file.remove(model_path)
  }
  # Write processed file if requested
  if (save_last) {
    message("Writing ", format, " file...")
    model_path <- file.path(dir, paste0(model, ".", format))
    if (format == "csv") readr::write_csv(as_tibble(out, rownames = "token"), model_path)
    if (format == "rds") saveRDS(out, model_path)
  }
  out
}

#' @noRd
supported_models <- c(
  glove.42B.300d = "https://huggingface.co/stanfordnlp/glove/resolve/main/glove.42B.300d.zip",
  glove.840B.300d = "https://huggingface.co/stanfordnlp/glove/resolve/main/glove.840B.300d.zip",
  glove.6B.50d = "https://github.com/piskvorky/gensim-data/releases/download/glove-wiki-gigaword-50/glove-wiki-gigaword-50.gz",
  glove.6B.100d = "https://github.com/piskvorky/gensim-data/releases/download/glove-wiki-gigaword-100/glove-wiki-gigaword-100.gz",
  glove.6B.200d = "https://github.com/piskvorky/gensim-data/releases/download/glove-wiki-gigaword-200/glove-wiki-gigaword-200.gz",
  glove.6B.300d = "https://github.com/piskvorky/gensim-data/releases/download/glove-wiki-gigaword-300/glove-wiki-gigaword-300.gz",
  glove.twitter.27B.25d = "https://github.com/piskvorky/gensim-data/releases/download/glove-twitter-25/glove-twitter-25.gz",
  glove.twitter.27B.50d = "https://github.com/piskvorky/gensim-data/releases/download/glove-twitter-50/glove-twitter-50.gz",
  glove.twitter.27B.100d = "https://github.com/piskvorky/gensim-data/releases/download/glove-twitter-100/glove-twitter-100.gz",
  glove.twitter.27B.200d = "https://github.com/piskvorky/gensim-data/releases/download/glove-twitter-200/glove-twitter-200.gz",
  GoogleNews.vectors.negative300 = "https://github.com/piskvorky/gensim-data/releases/download/word2vec-google-news-300/word2vec-google-news-300.gz",
  coha.word_sgns. = "https://huggingface.co/embedplyr/coha.word_sgns/resolve/main/",
  coha.lemma_sgns. = "https://huggingface.co/embedplyr/coha.lemma_sgns/resolve/main/",
  eng.all_sgns. = "https://huggingface.co/embedplyr/eng.all_sgns/resolve/main/",
  eng.fiction.all_sgns. = "https://huggingface.co/embedplyr/eng.fiction.all_sgns/resolve/main/",
  chi.sim.all_sgns. = "https://huggingface.co/embedplyr/chi.sim.all_sgns/resolve/main/",
  fre.all_sgns. = "https://huggingface.co/embedplyr/fre.all_sgns/resolve/main/",
  ger.all_sgns. = "https://huggingface.co/embedplyr/ger.all_sgns/resolve/main/",
  numberbatch.19.08 = "https://conceptnet.s3.amazonaws.com/downloads/2019/numberbatch/numberbatch-19.08.txt.gz",
  cc. = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/"
)

#' @noRd
supported_model_names <- c(
  "glove.42B.300d", "glove.840B.300d", "glove.6B.50d", "glove.6B.100d",
  "glove.6B.200d", "glove.6B.300d", "glove.twitter.27B.25d", "glove.twitter.27B.50d",
  "glove.twitter.27B.100d", "glove.twitter.27B.200d", "GoogleNews.vectors.negative300",
  "coha.word_sgns.1830", "coha.word_sgns.1840", "coha.word_sgns.1850",
  "coha.word_sgns.1860", "coha.word_sgns.1870", "coha.word_sgns.1880",
  "coha.word_sgns.1890", "coha.word_sgns.1900", "coha.word_sgns.1910",
  "coha.word_sgns.1920", "coha.word_sgns.1930", "coha.word_sgns.1940",
  "coha.word_sgns.1950", "coha.word_sgns.1960", "coha.word_sgns.1970",
  "coha.word_sgns.1980", "coha.word_sgns.1990", "coha.word_sgns.2000",
  "coha.lemma_sgns.1830", "coha.lemma_sgns.1840", "coha.lemma_sgns.1850",
  "coha.lemma_sgns.1860", "coha.lemma_sgns.1870", "coha.lemma_sgns.1880",
  "coha.lemma_sgns.1890", "coha.lemma_sgns.1900", "coha.lemma_sgns.1910",
  "coha.lemma_sgns.1920", "coha.lemma_sgns.1930", "coha.lemma_sgns.1940",
  "coha.lemma_sgns.1950", "coha.lemma_sgns.1960", "coha.lemma_sgns.1970",
  "coha.lemma_sgns.1980", "coha.lemma_sgns.1990", "coha.lemma_sgns.2000",
  "eng.all_sgns.1800", "eng.all_sgns.1810", "eng.all_sgns.1820",
  "eng.all_sgns.1830", "eng.all_sgns.1840", "eng.all_sgns.1850",
  "eng.all_sgns.1860", "eng.all_sgns.1870", "eng.all_sgns.1880",
  "eng.all_sgns.1890", "eng.all_sgns.1900", "eng.all_sgns.1910",
  "eng.all_sgns.1920", "eng.all_sgns.1930", "eng.all_sgns.1940",
  "eng.all_sgns.1950", "eng.all_sgns.1960", "eng.all_sgns.1970",
  "eng.all_sgns.1980", "eng.all_sgns.1990",
  "eng.fiction.all_sgns.1800", "eng.fiction.all_sgns.1810", "eng.fiction.all_sgns.1820",
  "eng.fiction.all_sgns.1830", "eng.fiction.all_sgns.1840", "eng.fiction.all_sgns.1850",
  "eng.fiction.all_sgns.1860", "eng.fiction.all_sgns.1870", "eng.fiction.all_sgns.1880",
  "eng.fiction.all_sgns.1890", "eng.fiction.all_sgns.1900", "eng.fiction.all_sgns.1910",
  "eng.fiction.all_sgns.1920", "eng.fiction.all_sgns.1930", "eng.fiction.all_sgns.1940",
  "eng.fiction.all_sgns.1950", "eng.fiction.all_sgns.1960", "eng.fiction.all_sgns.1970",
  "eng.fiction.all_sgns.1980", "eng.fiction.all_sgns.1990",
  "chi.sim.all_sgns.1950", "chi.sim.all_sgns.1960", "chi.sim.all_sgns.1970",
  "chi.sim.all_sgns.1980", "chi.sim.all_sgns.1990",
  "fre.all_sgns.1800", "fre.all_sgns.1810", "fre.all_sgns.1820",
  "fre.all_sgns.1830", "fre.all_sgns.1840", "fre.all_sgns.1850",
  "fre.all_sgns.1860", "fre.all_sgns.1870", "fre.all_sgns.1880",
  "fre.all_sgns.1890", "fre.all_sgns.1900", "fre.all_sgns.1910",
  "fre.all_sgns.1920", "fre.all_sgns.1930", "fre.all_sgns.1940",
  "fre.all_sgns.1950", "fre.all_sgns.1960", "fre.all_sgns.1970",
  "fre.all_sgns.1980", "fre.all_sgns.1990",
  "ger.all_sgns.1800", "ger.all_sgns.1810", "ger.all_sgns.1820",
  "ger.all_sgns.1830", "ger.all_sgns.1840", "ger.all_sgns.1850",
  "ger.all_sgns.1860", "ger.all_sgns.1870", "ger.all_sgns.1880",
  "ger.all_sgns.1890", "ger.all_sgns.1900", "ger.all_sgns.1910",
  "ger.all_sgns.1920", "ger.all_sgns.1930", "ger.all_sgns.1940",
  "ger.all_sgns.1950", "ger.all_sgns.1960", "ger.all_sgns.1970",
  "ger.all_sgns.1980", "ger.all_sgns.1990",
  "numberbatch.19.08",
  "cc.af.300", "cc.sq.300", "cc.als.300", "cc.am.300", "cc.ar.300",
  "cc.an.300", "cc.hy.300", "cc.as.300", "cc.ast.300", "cc.az.300",
  "cc.ba.300", "cc.eu.300", "cc.bar.300", "cc.be.300", "cc.bn.300",
  "cc.bh.300", "cc.bpy.300", "cc.bs.300", "cc.br.300", "cc.bg.300",
  "cc.my.300", "cc.ca.300", "cc.ceb.300", "cc.bcl.300", "cc.ce.300",
  "cc.zh.300", "cc.cv.300", "cc.co.300", "cc.hr.300", "cc.cs.300",
  "cc.da.300", "cc.dv.300", "cc.nl.300", "cc.pa.300", "cc.arz.300",
  "cc.eml.300", "cc.en.300", "cc.myv.300", "cc.eo.300", "cc.et.300",
  "cc.hif.300", "cc.fi.300", "cc.fr.300", "cc.gl.300", "cc.ka.300",
  "cc.de.300", "cc.gom.300", "cc.el.300", "cc.gu.300", "cc.ht.300",
  "cc.he.300", "cc.mrj.300", "cc.hi.300", "cc.hu.300", "cc.is.300",
  "cc.io.300", "cc.ilo.300", "cc.id.300", "cc.ia.300", "cc.ga.300",
  "cc.it.300", "cc.ja.300", "cc.jv.300", "cc.kn.300", "cc.pam.300",
  "cc.kk.300", "cc.km.300", "cc.ky.300", "cc.ko.300", "cc.ku.300",
  "cc.ckb.300", "cc.la.300", "cc.lv.300", "cc.li.300", "cc.lt.300",
  "cc.lmo.300", "cc.nds.300", "cc.lb.300", "cc.mk.300", "cc.mai.300",
  "cc.mg.300", "cc.ms.300", "cc.ml.300", "cc.mt.300", "cc.gv.300",
  "cc.mr.300", "cc.mzn.300", "cc.mhr.300", "cc.min.300", "cc.xmf.300",
  "cc.mwl.300", "cc.mn.300", "cc.nah.300", "cc.nap.300", "cc.ne.300",
  "cc.new.300", "cc.frr.300", "cc.nso.300", "cc.no.300", "cc.nn.300",
  "cc.oc.300", "cc.or.300", "cc.os.300", "cc.pfl.300", "cc.ps.300",
  "cc.fa.300", "cc.pms.300", "cc.pl.300", "cc.pt.300", "cc.qu.300",
  "cc.ro.300", "cc.rm.300", "cc.ru.300", "cc.sah.300", "cc.sa.300",
  "cc.sc.300", "cc.sco.300", "cc.gd.300", "cc.sr.300", "cc.sh.300",
  "cc.scn.300", "cc.sd.300", "cc.si.300", "cc.sk.300", "cc.sl.300",
  "cc.so.300", "cc.azb.300", "cc.es.300", "cc.su.300", "cc.sw.300",
  "cc.sv.300", "cc.tl.300", "cc.tg.300", "cc.ta.300", "cc.tt.300",
  "cc.te.300", "cc.th.300", "cc.bo.300", "cc.tr.300", "cc.tk.300",
  "cc.uk.300", "cc.hsb.300", "cc.ur.300", "cc.ug.300", "cc.uz.300",
  "cc.vec.300", "cc.vi.300", "cc.vo.300", "cc.wa.300", "cc.war.300",
  "cc.cy.300", "cc.vls.300", "cc.fy.300", "cc.pnb.300", "cc.yi.300",
  "cc.yo.300", "cc.diq.300", "cc.zea.300"
  )
