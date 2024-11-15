#' Reduce the Dimensionality of Embeddings
#'
#' Includes methods for dataframes (in the style of `dplyr`), embeddings objects, and matrices.
#'
#' @param x a dataframe, embeddings object, or matrix with one embedding per row
#' @param ... additional parameters to be passed to class-specific methods
#' @param cols tidyselect - columns that contain numeric embedding values
#' @param reduce_to number of dimensions to keep.
#' The value is passed to [stats::prcomp()] as `rank.`.
#' @param center logical. Should dimensions be shifted to be centered at zero?
#' @param scale logical. Should dimensions be scaled to have unit variance?
#' @param custom_rotation optional rotation specification obtained by calling the
#' function with `output_rotation = TRUE`. This will override `reduce_to`,
#' `center`, and `scale`, and instead simply apply the custom rotation.
#' @param output_rotation `TRUE` outputs a rotation specification that can be
#' applied to other embeddings
#'
#' @details
#' By default, `reduce_dimensionality()`, performs principle components analysis
#' (PCA) without column normalization, and outputs the rotated data. If `center = FALSE`
#' and `scale = FALSE`, this is equivalent to singular value decomposition (SVD),
#' \eqn{X = U \Sigma V^{T}}, where the output columns are equal to the first
#' `reduce_to` columns of \eqn{U \Sigma}.
#'
#' @section Value:
#' If `output_rotation = FALSE`, an object of the same class as x, with the same
#' number of rows but fewer columns. Reduced columns in the output will be named
#' "PC1", "PC2", etc.
#'
#' If `output_rotation = TRUE`, a list with the following
#' components:
#' \itemize{
#'   \item `rotation`: a rotation matrix
#'   \item `center`: a vector describing how much to offset each dimension to
#'   match the centering of `x`
#'   \item `scale`: a vector with the standard deviation of each column of `x`
#' }
#'
#' @import tibble
#' @examples
#' glove_2d <- reduce_dimensionality(glove_twitter_25d, 2)
#' glove_2d
#'
#' library(tibble)
#' glove_tbl <- as_tibble(glove_twitter_25d, rownames = "token")
#' glove_tbl_2d <- glove_tbl |> reduce_dimensionality(dim_1:dim_25, 2)
#' glove_tbl_2d

#' @export
reduce_dimensionality <- function(x, ...) {
  UseMethod("reduce_dimensionality")
}

#' @export
reduce_dimensionality.default <- function(x, reduce_to, center = TRUE, scale = FALSE, ..., custom_rotation = NULL, output_rotation = FALSE) {
  if (!is_matrixlike(x)) stop(paste(class(x),collapse = "/"), " object cannot be reduced.")
  if (any(is.na(x))) {
    warning("Input data contains missing values. Rows dropped in output.")
  }
  if (is.null(custom_rotation)) {
    pca <- stats::prcomp(~., data = x, center = center, scale. = scale, rank. = reduce_to)
    if (output_rotation){
      rotation <- pca$rotation
      if (center) center <- colMeans(x, na.rm = TRUE) else center <- 0
      if (scale) scale <- apply(x, 2, sd, na.rm = TRUE) else scale <- 1
      return(list(rotation = rotation, center = center, scale = scale))
    }else{
      out <- pca$x
      rownames(out) <- rownames(x)
      out
    }
  }else{
    if (output_rotation) return(custom_rotation)
    out <- sweep(x, 2, custom_rotation$center)
    out <- t(t(x) / custom_rotation$scale)
    out <- out %*% custom_rotation$rotation
    out
  }
}

#' @rdname reduce_dimensionality
#' @method reduce_dimensionality data.frame
#' @export
reduce_dimensionality.data.frame <- function(x, cols, reduce_to, center = TRUE, scale = FALSE, ..., custom_rotation = NULL, output_rotation = FALSE){
  in_dat <- dplyr::select(x, {{ cols }})
  out_dat <- reduce_dimensionality.default(in_dat, reduce_to, center, scale, custom_rotation = custom_rotation, output_rotation = output_rotation)
  if (output_rotation) return(out_dat)
  out_dat <- as.data.frame(out_dat)
  dplyr::bind_cols( dplyr::select(x, -{{ cols }}), out_dat )
}

#' @rdname reduce_dimensionality
#' @method reduce_dimensionality embeddings
#' @export
reduce_dimensionality.embeddings <- function(x, reduce_to, center = TRUE, scale = FALSE, ..., custom_rotation = NULL, output_rotation = FALSE){
  out_dat <- reduce_dimensionality.default(x, reduce_to, center, scale, custom_rotation = custom_rotation, output_rotation = output_rotation)
  if (output_rotation) return(out_dat)
  as.embeddings(out_dat)
}
