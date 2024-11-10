#' Magnitude of Embeddings
#'
#' The magnitude, norm, or length of a vector is its Euclidean distance from the origin.
#'
#' @param x a numeric vector or embeddings object
#' @param ... additional parameters to be passed to methods
#'
#' @section Value:
#' a numeric vector with one item per embedding in `x`
#'
#' @examples
#' vec <- c(1, 4, 2)
#' magnitude(vec)
#'
#' valence_embeddings <- predict(glove_twitter_25d, c("good", "bad"))
#' magnitude(valence_embeddings)

#' @export
magnitude <- function(x, ...) {
	UseMethod("magnitude")
}

#' @export
magnitude.default <- function(x, ...) {
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
