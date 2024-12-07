% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/reduce_dimensionality.R
\name{reduce_dimensionality}
\alias{reduce_dimensionality}
\alias{reduce_dimensionality.data.frame}
\alias{reduce_dimensionality.embeddings}
\title{Reduce the Dimensionality of Embeddings}
\usage{
reduce_dimensionality(x, ...)

\method{reduce_dimensionality}{data.frame}(
  x,
  cols,
  reduce_to = NULL,
  center = TRUE,
  scale = FALSE,
  tol = NULL,
  ...,
  custom_rotation = NULL,
  output_rotation = FALSE
)

\method{reduce_dimensionality}{embeddings}(
  x,
  reduce_to = NULL,
  center = TRUE,
  scale = FALSE,
  tol = NULL,
  ...,
  custom_rotation = NULL,
  output_rotation = FALSE
)
}
\arguments{
\item{x}{an \link{embeddings} object or dataframe with one embedding per row, or a
list of such objects}

\item{...}{additional parameters to be passed to class-specific methods}

\item{cols}{tidyselect - columns that contain numeric embedding values}

\item{reduce_to}{number of dimensions to keep.
The value is passed to \code{\link[stats:prcomp]{stats::prcomp()}} as \code{rank.}.}

\item{center}{logical. Should dimensions be shifted to be centered at zero?}

\item{scale}{logical. Should dimensions be scaled to have unit variance?}

\item{tol}{a value indicating a magnitude below which dimensions should be
omitted. (Components are omitted if their standard deviations are less than
or equal to tol times the standard deviation of the first component.) Value
passed to \code{\link[stats:prcomp]{stats::prcomp()}}.}

\item{custom_rotation}{optional rotation specification obtained by calling the
function with \code{output_rotation = TRUE}. This will override \code{reduce_to},
\code{center}, and \code{scale}, and instead simply apply the custom rotation.}

\item{output_rotation}{\code{TRUE} outputs a rotation specification that can be
applied to other embeddings}
}
\description{
Includes methods for dataframes (in the style of \code{dplyr}), embeddings objects, and matrices.
}
\details{
By default, \code{reduce_dimensionality()}, performs principle components analysis
(PCA) without column normalization, and outputs the rotated data. If \code{center = FALSE}
and \code{scale = FALSE}, this is equivalent to singular value decomposition (SVD),
\eqn{X = U \Sigma V^{T}}, where the output columns are equal to the first
\code{reduce_to} columns of \eqn{U \Sigma} that meet the criterion set by \code{tol}.
}
\section{Value}{

If \code{output_rotation = FALSE}, an object of the same class as x, with the same
number of rows but fewer columns. Reduced columns in the output will be named
"PC1", "PC2", etc.

If \code{output_rotation = TRUE}, a list with the following components:
\itemize{
\item \code{rotation}: a rotation matrix
\item \code{center}: a vector describing how much to offset each dimension to
match the centering of \code{x}
\item \code{scale}: a vector with the standard deviation of each column of \code{x}
}

If \code{x} is a list, the function will be called recursively and output a list
of the same length.
}

\examples{
glove_2d <- reduce_dimensionality(glove_twitter_25d, 2)
glove_2d

embeddings_list <- find_nearest(glove_twitter_25d, c("good", "bad"), each = TRUE)
embeddings_list_2d <- reduce_dimensionality(embeddings_list, 2)
embeddings_list_2d

library(tibble)
glove_tbl <- as_tibble(glove_twitter_25d, rownames = "token")
glove_tbl_2d <- glove_tbl |> reduce_dimensionality(dim_1:dim_25, 2)
glove_tbl_2d
}
