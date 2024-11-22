#' Extract or Subset Parts of Embeddings Objects
#'
#' Extraction, replacement, and subsetting nearly identically matches the behavior
#' of matrices, with one exception: If a character item in `i` matches multiple
#' rownames in `x`, the _last_ match will be returned.
#'
#' @param i row index or indices to extract or replace. Can be `numeric` or `character`.
#' @param j column index or indeces to extract or replace. Can be `numeric` or `character`.
#' @param drop logical. If `TRUE` (the default) and the result is one-dimensional
#' (e.g. a single row), the output will be a (named) vector.
#' @param value typically a numeric vector, matrix, or embeddings object.
#' @inheritParams base::subset
#'
#' @details
#' The difference between `embeddings[i,]` and `predict(embeddings, i)` is that
#' the former will throw an error when items of `i` are not valid indices, whereas
#' the latter will handle it gracefully (at the cost of a few more milliseconds
#' if `i` is long).
#'
#' @examples
#' glove_twitter_25d["this",]
#' glove_twitter_25d[c("this", "that"),]
#'
#' glove_twitter_25d[1,]
#' glove_twitter_25d[1:10,]
#'
#' glove_twitter_25d[1]
#' glove_twitter_25d[1,1:10]
#'
#' duplicate_tokens <- embeddings(
#'   1:15,
#'   nrow = 3,
#'   dimnames = list(c("this", "that", "this"))
#'   )
#' duplicate_tokens["this",]

#' @rdname embeddings-subsetting
#' @export
#' @aliases [.embeddings
`[.embeddings` <- function(x, i, j, drop = TRUE) {
	if (!missing(i) && is.character(i)) {
		i <- unlist(mget(i, envir = attr(x, "token_index")))
	}
	out <- NextMethod("[", i)
	if (drop && !is_matrixlike(out)) {
		out
	}else{
		as.embeddings(out, rowname_repair = FALSE)
	}
}

#' @rdname embeddings-subsetting
#' @export
#' @aliases [<-.embeddings
`[<-.embeddings` <- function(x, i, j, value) {
	if (!missing(i) && is.character(i)) {
		i <- unlist(mget(i, envir = attr(x, "token_index")))
	}
	NextMethod("[<-", i)
}

#' @rdname embeddings-subsetting
#' @method subset embeddings
#' @export
subset.embeddings <- function(x, subset, ...) {
	out <- NextMethod("subset")
	out <- as.embeddings(out, rowname_repair = FALSE)
	out
}
