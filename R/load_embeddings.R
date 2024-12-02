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
  numberbatch.19.08 = "https://conceptnet.s3.amazonaws.com/downloads/2019/numberbatch/numberbatch-19.08.txt.gz",
  cc.af.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.af.300.vec.gz", # Afrikaans
  cc.sq.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.sq.300.vec.gz", # Albanian
  cc.als.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.als.300.vec.gz", # Alemannic
  cc.am.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.am.300.vec.gz", # Amharic
  cc.ar.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ar.300.vec.gz", # Arabic
  cc.an.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.an.300.vec.gz", # Aragonese
  cc.hy.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.hy.300.vec.gz", # Armenian
  cc.as.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.as.300.vec.gz", # Assamese
  cc.ast.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ast.300.vec.gz", # Asturian
  cc.az.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.az.300.vec.gz", # Azerbaijani
  cc.ba.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ba.300.vec.gz", # Bashkir
  cc.eu.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.eu.300.vec.gz", # Basque
  cc.bar.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.bar.300.vec.gz", # Bavarian
  cc.be.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.be.300.vec.gz", # Belarusian
  cc.bn.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.bn.300.vec.gz", # Bengali
  cc.bh.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.bh.300.vec.gz", # Bihari
  cc.bpy.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.bpy.300.vec.gz", # Bishnupriya Manipuri
  cc.bs.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.bs.300.vec.gz", # Bosnian
  cc.br.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.br.300.vec.gz", # Breton
  cc.bg.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.bg.300.vec.gz", # Bulgarian
  cc.my.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.my.300.vec.gz", # Burmese
  cc.ca.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ca.300.vec.gz", # Catalan
  cc.ceb.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ceb.300.vec.gz", # Cebuano
  cc.bcl.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.bcl.300.vec.gz", # Central Bicolano
  cc.ce.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ce.300.vec.gz", # Chechen
  cc.zh.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.zh.300.vec.gz", # Chinese
  cc.cv.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.cv.300.vec.gz", # Chuvash
  cc.co.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.co.300.vec.gz", # Corsican
  cc.hr.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.hr.300.vec.gz", # Croatian
  cc.cs.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.cs.300.vec.gz", # Czech
  cc.da.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.da.300.vec.gz", # Danish
  cc.dv.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.dv.300.vec.gz", # Divehi
  cc.nl.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.nl.300.vec.gz", # Dutch
  cc.pa.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.pa.300.vec.gz", # Eastern Punjabi
  cc.arz.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.arz.300.vec.gz", # Egyptian Arabic
  cc.eml.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.eml.300.vec.gz", # Emilian-Romagnol
  cc.en.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.en.300.vec.gz", # English
  cc.myv.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.myv.300.vec.gz", # Erzya
  cc.eo.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.eo.300.vec.gz", # Esperanto
  cc.et.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.et.300.vec.gz", # Estonian
  cc.hif.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.hif.300.vec.gz", # Fiji Hindi
  cc.fi.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.fi.300.vec.gz", # Finnish
  cc.fr.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.fr.300.vec.gz", # French
  cc.gl.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.gl.300.vec.gz", # Galician
  cc.ka.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ka.300.vec.gz", # Georgian
  cc.de.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.de.300.vec.gz", # German
  cc.gom.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.gom.300.vec.gz", # Goan Konkani
  cc.el.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.el.300.vec.gz", # Greek
  cc.gu.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.gu.300.vec.gz", # Gujarati
  cc.ht.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ht.300.vec.gz", # Haitian
  cc.he.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.he.300.vec.gz", # Hebrew
  cc.mrj.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.mrj.300.vec.gz", # Hill Mari
  cc.hi.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.hi.300.vec.gz", # Hindi
  cc.hu.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.hu.300.vec.gz", # Hungarian
  cc.is.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.is.300.vec.gz", # Icelandic
  cc.io.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.io.300.vec.gz", # Ido
  cc.ilo.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ilo.300.vec.gz", # Ilokano
  cc.id.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.id.300.vec.gz", # Indonesian
  cc.ia.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ia.300.vec.gz", # Interlingua
  cc.ga.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ga.300.vec.gz", # Irish
  cc.it.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.it.300.vec.gz", # Italian
  cc.ja.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ja.300.vec.gz", # Japanese
  cc.jv.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.jv.300.vec.gz", # Javanese
  cc.kn.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.kn.300.vec.gz", # Kannada
  cc.pam.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.pam.300.vec.gz", # Kapampangan
  cc.kk.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.kk.300.vec.gz", # Kazakh
  cc.km.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.km.300.vec.gz", # Khmer
  cc.ky.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ky.300.vec.gz", # Kirghiz
  cc.ko.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ko.300.vec.gz", # Korean
  cc.ku.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ku.300.vec.gz", # Kurdish (Kurmanji)
  cc.ckb.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ckb.300.vec.gz", # Kurdish (Sorani)
  cc.la.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.la.300.vec.gz", # Latin
  cc.lv.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.lv.300.vec.gz", # Latvian
  cc.li.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.li.300.vec.gz", # Limburgish
  cc.lt.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.lt.300.vec.gz", # Lithuanian
  cc.lmo.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.lmo.300.vec.gz", # Lombard
  cc.nds.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.nds.300.vec.gz", # Low Saxon
  cc.lb.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.lb.300.vec.gz", # Luxembourgish
  cc.mk.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.mk.300.vec.gz", # Macedonian
  cc.mai.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.mai.300.vec.gz", # Maithili
  cc.mg.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.mg.300.vec.gz", # Malagasy
  cc.ms.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ms.300.vec.gz", # Malay
  cc.ml.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ml.300.vec.gz", # Malayalam
  cc.mt.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.mt.300.vec.gz", # Maltese
  cc.gv.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.gv.300.vec.gz", # Manx
  cc.mr.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.mr.300.vec.gz", # Marathi
  cc.mzn.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.mzn.300.vec.gz", # Mazandarani
  cc.mhr.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.mhr.300.vec.gz", # Meadow Mari
  cc.min.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.min.300.vec.gz", # Minangkabau
  cc.xmf.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.xmf.300.vec.gz", # Mingrelian
  cc.mwl.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.mwl.300.vec.gz", # Mirandese
  cc.mn.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.mn.300.vec.gz", # Mongolian
  cc.nah.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.nah.300.vec.gz", # Nahuatl
  cc.nap.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.nap.300.vec.gz", # Neapolitan
  cc.ne.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ne.300.vec.gz", # Nepali
  cc.new.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.new.300.vec.gz", # Newar
  cc.frr.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.frr.300.vec.gz", # North Frisian
  cc.nso.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.nso.300.vec.gz", # Northern Sotho
  cc.no.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.no.300.vec.gz", # Norwegian (Bokmål)
  cc.nn.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.nn.300.vec.gz", # Norwegian (Nynorsk)
  cc.oc.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.oc.300.vec.gz", # Occitan
  cc.or.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.or.300.vec.gz", # Oriya
  cc.os.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.os.300.vec.gz", # Ossetian
  cc.pfl.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.pfl.300.vec.gz", # Palatinate German
  cc.ps.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ps.300.vec.gz", # Pashto
  cc.fa.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.fa.300.vec.gz", # Persian
  cc.pms.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.pms.300.vec.gz", # Piedmontese
  cc.pl.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.pl.300.vec.gz", # Polish
  cc.pt.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.pt.300.vec.gz", # Portuguese
  cc.qu.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.qu.300.vec.gz", # Quechua
  cc.ro.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ro.300.vec.gz", # Romanian
  cc.rm.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.rm.300.vec.gz", # Romansh
  cc.ru.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ru.300.vec.gz", # Russian
  cc.sah.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.sah.300.vec.gz", # Sakha
  cc.sa.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.sa.300.vec.gz", # Sanskrit
  cc.sc.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.sc.300.vec.gz", # Sardinian
  cc.sco.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.sco.300.vec.gz", # Scots
  cc.gd.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.gd.300.vec.gz", # Scottish Gaelic
  cc.sr.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.sr.300.vec.gz", # Serbian
  cc.sh.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.sh.300.vec.gz", # Serbo-Croatian
  cc.scn.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.scn.300.vec.gz", # Sicilian
  cc.sd.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.sd.300.vec.gz", # Sindhi
  cc.si.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.si.300.vec.gz", # Sinhalese
  cc.sk.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.sk.300.vec.gz", # Slovak
  cc.sl.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.sl.300.vec.gz", # Slovenian
  cc.so.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.so.300.vec.gz", # Somali
  cc.azb.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.azb.300.vec.gz", # Southern Azerbaijani
  cc.es.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.es.300.vec.gz", # Spanish
  cc.su.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.su.300.vec.gz", # Sundanese
  cc.sw.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.sw.300.vec.gz", # Swahili
  cc.sv.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.sv.300.vec.gz", # Swedish
  cc.tl.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.tl.300.vec.gz", # Tagalog
  cc.tg.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.tg.300.vec.gz", # Tajik
  cc.ta.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ta.300.vec.gz", # Tamil
  cc.tt.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.tt.300.vec.gz", # Tatar
  cc.te.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.te.300.vec.gz", # Telugu
  cc.th.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.th.300.vec.gz", # Thai
  cc.bo.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.bo.300.vec.gz", # Tibetan
  cc.tr.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.tr.300.vec.gz", # Turkish
  cc.tk.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.tk.300.vec.gz", # Turkmen
  cc.uk.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.uk.300.vec.gz", # Ukrainian
  cc.hsb.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.hsb.300.vec.gz", # Upper Sorbian
  cc.ur.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ur.300.vec.gz", # Urdu
  cc.ug.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ug.300.vec.gz", # Uyghur
  cc.uz.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.uz.300.vec.gz", # Uzbek
  cc.vec.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.vec.300.vec.gz", # Venetian
  cc.vi.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.vi.300.vec.gz", # Vietnamese
  cc.vo.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.vo.300.vec.gz", # Volapük
  cc.wa.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.wa.300.vec.gz", # Walloon
  cc.war.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.war.300.vec.gz", # Waray
  cc.cy.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.cy.300.vec.gz", # Welsh
  cc.vls.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.vls.300.vec.gz", # West Flemish
  cc.fy.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.fy.300.vec.gz", # West Frisian
  cc.pnb.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.pnb.300.vec.gz", # Western Punjabi
  cc.yi.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.yi.300.vec.gz", # Yiddish
  cc.yo.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.yo.300.vec.gz", # Yoruba
  cc.diq.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.diq.300.vec.gz", # Zazaki
  cc.zea.300 = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.zea.300.vec.gz" # Zeelandic
)

