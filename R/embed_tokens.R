#' Get Embeddings of Tokens in a Text or Corpus
#'
#' Given a character vector or 'quanteda' object ([tokens][quanteda::tokens], [dfm][quanteda::dfm], or [corpus][quanteda::corpus])  and a
#' word embeddings model in the form of an [embeddings] object, [embed_tokens()]
#' returns the embedding for each token.
#'
#' @param x a character vector of texts, a data frame, a 'quanteda'
#' [tokens][quanteda::tokens] object, or a 'quanteda' [corpus][quanteda::corpus]
#' @param text_col string. a column of texts to be tokenized and converted to embeddings
#' @param model a word embeddings model in the form of an [embeddings] object
#' @param id_col optional string. column of unique document ids
#' @param ... additional parameters to pass to `quanteda::tokens()`
#' @param .keep_missing logical. What should be done about tokens in `x` that
#' are not present in `model`? If `FALSE` (the default), they will be ignored.
#' If `TRUE`, they will be returned as `NA`.
#' @param .keep_all logical. Keep all columns from input? Ignored if `output_embeddings = TRUE`.
#' @param tolower logical. Convert all text to lowercase?
#' @param output_embeddings `FALSE` (the default) returns a tibble.
#' `TRUE` returns a list of embeddings objects. See 'Value' for details.
#'
#' @section Value:
#' If `output_embeddings = FALSE`, a tibble with columns `doc_id`, `token`, and embedding
#' dimension names. If `.keep_all = TRUE`, the new columns will appear after
#' existing ones, and the class of the input will be maintained.
#' If `output_embeddings = TRUE`, a named list of embeddings objects with tokens as
#' rownames.
#'
#' @seealso [embed_docs()]
#'
#' @examples
#' texts <- c("this says one thing", "and this says another")
#' texts_token_embeddings <- embed_tokens(texts, glove_twitter_25d)
#' texts_token_embeddings
#'
#' # quanteda workflow
#' library(quanteda)
#' texts_tokens <- tokens(texts)
#' texts_token_embeddings <- embed_tokens(texts_tokens, glove_twitter_25d)
#' texts_token_embeddings
#'
#' # dplyr workflow
#' texts_df <- data.frame(text = texts)
#' texts_token_embeddings <- texts_df |> embed_tokens("text", glove_twitter_25d)
#' texts_token_embeddings

#' @export
embed_tokens <- function(x, ...) {
	UseMethod("embed_tokens")
}

#' @rdname embed_tokens
#' @method embed_tokens default
#' @export
embed_tokens.default <- function(x, model, ..., .keep_missing = FALSE,
												 tolower = TRUE, output_embeddings = FALSE) {
	if (!is.embeddings(model)) stop("`model` must be an embeddings object.")
	x <- quanteda::tokens(x, ...)
	if (tolower) x <- quanteda::tokens_tolower(x)
	x <- as.list(x)
	unique_x <- unique(unlist(x, use.names = FALSE))
	embedding_not_found <- !vapply(unique_x, exists, FALSE, envir = attr(model, "token_index"))
	if (any(embedding_not_found)) {
		warning(sprintf("%d tokens in `x` are not present in `model`.", sum(embedding_not_found)))
	}
	out <- lapply(x, function(nd) suppressWarnings(predict.embeddings(model, nd, drop = FALSE, .keep_missing = .keep_missing)))
	if (output_embeddings) return(out)
	out <- lapply(out, function(emb) if (nrow(emb) != 0) as_tibble(emb, rownames = "token") else NULL)
	dplyr::bind_rows(out, .id = "doc_id")
}

#' @rdname embed_tokens
#' @method embed_tokens data.frame
#' @export
embed_tokens.data.frame <- function(x, text_col, model, id_col = NULL,
																		..., .keep_missing = FALSE, .keep_all = FALSE,
																		tolower = TRUE, output_embeddings = FALSE) {
	texts <- dplyr::pull(x, text_col, name = !!id_col)
	out <- embed_tokens.default(texts, model = model, ..., .keep_missing = .keep_missing,
															tolower = tolower, output_embeddings = output_embeddings)
	if(output_embeddings) return(out)
	if (is.null(id_col)) {
		x <- dplyr::mutate(x, "doc_id" = paste0("text",seq_len(nrow(x))))
		id_col <- "doc_id"
	}else{
		names(out)[1] <- id_col
	}
	if(.keep_all) out <- dplyr::right_join(x, out, by = id_col)
	out
}
