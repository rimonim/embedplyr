#' Find Nearest Tokens in Embedding Space
#'
#' @param object an embeddings object made by `load_embeddings()` or `as.embeddings()`
#' @param newdata a character vector of tokens indexed by `object`,
#' an embeddings object of the same dimensionality as `object`,
#' or a numeric vector of the same dimensionality as `object`.
#' @param top_n integer. How many nearest neighbors should be output? If `each = TRUE`,
#' how many nearest neighbors should be output for each token?
#' @param method either the name of a method to compute similarity or distance,
#' or a function that takes two vectors and outputs a scalar, like those listed
#' in [Similarity and Distance Metrics][sim_metrics]. The value is passed to [get_similarities()].
#' @param ... additional parameters to be passed to method function by way of [get_similarities()]
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
                         method = c("cosine", "euclidean", "minkowski", "dot_prod", "anchored"),
                         ...,
                         each = FALSE,
                         include_self = TRUE){
  if (!inherits(object, "embeddings")) {stop("`object` is not an embeddings object")}
  if (!(is.character(newdata) || is.numeric(newdata) || inherits(newdata, "embeddings"))) {
    stop("`newdata` must be a character vector, a numeric vector, or an embeddings object.")
  }
  if (is.character(newdata)) {
    all_tokens <- newdata
    embedding_not_found <- !(newdata %in% rownames(object))
    if (any(embedding_not_found)) {
      if(all(embedding_not_found)){stop("None of the items in `newdata` are tokens in the embeddings object")}
      warning(sprintf("%d items in `newdata` are not present in the embeddings object.", sum(embedding_not_found)))
    }
    missing_tokens <- newdata[embedding_not_found]
    available_tokens <- newdata[!embedding_not_found]
    if (!each) {
      target <- object[available_tokens,]
    }else{
      target <- lapply(available_tokens, function(tok){object[tok,]})
      names(target) <- available_tokens
    }
  }else{
    if (all(is.na(newdata))) stop("newdata is entirely NAs")
    all_tokens <- rownames(newdata)
    missing_tokens <- NULL
    if (!each) {
      target <- newdata
      available_tokens <- rownames(newdata)
    }else{
      target <- as.embeddings(newdata)
      available_tokens <- rownames(target)
      target <- lapply(available_tokens, function(tok){target[tok,]})
      names(target) <- available_tokens
    }
  }
  if (!each) {
    if (length(available_tokens) > 1) {
      target <- colMeans(target, na.rm = TRUE)
    }
    sims <- get_similarities(object, list(sim = target), method, ...)$sim
    if (include_self) {
      object <- object[order(sims, decreasing = TRUE)[1:top_n],]
    }else{
      object <- object[order(sims, decreasing = TRUE)[1:(top_n+length(available_tokens))],]
      object <- object[!(rownames(object) %in% available_tokens),]
    }
    as.embeddings(object)
  }else{
    sims <- lapply(target, function(vec){get_similarities(object, list(sim = vec), method, ...)$sim})
    object <- lapply(sims, function(sim){object[order(sim, decreasing = TRUE),]})
    if (!include_self) {object <- lapply(object, function(x){x[!(rownames(x) %in% available_tokens),]})}
    object <- lapply(object, function(x){as.embeddings(utils::head(x, top_n))})
    object[all_tokens %in% missing_tokens] <- NA
    names(object) <- all_tokens
    object
  }
}
