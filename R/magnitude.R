#' Magnitude of Embeddings
#'
#' The magnitude, norm, or length of a vector is its Euclidean distance from the origin.
#'
#' @param x a numeric vector, embeddings object, or list of numeric or embeddings objects
#' @param ... additional parameters to be passed to methods
#'
#' @section Value:
#' a numeric vector with one item per embedding in `x`. If `x` is a list, the
#' function will be called recursively and return a list.
#'
#' @examples
#' vec <- c(1, 4, 2)
#' magnitude(vec)
#'
#' valence_embeddings <- emb(glove_twitter_25d, c("good", "bad"))
#' magnitude(valence_embeddings)
#'
#' embeddings_list <- find_nearest(glove_twitter_25d, c("good", "bad"), each = TRUE)
#' magnitude(embeddings_list)

#' @export
magnitude <- function(x, ...) {
	UseMethod("magnitude")
}

#' @export
magnitude.default <- function(x, ...) {
	if (inherits(x, "list")) return(lapply(x, magnitude))
	if (!(any(class(x) %in% c("numeric", "embeddings")))) stop("x must be a numeric vector or an embeddings object")
	out <- apply(x, 1, function(x){sqrt(sum(x^2))})
	names(out) <- rownames(x)
	out
}

#' @rdname magnitude
#' @method magnitude numeric
#' @export
magnitude.numeric <- function(x, ...) {
	if (!is.null(dim(x))) stop("x must be a numeric vector or an embeddings object")
	sqrt(sum(x^2))
}
