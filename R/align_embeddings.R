#' Align Two Embeddings Models
#'
#' Rotates the embeddings in `x` so that they can be compared with those in `y`.
#'
#' @param x an embeddings object
#' @param y an embeddings object. If `matching = NULL`, `y` must contain at least
#' a few rownames matching those of `x`.
#' @param matching (optional) a named character vector specifying a one-to-one
#' matching between rownames of `x` (names) and rownames of `y` (values)
#'
#' @details
#' Computes orthogonal Procrustes as described by Schönemann (1966). This
#' computation is based only on rows with names that appear in both `x` and `y`
#' (or on rows specified by `matching`), but the output includes all rows of `x`.
#'
#' @section Value:
#' An embeddings object with the same rownames and number of rows as `x`, rotated
#' (and with reduced or increased dimensionality, if need be) to align with `y`.
#'
#' @references Schönemann, P. H. (1966). A generalized solution of the orthogonal
#'  procrustes problem. Psychometrika, 31(1), 1–10. https://doi.org/10.1007/BF02289451

#' @export
align_embeddings <- function(x, y, matching = NULL) {
	# match dimensionality
	if (ncol(x) > ncol(y)) {
		message("`x` has more dimensions than `y`. Reducing dimensionality with PCA...")
		x <- reduce_dimensionality(x, ncol(y))
	}
	# remove NA rows
	x_temp <- stats::na.omit(x)
	y_temp <- stats::na.omit(y)
	# match rows
	if (!is.null(matching)) {
		row_overlap <- names(matching)
		matching <- as.vector(matching)
		embedding_available <- vapply(row_overlap, exists, FALSE, envir = attr(x_temp, "token_index")) & vapply(matching, exists, FALSE, envir = attr(y_temp, "token_index"))
		row_overlap <- row_overlap[embedding_available]
		y_temp <- y_temp[matching[embedding_available],]
	}else{
		row_overlap <- intersect(rownames(x_temp), rownames(y_temp))
		y_temp <- y_temp[row_overlap,]
	}
	if ((nrow(x_temp) - length(row_overlap)) > 0) message("Aligning based on ", length(row_overlap), " matching rows.")
	x_temp <- x_temp[row_overlap,]
	# compute Procrustes
	return(as.embeddings(x %*% procrustes(x_temp, y_temp)))
}

#' @noRd
procrustes <- function(x, y) {
	cp_svd <- svd(crossprod(x, y))
	q <- cp_svd$u %*% t(cp_svd$v)
	q
}
