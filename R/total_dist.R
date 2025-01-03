#' @noRd
#' @include sim_metrics.R
sim_parallel_list <- list(
	"euclidean" = euc_dist_parallel, "minkowski" = minkowski_dist_parallel,
	"cosine" = cos_sim_parallel, "cosine_squished" = cos_sim_squished_parallel,
	"dot_prod" = dot_prod_parallel
)

#' Compare Two Embedding Models
#'
#' Given two alternative embeddings of a set of tokens or documents, `total_dist()`
#' computes a global metric of the distance between the alternatives (by default
#' the Wasserstein distance).
#'
#' @inheritParams align_embeddings
#' @param method either the name of a method to compute similarity or distance,
#' or a function that takes two vectors, `x` and `y`, and outputs a scalar,
#' similar to those listed in [Similarity and Distance Metrics][sim_metrics]
#' @param average logical. Should the rowwise distances be averaged as opposed
#' to summed?
#' @param ... additional parameters to be passed to method function
#'
#' @details
#' `total_dist()` computes the distance or similarity between the embeddings in
#' `x` and their direct counterparts in `y`. `average = TRUE` returns the
#' mean of these values, while `average = FALSE` (the default) returns the sum.
#'
#' For more information on available methods, see [get_sims()].
#'
#' `method = "euclidean"` and `average = FALSE` (the default for `total_dist()`)
#' results in the [Wasserstein distance](https://en.wikipedia.org/wiki/Wasserstein_metric),
#' if embeddings are taken as equally weighted point masses.
#'
#' `average_sim()` is identical to `total_dist()`, but with different defaults.

#' @export
total_dist <- function(x, y, matching = NULL,
											 method = c("euclidean", "minkowski", "cosine", "cosine_squished", "dot_prod"),
											 average = FALSE, ...) {
	stopifnot("x and y must have the same number of dimensions" = ncol(x) == ncol(y))
	# match rows
	if (!is.null(matching)) {
		row_overlap <- names(matching)
		matching <- as.vector(matching)
		embedding_available <- vapply(row_overlap, exists, FALSE, envir = attr(x, "token_index")) & vapply(matching, exists, FALSE, envir = attr(y, "token_index"))
		row_overlap <- row_overlap[embedding_available]
		y <- y[matching[embedding_available],]
	}else{
		row_overlap <- intersect(rownames(x), rownames(y))
		y <- y[row_overlap,]
	}
	if ((nrow(x) - length(row_overlap)) > 0) message("Computing metric based on ", length(row_overlap), " matching rows.")
	x <- x[row_overlap,]
	# compute similarity / distance
	if (is.character(method)) {
		method_name <- method[1]
		method <- sim_parallel_list[[method_name]]
		if (is.null(method)) {
			stop("Unknown method '", method_name, "'. Supported methods are: ",
					 paste(names(sim_parallel_list), collapse = ", "))
		}
		distances <- method(x, y, ...)
	}else if (is.function(method)){
		distances <- vapply(seq_len(nrow(x)), function(i) method(as.vector(x[i,]), as.vector(y[i,]), ...), numeric(1), USE.NAMES = FALSE)
	}else{
		stop("`method` must be one of: ", paste(names(sim_parallel_list), collapse = ", "), " or a custom function.")
	}
	if (average) return(mean(distances, na.rm = TRUE)) else return(sum(distances, na.rm = TRUE))
}

#' @rdname total_dist
#' @export
average_sim <- function(x, y, matching = NULL,
												method = "cosine",
												average = TRUE, ...) {
	total_dist(x, y, matching = matching, method = method, average = average, ...)
}
