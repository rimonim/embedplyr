#' Methods for Embeddings Objects
#'
#' Functions that modify the rownames or indices of embeddings objects
#' (e.g. `unique`, `rbind`, `rownames<-` etc.) will behave as usual
#' for matrices while automatically updating the hash table as necessary.
#' Functions that coerce embeddings objects to other data types (e.g. `as.matrix`)
#' will strip the hash table attribute, leaving a clean, familiar object.
#'
#' @param x an embeddings object
#' @param ... for `rbind`, embeddings objects or other objects that will be coerced
#' to embeddings. Otherwise, arguments for particular methods.
#' @inheritParams base::rownames
#' @inheritParams base::dimnames
#' @inheritParams base::unique
#' @inheritParams base::t
#' @inheritParams base::rbind
#' @inheritParams base::as.matrix
#' @inheritParams tibble::as_tibble

#' @rdname embeddings-methods
#' @method `rownames<-` embeddings
#' @usage
#' \method{rownames}{embeddings}(x) <- value
#' @export
`rownames<-.embeddings` <- function(x, value) {
	attr(x, "dimnames")[[1]] <- value
	x <- as.embeddings(x, rowname_repair = FALSE)
	x
}

#' @rdname embeddings-methods
#' @method `dimnames<-` embeddings
#' @usage
#' \method{dimnames}{embeddings}(x) <- value
#' @export
`dimnames<-.embeddings` <- function(x, value) {
	attr(x, "dimnames") <- value
	x <- structure(x, class = c("embeddings", "matrix", "array"))
	build_token_index(x)
}

#' @noRd
#' @method `dim<-` embeddings
#' @export
`dim<-.embeddings` <- function(x, value) {
	stop("Cannot change dimensions of an embeddings object directly.")
}

#' @rdname embeddings-methods
#' @method unique embeddings
#' @export
unique.embeddings <- function(x, incomparables = FALSE, MARGIN = 1,
															fromLast = FALSE, ...) {
	x <- NextMethod("unique")
	as.embeddings(x, rowname_repair = FALSE)
}

#' @rdname embeddings-methods
#' @method t embeddings
#' @export
t.embeddings <- function(x) {
	x <- NextMethod("t")
	as.embeddings(x, rowname_repair = FALSE)
}

#' @rdname embeddings-methods
#' @method rbind embeddings
#' @export
rbind.embeddings <- function(..., deparse.level = 1) {
	embeddings_list <- list(...)
	embeddings_list <- lapply(embeddings_list, unclass) # unclass to avoid recursion
	result <- do.call(rbind, embeddings_list)
	# Update hash table
	added_tokens <- unlist(lapply(embeddings_list[-1], rownames))
	result <- token_index_add(result, added_tokens)
	result <- as.embeddings(result, rowname_repair = FALSE, rebuild_token_index = FALSE)
	result
}

#' @rdname embeddings-methods
#' @method as.matrix embeddings
#' @export
as.matrix.embeddings <- function(x, ...){
	x <- unclass(x)
	attr(x, "token_index") <- NULL
	as.matrix(x)
}

#' @importFrom rlang :=
#' @importFrom rlang %||%
#' @rdname embeddings-methods
#' @method as_tibble embeddings
#' @export
as_tibble.embeddings <- function(x, ..., rownames = NULL) {
	rn <- rownames(x) %||% NA
	x <- as.data.frame(x)
	if (!is.null(rownames)) {
		x <- dplyr::mutate(x, !!rownames := rn)
		x <- dplyr::relocate(x, tidyselect::all_of(rownames))
	}
	tibble::as_tibble(x, ...)
}
