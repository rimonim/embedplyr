#' Find Nearest Tokens in Embedding Space
#'
#' @param object an embeddings object made by `load_embeddings()` or `as.embeddings()`
#' @param newdata a character vector of tokens
#' @param top_n integer. How many nearest neighbors should be output? If `each = TRUE`,
#' how many nearest neighbors should be output for each token?
#' @param sim_func a function that takes two vectors and outputs a scalar
#' similarity metric. Defaults to cosine similarity.
#' @param each logical. If `FALSE` (the default), the embeddings of newdata are
#' averaged and the function will output an embeddings object with the `top_n`
#' nearest tokens to the overall average embedding. If `TRUE`, the function will
#' output a named list with one embeddings object for each token in newdata.
#' @param include_self logical. Should the token(s) in `newdata` be included in
#' the output?
#' @import quanteda
#'
#' @section Value:
#' An embeddings object or list of embeddings objects.
#'
#' @examples
#' words <- c("happy", "sad")
#'
#' find_nearest(glove_twitter_25d, words)
#' find_nearest(glove_twitter_25d, words, each = TRUE)

#' @rdname find_nearest
#' @export
find_nearest <- function(object, newdata,
                         top_n = 10L,
                         sim_func = cos_sim,
                         each = FALSE,
                         include_self = TRUE){
  if (!("embeddings" %in% class(object))) {stop("`object` is not an embeddings object")}
  newdata[!(newdata %in% rownames(object))] <- "NOT_IN_DICT"
  if(all(newdata == "NOT_IN_DICT")){stop("None of the items in `newdata` are tokens in the embeddings object")}
  embeddings <- rbind(object, matrix(ncol = ncol(object), dimnames = list("NOT_IN_DICT")))
  if (!each) {
    if(length(newdata) > 1){
      target <- as.vector(apply(embeddings[newdata,], 2, mean, na.rm = TRUE))
    }else{
      target <- as.vector(embeddings[newdata,])
    }
    sims <- apply(object, 1, sim_func, target)
    embeddings <- embeddings[rev(order(sims)),]
    if (!include_self) {embeddings <- embeddings[!(rownames(embeddings) %in% newdata),]}
    as.embeddings(utils::head(embeddings, top_n))
  }else{
    target <- lapply(newdata, function(tok){as.vector(embeddings[tok,])})
    names(target) <- newdata
    sims <- lapply(target, function(vec){apply(object, 1, sim_func, vec)})
    embeddings <- lapply(sims, function(sim){embeddings[rev(order(sim)),]})
    if (!include_self) {embeddings <- lapply(embeddings, function(x){x[!(rownames(x) %in% newdata),]})}
    lapply(embeddings, function(x){as.embeddings(utils::head(x, top_n))})
  }
}
