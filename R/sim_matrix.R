#' Pairwise Similarity or Distance Matrix
#'
#' Calculate a matrix of similarity scores between the rows of the input.
#'
#' @param x an embeddings object, matrix, or dataframe with one embedding per row
#' @param cols tidyselect - columns that contain numeric embedding values
#' @param method either the name of a method to compute similarity or distance,
#' or a function that takes two vectors, `x` and `y`, and outputs a scalar,
#' similar to those listed in [Similarity and Distance Metrics][sim_metrics]
#' @param ... additional parameters to be passed to method function
#' @param tidy_output logical. If `FALSE` (the default), output a [stats::dist]
#' object. If `TRUE`, output a tibble with columns `doc_id_1`, `doc_id_2`, and
#' the similarity or distance metric.
#'
#' @details ## Available Methods
#' When `method` is the name of one of the following supported methods,
#' computations are done with matrix operations and are therefore blazing fast.
#' \itemize{
#'   \item `cosine`: cosine similarity
#'   \item `cosine_squished`: cosine similarity, rescaled to range from 0 to 1
#'   \item `euclidean`: Euclidean distance
#'   \item `minkowski`: Minkowski distance; requires parameter `p`. When `p = 1`
#'   (the default), this is the Manhattan distance. When `p = 2`, it is the
#'   Euclidean distance. When `p = Inf`, it is the Chebyshev distance.
#'   \item `dot_prod`: Dot product
#' }
#' When `method` is a custom function, operations are performed for each row and
#' may be slow for large inputs.
#'
#' @section Value:
#' If `tidy_output = FALSE` (the default), a [stats::dist] object.
#' If `tidy_output = TRUE`, a tibble with columns `doc_id_1`, `doc_id_2`, and
#' the similarity or distance metric.
#'
#' @import tibble
#' @examples
#' emb <- predict(glove_twitter_25d, c("table", "chair", "cat"))
#'
#' sim_matrix(emb)
#' sim_matrix(emb, method = "euclidean")
#' sim_matrix(emb, method = function(x, y) sum(abs(x - y)))
#'
#' valence_df <- tibble::as_tibble(emb, rownames = "token")
#' valence_df |> sim_matrix(dim_1:dim_25, tidy_output = TRUE)


#' @export
sim_matrix <- function(x, ...) {
	UseMethod("sim_matrix")
}

#' @noRd
#' @include sim_metrics.R
sim_matrix_list <- list(
	"cosine" = cos_sim_matrix, "cosine_squished" = cos_sim_squished_matrix,
	"euclidean" = euc_dist_matrix, "minkowski" = minkowski_dist_matrix,
	"dot_prod" = dot_prod_matrix
)

#' @importFrom rlang %||%
#' @export
sim_matrix.default <- function(x, method = c("cosine", "cosine_squished", "euclidean", "minkowski", "dot_prod", "anchored"), ..., tidy_output = FALSE) {
	if (inherits(x, "list")) return(lapply(x, sim_matrix))
	if (!inherits(x, "matrix")) stop("x must be an embeddings object or numeric matrix")
	if (is.character(method)) {
		method_name <- method[1]
		method <- sim_matrix_list[[method_name]]
		if (is.null(method)) {
			stop("Unknown method '", method_name, "'. Supported methods are: ",
					 paste(names(sim_mat_vec_list), collapse = ", "))
		}
		method(x, ..., tidy_output = tidy_output)
	}else if (is.function(method)){
		out <- apply(x, 1, function(v1) apply(x, 1, function(v2) method(v1, v2)))
		out <- stats::as.dist(out)
		if (tidy_output) {
			rn <- rownames(x) %||% seq_len(nrow(x))
			out <- tibble::tibble(
				doc_id_1 = rep.int(rn, rev(seq_along(rn) - 1L)),
				doc_id_2 = unlist(sapply(2:nrow(x), function(i) rn[i:nrow(x)]), use.names = FALSE),
				cosine = out
			)
		}
		out
	}else{
		stop("`method` must be one of: ", paste(names(sim_matrix_list), collapse = ", "), " or a custom function.")
	}
}

#' @rdname sim_matrix
#' @method sim_matrix data.frame
#' @export
sim_matrix.data.frame <- function(x, cols, method = c("cosine", "cosine_squished", "euclidean", "minkowski", "dot_prod", "anchored"), ..., tidy_output = FALSE) {
	in_dat <- as.matrix(dplyr::select(dplyr::ungroup(x), {{ cols }}))
	if (!is.numeric(in_dat)) stop("Selected columns must be numeric.")
	sim_matrix.default(in_dat, method = method, ..., tidy_output = tidy_output)
}
