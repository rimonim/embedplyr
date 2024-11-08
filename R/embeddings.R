#' Coercion and checking functions for embeddings objects
#'
#' An embeddings object is a numeric matrix with rownames (generally tokens). Convert an
#' eligible input object into an embeddings object, or check whether an object
#' is an embeddings object.
#'
#' @param x a numeric matrix or dataframe in which the only non-numeric column is specified by `id_col`
#' @param ... additional arguments to be passed to class-specific methods
#' @import tibble
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
  if(!embeddings_check(x)){stop(paste(class(x),collapse = "/"), " object cannot be coerced to embeddings.")}
  if (is.null(colnames(x))){
    colnames(x) <- paste0("dim_", 1:ncol(x))
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
  if (!is.numeric(x)) {
    stop("Input is not numeric")
  }
  as.embeddings.default(x)
}

#' @rdname embeddings
#' @usage
#' \method{as.embeddings}{data.frame}(x, id_col = "token", ...)
#' @param x A data frame to be converted into embeddings.
#' @param id_col Column to take row names from. Defaults to `"token"`.
#' @param ... Additional arguments passed to or from other methods.
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

#' @rdname embeddings
#' @method as.matrix embeddings
#' @export
as.matrix.embeddings <- function(x, ...){
  structure(x, class = c("matrix", "array"))
}

#' @noRd
#' @method '[' embeddings
#' @export
'[.embeddings' <- function(x, ..., drop = FALSE) {
  out <- NextMethod('[')
  if (embeddings_check(out)) {
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

#' Check if and object can be coerced to embeddings
#' @param x an object to be checked for coercability to embeddings
#' @keywords internal
embeddings_check <- function(x) {
  any(class(x) %in% c("embeddings", "matrix", "Matrix", "data.frame")) && is.numeric(as.matrix(x))
}

#' @noRd
#' @method as_tibble embeddings
#' @export
as_tibble.embeddings <- function(x, ...,
                                 .rows = NULL,
                                 .name_repair = c("check_unique", "unique", "universal", "minimal"),
                                 rownames = pkgconfig::get_config("tibble::rownames", NULL)){
  x <- unclass(x)
  NextMethod("as_tibble")
}
