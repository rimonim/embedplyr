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
  dot <- x %*% y
  as.vector(dot)
}

#' @rdname sim_metrics
#' @export
cos_sim <- function(x, y){
  dot <- x %*% y
  normx <- sqrt(sum(x^2))
  normy <- sqrt(sum(y^2))
  as.vector( dot / (normx*normy) )
}

#' @rdname sim_metrics
#' @export
euc_dist <- function(x, y){
  diff <- x - y
  sqrt(sum(diff^2))
}

#' @rdname sim_metrics
#' @export
anchored_sim <- function(x, pos, neg){
  # direction vector of the line segment
  line_direction <- pos - neg
  # vector from the starting point of the line to the point
  vector_to_point <- x - pos
  # dot product
  dot <- vector_to_point %*% line_direction
  # squared length of the line segment
  length_squared <- sum(line_direction^2)
  # Calculate t
  t <- dot / length_squared
  as.numeric(t) + 1
}
