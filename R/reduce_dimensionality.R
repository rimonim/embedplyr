#' Reduce the Dimensionality of Embeddings
#'
#' Includes methods for dataframes (in the style of `dplyr`) embeddings objects, and matrices.
#'
#' @param x a dataframe with one embedding per row
#' @param ... additional parameters to be passed to class-specific methods
#' @param cols tidyselect - columns that contain numeric embedding values
#' @param reduce_to number of dimensions to keep
#' @param scale perform scaling in addition to centering?
#'
#' @details
#' The file must have tokens in the first column and numbers in all other columns.
#'
#' @section Value:
#' An embeddings object (a numeric matrix with tokens as rownames)

#' @export
reduce_dimensionality <- function(x, ...) {
  UseMethod("reduce_dimensionality")
}

#' @noRd
#' @export
reduce_dimensionality.default <- function(x, reduce_to, scale, ...) {
  if (any(is.na(x))) {
    warning("Input data contains missing values. Rows dropped in output.")
  }
  pca <- stats::prcomp(~., data = x, scale = scale, rank. = reduce_to)
  out <- pca$x
  rownames(out) <- rownames(x)
  out
}

#' @rdname reduce_dimensionality
#' @method reduce_dimensionality data.frame
#' @export
reduce_dimensionality.data.frame <- function(x, cols, reduce_to, scale = FALSE, ...){
  in_dat <- dplyr::select(x, {{ cols }})
  out_dat <- as.data.frame(reduce_dimensionality.default(x, reduce_to, scale))
  dplyr::bind_cols( dplyr::select(x, -{{ cols }}), out_dat )
}

#' @rdname reduce_dimensionality
#' @method reduce_dimensionality embeddings
#' @export
reduce_dimensionality.embeddings <- function(x, reduce_to, scale = FALSE, ...){
  out_dat <- reduce_dimensionality.default(x, reduce_to, scale)
  as.embeddings(out_dat)
}

#' @rdname reduce_dimensionality
#' @method reduce_dimensionality matrix
#' @export
reduce_dimensionality.matrix <- function(x, reduce_to, scale = FALSE, ...){
  reduce_dimensionality.default(x, reduce_to, scale)
}
