% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_sims.R
\name{get_sims}
\alias{get_sims}
\alias{get_sims.embeddings}
\alias{get_sims.data.frame}
\title{Row-wise Similarity and Distance Metrics}
\usage{
get_sims(x, ...)

\method{get_sims}{embeddings}(
  x,
  y,
  method = c("cosine", "cosine_squished", "euclidean", "minkowski", "dot_prod",
    "anchored"),
  ...
)

\method{get_sims}{data.frame}(
  x,
  cols,
  y,
  method = c("cosine", "cosine_squished", "euclidean", "minkowski", "dot_prod",
    "anchored"),
  ...,
  .keep_all = "except.embeddings"
)
}
\arguments{
\item{x}{an embeddings object, matrix, or dataframe with one embedding per row}

\item{...}{additional parameters to be passed to method function}

\item{y}{a named list of vectors with the same dimensionality as embeddings in x.
Each item will result in a column in the output, showing the similarity of each
embedding in x to the vector specified in y. When \code{method = "anchored"},
each item of y should be a list with named vectors \code{pos} and \code{neg}.}

\item{method}{either the name of a method to compute similarity or distance,
or a function that takes two vectors, \code{x} and \code{y}, and outputs a scalar,
similar to those listed in \link[=sim_metrics]{Similarity and Distance Metrics}}

\item{cols}{tidyselect - columns that contain numeric embedding values}

\item{.keep_all}{If \code{TRUE}, all columns from input are retained in output.
If \code{FALSE}, only similarity metrics will be included. If \code{"except.embeddings"}
(the default), all columns except those used to compute the similarity will be retained.}
}
\description{
\code{get_sims(df, col1:col2, list(sim = vec2))} is essentially
equivalent to \code{mutate(rowwise(df), sim = cos_sim(c_across(col1:col2), vec2))}.
Includes methods for dataframes (in the style of \code{dplyr}), embeddings
objects, and matrices.
}
\details{
\subsection{Available Methods}{

When \code{method} is the name of one of the following supported methods,
computations are done with matrix operations and are therefore blazing fast.
\itemize{
\item \code{cosine}: cosine similarity
\item \code{cosine_squished}: cosine similarity, rescaled to range from 0 to 1
\item \code{euclidean}: Euclidean distance
\item \code{minkowski}: Minkowski distance; requires parameter \code{p}. When \code{p = 1}
(the default), this is the Manhattan distance. When \code{p = 2}, it is the
Euclidean distance. When \code{p = Inf}, it is the Chebyshev distance.
\item \code{dot_prod}: Dot product
\item \code{anchored}: \code{x} is projected onto the range between two anchor points,
such that vectors aligned with \code{pos} are given a score of 1 and those aligned
with \code{neg} are given a score of 0. For more on anchored vectors, see
\href{https://ds4psych.com/navigating-vectorspace#sec-dimension-projection}{Data Science for Psychology: Natural Language, Chapter 20}.
}
When \code{method} is a custom function, operations are performed for each row and
may be slow for large inputs.
}
}
\section{Value}{

A tibble with columns \code{doc_id}, and similarity metrics.
If \code{.keep_all = TRUE} or \code{.keep_all = "except.embeddings"}, the new columns
will appear after existing ones.
}

\examples{
valence_embeddings <- predict(glove_twitter_25d, c("good", "bad"))
happy_vec <- predict(glove_twitter_25d, "happy")
sad_vec <- predict(glove_twitter_25d, "sad")

valence_embeddings |>
  get_sims(list(happy = happy_vec))
valence_embeddings |>
  get_sims(
    list(happy = list(pos = happy_vec, neg = sad_vec)),
    anchored_sim
    )
valence_embeddings |>
  get_sims(
    list(happy = happy_vec),
    method = function(x, y) sum(abs(x - y))
    )

valence_df <- tibble::as_tibble(valence_embeddings, rownames = "token")
valence_df |> get_sims(
  dim_1:dim_25,
  list(happy = happy_vec, sad = sad_vec),
  .keep_all = TRUE
  )
}
