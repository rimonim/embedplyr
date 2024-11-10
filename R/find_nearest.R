#' Find Nearest Tokens in Embedding Space
#'
#' @param object an embeddings object made by `load_embeddings()` or `as.embeddings()`
#' @param newdata a character vector of tokens indexed by `object`,
#' an embeddings object of the same dimensionality as `object`,
#' or a numeric vector of the same dimensionality as `object`.
#' @param top_n integer. How many nearest neighbors should be output? If `each = TRUE`,
#' how many nearest neighbors should be output for each token?
#' @param sim_func a function that takes two vectors and outputs a scalar
#' similarity metric. Defaults to cosine similarity. For more options see
#' [Similarity and Distance Metrics][sim_metrics].
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
  if (is.character(newdata)) {
    newdata_raw <- newdata
    embedding_not_found <- !(newdata %in% rownames(object))
    if (any(embedding_not_found)) {
      warning(sum(embedding_not_found), " items in `newdata` are not tokens in the embeddings object.")
      newdata[embedding_not_found] <- "EMBEDDING_NOT_FOUND"
    }
    if(all(newdata == "EMBEDDING_NOT_FOUND")){stop("None of the items in `newdata` are tokens in the embeddings object")}
    object <- rbind(object, matrix(ncol = ncol(object), dimnames = list("EMBEDDING_NOT_FOUND")))
    if (!each) {
      target <- object[newdata,]
    }else{
      target <- lapply(newdata, function(tok){object[tok,]})
      names(target) <- newdata
    }
  }else{
    if (all(is.na(newdata))) stop("newdata is entirely NAs")
    newdata_raw <- rownames(newdata)
    if (!each) {
      target <- newdata
      newdata <- rownames(newdata)
    }else{
      target <- as.embeddings(newdata)
      newdata <- rownames(target)
      target <- lapply(newdata, function(tok){target[tok,]})
      names(target) <- newdata
    }
  }
  if (!each) {
    if (length(newdata) > 1) {
      target <- apply(target, 2, mean, na.rm = TRUE)
    }
    sims <- apply(object, 1, sim_func, target)
    if (include_self) {
      object <- object[order(sims, decreasing = TRUE)[1:top_n],]
    }else{
      object <- object[order(sims, decreasing = TRUE)[1:(top_n+length(newdata))],]
      object <- object[!(rownames(object) %in% newdata),]
    }
    as.embeddings(object)
  }else{
    sims <- lapply(target, function(vec){apply(object, 1, sim_func, vec)})
    object <- lapply(sims, function(sim){object[order(sim, decreasing = TRUE),]})
    if (!include_self) {object <- lapply(object, function(x){x[!(rownames(x) %in% newdata),]})}
    object <- lapply(object, function(x){as.embeddings(utils::head(x, top_n))})
    object[names(object) == "EMBEDDING_NOT_FOUND"] <- NA
    names(object) <- newdata_raw
    object
  }
}
