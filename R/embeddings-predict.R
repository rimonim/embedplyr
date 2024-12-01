#' Retrieve Token Embeddings
#'
#' @param object an embeddings object made by `load_embeddings()` or `as.embeddings()`
#' @param newdata a character vector of tokens
#' @param drop logical. If `TRUE` (the default) and the result is one-dimensional
#' (e.g. a single row), the output will be a (named) vector.
#' @param .keep_missing logical. What should be done about items in `newdata`
#' that are not present in the embeddings object? If `FALSE` (the default), they
#' will be ignored. If `TRUE`, they will be returned as `NA`.
#' @import quanteda
#'
#' @details
#' Duplicated items in `newdata` will result in duplicated rows in the output.
#' If an item in `newdata` matches multiple rows in `object`, the last one will
#' be returned.
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
predict.embeddings <- function(object, newdata, drop = TRUE, .keep_missing = FALSE){
  if (any(zchars <- !nzchar(newdata))) {
    warning(sprintf('Replacing %d empty strings with " ".', sum(zchars)))
    newdata[zchars] <- " "
  }
  embedding_not_found <- !sapply(newdata, exists, envir = attr(object, "token_index"))
  if (any(embedding_not_found)) {
    warning(sprintf("%d items in `newdata` are not present in the embeddings object.", sum(embedding_not_found)))
  }
  if (.keep_missing) {
    out <- matrix(nrow = length(newdata), ncol = ncol(object), dimnames = list(newdata, colnames(object)))
    out[!embedding_not_found,] <- object[newdata[!embedding_not_found],]
    out <- as.embeddings(out, rowname_repair = FALSE)
    if (drop && nrow(out) == 1L) return(out[1,])
  }else{
    out <- object[newdata[!embedding_not_found],,drop = drop]
    if (drop && length(out) == 0L) return(numeric())
  }
  out
}
