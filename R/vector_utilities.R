#' Additional Vector Utilities
#'
#' @param points a dataframe, matrix, or embeddings object in which each row
#' represents the coordinates of a point to be projected onto the line
#' @param line_start a vector of representing the coordinates of the line's start
#' @param line_end a vector representing the coordinates of the line's end
#' @details
#' `project_points_onto_line` calculated the projections of a group of points onto
#' a line defined by two end points. It is useful for graphing the positions of
#' embeddings with respect to an anchored vector.
#'
#' @examples
#' emotion_words <- c("happy", "sad", "scared", "angry", "anxious", "grateful")
#' emotion_embeddings <- predict(glove_twitter_25d, emotion_words)
#' emotion_embeddings_2d <- reduce_dimensionality(emotion_embeddings, 2)
#'
#' # project points
#' happy_vec_2d <- predict(emotion_embeddings_2d, "happy")
#' sad_vec_2d <- predict(emotion_embeddings_2d, "sad")
#' emotional_projections <- emotion_embeddings_2d |>
#'   project_points_onto_line(happy_vec_2d, sad_vec_2d)
#'
#' @export
project_points_onto_line <- function(points, line_start, line_end) {

  # direction vector of the line segment
  line_direction <- line_end - line_start

  # vector from the starting point of the line to the points
  vectors_to_points <- t(t(points) - line_start)

  # dot product
  dot_products <- rowSums(vectors_to_points %*% line_direction)

  # calculate t for the projection
  length_squared <- sum(line_direction^2)
  t <- dot_products / length_squared

  # coordinates of the projected points
  line_start_mat <- matrix(line_start, nrow = nrow(points), ncol = length(line_start), byrow = TRUE)
  line_direction_mat <- matrix(line_direction, nrow = nrow(points), ncol = length(line_start), byrow = TRUE)
  projected_points <- line_start_mat + line_direction_mat * t

  # output
  rownames(projected_points) <- rownames(points)
  colnames(projected_points) <- colnames(points)
  if (is.data.frame(points)) {
    projected_points <- data.frame(projected_points)
  }else if(is.embeddings(points)) {
    projected_points <- as.embeddings(projected_points)
  }

  return(projected_points)
}
