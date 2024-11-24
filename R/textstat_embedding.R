#' Get Text Embeddings by Averaging Word Embeddings
#'
#' `textstat_embedding()` takes a 'quanteda' dfm. `embed_docs()` is a more
#' versatile function for use in a purely dplyr-style workflow, which acts directly
#' on a column of texts.
#'
#' @param dfm a quanteda dfm
#' @param model an [embeddings] object. For `embed_docs()`, `model`
#' can alternatively be a function that takes a character vector and outputs a
#' dataframe with a row for each element of the input.
#' @param w optional weighting for embeddings in `model` if `model` is an
#' embeddings object. See [average_embedding()].
#' @param method method to use for averaging. See [average_embedding()]. Note that
#' `method = "median"` does not use matrix operations and may therefore be slow
#' for datasets with many documents.
#' @param data 	a data frame or data frame extension (e.g. a tibble)
#' @param text_col string. a column of texts for which to compute embeddings
#' @param id_col optional string. column of unique document ids
#' @param ... additional parameters to pass to `quanteda::tokens()` or to the
#' user-specified modeling function
#' @param .keep_all logical. Keep all columns from input? Ignored if `output = "tibble"`.
#' @param tolower logical. Convert all text to lowercase? If `model` is an
#' embeddings object, this value is passed to [quanteda::dfm()].
#' @param output `"tibble"` (the default) returns a tibble. `"embeddings"`
#' returns an embeddings object. See 'Value' for details.
#' @import quanteda
#'
#' @section Value:
#' If `output = "tibble"`, a tibble with columns `doc_id`, and `dim_1`, `dim_2`,
#' etc. or similar. If `.keep_all = TRUE`, the new columns will appear after
#' existing ones.
#' If `output = "embeddings"`, an embeddings object with document ids as rownames.
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
textstat_embedding <- function(dfm, model, w = NULL, method = "mean", output = "tibble"){
  if(!inherits(model, "embeddings")) stop("`model` must be an embeddings object")
  if (!(method %in% c("mean", "median", "sum"))) stop("'", method, "' is not a recognized averaging method")
  feats <- quanteda::featnames(dfm)
  # weights
  if (!is.null(w)) {
    w <- make_embedding_weights(rownames(model), w)
    dfm <- suppressWarnings( quanteda::dfm_weight(dfm, weights = w) )
  }
  # find word embeddings
  feat_embeddings <- predict.embeddings(model, feats, .keep_missing = TRUE)

  if (method == "median") {
    out_list <- lapply(seq_len(nrow(dfm)), function(r){
      w <- as.numeric(dfm[r,])
      names(w) <- feats
      w
      })
    out_list <- lapply(out_list, function(w){
      stopifnot("package 'Gmedian' is required" = requireNamespace("Gmedian", quietly = TRUE))
      out <- Gmedian::Weiszfeld(model[feats,], w = w)$median
      colnames(out) <- colnames(model)
      out
      })
    out_mat <- do.call(rbind, out_list)
    rownames(out_mat) <- rownames(dfm)
  }else{
    # ignore tokens with no embedding
    feat_embeddings[is.na(feat_embeddings)] <- 0
    # average word embeddings of each document
    out_mat <- (dfm %*% feat_embeddings)
    if (method == "mean") out_mat <- out_mat/rowSums(dfm)
    out_mat <- as.matrix(out_mat)
  }
  if (output == "tibble") {
    tibble::as_tibble(out_mat, rownames = "doc_id")
  }else if (output == "embeddings"){
    as.embeddings(out_mat)
  }else{
    stop('`output` must be either "tibble" or "embeddings"')
  }
}

#' @importFrom rlang :=
#' @rdname textstat_embedding
#' @export
embed_docs <- function(data, text_col, model, id_col = NULL,
                       w = NULL, method = "mean", ...,
                       .keep_all = FALSE, tolower = TRUE, output = "tibble"){
  if(is.null(id_col)){
    id_col <- "doc_id"
    data <- dplyr::mutate(data, doc_id = paste0("text", 1:nrow(data)))
  }
  if(inherits(model, "embeddings")){
    data_dfm <- quanteda::dfm(quanteda::tokens(quanteda::corpus(data, docid_field = id_col, text_field = text_col), ...))
    new_cols <- textstat_embedding(data_dfm, model, w, method, output = output)
    if (output == "embeddings") return(new_cols)
    names(new_cols)[1] <- id_col
    new_cols <- dplyr::mutate(new_cols, !!id_col := methods::as(!!rlang::sym(id_col), class(dplyr::pull(data, id_col))[1]))
  }else if(inherits(model, "function")){
    texts <- dplyr::pull(data, text_col)
    if (tolower) texts <- tolower(texts)
    new_cols <- model(texts, ...)
    if(!inherits(new_cols, "data.frame") || nrow(new_cols) != nrow(data)){
      stop("`model` must be either an embeddings object or a function that outputs a dataframe with the same number of rows as `data`")
    }
    new_cols <- dplyr::bind_cols(dplyr::select(data, tidyselect::all_of(id_col)), new_cols)
    if (output == "embeddings") return(as.embeddings(new_cols, id_col = id_col))
  }else{
    stop("`model` must be either an embeddings object or a function that outputs a dataframe with the same number of rows as `data`")
  }
  if(.keep_all){
    return(dplyr::left_join(data, new_cols, by = id_col))
  }else{
    new_cols
  }
}
