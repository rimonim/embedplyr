#' Reduce the Dimensionality of Embeddings
#'
#' Includes methods for dataframes (in the style of `dplyr`) embeddings objects, and matrices.
#'
#' @param data a dataframe with one embedding per row
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
reduce_dimensionality <- function(x) {
  UseMethod("reduce_dimensionality")
}

#' @method reduce_dimensionality data.frame
#' @export
reduce_dimensionality.data.frame <- function(data, cols, reduce_to, scale = FALSE){
  in_dat <- dplyr::select(data, {{ cols }})
  if (any(is.na(in_dat))) {
    warning("Input data contains missing values. Rows dropped in output.")
    data <- tidyr::drop_na(data, {{ cols }})
  }
  pca <- stats::prcomp(~., data = in_dat, scale = scale, rank. = reduce_to)
  out_dat <- as.data.frame(pca$x)
  dplyr::bind_cols( select(data, -{{ cols }}), out_dat )
}

#' @method reduce_dimensionality embeddings
#' @export
reduce_dimensionality.embeddings <- function(data, reduce_to, scale = FALSE){
  if (any(is.na(data))) {
    warning("Input data contains missing values. Rows dropped in output.")
  }
  pca <- stats::prcomp(~., data = data, scale = scale, rank. = reduce_to)
  out_dat <- pca$x
  rownames(out_dat) <- rownames(data)
  as.embeddings(out_dat)
}

#' @method reduce_dimensionality matrix
#' @export
reduce_dimensionality.matrix <- function(data, reduce_to, scale = FALSE){
  if (any(is.na(data))) {
    warning("Input data contains missing values. Rows dropped in output.")
  }
  pca <- stats::prcomp(~., data = data, scale = scale, rank. = reduce_to)
  pca$x
}
