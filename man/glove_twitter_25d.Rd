% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{glove_twitter_25d}
\alias{glove_twitter_25d}
\title{25-d GloVe Model Pretrained on Twitter (subset)}
\format{
An object of class \code{embeddings} (inherits from \code{matrix}, \code{array}) with 11925 rows and 25 columns.
}
\usage{
glove_twitter_25d
}
\description{
An embeddings object containing a subset of glove.twitter.25d pretrained by
Pennington et al. (2014) on 2B Tweets. This subset includes only embeddings
included in the 12,000 most common English words, as defined by
\href{https://norvig.com/ngrams/count_1w.txt}{Peter Norvig's compilation},
derived from the Google Web Trillion Word Corpus.
Full pretrained GloVe models are available for download at https://nlp.stanford.edu/projects/glove/
}
\references{
Pennington, J., Socher, R., and Manning, C. D. (2014).
GloVe: Global Vectors for Word Representation. https://nlp.stanford.edu/projects/glove/
}
\keyword{data}
\keyword{glove_twitter_25d}
