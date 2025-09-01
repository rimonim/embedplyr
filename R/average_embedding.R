#' @noRd
make_embedding_weights <- function(x_names, w){
	if(w[1] == "trillion_word"){
		w <- trillion_word[x_names]
		min_w <- min(trillion_word)
	}else if (w[1] == "trillion_word_sif"){
		alpha <- 0.005 # reasonable parameter for SIF
		not_a_trillion <- 1024908267229 # total number of words processed by Google
		alpha <- 0.005*1024908267229
		w <- trillion_word[x_names]
		min_w <- alpha/(alpha + min(trillion_word))
		w <- alpha/(alpha + w)
	}else{
		stopifnot("w must be either a numeric vector or the name of a supported weighting scheme" = is.numeric(w))
		if (!is.null(names(w))) {
			min_w <- min(w, na.rm = TRUE)
			w <- w[x_names]
		}
	}
	missing_w <- is.na(w)
	if (all(missing_w)) warning("w does not include any applicable values")
	if (any(missing_w)) warning("Replacing ", sum(missing_w), " unspecified weights with the minimum value in w", call. = FALSE)
	w[missing_w] <- min_w
	names(w) <- x_names
	w
}

#' Average Embeddings
#'
#' Calculate the (weighted) average of multiple embeddings.
#'
#' @param x an embeddings object or list of embeddings objects
#' @param w optional weighting for rows in x. This can be an unnamed
#' numeric vector with one item per row of x, a named numeric vector of any
#' length with names that match the row names of x, `"trillion_word"` (125,000
#' English word frequencies from [Peter Norvig's compilation](https://norvig.com/ngrams/count_1w.txt),
#' derived from the Google Web Trillion Word Corpus), or `"trillion_word_sif"`
#' for smooth inverse frequencies (SIF) calculated using the same list.
#' @param method method to use for averaging. `"mean"` (the default) is the standard
#' arithmetic mean. `"median"` is the geometric median (also called spatial median or
#' L1-median), computed using [Gmedian::Gmedian()] or, if weights are provided,
#' [Gmedian::Weiszfeld()]. `"sum"` is the (weighted) sum.
#' @param ... additional arguments to be passed to the averaging function
#'
#' @details
#' For `w = "trillion_word"` or `w = "trillion_word_sif"`, tokens
#' that do not appear in the word frequency list are treated as if they appeared
#' as often as the least frequent word in the list. If `w` is a named vector,
#' rows that do not match any items in the vector will be assigned the minimum
#' value of that vector.
#'
#' @section Value:
#' A named numeric vector. If `x` is a list, the function will be called
#' recursively and output a list of the same length.
#'
#' @importFrom stats weighted.mean
#' @examples
#' happy_dict <- c("happy", "joy", "smile", "enjoy")
#' happy_dict_embeddings <- emb(glove_twitter_25d, happy_dict)
#'
#' happy_dict_vec <- average_embedding(happy_dict_embeddings)
#' happy_dict_vec_weighted <- average_embedding(happy_dict_embeddings, w = "trillion_word")
#'
#' happy_dict_list <- find_nearest(glove_twitter_25d, happy_dict, each = TRUE)
#' happy_dict_vec_list <- average_embedding(happy_dict_list)

#' @export
average_embedding <- function(x, w = NULL, method = "mean", ...){
	if (inherits(x, "list")) return(lapply(x, average_embedding, w = w, method = method))
	if(!is.null(w)){
		w <- make_embedding_weights(rownames(x), w)
		if (method == "mean") return( apply(x, 2, weighted.mean, w = w, ...) )
		if (method == "sum") x <- t(t(x)*w)
	}
	if (method == "mean") return( colMeans(x, ...) )
	if (method == "sum") return( colSums(x, ...) )
	if (method == "median") {
		stopifnot("Package 'Gmedian' is required" = requireNamespace("Gmedian", quietly = TRUE))
		if (is.null(w)) {
			out <- as.numeric( Gmedian::Gmedian(x, ...) )
		}else{
			out <- as.numeric( Gmedian::Weiszfeld(x, w = w, ...)$median )
		}
		names(out) <- colnames(x)
		out
	}else{
		stop("'", method, "' is not a recognized averaging method")
	}
}
