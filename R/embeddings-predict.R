#' Retrieve Token Embeddings
#'
#' @param object an embeddings object made by `load_embeddings()` or `as.embeddings()`
#' @param newdata a character vector of tokens
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
predict.embeddings <- function(object, newdata){
  embeddings <- as.matrix(object)
  embeddings <- rbind(embeddings, matrix(ncol = ncol(embeddings), dimnames = list("EMBEDDING_NOT_FOUND")))
  newdata[!(newdata %in% rownames(embeddings))] <- "EMBEDDING_NOT_FOUND"
  out <- embeddings[newdata,]
  if(is.vector(out)){
    out
  }else{
    as.embeddings(out)
  }
}
