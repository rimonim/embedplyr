#' Row-wise Similarity and Distance Metrics
#'
#' `get_similarities(df, everything(), list(sim = vec2))` is essentially
#' equivalent to `mutate(rowwise(df), sim = cos_sim(c_across(everything()), vec2))`.
#' Includes methods for dataframes (in the style of `dplyr`), embeddings
#' objects, and matrices.
#'
#' @param x an embeddings object, matrix, or dataframe with one embedding per row
#' @param cols tidyselect - columns that contain numeric embedding values
#' @param y a named list of vectors with the same dimensionality as embeddings in x.
#' Each item will result in a column in the output, showing the similarity of each
#' embedding in x to the vector specified in y. When `sim_func = anchored_sim`,
#' each item of y should be a list with named vectors `pos` and `neg`.
#' @param sim_func a function that takes two vectors and outputs a scalar
#' similarity metric. Defaults to cosine similarity. For more options see
#' [Similarity and Distance Metrics][sim_metrics]
#' @param ... additional parameters to be passed to methods
#' @param .keep_all If `TRUE`, all columns from input are retained in output.
#' If `FALSE`, only similarity metrics will be included. If `"except.embeddings"`
#' (the default), all columns except those used to compute the similarity will be retained.
#'
#' @section Value:
#' A tibble with columns `doc_id`, and similarity metrics.
#' If `.keep_all = TRUE` or `.keep_all = "except.embeddings"`, the new columns
#' will appear after existing ones.
#'
#' @import tibble
#' @examples
#' valence_embeddings <- predict(glove_twitter_25d, c("good", "bad"))
#' happy_vec <- predict(glove_twitter_25d, "happy")
#' sad_vec <- predict(glove_twitter_25d, "sad")
#'
#' valence_embeddings |>
#'   get_similarities(list(happy = happy_vec))
#' valence_embeddings |>
#'   get_similarities(
#'     list(happy = list(pos = happy_vec, neg = sad_vec)),
#'     anchored_sim
#'     )
#'
#' valence_df <- tibble::as_tibble(valence_embeddings, rownames = "token")
#' valence_df |> get_similarities(
#'   dim_1:dim_25,
#'   list(happy = happy_vec, sad = sad_vec),
#'   .keep_all = TRUE
#'   )

#' @export
get_similarities <- function(x, ...) {
  UseMethod("get_similarities")
}

#' @noRd
call_with_list <- function(x, what, args){
	arg_list <- c(list(x = x), args)
	do.call(what, arg_list)
}

#' @noRd
apply_func <- function(y_item, x, sim_func) {
	if (!is.list(y_item)){
		apply(x, 1, sim_func, y = y_item)
	}else if (all(names(y_item) %in% names(as.list(args(sim_func))))) {
		apply(x, 1, call_with_list, what = sim_func, args = y_item)
	}else{
		stop("y must provide appropriate arguments for sim_func\nRequired arguments: ",
				 paste(setdiff(names(as.list(args(sim_func))), c("x", "")),collapse = ", "))
	}
}

#' @export
get_similarities.default <- function(x, y, sim_func = cos_sim, ...) {
	if (!embeddings_check(x)) stop("x must be an embeddings object, matrix, or dataframe")
	if (!is.list(y)) stop("y must be a named list")
	out_cols <- lapply(y, apply_func, x = x, sim_func = sim_func)
	tibble::as_tibble(out_cols)
}

#' @rdname get_similarities
#' @method get_similarities embeddings
#' @export
get_similarities.embeddings <- function(x, y, sim_func = cos_sim, ...) {
	x <- as.embeddings(x)
	out <- get_similarities.default(x, y, sim_func, ...)
	dplyr::bind_cols(tibble::tibble(doc_id = rownames(x)), out)
}

#' @rdname get_similarities
#' @method get_similarities data.frame
#' @export
get_similarities.data.frame <- function(x, cols, y, sim_func = cos_sim, ..., .keep_all = "except.embeddings") {
  in_dat <- dplyr::select(x, {{ cols }})
  out_dat <- get_similarities.default(in_dat, y)
  if (.keep_all == "except.embeddings") {
  	dplyr::bind_cols( dplyr::select(x, -{{ cols }}), out_dat )
  }else if (.keep_all) {
  	dplyr::bind_cols( x, out_dat )
  }else{
  	out_dat
  }
}
