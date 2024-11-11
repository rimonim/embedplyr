#' Coercion and checking functions for embeddings objects
#'
#' An embeddings object is a numeric matrix with rownames (generally tokens). Convert an
#' eligible input object into an embeddings object, or check whether an object
#' is an embeddings object.
#'
#' @param x a numeric matrix or dataframe in which the only non-numeric column is specified by `id_col`
#' @param ... additional arguments to be passed to or from class-specific methods
#' @importFrom tibble column_to_rownames as_tibble
#' @examples
#' random_mat <- matrix(
#'   sample(1:10, 20, replace = TRUE),
#'   nrow = 2,
#'   dimnames = list(c("happy", "sad"))
#'   )
#' random_embeddings <- as.embeddings(random_mat)
#' as.matrix(random_embeddings)
#'
#' tibble::as_tibble(random_embeddings, rownames = "token")

#' @rdname embeddings
#' @export
as.embeddings <- function(x, ...) {
  UseMethod("as.embeddings")
}

#' @noRd
#' @export
as.embeddings.default <- function(x, ...) {
  if(!is_matrixlike(x)){stop(sprintf("No method for coercing objects of class '%s' to embeddings.", class(x)))}
  # default row and column names
  if (is.null(rownames(x)) && nrow(x) > 0 || any(duplicated(rownames(x)))){
    warning("unique row names not provided. Naming rows doc_1, doc_2, etc.")
    rownames(x) <- paste0("doc_", seq_len(nrow(x)))
  }
  if (is.null(colnames(x)) && ncol(x) > 0 || any(duplicated(colnames(x)))){
    colnames(x) <- paste0("dim_", seq_len(ncol(x)))
  }
  structure(x, class = c("embeddings", "matrix", "array"))
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
  x <- as.matrix(x)
  if (!is.numeric(x)) {
    stop("Input is not numeric")
  }
  as.embeddings.default(x)
}

#' @noRd
#' @method as.embeddings numeric
#' @export
as.embeddings.numeric <- function(x, ...){
  if (is.array(x) && length(dim(x)) > 1) {
    stop("High dimensional arrays cannot be coerced to embeddings.")
  }
  x <- matrix(x, nrow = 1)
  as.embeddings.default(x)
}

#' @rdname embeddings
#' @usage
#' \method{as.embeddings}{data.frame}(x, id_col = NULL, ...)
#' @param x A data frame to be converted into embeddings.
#' @param id_col Optional column to take row names from.
#' @param ... Additional arguments passed to or from other methods.
#' @export
as.embeddings.data.frame <- function(x, id_col = NULL, ...){
  if (!is.null(id_col)) {
    x <- tibble::column_to_rownames(x, id_col)
  }
  if (!all(sapply(x, is.numeric))) {
    stop("Input contains non-numeric columns other than id_col")
  }
  x <- data.matrix(x)
  as.embeddings.default(x)
}

#' @rdname embeddings
#' @export
is.embeddings <- function(x, ...){
  inherits(x, "embeddings")
}

#' @rdname embeddings
#' @method as.matrix embeddings
#' @export
as.matrix.embeddings <- function(x, ...){
  x <- structure(x, class = c("matrix", "array"))
  as.matrix(x)
}

#' @noRd
#' @method '[' embeddings
#' @export
'[.embeddings' <- function(x, ..., drop = FALSE) {
  out <- NextMethod('[')
  if (is_matrixlike(out)) {
    as.embeddings(out)
  }else{
    out
  }
}

#' @noRd
#' @method 'rownames<-' embeddings
#' @export
'rownames<-.embeddings' <- function(x, value) {
  attr(x, "dimnames")[[1]] <- value
  x <- as.embeddings(x)
}

#' @noRd
#' @method 'colnames<-' embeddings
#' @export
'colnames<-.embeddings' <- function(x, value) {
  attr(x, "dimnames")[[2]] <- value
  x <- as.embeddings(x)
}

#' Check if an object is matrix-like and numeric
#' @param x an object to be checked
#' @keywords internal
is_matrixlike <- function(x) {
  (is.matrix(x) || inherits(x, "Matrix") || is.data.frame(x)) && is.numeric(as.matrix(x))
}

#' @noRd
#' @method as_tibble embeddings
#' @export
as_tibble.embeddings <- function(x, ..., rownames = NULL) {
  x <- as.data.frame(x)
  if (!is.null(rownames)) {
    x <- tibble::rownames_to_column(x, var = rownames)
  }
  tibble::as_tibble(x, ...)
}
