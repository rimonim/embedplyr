#' Row-wise Similarity and Distance Metrics
#'
#' `get_sims(df, col1:col2, list(sim = vec2))` is essentially
#' equivalent to `mutate(rowwise(df), sim = cos_sim(c_across(col1:col2), vec2))`.
#' Includes methods for dataframes (in the style of `dplyr`), embeddings
#' objects, and matrices.
#'
#' @param x an embeddings object, matrix, or dataframe with one embedding per row
#' @param cols tidyselect - columns that contain numeric embedding values
#' @param y a named list of vectors with the same dimensionality as embeddings in x.
#' Each item will result in a column in the output, showing the similarity of each
#' embedding in x to the vector specified in y. When `method = "anchored"`,
#' each item of y should be a list with named vectors `pos` and `neg`.
#' @param method either the name of a method to compute similarity or distance,
#' or a function that takes two vectors, `x` and `y`, and outputs a scalar,
#' similar to those listed in [Similarity and Distance Metrics][sim_metrics]
#' @param ... additional parameters to be passed to method function
#' @param .keep_all If `TRUE`, all columns from input are retained in output.
#' If `FALSE`, only similarity metrics will be included. If `"except.embeddings"`
#' (the default), all columns except those used to compute the similarity will be retained.
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
#'   \item `anchored`: `x` is projected onto the range between two anchor points,
#'   such that vectors aligned with `pos` are given a score of 1 and those aligned
#'   with `neg` are given a score of 0. For more on anchored vectors, see
#'   [Data Science for Psychology: Natural Language, Chapter 20](https://ds4psych.com/navigating-vectorspace#sec-dimension-projection).
#' }
#' When `method` is a custom function, operations are performed for each row and
#' may be slow for large inputs.
#'
#' @section Value:
#' A tibble with columns `doc_id`, and similarity metrics.
#' If `.keep_all = TRUE` or `.keep_all = "except.embeddings"`, the new columns
#' will appear after existing ones.
#'
#' @import tibble
#' @examples
#' valence_embeddings <- emb(glove_twitter_25d, c("good", "bad"))
#' happy_vec <- emb(glove_twitter_25d, "happy")
#' sad_vec <- emb(glove_twitter_25d, "sad")
#'
#' valence_embeddings |>
#'   get_sims(list(happy = happy_vec))
#' valence_embeddings |>
#'   get_sims(
#'     list(happy = list(pos = happy_vec, neg = sad_vec)),
#'     anchored_sim
#'     )
#' valence_embeddings |>
#'   get_sims(
#'     list(happy = happy_vec),
#'     method = function(x, y) sum(abs(x - y))
#'     )
#'
#' valence_df <- tibble::as_tibble(valence_embeddings, rownames = "token")
#' valence_df |> get_sims(
#'   dim_1:dim_25,
#'   list(happy = happy_vec, sad = sad_vec),
#'   .keep_all = TRUE
#'   )


#' @export
get_sims <- function(x, ...) {
  UseMethod("get_sims")
}

#' @noRd
#' @include sim_metrics.R
sim_mat_vec_list <- list(
	"cosine" = cos_sim_mat_vec, "cosine_squished" = cos_sim_squished_mat_vec,
	"euclidean" = euc_dist_mat_vec, "minkowski" = minkowski_dist_mat_vec,
	"dot_prod" = dot_prod_mat_vec, "anchored" = anchored_sim_mat_vec
)

# wrap do.call so that input is first argument and further arguments can come from a list
#' @noRd
call_with_list <- function(x, what, args, ...){
	arg_list <- c(list(x = x), args, list(...))
	do.call(what, arg_list)
}

# Function to apply to each item of `y`
#' @noRd
apply_func <- function(y_item, x, method, ...) {
	if (is.character(method)) {
		method_name <- method[1]
		method <- sim_mat_vec_list[[method_name]]
		if (is.null(method)) {
      stop("Unknown method '", method_name, "'. Supported methods are: ",
           paste(names(sim_mat_vec_list), collapse = ", "))
		}
		if (method_name == "anchored" && (!is.list(y_item) || !all(c("pos", "neg") %in% names(y_item)))) {
			stop("For method 'anchored', each item in `y` must be a list with 'pos' and 'neg' vectors.")
		}
		if (!is.list(y_item)){
			method(x, y_item, ...)
		}else if (all(names(y_item) %in% names(as.list(args(method))))) {
			call_with_list(x, what = method, args = y_item, ...)
		}else{
			stop("y must provide appropriate arguments for method\nRequired arguments: ",
					 paste(setdiff(names(as.list(args(method))), c("x", "")),collapse = ", "))
		}
	}else if (is.function(method)){
		if (!is.list(y_item)){
			apply(x, 1, method, y = y_item, ...)
		}else if (all(names(y_item) %in% names(as.list(args(method))))) {
			apply(x, 1, call_with_list, what = method, args = y_item, ...)
		}else{
			stop("y must provide appropriate arguments for method\nRequired arguments: ",
					 paste(setdiff(names(as.list(args(method))), c("x", "")),collapse = ", "))
		}
	}else{
		stop("`method` must be one of: ", paste(names(sim_mat_vec_list), collapse = ", "), " or a custom function.")
	}
}

#' @export
get_sims.default <- function(x, y, method = c("cosine", "cosine_squished", "euclidean", "minkowski", "dot_prod", "anchored"), ...) {
	if (!inherits(x, "matrix")) stop("x must be an embeddings object or numeric matrix")
	if (!is.list(y) || is.null(names(y)) || any(names(y) == "")) {
		stop("`y` must be a named list with non-empty names.")
	}
	out_cols <- lapply(y, apply_func, x = x, method = method, ...)
	tibble::as_tibble(out_cols)
}

#' @rdname get_sims
#' @method get_sims embeddings
#' @export
get_sims.embeddings <- function(x, y, method = c("cosine", "cosine_squished", "euclidean", "minkowski", "dot_prod", "anchored"), ...) {
	out <- get_sims.default(x, y, method = method, ...)
	dplyr::bind_cols(tibble::tibble(doc_id = rownames(x)), out)
}

#' @rdname get_sims
#' @method get_sims data.frame
#' @export
get_sims.data.frame <- function(x, cols, y, method = c("cosine", "cosine_squished", "euclidean", "minkowski", "dot_prod", "anchored"), ..., .keep_all = "except.embeddings") {
  in_dat <- as.matrix(dplyr::select(dplyr::ungroup(x), {{ cols }}))
  if (!is.numeric(in_dat)) stop("Selected columns must be numeric.")
  if (.keep_all != "except.embeddings" && !is.logical(.keep_all)) stop("`.keep_all` must be TRUE, FALSE, or 'except.embeddings'.")
  out_dat <- get_sims.default(in_dat, y, method = method, ...)
  if (.keep_all == "except.embeddings") {
  	dplyr::bind_cols( dplyr::select(x, -{{ cols }}), out_dat )
  }else if (.keep_all) {
  	dplyr::bind_cols( x, out_dat )
  }else{
  	out_dat
  }
}
