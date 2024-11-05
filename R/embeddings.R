#' Coercion and checking functions for embeddings objects
#'
#' An embeddings object is a numeric matrix with rownames (generally tokens). Convert an
#' eligible input object into an embeddings object, or check whether an object
#' is an embeddings object.
#'
#' @param x a numeric matrix or dataframe in which the only non-numeric column is specified by `id_col`
#' @param ... additional arguments to be passed to class-specific methods
#' @examples
#' random_mat <- matrix(
#'   sample(1:10, 20, replace = TRUE),
#'   nrow = 2,
#'   dimnames = list(c("happy", "sad"))
#'   )
#' as.embeddings(random_mat)

#' @rdname embeddings
#' @export
as.embeddings <- function(x, ...) {
  UseMethod("as.embeddings")
}

#' @noRd
#' @export
as.embeddings.default <- function(x, ...) {
  if(!any(class(x) %in% c("embeddings", "matrix", "Matrix", "data.frame"))){stop(paste(class(x),collapse = "/"), " object cannot be coerced to embeddings.")}
  if (is.null(colnames(x))){
    colnames(x) <- paste0("dim_", 1:ncol(x))
  }
  class(x) <- c("embeddings", "matrix", "array")
  x
}

#' @noRd
#' @method as.embeddings matrix
#' @export
as.embeddings.matrix <- function(x, ...){
  if (!is.numeric(x)) {
    stop("Input is not numeric")
  }
  as.embeddings.default(x)
}

#' @noRd
#' @method as.embeddings Matrix
#' @export
as.embeddings.Matrix <- function(x, ...){
  if (!is.numeric(x)) {
    stop("Input is not numeric")
  }
  as.embeddings.default(x)
}

#' @rdname embeddings
#' @param id_col column to take row names from. Defaults to "token"
#' @method as.embeddings data.frame
#' @export
as.embeddings.data.frame <- function(x, id_col = "token", ...){
  x <- tibble::column_to_rownames(x, id_col)
  if (!all(sapply(x, is.numeric))) {
    stop("Input contains non-numeric columns other than id_col")
  }
  x <- as.matrix(x, dimnames = list(rownames(x), colnames(x)))
  as.embeddings.default(x)
}

#' @rdname embeddings
#' @export
is.embeddings <- function(x, ...){
  inherits(x, "embeddings")
}
