% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load_embeddings.R
\name{load_embeddings}
\alias{load_embeddings}
\title{Load Pretrained GloVe, word2vec, and fastText Embeddings}
\usage{
load_embeddings(
  model,
  dir = NULL,
  words = NULL,
  save = TRUE,
  format = "original"
)
}
\arguments{
\item{model}{the name of a supported model}

\item{dir}{directory in which the model is or should be saved when \code{save = TRUE}.
The default is the working directory, \code{\link[=getwd]{getwd()}}. Dir can be set more
permanently using \code{options(embeddings.model.path = dir)}.}

\item{words}{optional list of words for which to retrieve embeddings.}

\item{save}{logical. Should the model be saved to \code{dir} if it does not
already exist there?}

\item{format}{the format in which the model should be saved if it does not
exist already. \code{"original"} (the default) saves the file as is.
Other options are \code{"csv"} or \code{"rds"}.}
}
\description{
Loads pretrained word embeddings. If the specified model has already been
downloaded, it is read from file with \code{\link[=read_embeddings]{read_embeddings()}}. If not, the model
is retrieved from online sources and, by default, saved.
}
\details{
The following are supported models for download. Note that some models are very large.
If you know in advance which word embeddings you will need (e.g. the set of unique
tokens in your corpus), consider specifying this with the \code{words} parameter to save
memory and processing time.
\subsection{GloVe}{

\itemize{
\item \code{glove.42B.300d}: Common Crawl (42B tokens, 1.9M vocab, uncased, 300d). Downloaded from https://huggingface.co/stanfordnlp/glove.
This file is a zip archive and must temporarily be downloaded in its entirety even when \code{words} is specified.
\item \code{glove.840B.300d}: Common Crawl (840B tokens, 2.2M vocab, cased, 300d). Downloaded from https://huggingface.co/stanfordnlp/glove.
This file is a zip archive and must temporarily be downloaded in its entirety even when \code{words} is specified.
\item \code{glove.6B.50d}: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, uncased, 50d). Downloaded from https://github.com/piskvorky/gensim-data
\item \code{glove.6B.100d}: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, uncased, 100d). Downloaded from https://github.com/piskvorky/gensim-data
\item \code{glove.6B.200d}: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, uncased, 200d). Downloaded from https://github.com/piskvorky/gensim-data
\item \code{glove.6B.300d}: Wikipedia 2014 + Gigaword 5 (6B tokens, 400K vocab, uncased, 300d). Downloaded from https://github.com/piskvorky/gensim-data
\item \code{glove.twitter.27B.25d}: Twitter (2B tweets, 27B tokens, 1.2M vocab, uncased, 25d). Downloaded from https://github.com/piskvorky/gensim-data
\item \code{glove.twitter.27B.50d}: Twitter (2B tweets, 27B tokens, 1.2M vocab, uncased, 50d). Downloaded from https://github.com/piskvorky/gensim-data
\item \code{glove.twitter.27B.100d}: Twitter (2B tweets, 27B tokens, 1.2M vocab, uncased, 100d). Downloaded from https://github.com/piskvorky/gensim-data
\item \code{glove.twitter.27B.200d}: Twitter (2B tweets, 27B tokens, 1.2M vocab, uncased, 200d). Downloaded from https://github.com/piskvorky/gensim-data
}
}

\subsection{word2vec}{

Note that reading word2vec bin files may be slower than other formats. If
read time is a concern, consider setting \code{format = "csv"} or \code{format = "rds"}.
\itemize{
\item \code{GoogleNews.vectors.negative300}: Trained with skip-gram on Google News (~100B tokens, 3M vocab, cased, 300d). Downloaded from https://github.com/piskvorky/gensim-data
}
}

\subsection{ConceptNet Numberbatch}{

Multilingual word embeddings trained using an ensemble that combines data from
word2vec, GloVe, OpenSubtitles, and the ConceptNet common sense knowledge database.
Tokens are prefixed with language codes. For example, the English word "token" is
labeled "/c/en/token".
Downloaded from https://github.com/commonsense/conceptnet-numberbatch
\itemize{
\item \code{numberbatch.19.08}: Multilingual (9.2M vocab, uncased, 300d)
}
}

