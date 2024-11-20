#' Retrieve Token Embeddings
#'
#' @param object an embeddings object made by `load_embeddings()` or `as.embeddings()`
#' @param newdata a character vector of tokens
#' @param .keep_missing logical. What should be done about items in `newdata`
#' that are not present in the embeddings object? If `FALSE` (the default), they
#' will be ignored. If `TRUE`, they will be returned as `NA`.
#' @import quanteda
#'
#' @section Value:
#' Either an embeddings object with a row for each item in `newdata`, or, when
#' `newdata` is of length 1, a named numeric vector.
#'
#' @examples
#' words <- c("happy", "sad")
#'
#' texts_embeddings <- predict(glove_twitter_25d, words)
#' texts_embeddings

#' @rdname predict.embeddings
#' @export
predict.embeddings <- function(object, newdata, .keep_missing = FALSE){
  embedding_not_found <- !(newdata %in% rownames(object))
  if (any(embedding_not_found)) {
    warning(sprintf("%d items in `newdata` are not present in the embeddings object.", sum(embedding_not_found)))
  }
  if (.keep_missing) {
    out <- matrix(nrow = length(newdata), ncol = ncol(object), dimnames = list(newdata, colnames(object)))
    out[!embedding_not_found,] <- object[newdata[!embedding_not_found],]
  }else{
    out <- object[newdata[!embedding_not_found],]
  }
  if(is.vector(out)){
    out
  }else{
    as.embeddings(out, .rowname_repair = FALSE)
  }
}
