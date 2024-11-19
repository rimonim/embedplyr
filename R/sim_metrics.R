#' Similarity and Distance Metrics
#'
#' Metrics for measuring relationships between vector embeddings.
#'
#' @param x a numeric vector
#' @param y a numeric vector the same length as x
#' @param pos,neg a pair of numeric vectors the same length as x; the positive and negative ends of the anchored vector
#'
#' @details
#' `dot_prod` gives the dot product. `cos_sim` gives the cosine similarity (i.e.
#' the dot product of two normalized vectors). `euc_dist` gives the Euclidean
#' distance. `anchored_sim` gives the position of `x` on the spectrum between two
#' anchor points, where vectors aligned with `pos` are given a score of 1 and those
#' aligned with `neg` are given a score of 0. For more on anchored vectors, see
#' [Data Science for Psychology: Natural Language, Chapter 20](https://ds4psych.com/navigating-vectorspace#sec-dimension-projection).
#' Note that, for a given set of values of `x`, `anchored_sim(x, pos, neg)` will
#' be perfectly correlated with `dot_prod(x, pos - neg)`.
#' @aliases sim_metrics
#' @examples
#' vec1 <- c(1, 5, 2)
#' vec2 <- c(4, 2, 2)
#' vec3 <- c(1, -2, -13)
#'
#' dot_prod(vec1, vec2)
#' cos_sim(vec1, vec2)
#' euc_dist(vec1, vec2)
#' anchored_sim(vec1, vec2, vec3)

#' @rdname sim_metrics
#' @export
dot_prod <- function(x, y){
  stopifnot("x and y must have the same number of dimensions" = length(x) == length(y))
  dot <- x %*% y
  as.numeric(dot)
}

#' @rdname sim_metrics
#' @export
cos_sim <- function(x, y){
  stopifnot("x and y must have the same number of dimensions" = length(x) == length(y))
  dot <- x %*% y
  normx <- sqrt(sum(x^2))
  normy <- sqrt(sum(y^2))
  if (!any(is.na(dot)) && (normx == 0 || normy == 0)) {
    warning("One of the vectors has zero length; returning NA")
    return(NA_real_)
  }
  as.numeric( dot / (normx*normy) )
}

#' @rdname sim_metrics
#' @export
euc_dist <- function(x, y){
  stopifnot("x and y must have the same number of dimensions" = length(x) == length(y))
  diff <- x - y
  sqrt(sum(diff^2))
}

#' @rdname sim_metrics
#' @param p [p-norm](https://en.wikipedia.org/wiki/Lp_space#The_p-norm_in_finite_dimensions) used to compute the Minkowski distance
#' @export
minkowski_dist <- function(x, y, p = 1){
  stopifnot(
    "p must be greater than or equal to 1" = p >= 1,
    "p must be scalar" = length(p) == 1,
    "x and y must have the same number of dimensions" = length(x) == length(y)
    )
  if (is.infinite(p)) return(max(abs(x - y)))
  sum(abs(x - y)^p)^(1/p)
}

#' @rdname sim_metrics
#' @export
anchored_sim <- function(x, pos, neg){
  stopifnot("x, pos, and neg must have the same number of dimensions" = length(x) == length(pos) && length(pos) == length(neg))
  anchored_vec <- pos - neg
  proj <- (x - neg) %*% anchored_vec
  anchored_norm <- sum(anchored_vec^2)
  if (!is.na(anchored_norm) && anchored_norm == 0) {
    warning("Anchored vector has zero length; returning NA")
    return(NA_real_)
  }
  as.numeric(proj) / anchored_norm
}

#' Faster Similarity and Distance Metrics With Matrix Operations
#' @rdname sim_metrics_matrix
#' @param x a numeric matrix or embeddings object
#' @param y a numeric vector of length `ncol(x)`
#' @section Value:
#' A named numeric vector of length `nrow(x)`
#' @keywords internal
dot_prod_matrix <- function(x, y) {
  stopifnot("x and y must have the same number of dimensions" = ncol(x) == length(y))
  x %*% y
}

#' @rdname sim_metrics_matrix
#' @keywords internal
cos_sim_matrix <- function(x, y) {
  stopifnot("x and y must have the same number of dimensions" = ncol(x) == length(y))
  normx <- sqrt(rowSums(x^2))
  normy <- sqrt(sum(y^2))
  norm_prod <- normx * normy
  sims <- (x %*% y) / norm_prod
  sims[norm_prod == 0] <- NA_real_
  as.numeric(sims)
}

#' @rdname sim_metrics_matrix
#' @keywords internal
cos_sim_squished_matrix <- function(x, y) {
  stopifnot("x and y must have the same number of dimensions" = ncol(x) == length(y))
  cos <- cos_sim_matrix(x, y)
  cos*0.5 + 0.5
}

#' @rdname sim_metrics_matrix
#' @keywords internal
euc_dist_matrix <- function(x, y) {
  stopifnot("x and y must have the same number of dimensions" = ncol(x) == length(y))
  diff <- t(t(x) - y)
  sqrt(rowSums(diff^2))
}

#' @rdname sim_metrics_matrix
#' @param p [p-norm](https://en.wikipedia.org/wiki/Lp_space#The_p-norm_in_finite_dimensions) used to compute the Minkowski distance
#' @keywords internal
minkowski_dist_matrix <- function(x, y, p = 1) {
  stopifnot(
    "p must be greater than or equal to 1" = p >= 1,
    "p must be scalar" = length(p) == 1,
    "x and y must have the same number of dimensions" = ncol(x) == length(y)
    )
  diff <- t(t(x) - y)
  if (is.infinite(p)) return(apply(abs(diff), 1, max))
  rowSums(abs(diff)^p)^(1/p)
}

#' @rdname sim_metrics_matrix
#' @keywords internal
anchored_sim_matrix <- function(x, pos, neg) {
  stopifnot("x, pos, and neg must have the same number of dimensions" = ncol(x) == length(pos) && length(pos) == length(neg))
  anchored_vec <- pos - neg
  dot <- t(t(x) - neg) %*% anchored_vec
  out <- as.numeric(dot)/sum(anchored_vec^2)
}
