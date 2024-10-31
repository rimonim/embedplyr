#' Coercion and checking functions for embeddings objects
#'
#' An embeddings object is a numeric matrix with rownames (generally tokens). Convert an
#' eligible input object into an embeddings object, or check whether an object
#' is an embeddings object.
#'
#' @param mat a matrix
#' @examples
#'    random_mat <- matrix(
#'       sample(1:10, 20, replace = TRUE),
#'       nrow = 2,
#'       dimnames = list(c("happy", "sad"))
#'       )
#'    as.embeddings(random_mat)

#' @export
as.embeddings <- function(x) {
  UseMethod("as.embeddings")
}

#' @export
as.embeddings.default <- function(x) {
  if(!any(class(x) %in% c("embeddings", "matrix", "Matrix", "data.frame"))){stop(paste(class(x),collapse = "/"), " object cannot be coerced to embeddings.")}
}

#' @noRd
#' @method as.embeddings embeddings
#' @export
as.embeddings.embeddings <- function(x) {
  x
}

#' @noRd
#' @method as.embeddings matrix
#' @export
as.embeddings.matrix <- function(x){
  if (!is.numeric(x)) {
    stop("Input is not numeric")
  }
  class(x) <- c("embeddings", "matrix", "array")
  x
}

#' @noRd
#' @method as.embeddings Matrix
#' @export
as.embeddings.Matrix <- function(x){
  if (!is.numeric(x)) {
    stop("Input is not numeric")
  }
  class(x) <- c("embeddings", "matrix", "array")
  x
}

#' @method as.embeddings data.frame
#' @export
as.embeddings.data.frame <- function(x, token_col = "token"){
  x <- tibble::column_to_rownames(x, token_col)
  if (!all(apply(pretrained_mod, 2, is.numeric))) {
    stop("Input contains non-numeric columns other than token_col")
  }
  x <- as.matrix(x, dimnames = list(rownames(x)))
  class(x) <- c("embeddings", "matrix", "array")
  x
}

#' @export
is.embeddings <- function(x){
  "embeddings" %in% class(x)
}
