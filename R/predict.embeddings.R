#' Retrieve Token Embeddings
#'
#' @param object an embeddings object made by `load_embeddings()` or `as.embeddings()`
#' @param newdata a character vector of tokens
#' @import quanteda
#'
#' @section Value:
#' An embeddings object with a row for each item in `newdata`
#'
#' @examples
#' words <- c("happy", "sad")
#'
#' fake_mod <- as.embeddings(
#'     matrix(
#'         sample(1:10, 20, replace = TRUE),
#'         nrow = 2,
#'         dimnames = list(c("happy", "sad"))
#'     )
#' )
#'
#' texts_embeddings <- predict(fake_mod, words)
#' texts_embeddings

#' @rdname predict.embeddings
#' @export
predict.embeddings <- function(object, newdata){
  embeddings <- as.matrix(object)
  embeddings <- rbind(embeddings, matrix(ncol = ncol(embeddings), dimnames = list("NOT_IN_DICT")))
  newdata[!(newdata %in% rownames(embeddings))] <- "NOT_IN_DICT"
  as.embeddings(embeddings[newdata,])
}