\subsection{fastText}{

300-dimensional word vectors for 157 languages, trained with CBOW on Common
Crawl and Wikipedia. Downloaded from https://fasttext.cc/docs/en/crawl-vectors.html
\itemize{
\item \code{cc.af.300}: Afrikaans
\item \code{cc.sq.300}: Albanian
\item \code{cc.als.300}: Alemannic
\item \code{cc.am.300}: Amharic
\item \code{cc.ar.300}: Arabic
\item \code{cc.an.300}: Aragonese
\item \code{cc.hy.300}: Armenian
\item \code{cc.as.300}: Assamese
\item \code{cc.ast.300}: Asturian
\item \code{cc.az.300}: Azerbaijani
\item \code{cc.ba.300}: Bashkir
\item \code{cc.eu.300}: Basque
\item \code{cc.bar.300}: Bavarian
\item \code{cc.be.300}: Belarusian
\item \code{cc.bn.300}: Bengali
\item \code{cc.bh.300}: Bihari
\item \code{cc.bpy.300}: Bishnupriya Manipuri
\item \code{cc.bs.300}: Bosnian
\item \code{cc.br.300}: Breton
\item \code{cc.bg.300}: Bulgarian
\item \code{cc.my.300}: Burmese
\item \code{cc.ca.300}: Catalan
\item \code{cc.ceb.300}: Cebuano
\item \code{cc.bcl.300}: Central Bicolano
\item \code{cc.ce.300}: Chechen
\item \code{cc.zh.300}: Chinese
\item \code{cc.cv.300}: Chuvash
\item \code{cc.co.300}: Corsican
\item \code{cc.hr.300}: Croatian
\item \code{cc.cs.300}: Czech
\item \code{cc.da.300}: Danish
\item \code{cc.dv.300}: Divehi
\item \code{cc.nl.300}: Dutch
\item \code{cc.pa.300}: Eastern Punjabi
\item \code{cc.arz.300}: Egyptian Arabic
\item \code{cc.eml.300}: Emilian-Romagnol
\item \code{cc.en.300}: English
\item \code{cc.myv.300}: Erzya
\item \code{cc.eo.300}: Esperanto
\item \code{cc.et.300}: Estonian
\item \code{cc.hif.300}: Fiji Hindi
\item \code{cc.fi.300}: Finnish
\item \code{cc.fr.300}: French
\item \code{cc.gl.300}: Galician
\item \code{cc.ka.300}: Georgian
\item \code{cc.de.300}: German
\item \code{cc.gom.300}: Goan Konkani
\item \code{cc.el.300}: Greek
\item \code{cc.gu.300}: Gujarati
\item \code{cc.ht.300}: Haitian
\item \code{cc.he.300}: Hebrew
\item \code{cc.mrj.300}: Hill Mari
\item \code{cc.hi.300}: Hindi
\item \code{cc.hu.300}: Hungarian
\item \code{cc.is.300}: Icelandic
\item \code{cc.io.300}: Ido
\item \code{cc.ilo.300}: Ilokano
\item \code{cc.id.300}: Indonesian
\item \code{cc.ia.300}: Interlingua
\item \code{cc.ga.300}: Irish
\item \code{cc.it.300}: Italian
\item \code{cc.ja.300}: Japanese
\item \code{cc.jv.300}: Javanese
\item \code{cc.kn.300}: Kannada
\item \code{cc.pam.300}: Kapampangan
\item \code{cc.kk.300}: Kazakh
\item \code{cc.km.300}: Khmer
\item \code{cc.ky.300}: Kirghiz
\item \code{cc.ko.300}: Korean
\item \code{cc.ku.300}: Kurdish (Kurmanji)
\item \code{cc.ckb.300}: Kurdish (Sorani)
\item \code{cc.la.300}: Latin
\item \code{cc.lv.300}: Latvian
\item \code{cc.li.300}: Limburgish
\item \code{cc.lt.300}: Lithuanian
\item \code{cc.lmo.300}: Lombard
\item \code{cc.nds.300}: Low Saxon
\item \code{cc.lb.300}: Luxembourgish
\item \code{cc.mk.300}: Macedonian
\item \code{cc.mai.300}: Maithili
\item \code{cc.mg.300}: Malagasy
\item \code{cc.ms.300}: Malay
\item \code{cc.ml.300}: Malayalam
\item \code{cc.mt.300}: Maltese
\item \code{cc.gv.300}: Manx
\item \code{cc.mr.300}: Marathi
\item \code{cc.mzn.300}: Mazandarani
\item \code{cc.mhr.300}: Meadow Mari
\item \code{cc.min.300}: Minangkabau
\item \code{cc.xmf.300}: Mingrelian
\item \code{cc.mwl.300}: Mirandese
\item \code{cc.mn.300}: Mongolian
\item \code{cc.nah.300}: Nahuatl
\item \code{cc.nap.300}: Neapolitan
\item \code{cc.ne.300}: Nepali
\item \code{cc.new.300}: Newar
\item \code{cc.frr.300}: North Frisian
\item \code{cc.nso.300}: Northern Sotho
\item \code{cc.no.300}: Norwegian (Bokmål)
\item \code{cc.nn.300}: Norwegian (Nynorsk)
\item \code{cc.oc.300}: Occitan
\item \code{cc.or.300}: Oriya
\item \code{cc.os.300}: Ossetian
\item \code{cc.pfl.300}: Palatinate German
\item \code{cc.ps.300}: Pashto
\item \code{cc.fa.300}: Persian
\item \code{cc.pms.300}: Piedmontese
\item \code{cc.pl.300}: Polish
\item \code{cc.pt.300}: Portuguese
\item \code{cc.qu.300}: Quechua
\item \code{cc.ro.300}: Romanian
\item \code{cc.rm.300}: Romansh
\item \code{cc.ru.300}: Russian
\item \code{cc.sah.300}: Sakha
\item \code{cc.sa.300}: Sanskrit
\item \code{cc.sc.300}: Sardinian
\item \code{cc.sco.300}: Scots
\item \code{cc.gd.300}: Scottish Gaelic
\item \code{cc.sr.300}: Serbian
\item \code{cc.sh.300}: Serbo-Croatian
\item \code{cc.scn.300}: Sicilian
\item \code{cc.sd.300}: Sindhi
\item \code{cc.si.300}: Sinhalese
\item \code{cc.sk.300}: Slovak
\item \code{cc.sl.300}: Slovenian
\item \code{cc.so.300}: Somali
\item \code{cc.azb.300}: Southern Azerbaijani
\item \code{cc.es.300}: Spanish
\item \code{cc.su.30}: Sundanese
\item \code{cc.sw.300}: Swahili
\item \code{cc.sv.300}: Swedish
\item \code{cc.tl.300}: Tagalog
\item \code{cc.tg.300}: Tajik
\item \code{cc.ta.300}: Tamil
\item \code{cc.tt.300}: Tatar
\item \code{cc.te.300}: Telugu
\item \code{cc.th.300}: Thai
\item \code{cc.bo.300}: Tibetan
\item \code{cc.tr.300}: Turkish
\item \code{cc.tk.300}: Turkmen
\item \code{cc.uk.300}: Ukrainian
\item \code{cc.hsb.300}: Upper Sorbian
\item \code{cc.ur.300}: Urdu
\item \code{cc.ug.300}: Uyghur
\item \code{cc.uz.300}: Uzbek
\item \code{cc.vec.300}: Venetian
\item \code{cc.vi.300}: Vietnamese
\item \code{cc.vo.300}: Volapük
\item \code{cc.wa.300}: Walloon
\item \code{cc.war.300}: Waray
\item \code{cc.cy.300}: Welsh
\item \code{cc.vls.300}: West Flemish
\item \code{cc.fy.300}: West Frisian
\item \code{cc.pnb.300}: Western Punjabi
\item \code{cc.yi.300}: Yiddish
\item \code{cc.yo.300}: Yoruba
\item \code{cc.diq.300}: Zazaki
\item \code{cc.zea.300}: Zeelandic
}
}
}
\section{Value}{

An embeddings object (a numeric matrix with tokens as rownames)
}

\references{
Bojanowski, P., Grave, E., Joulin, A., and Mikolov, T. (2016). Enriching Word Vectors with Subword Information. arXiv preprint. https://arxiv.org/abs/1607.04606

Mikolov, T., Chen, K., Corrado, G., and Dean, J. (2013). Efficient Estimation of Word Representations in Vector Space. In Proceedings of Workshop at ICLR. https://arxiv.org/pdf/1301.3781

Pennington, J., Socher, R., and Manning, C. D. (2014). GloVe: Global Vectors for Word Representation. https://nlp.stanford.edu/projects/glove/

Speer, R., Chin, J., and Havasi, C. (2017). ConceptNet 5.5: An Open Multilingual Graph of General Knowledge. In proceedings of AAAI 2017. http://aaai.org/ocs/index.php/AAAI/AAAI17/paper/view/14972
}
