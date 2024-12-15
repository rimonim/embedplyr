#' Embeddings Objects
#'
#' An embeddings object is a numeric matrix with fast indexing by rownames
#' (generally tokens).
#'
#' @param x a numeric matrix or dataframe in which the only non-numeric column is
#' specified by `id_col`, or an existing embeddings object
#' @param ... additional arguments to be passed to or from class-specific methods
#' @param rowname_repair logical. If `TRUE` (the default), check that unique
#' rownames are provided, and name rows "doc_1", "doc_2", etc. if not.
#' @param rebuild_token_index logical. If `TRUE`, the hash table index will be rebuilt
#' even when `x` is an embeddings object.
#' @inheritParams base::matrix
#'
#' @details
#' Fast row indexing is implemented using hash tables in native R environments.
#' The "token_index" attribute of an embeddings object stores the environment
#' that maps rownames to their corresponding indices.
#'
#' If `dimnames` is not supplied, `embeddings` will automatically name rows
#' doc_1, doc_2, etc., and columns dim_1, dim_2, etc.
#'
#' @importFrom tibble as_tibble
#' @examples
#' random_mat <- matrix(
#'   sample(1:10, 20, replace = TRUE),
#'   nrow = 2,
#'   dimnames = list(c("happy", "sad"))
#'   )
#' random_embeddings <- as.embeddings(random_mat)
#' is.embeddings(random_embeddings[,2:5])
#'
#' tibble::as_tibble(random_embeddings, rownames = "token")

#' @export
embeddings <- function(data = NA, nrow = 1, ncol = 1, byrow = FALSE, dimnames = NULL) {
  if (missing(nrow) && missing(ncol)) {
    nrow <- length(data)
    ncol <- 1
  } else if (missing(nrow)) {
    nrow <- ceiling(length(data) / ncol)
  } else if (missing(ncol)) {
    ncol <- ceiling(length(data) / nrow)
  }
  x <- matrix(data = data, nrow = nrow, ncol = ncol, byrow = byrow, dimnames = dimnames)
  if (is.null(dimnames)) rowname_repair <- TRUE else rowname_repair <- FALSE
  x <- suppressWarnings( as.embeddings(x, rowname_repair = rowname_repair) )
  x
}

#' @rdname embeddings
#' @export
as.embeddings <- function(x, ...) {
  UseMethod("as.embeddings")
}

#' @rdname embeddings
#' @export
as.embeddings.default <- function(x, ..., rowname_repair = TRUE, rebuild_token_index = TRUE) {
  if(!is_matrixlike(x)){stop(sprintf("No method for coercing objects of class '%s' to embeddings.", class(x)))}
  # default row and column names
  if (rowname_repair && (is.null(rownames(x)) && nrow(x) > 0 || any(duplicated(rownames(x))))){
    warning("unique row names not provided. Naming rows doc_1, doc_2, etc.")
    rownames(x) <- paste0("doc_", seq_len(nrow(x)))
  }
  if (is.null(colnames(x)) && ncol(x) > 0 || any(duplicated(colnames(x)))){
    colnames(x) <- paste0("dim_", seq_len(ncol(x)))
  }
  x <- structure(x, class = c("embeddings", "matrix", "array"))
  if (rebuild_token_index || is.null(attr(x, "token_index"))) build_token_index(x) else x
}

#' @noRd
#' @method as.embeddings embeddings
#' @export
as.embeddings.embeddings <- function(x, ..., rowname_repair = TRUE, rebuild_token_index = TRUE){
  as.embeddings.default(x, rowname_repair = rowname_repair, rebuild_token_index = rebuild_token_index)
}

#' @noRd
#' @method as.embeddings matrix
#' @export
as.embeddings.matrix <- function(x, ..., rowname_repair = TRUE){
  if (!is.numeric(x)) {
    stop("Input is not numeric")
  }
  as.embeddings.default(x, rowname_repair = rowname_repair)
}

#' @noRd
#' @method as.embeddings Matrix
#' @export
as.embeddings.Matrix <- function(x, ..., rowname_repair = TRUE){
  x <- as.matrix(x)
  if (!is.numeric(x)) {
    stop("Input is not numeric")
  }
  as.embeddings.default(x, rowname_repair = rowname_repair)
}

#' @noRd
#' @method as.embeddings numeric
#' @export
as.embeddings.numeric <- function(x, ...){
  if (is.array(x) && length(dim(x)) > 1) {
    stop("High dimensional arrays cannot be coerced to embeddings.")
  }
  x <- matrix(x, nrow = 1, dimnames = list("doc_1"))
  as.embeddings.default(x)
}

#' @rdname embeddings
#' @usage
#' \method{as.embeddings}{data.frame}(x, id_col = NULL, ..., rowname_repair = TRUE)
#' @param x A data frame to be converted into embeddings.
#' @param id_col Optional name of a column to take row names from.
#' @param ... Additional arguments passed to or from other methods.
#' @param rowname_repair logical. If `TRUE` (the default), check that unique
#' rownames are provided, and name rows "doc_1", "doc_2", etc. if not.
#' @export
as.embeddings.data.frame <- function(x, id_col = NULL, ..., rowname_repair = TRUE){
  if (!is.null(id_col)) {
    id <- dplyr::pull(x, id_col)
    x <- x[,names(x) != id_col]
  }else{
    id <- NULL
  }
  if (!all(vapply(x, is.numeric, TRUE))) {
    stop("Input contains non-numeric columns other than id_col")
  }
  x <- data.matrix(x)
  rownames(x) <- id
  as.embeddings.default(x, rowname_repair = rowname_repair)
}

#' @rdname embeddings
#' @export
is.embeddings <- function(x, ...){
  inherits(x, "embeddings")
}

#' Build hash table to map tokens (i.e. doc_ids) to matrix indices
#' @param embeddings an embeddings object
#' @keywords internal
build_token_index <- function(embeddings) {
  token_index <- new.env(hash = TRUE, parent = emptyenv())
  tokens <- rownames(embeddings)
  for (i in seq_along(tokens)) {
    token_index[[tokens[i]]] <- i
  }
  attr(embeddings, "token_index") <- token_index
  embeddings
}

#' Update hash table after additions
#' @param embeddings an embeddings object
#' @param added_tokens tokens to be added to the hash table
#' @keywords internal
token_index_add <- function(embeddings, added_tokens) {
  token_index <- attr(embeddings, "token_index")
  if (is.null(token_index)) {
    token_index <- new.env(hash = TRUE, parent = emptyenv())
  }
  added_indices <- match(added_tokens, rownames(embeddings))
  for (i in seq_along(added_tokens)) {
    token_index[[added_tokens[i]]] <- added_indices[i]
  }

  attr(embeddings, "token_index") <- token_index
  embeddings
}

#' Check if an object is matrix-like and numeric
#' @param x an object to be checked
#' @keywords internal
is_matrixlike <- function(x) {
  (is.matrix(x) || inherits(x, "Matrix") || is.data.frame(x)) && is.numeric(as.matrix(x))
}