#' Load Pretrained GloVe, word2vec, and fastText Embeddings
#'
#' Loads pretrained word embeddings. If the specified model has already been
#' downloaded, it is read from file with [read_embeddings()]. If not, the model
#' is retrieved from online sources and, by default, saved.
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
#' Other options are `"csv"` or `"rds"`.
#'
#' @details
#' The following are supported models for download. Note that some models are very large.
#' If you know in advance which word embeddings you will need (e.g. the set of unique
#' tokens in your corpus), consider specifying this with the `words` parameter to save
#' memory and processing time.
#' ## GloVe
#' \itemize{
#'   \item `glove.42B.300d`: Common Crawl (42B tokens, 1.9M vocab, uncased, 300d). Downloaded from https://huggingface.co/stanfordnlp/glove.
#'   This file is a zip archive and must temporarily be downloaded in its entirety even when `words` is specified.
#'   \item `glove.840B.300d`: Common Crawl (840B tokens, 2.2M vocab, cased, 300d). Downloaded from https://huggingface.co/stanfordnlp/glove.
#'   This file is a zip archive and must temporarily be downloaded in its entirety even when `words` is specified.
#'   \item `glove.6B.50d`: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, uncased, 50d). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.6B.100d`: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, uncased, 100d). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.6B.200d`: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, uncased, 200d). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.6B.300d`: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, uncased, 300d). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.twitter.27B.25d`: Twitter (2B tweets, 27B tokens, 1.2M vocab, uncased, 25d). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.twitter.27B.50d`: Twitter (2B tweets, 27B tokens, 1.2M vocab, uncased, 50d). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.twitter.27B.100d`: Twitter (2B tweets, 27B tokens, 1.2M vocab, uncased, 100d). Downloaded from https://github.com/piskvorky/gensim-data
#'   \item `glove.twitter.27B.200d`: Twitter (2B tweets, 27B tokens, 1.2M vocab, uncased, 200d). Downloaded from https://github.com/piskvorky/gensim-data
#' }
#' ## word2vec
#' \itemize{
#'   \item `GoogleNews.vectors.negative300`: Trained with skip-gram on Google News (~100B tokens, 3M vocab, cased, 300d). Downloaded from https://github.com/piskvorky/gensim-data
#' }
#' ### ConceptNet Numberbatch
#' Multilingual word embeddings trained using an ensemble that combines data from
#' word2vec, GloVe, OpenSubtitles, and the ConceptNet common sense knowledge database.
#' Tokens are prefixed with language codes. For example, the English word "token" is
#' labeled "/c/en/token".
#' Downloaded from https://github.com/commonsense/conceptnet-numberbatch
#' \itemize{
#'   \item `numberbatch.19.08`: Multilingual (9.2M vocab, uncased, 300d)
#' }
#' ## fastText
#' 300-dimensional word vectors for 157 languages, trained with CBOW on Common
#' Crawl and Wikipedia. Downloaded from https://fasttext.cc/docs/en/crawl-vectors.html
#' \itemize{
#'   \item `cc.af.300`: Afrikaans
#'   \item `cc.sq.300`: Albanian
#'   \item `cc.als.300`: Alemannic
#'   \item `cc.am.300`: Amharic
#'   \item `cc.ar.300`: Arabic
#'   \item `cc.an.300`: Aragonese
#'   \item `cc.hy.300`: Armenian
#'   \item `cc.as.300`: Assamese
#'   \item `cc.ast.300`: Asturian
#'   \item `cc.az.300`: Azerbaijani
#'   \item `cc.ba.300`: Bashkir
#'   \item `cc.eu.300`: Basque
#'   \item `cc.bar.300`: Bavarian
#'   \item `cc.be.300`: Belarusian
#'   \item `cc.bn.300`: Bengali
#'   \item `cc.bh.300`: Bihari
#'   \item `cc.bpy.300`: Bishnupriya Manipuri
#'   \item `cc.bs.300`: Bosnian
#'   \item `cc.br.300`: Breton
#'   \item `cc.bg.300`: Bulgarian
#'   \item `cc.my.300`: Burmese
#'   \item `cc.ca.300`: Catalan
#'   \item `cc.ceb.300`: Cebuano
#'   \item `cc.bcl.300`: Central Bicolano
#'   \item `cc.ce.300`: Chechen
#'   \item `cc.zh.300`: Chinese
#'   \item `cc.cv.300`: Chuvash
#'   \item `cc.co.300`: Corsican
#'   \item `cc.hr.300`: Croatian
#'   \item `cc.cs.300`: Czech
#'   \item `cc.da.300`: Danish
#'   \item `cc.dv.300`: Divehi
#'   \item `cc.nl.300`: Dutch
#'   \item `cc.pa.300`: Eastern Punjabi
#'   \item `cc.arz.300`: Egyptian Arabic
#'   \item `cc.eml.300`: Emilian-Romagnol
#'   \item `cc.en.300`: English
#'   \item `cc.myv.300`: Erzya
#'   \item `cc.eo.300`: Esperanto
#'   \item `cc.et.300`: Estonian
#'   \item `cc.hif.300`: Fiji Hindi
#'   \item `cc.fi.300`: Finnish
#'   \item `cc.fr.300`: French
#'   \item `cc.gl.300`: Galician
#'   \item `cc.ka.300`: Georgian
#'   \item `cc.de.300`: German
#'   \item `cc.gom.300`: Goan Konkani
#'   \item `cc.el.300`: Greek
#'   \item `cc.gu.300`: Gujarati
#'   \item `cc.ht.300`: Haitian
#'   \item `cc.he.300`: Hebrew
#'   \item `cc.mrj.300`: Hill Mari
#'   \item `cc.hi.300`: Hindi
#'   \item `cc.hu.300`: Hungarian
#'   \item `cc.is.300`: Icelandic
#'   \item `cc.io.300`: Ido
#'   \item `cc.ilo.300`: Ilokano
#'   \item `cc.id.300`: Indonesian
#'   \item `cc.ia.300`: Interlingua
#'   \item `cc.ga.300`: Irish
#'   \item `cc.it.300`: Italian
#'   \item `cc.ja.300`: Japanese
#'   \item `cc.jv.300`: Javanese
#'   \item `cc.kn.300`: Kannada
#'   \item `cc.pam.300`: Kapampangan
#'   \item `cc.kk.300`: Kazakh
#'   \item `cc.km.300`: Khmer
#'   \item `cc.ky.300`: Kirghiz
#'   \item `cc.ko.300`: Korean
#'   \item `cc.ku.300`: Kurdish (Kurmanji)
#'   \item `cc.ckb.300`: Kurdish (Sorani)
#'   \item `cc.la.300`: Latin
#'   \item `cc.lv.300`: Latvian
#'   \item `cc.li.300`: Limburgish
#'   \item `cc.lt.300`: Lithuanian
#'   \item `cc.lmo.300`: Lombard
#'   \item `cc.nds.300`: Low Saxon
#'   \item `cc.lb.300`: Luxembourgish
#'   \item `cc.mk.300`: Macedonian
#'   \item `cc.mai.300`: Maithili
#'   \item `cc.mg.300`: Malagasy
#'   \item `cc.ms.300`: Malay
#'   \item `cc.ml.300`: Malayalam
#'   \item `cc.mt.300`: Maltese
#'   \item `cc.gv.300`: Manx
#'   \item `cc.mr.300`: Marathi
#'   \item `cc.mzn.300`: Mazandarani
#'   \item `cc.mhr.300`: Meadow Mari
#'   \item `cc.min.300`: Minangkabau
#'   \item `cc.xmf.300`: Mingrelian
#'   \item `cc.mwl.300`: Mirandese
#'   \item `cc.mn.300`: Mongolian
#'   \item `cc.nah.300`: Nahuatl
#'   \item `cc.nap.300`: Neapolitan
#'   \item `cc.ne.300`: Nepali
#'   \item `cc.new.300`: Newar
#'   \item `cc.frr.300`: North Frisian
#'   \item `cc.nso.300`: Northern Sotho
#'   \item `cc.no.300`: Norwegian (Bokmål)
#'   \item `cc.nn.300`: Norwegian (Nynorsk)
#'   \item `cc.oc.300`: Occitan
#'   \item `cc.or.300`: Oriya
#'   \item `cc.os.300`: Ossetian
#'   \item `cc.pfl.300`: Palatinate German
#'   \item `cc.ps.300`: Pashto
#'   \item `cc.fa.300`: Persian
#'   \item `cc.pms.300`: Piedmontese
#'   \item `cc.pl.300`: Polish
#'   \item `cc.pt.300`: Portuguese
#'   \item `cc.qu.300`: Quechua
#'   \item `cc.ro.300`: Romanian
#'   \item `cc.rm.300`: Romansh
#'   \item `cc.ru.300`: Russian
#'   \item `cc.sah.300`: Sakha
#'   \item `cc.sa.300`: Sanskrit
#'   \item `cc.sc.300`: Sardinian
#'   \item `cc.sco.300`: Scots
#'   \item `cc.gd.300`: Scottish Gaelic
#'   \item `cc.sr.300`: Serbian
#'   \item `cc.sh.300`: Serbo-Croatian
#'   \item `cc.scn.300`: Sicilian
#'   \item `cc.sd.300`: Sindhi
#'   \item `cc.si.300`: Sinhalese
#'   \item `cc.sk.300`: Slovak
#'   \item `cc.sl.300`: Slovenian
#'   \item `cc.so.300`: Somali
#'   \item `cc.azb.300`: Southern Azerbaijani
#'   \item `cc.es.300`: Spanish
#'   \item `cc.su.30`: Sundanese
#'   \item `cc.sw.300`: Swahili
#'   \item `cc.sv.300`: Swedish
#'   \item `cc.tl.300`: Tagalog
#'   \item `cc.tg.300`: Tajik
#'   \item `cc.ta.300`: Tamil
#'   \item `cc.tt.300`: Tatar
#'   \item `cc.te.300`: Telugu
#'   \item `cc.th.300`: Thai
#'   \item `cc.bo.300`: Tibetan
#'   \item `cc.tr.300`: Turkish
#'   \item `cc.tk.300`: Turkmen
#'   \item `cc.uk.300`: Ukrainian
#'   \item `cc.hsb.300`: Upper Sorbian
#'   \item `cc.ur.300`: Urdu
#'   \item `cc.ug.300`: Uyghur
#'   \item `cc.uz.300`: Uzbek
#'   \item `cc.vec.300`: Venetian
#'   \item `cc.vi.300`: Vietnamese
#'   \item `cc.vo.300`: Volapük
#'   \item `cc.wa.300`: Walloon
#'   \item `cc.war.300`: Waray
#'   \item `cc.cy.300`: Welsh
#'   \item `cc.vls.300`: West Flemish
#'   \item `cc.fy.300`: West Frisian
#'   \item `cc.pnb.300`: Western Punjabi
#'   \item `cc.yi.300`: Yiddish
#'   \item `cc.yo.300`: Yoruba
#'   \item `cc.diq.300`: Zazaki
#'   \item `cc.zea.300`: Zeelandic
#' }
#'
#' @section Value:
#' An embeddings object (a numeric matrix with tokens as rownames)
#'
#' @references
#' Bojanowski, P., Grave, E., Joulin, A., and Mikolov, T. (2016). Enriching Word Vectors with Subword Information. arXiv preprint. https://arxiv.org/abs/1607.04606
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
  stopifnot("Unrecognized model. Please specify a supported model." = model %in% names(supported_models))
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
    download_link <- supported_models[[model]]
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
      if (save && format == "original" && is.character(words)) warning("Saving only a subset of words is not supported for original format. Saving full model file.")
      utils::download.file(download_link, model_path, mode = "wb")
    }
  }
  # Read from file if downloaded
  if (!new_download || !(save_last || !save)) {
    message("Reading model from file...")
    if (!new_download && saved_format == "rds") {
      out <- readRDS(model_path)
      if (is.character(words)) out <- predict.embeddings(out, words)
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

#' Read Embeddings From a Text or Binary File
#'
#' Reads GloVe text format, fastText text format, word2vec binary format,
#' and most tabular formats (csv, tsv, etc.)
#'
#' @param path a file path or url
#' @param words optional list of words for which to retrieve embeddings.
#'
#' @details
#' If using a custom tabular format, the file must have tokens in the first column and numbers in all other columns.
#'
#' @section Value:
#' An embeddings object (a numeric matrix with tokens as rownames)

#' @export
read_embeddings <- function(path, words = NULL) {
  path_format <- substring(path, regexpr("\\.([[:alnum:]]+)$", path) + 1L)
  # word2vec binary format
  if (path_format == "bin" || grepl("\\.bin\\.", path) || grepl("word2vec", path)) {
    out <- tryCatch(
      read_word2vec(path, words = words),
      error = function(e) stop(
        conditionMessage(e),
        "\nThis file was assumed based on its name to be written in word2vec bin format. ",
        "This assumption may have been mistaken. "
        )
      )
  }else{
    if (grepl("numberbatch", path)) use_sys <- FALSE else use_sys <- TRUE
    out <- read_table_embeddings(path, words = words, use_sys = use_sys)
  }
  out
}

# check if a file is gzipped
#' @noRd
is_gzipped <- function(file) {
  if (is_url(file)) {
    # For URLs, check if the URL ends with .gz or .gzip
    return(grepl("\\.gz(ip)?$", file, ignore.case = TRUE))
  } else {
    # For local files, check the file signature for gzip magic numbers
    con <- file(file, "rb")
    magic <- readBin(con, "raw", n = 2)
    close(con)
    return(identical(magic, as.raw(c(0x1f, 0x8b))))
  }
}

#' @noRd
read_word2vec_word <- function(f, max_len = 50) {
  number_str <- ""
  for (i in seq_len(max_len)) {
    ch <- suppressWarnings( readChar(f, nchars = 1, useBytes = TRUE) )
    if (ch %in% c(" ", "\n", "\t")) break
    number_str <- paste0(number_str, ch)
  }
  number_str
}

#' @noRd
read_word2vec <- function(path, words = NULL){
  # handle for HTTP requests
  h <- curl::new_handle()
  curl::handle_setopt(h, timeout = 10000);
  curl::handle_setheaders(h, "User-Agent" = "embedplyr (https://github.com/rimonim/embedplyr)")
  # open binary file in read mode
  is_gz <- is_gzipped(path)
  if (is_url(path)) {
    conn <- curl::curl(path, "rb")
    if (is_gz) {
      conn <- gzcon(conn)
    }
  } else {
    conn <- tryCatch({
      if (is_gz) {
        gzfile(path, "rb")
      } else {
        file(path, "rb")
      }
    }, error = function(e) {
      stop("Error opening file: ", conditionMessage(e))
    })
  }
  if (!isOpen(conn)) stop("Input file not found")
  on.exit(close(conn))
  # read header
  vocab_size <- as.numeric(read_word2vec_word(conn))
  dimensions <- as.numeric(read_word2vec_word(conn))
  # read word embeddings
  pb <- utils::txtProgressBar(0, vocab_size, style = 3)
  if (is.null(words)) {
    vocab <- character(vocab_size)
    mat <- matrix(0, nrow = vocab_size, ncol = dimensions)
    for (r in seq_len(vocab_size)) {
      utils::setTxtProgressBar(pb, r)
      vocab[r] <- read_word2vec_word(conn)
      mat[r,seq_len(dimensions)] <- readBin(conn, what = "numeric", size = 4, n = dimensions, endian = "little")
    }
  }else{
    vocab <- character(length(words))
    mat <- matrix(NA, nrow = length(words), ncol = dimensions)
    i <- 1L
    for (r in seq_len(vocab_size)) {
      utils::setTxtProgressBar(pb, r)
      new_word <- read_word2vec_word(conn)
      new_vec <- readBin(conn, what = "numeric", size = 4, n = dimensions, endian = "little")
      if (new_word %in% words) {
        vocab[i] <- new_word
        mat[i,seq_len(dimensions)] <- new_vec
        i <- i + 1L
      }
    }
  }
  close(pb)
  # output embeddings object
  dup <- duplicated(vocab)
  mat <- mat[!dup,]
  rownames(mat) <- vocab[!dup]
  mat <- as.embeddings(mat)
}

#' @noRd
read_table_embeddings <- function(path, words = NULL, use_sys = TRUE, timeout = 1000){
  # read table with token embeddings
  if (is.character(words)) {
    if (grepl("\\.zip$", path, ignore.case = TRUE)) {
      warning("Line by line file reading is not supported for zip files. Loading full file before filtering words.")
      x <- suppressWarnings( data.table::fread(path, quote = "", showProgress = TRUE) )
      x <- x[x[[1]] %in% words,]
    }else{
      x <- fread_filtered(path, words = words, use_sys = use_sys, quote = "", showProgress = TRUE)
      if (nrow(x) == 0){
        x <- data.table::fread(path, nrows = 0, quote = "", showProgress = TRUE)
      }
    }
  }else{
    x <- suppressWarnings( data.table::fread(path, quote = "", showProgress = TRUE) )
  }
  id <- x[[1]]

  # remove duplicates
  duplicates <- duplicated(id)
  if (any(duplicates)) {
    warning("Tokens are not unique. Removing duplicates.")
    x <- x[!duplicates,]
    id <- x[[1]]
  }
  # coerce to numeric matrix
  x <- x[,-1]
  if (!all(sapply(x, is.numeric))) {
    stop("Input is not numeric")
  }
  x <- as.matrix(x)
  # set row and column names
  rownames(x) <- id
  if (all(colnames(x)[-1] == paste0("V",3:(ncol(x)+1L)))) colnames(x) <- NULL
  # update class
  return(as.embeddings(x))
}

# check if a string is a URL
#' @noRd
is_url <- function(x) {
  grepl("^(http|https|ftp)://", x)
}

# read tabular from file or url, ignoring lines that don't start with a word in `words`
#' @noRd
fread_filtered <- function(file, words, use_sys = TRUE, ..., timeout = 1000) {
  # Force use_sys to FALSE on Windows
  if (.Platform$OS.type == "windows") {
    use_sys <- FALSE
  }
  # check for the required system commands
  sys_commands_available <- all(nzchar(Sys.which(c("curl", "gunzip", "awk"))))
  # is file gzipped?
  is_gz <- is_gzipped(file)
  # expand file path
  file <- path.expand(file)
  if (use_sys && sys_commands_available) {
    awk_script <- "NR==FNR{words[$1]=1;next} words[$1]"
    # write words to temporary file
    wordfile <- tempfile()
    writeLines(words, wordfile)
    # write shell command
    if (is_url(file)) {
      if (is_gz) {
        cmd <- paste(
          "curl -L -s", shQuote(file), "|",
          "gunzip -c |",
          "awk", shQuote(awk_script),
          shQuote(wordfile), "-"
        )
      } else {
        cmd <- paste(
          "curl -L -s", shQuote(file), "|",
          "awk", shQuote(awk_script),
          shQuote(wordfile), "-"
        )
      }
    } else {
      # Local file
      if (is_gz) {
        cmd <- paste(
          "gunzip -c", shQuote(file), "|",
          "awk", shQuote(awk_script),
          shQuote(wordfile), "-"
        )
      } else {
        cmd <- paste(
          "awk", shQuote(awk_script),
          shQuote(wordfile), shQuote(file)
        )
      }
    }

    # Read data and finish up
    data <- data.table::fread(cmd = cmd, ...)
    unlink(wordfile)
    return(data)
  } else {
    # R-only version
    # handle for HTTP requests
    h <- curl::new_handle()
    curl::handle_setopt(h, timeout = 10000);
    curl::handle_setheaders(h, "User-Agent" = "embedplyr (https://github.com/rimonim/embedplyr)")
    # open connection
    if (is_url(file)) {
      conn <- tryCatch({
        if (is_gz) {
          gzcon(curl::curl(file, "rb", handle = h))
        } else {
          curl::curl(file, "rt", handle = h)
        }
      }, error = function(e) {
        stop("Error opening URL: ", conditionMessage(e))
      })
    } else {
      conn <- tryCatch({
        if (is_gz) {
          gzfile(file, "rt")
        } else {
          file(file, "rt")
        }
      }, error = function(e) {
        stop("Error opening file: ", conditionMessage(e))
      })
    }
    on.exit(close(conn))

    # regex for matching words
    pattern <- paste0("^(", paste(words, collapse = "|"), ")\\b")

    # process lines one at a time
    filtered_lines <- character()
    i <- 1
    message("Processing file...")
    line <- readLines(conn, n = 1, warn = FALSE)
    if (!is.na(numlines <- suppressWarnings(as.numeric(strsplit(line, " ")[[1]]))[1])) {
      # number of rows is known from header
      pb <- utils::txtProgressBar(0, numlines, style = 3)
      on.exit(close(pb), add = TRUE)
      for (i in seq_len(numlines)) {
        line <- readLines(conn, n = 1, warn = FALSE)
        if (grepl(pattern, line)) {
          filtered_lines <- c(filtered_lines, line)
          i <- i + 1
        }
        utils::setTxtProgressBar(pb, i)
      }
    }else{
      if (grepl(pattern, line)) filtered_lines <- c(filtered_lines, line)
      while (length(line <- readLines(conn, n = 1, warn = FALSE)) > 0) {
        if (grepl(pattern, line)) {
          filtered_lines <- c(filtered_lines, line)
          i <- i + 1
        }
      }
    }

    # check if any lines were matched
    if (length(filtered_lines) == 0) {
      warning("No embeddings found for items in `words`")
      return(data.table::data.table())
    }

    # convert filtered lines to a data.table
    data <- data.table::fread(text = filtered_lines, header = FALSE, ...)

    return(data)
  }
}
