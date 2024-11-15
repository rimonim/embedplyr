#' Average Embeddings
#'
#' Calculate the (weighted) average of multiple embeddings.
#'
#' @param x an embeddings object
#' @param weights a numeric vector of weights for each row in x, `"trillion_word"`
#' (125,000 English word frequencies from [Peter Norvig's compilation](https://norvig.com/ngrams/count_1w.txt),
#' derived from the Google Web Trillion Word Corpus), or smooth inverse frequencies
#' (SIF) calculated using the same list.
#' @param method method to use for averaging. `"mean"` (the default) is the standard
#' arithmetic mean. `"median"` is the geometric median (also called spatial median or
#' L1-median), computed using [Gmedian::Gmedian()] or, if weights are provided,
#' [Gmedian::Weiszfeld()].
#' @param ... additional arguments to be passed to the averaging function
#'
#' @details
#' For `weights = "trillion_word"`, tokens that do not appear in the word frequency
#' list are treated as if they appeared as often as the least frequent word in the list.
#'
#' @importFrom stats weighted.mean
#' @examples
#' happy_dict <- c("happy", "joy", "smile", "enjoy")
#' happy_dict_embeddings <- predict(glove_twitter_25d, happy_dict)
#'
#' happy_dict_vec <- average_embedding(happy_dict_embeddings)
#' happy_dict_vec_weighted <- average_embedding(happy_dict_embeddings, weights = "trillion_word")

#' @export
average_embedding <- function(x, weights = NULL, method = "mean", ...){
	if(!is.null(weights)){
		if(weights[1] == "trillion_word"){
			weights <- trillion_word[rownames(x)]
			weights[is.na(weights)] <- min(trillion_word)
		}else if (weights[1] == "trillion_word_sif"){
			alpha <- 0.005 # reasonable parameter for SIF
			not_a_trillion <- 1024908267229 # total number of words processed by Google
			alpha <- 0.005*1024908267229
			weights <- alpha/(alpha + trillion_word[rownames(x)])
		}else{
			stopifnot("length(weights) must equal nrow(x)" = length(weights) == nrow(x))
		}
		if (method == "mean") return( apply(x, 2, weighted.mean, w = weights, ...) )
	}else{
		if (method == "mean") return( colMeans(x, ...) )
	}
	if (method == "median") {
		stopifnot("package 'Gmedian' is required" = requireNamespace("Gmedian", quietly = TRUE))
		if (is.null(weights)) {
			out <- as.numeric( Gmedian::Gmedian(x, ...) )
		}else{
			out <- as.numeric( Gmedian::Weiszfeld(x, weights = weights, ...)$median )
		}
		names(out) <- colnames(x)
		out
	}
}
