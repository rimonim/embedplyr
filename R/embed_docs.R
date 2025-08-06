#' Get Text Embeddings by Averaging Word Embeddings
#'
#' `textstat_embedding()` takes a 'quanteda' [dfm][quanteda::dfm]. `embed_docs()` is a more
#' versatile function for which acts directly on either a character vector or
#' a column of texts in a dataframe.
#'
#' @param dfm a quanteda [dfm][quanteda::dfm]
#' @param model an [embeddings] object. For `embed_docs()`, `model`
#' can alternatively be a function that takes a character vector and outputs a
#' dataframe with a row for each element of the input.
#' @param w optional weighting for embeddings in `model` if `model` is an
#' embeddings object. See [average_embedding()].
#' @param method method to use for averaging. See [average_embedding()]. Note that
#' `method = "median"` does not use matrix operations and may therefore be slow
#' for datasets with many documents.
#' @param x a character vector, a data frame, or data frame extension (e.g. a tibble)
#' @param text_col string. a column of texts for which to compute embeddings
#' @param id_col optional string. column of unique document ids
#' @param ... additional parameters to pass to `quanteda::tokens()` or to the
#' user-specified modeling function
#' @param .keep_all logical. Keep all columns from input? Ignored if `output_embeddings = TRUE`.
#' @param tolower logical. Convert all text to lowercase? If `model` is an
#' embeddings object, this value is passed to [quanteda::dfm()].
#' @param output_embeddings `FALSE` (the default) returns a tibble.
#' `TRUE` returns an embeddings object. See 'Value' for details.
#' @import quanteda
#'
#' @section Value:
#' If `output_embeddings = FALSE`, a tibble with columns `doc_id`, and `dim_1`, `dim_2`,
#' etc. or similar. If `.keep_all = TRUE`, the new columns will appear after
#' existing ones.
#' If `output_embeddings = TRUE`, an embeddings object with document ids as rownames.
#'
#' @seealso [embed_tokens()]
#'
#' @aliases textstat_embedding
#' @examples
#' texts <- c("this says one thing", "and this says another")
#' texts_embeddings <- embed_docs(texts, glove_twitter_25d)
#' texts_embeddings
#'
#' # quanteda workflow
#' library(quanteda)
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
embed_docs <- function(x, ...) {
  UseMethod("embed_docs")
}

#' @rdname embed_docs
#' @importFrom rlang %||%
#' @export
embed_docs.default <- function(x, model, w = NULL, method = "mean", ...,
                               tolower = TRUE, output_embeddings = FALSE){
  if(inherits(model, "embeddings")){
    x_dfm <- quanteda::dfm(quanteda::tokens(x, ...), tolower = tolower)
    out <- textstat_embedding(x_dfm, model, w, method, output_embeddings = output_embeddings)
    if (output_embeddings) return(out)
  }else if(inherits(model, "function")){
    texts <- as.character(x)
    if (tolower) texts <- tolower(texts)
    out <- model(texts, ...)
    if(!inherits(out, "data.frame") || nrow(out) != length(texts)){
      stop("`model` must be either an embeddings object or a function that outputs a dataframe with the same number of rows as `x`")
    }
    docnames <- names(x) %||% paste0("text",seq_along(x))
    out <- dplyr::bind_cols(tibble::tibble("doc_id" = docnames), out)
    if (output_embeddings) return(as.embeddings(out, id_col = "doc_id"))
  }else{
    stop("`model` must be either an embeddings object or a function that outputs a dataframe with the same number of rows as `x`")
  }
  out
}

#' @importFrom rlang :=
#' @importFrom rlang %||%
#' @rdname embed_docs
#' @method embed_docs data.frame
#' @export
embed_docs.data.frame <- function(x, text_col, model, id_col = NULL,
                                  w = NULL, method = "mean", ...,
                                  .keep_all = FALSE, tolower = TRUE,
                                  output_embeddings = FALSE) {
  texts <- dplyr::pull(x, text_col, name = !!id_col)
  out <- embed_docs.default(texts, model = model, w = w, method = method, ...,
                            tolower = tolower, output_embeddings = output_embeddings)
  if(output_embeddings) return(out)
  if(.keep_all){
    out <- dplyr::bind_cols(x, out[,-1])
    return(tibble::as_tibble(dplyr::relocate(out, !!id_col)))
  }else{
    names(out)[1] <- id_col %||% "doc_id"
    out
  }
}

#' @rdname embed_docs
#' @export
textstat_embedding <- function(dfm, model, w = NULL, method = "mean", output_embeddings = FALSE){
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
  if (!output_embeddings) {
    tibble::as_tibble(out_mat, rownames = "doc_id")
  }else{
    as.embeddings(out_mat)
  }
}
