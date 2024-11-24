#' Scale Embeddings to the Unit Hypersphere
#'
#' Normalize embeddings such that their magnitude is 1, while their angle from the origin is unchanged.
#'
#' @param x for `normalize()`, a numeric vector, embeddings object, or list of numeric or embeddings objects.
#' For `normalize_rows()`, a matrix or dataframe with one embedding per row.
#' @param cols tidyselect - columns that contain numeric embedding values
#' @param ... additional parameters to be passed to methods
#'
#' @section Value:
#' An object of the same class and dimensionality as x
#'
#' @import tibble
#' @examples
#' vec <- c(1, 4, 2)
#' normalize(vec)
#'
#' valence_embeddings <- predict(glove_twitter_25d, c("good", "bad"))
#' normalize(valence_embeddings)
#'
#' embeddings_list <- find_nearest(glove_twitter_25d, c("good", "bad"), each = TRUE)
#' normalize(embeddings_list)
#'
#' valence_df <- tibble::as_tibble(valence_embeddings, rownames = "token")
#' valence_df |> normalize_rows(dim_1:dim_25)

#' @export
normalize <- function(x, ...) {
	UseMethod("normalize")
}

#' @export
normalize.default <- function(x, ...) {
	if (inherits(x, "list")) return(lapply(x, normalize))
	if (!(any(class(x) %in% c("numeric", "embeddings")))){
		stop("x must be a numeric vector or an embeddings object",
				 ifelse(any(class(x) == "data.frame"), "\nFor data frames and matrices, use normalize_rows().", ""))
	}
	out <- apply(x, 1, function(x){x / sqrt(sum(x^2))}, simplify = FALSE)
	out <- as.embeddings(do.call(rbind, out))
	colnames(out) <- colnames(x)
	out
}

#' @rdname normalize
#' @method normalize numeric
#' @export
normalize.numeric <- function(x, ...) {
	if (!is.null(dim(x))) stop("x must be a numeric vector, an embeddings object, or a dataframe with one embedding per row")
	x / sqrt(sum(x^2))
}

#' @rdname normalize
#' @export
normalize_rows <- function(x, ...) {
	UseMethod("normalize_rows")
}

#' @rdname normalize
#' @export
normalize_rows.default <- function(x, ...) {
	if (!(any(class(x) %in% c("data.frame", "matrix")))) stop("x must be a dataframe or matrix")
	out <- apply(x, 1, function(x){x / sqrt(sum(x^2))}, simplify = FALSE)
	out <- do.call(rbind, out)
	colnames(out) <- colnames(x)
	out
}

#' @rdname normalize
#' @method normalize_rows data.frame
#' @export
normalize_rows.data.frame <- function(x, cols, ...) {
	in_dat <- dplyr::select(x, {{ cols }})
	out_dat <- normalize_rows.default(in_dat)
	dplyr::bind_cols( dplyr::select(x, -{{ cols }}), out_dat )
}
