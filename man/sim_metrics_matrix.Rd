% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sim_metrics.R
\name{dot_prod_matrix}
\alias{dot_prod_matrix}
\alias{cos_sim_matrix}
\alias{cos_sim_squished_matrix}
\alias{euc_dist_matrix}
\alias{minkowski_dist_matrix}
\title{Similarity and Distance Matrices}
\usage{
dot_prod_matrix(x, tidy_output = FALSE)

cos_sim_matrix(x, tidy_output = FALSE)

cos_sim_squished_matrix(x, tidy_output = FALSE)

euc_dist_matrix(x, tidy_output = FALSE)

minkowski_dist_matrix(x, p = 1, tidy_output = FALSE)
}
\arguments{
\item{x}{a numeric matrix or embeddings object}

\item{tidy_output}{logical. If \code{FALSE} (the default), output a \link[stats:dist]{stats::dist}
object. If \code{TRUE}, output a tibble with columns \code{doc_id_1}, \code{doc_id_2}, and
the similarity or distance metric.}

\item{p}{\href{https://en.wikipedia.org/wiki/Lp_space#The_p-norm_in_finite_dimensions}{p-norm} used to compute the Minkowski distance}
}
\description{
These functions compute pairwise \link[=sim_metrics]{similarity metrics} between
each row of a matrix.
}
\section{Value}{

A named numeric vector of length \code{nrow(x)}
}

\keyword{internal}
