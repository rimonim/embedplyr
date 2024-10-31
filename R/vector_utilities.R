#' Additional Vector Utilities
#'
#' @param line_start a vector of representing the coordinates of the line's start
#' @param line_end a vector representing the coordinates of the line's end
#' @param points_df a dataframe in which each row represents the coordinates of a
#' point to be projected onto the line
#' @details
#' `project_points_onto_line` calculated the projections of a group of points onto
#' a line defined by two end points. It is useful for graphing the positions of
#' embeddings with respect to an anchored vector.
#' @export
project_points_onto_line <- function(line_start, line_end, points_df) {

  # Calculate the direction vector of the line segment
  line_direction <- line_end - line_start

  # Calculate the vector from the starting point of the line to the points
  vectors_to_points <- t(t(points_df) - line_start)

  # Calculate the dot product of the vectors
  dot_products <- rowSums(vectors_to_points %*% line_direction)

  # Calculate the squared length of the line segment
  length_squared <- sum(line_direction^2)

  # Calculate the parameter t for the projection
  t <- dot_products / length_squared

  # Calculate the coordinates of the projected points
  line_start_mat <- matrix(line_start, nrow = nrow(points_df), ncol = length(line_start), byrow = TRUE)
  line_direction_mat <- matrix(line_direction, nrow = nrow(points_df), ncol = length(line_start), byrow = TRUE)
  projected_points <- line_start_mat + line_direction_mat * t

  # Transpose the result to have one column per dimension
  result_df <- data.frame(projected_points)

  return(result_df)
}
