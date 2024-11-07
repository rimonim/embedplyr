#' Get Text Embeddings by Averaging Word Embeddings
#'
#' `textstat_embedding()` takes a 'quanteda' dfm. `embed_docs()` is a more
#' versatile function for use in a purely dplyr-style workflow, which acts directly
#' on a column of texts.
#'
#' @param dfm a quanteda dfm
#' @param model an embeddings object made by `load_embeddings()` or `as.embeddings()`. For `embed_docs()`, `model` can alternatively be a function that takes a character vector and outputs a dataframe with a row for each element of the input
#' @param data 	a data frame or data frame extension (e.g. a tibble)
#' @param text_col string. a column of texts for which to compute embeddings
#' @param id_col optional string. column of unique document ids
#' @param ... additional parameters to pass to `quanteda::tokens()` or to the user-specified modeling function
#' @param .keep_all description
#' @import quanteda
#'
#' @section Value:
#' A tibble with columns `doc_id`, and `V1`, `V2`, etc. or similar. If `.keep_all = TRUE`, the new columns will appear after existing ones.
#'
#' @aliases embed_docs
#' @examples
#' # quanteda workflow
#' library(quanteda)
#' texts <- c("this says one thing", "and this says another")
#' texts_dfm <- dfm(tokens(texts))
#'
#' texts_embeddings <- textstat_embedding(texts_dfm, glove_twitter_25d)
#' texts_embeddings
#'
#' # dplyr workflow
#' texts_df <- data.frame(text = texts)
#' texts_embeddings <- texts_df |> embed_docs("text", glove_twitter_25d)
#' texts_embeddings

#' @export
textstat_embedding <- function(dfm, model){
  if(!inherits(model, "embeddings")){stop("`model` must be an embeddings object")}
  feats <- quanteda::featnames(dfm)
  # find word embeddings
  feat_embeddings <- predict.embeddings(model, feats)
  feat_embeddings[is.na(feat_embeddings)] <- 0
  # average word embeddings of each document
  out_mat <- (dfm %*% feat_embeddings)/quanteda::ntoken(dfm)
  tibble::as_tibble(as.matrix(out_mat), rownames = "doc_id")
}

#' @importFrom rlang :=
#' @rdname textstat_embedding
#' @export
embed_docs <- function(data, text_col, model, id_col = NULL, ..., .keep_all = FALSE){
  if(is.null(id_col)){
    id_col <- "doc_id"
    data <- dplyr::mutate(data, doc_id = paste0("text", 1:nrow(data)))
  }
  if(inherits(model, "embeddings")){
    data_dfm <- quanteda::dfm(quanteda::tokens(quanteda::corpus(data, docid_field = id_col, text_field = text_col), ...))
    new_cols <- textstat_embedding(data_dfm, model)
    names(new_cols)[1] <- id_col
    new_cols <- dplyr::mutate(new_cols, !!id_col := methods::as(!!rlang::sym(id_col), class(dplyr::pull(data, id_col))[1]))
  }else if(inherits(model, "function")){
    new_cols <- model(data, ...)
    if(!inherits(new_cols, "data.frame") || nrow(new_cols) == nrow(data)){
      stop("`model` must be either an embeddings object or a function that outputs a dataframe with the same number of rows as `data`")
    }
    new_cols <- dplyr::bind_rows(dplyr::select(data, tidyselect::all_of(id_col)), new_cols)
  }
  if(.keep_all){
    return(dplyr::left_join(data, new_cols, by = id_col))
  }else{
    new_cols
  }
}
