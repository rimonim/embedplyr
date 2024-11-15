#' Average Embeddings
#'
#' Calculate the (weighted) average of multiple embeddings.
#'
#' @param x an embeddings object
#' @param weights a numeric vector of weights for each row in x, `"trillion_word"`
#' (125,000 English word frequencies from [Peter Norvig's compilation](https://norvig.com/ngrams/count_1w.txt),
#' derived from the Google Web Trillion Word Corpus), or smooth inverse frequencies
#' (SIF) calculated using the same list.
#' @param na.rm logical. Should missing values (including NaN) be omitted from the calculations?
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
average_embedding <- function(x, weights = NULL, na.rm = FALSE){
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
		return( apply(x, 2, weighted.mean, w = weights, na.rm = na.rm) )
	}else{
		return( colMeans(x, na.rm = na.rm) )
	}
}
