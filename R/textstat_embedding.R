#' Get Text Embeddings by Averaging Word Embeddings
#'
#'
#' @param dfm a quanteda dfm
#' @param model an embeddings object made by `load_embeddings()` or `as.embeddings()`
#' @import quanteda
#'
#' @section Value:
#' A tibble with columns `doc_id`, and `V1`, `V2`, etc.
#'
#' @examples
#'    texts <- c("this says one thing", "and this says another")
#'    texts_dfm <- dfm(tokens(texts))
#'
#'    fake_mod <- as.embeddings(
#'     matrix(
#'       sample(1:10, 30, replace = TRUE),
#'       nrow = 6,
#'       dimnames = list(c("this", "and", "says", "one", "thing", "another"))
#'       )
#'     )
#'
#'    texts_embeddings <- textstat_embeddings(texts_dfm, fake_mod)
#'    texts_embeddings

#' @rdname textstat_embedding
#' @export
textstat_embedding <- function(dfm, model){
  feats <- featnames(dfm)
  # find word embeddings
  feat_embeddings <- predict(model, feats, type = "embedding")
  feat_embeddings[is.na(feat_embeddings)] <- 0
  # average word embeddings of each document
  out_mat <- (dfm %*% feat_embeddings)/ntoken(dfm)
  colnames(out_mat) <- paste0("V", 1:ncol(out_mat))
  as_tibble(as.matrix(out_mat), rownames = "doc_id")
}
