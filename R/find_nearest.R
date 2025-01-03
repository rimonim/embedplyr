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
#' in [Similarity and Distance Metrics][sim_metrics]. The value is passed to [get_sims()].
#' @param ... additional parameters to be passed to method function by way of [get_sims()]
#' @param each logical. If `FALSE` (the default), the embeddings of newdata are
#' averaged and the function will output an embeddings object with the `top_n`
#' nearest tokens to the overall average embedding. If `TRUE`, the function will
#' output a named list with one embeddings object for each token in newdata.
#' @param include_self logical. Should the token(s) in `newdata` be included in
#' the output?
#' @param decreasing logical. Determines the order of sorting the similarity scores.
#' If `TRUE` (the default for `"cosine"`, `"dot_prod"`, and `"anchored"` methods),
#' the embeddings with the highest similarity scores are output. If `FALSE`
#' (the default for `"euclidean"` and `"minkowski"` methods), the embeddings with
#' the lowest distance scores are output.
#' @param get_sims logical. If `FALSE` (the default), output an embeddings
#' object or list of embeddings objects. If `TRUE`, output a tibble with similarity
#' or distance scores for each document.
#'
#' @section Value:
#' If `get_sims = FALSE` (the default), an embeddings object or list of
#' embeddings objects.  If `get_sims = TRUE`, a tibble or list of tibbles
#' with similarity or distance scores for each document, with columns `doc_id`
#' and the name of the requested `method`.
#'
#' @examples
#' words <- c("happy", "sad")
#' words_embeddings <- predict(glove_twitter_25d, words)
#'
#' find_nearest(glove_twitter_25d, words)
#' find_nearest(glove_twitter_25d, words_embeddings) # equivalent to previous
#' find_nearest(glove_twitter_25d, words, each = TRUE)
#' find_nearest(glove_twitter_25d, words_embeddings, each = TRUE) # equivalent to previous
#'
#' rand_vec <- rnorm(25)
#' find_nearest(glove_twitter_25d, rand_vec)

#' @rdname find_nearest
#' @export
find_nearest <- function(object, newdata,
                         top_n = 10L,
                         method = c("cosine", "euclidean", "minkowski", "dot_prod", "anchored"),
                         ...,
                         each = FALSE,
                         include_self = TRUE,
                         decreasing = NULL,
                         get_sims = FALSE){
  if (!inherits(object, "embeddings")) {stop("`object` is not an embeddings object")}
  object <- stats::na.omit(object)
  # similarity or distance?
  if (is.character(method)) {
    method <- method[1]
    if (method %in% c("euclidean", "minkowski")){
      decreasing <- decreasing %||% FALSE
    }else{
      decreasing <- decreasing %||% TRUE
    }
  }else{
    decreasing <- decreasing %||% TRUE
  }
  # preprocess newdata
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
  }else if (is.numeric(newdata) || inherits(newdata, "embeddings")){
    if (all(is.na(newdata))) stop("newdata is entirely NAs")
    all_tokens <- rownames(newdata)
    missing_tokens <- NULL
    if (!each) {
      target <- newdata
      available_tokens <- rownames(newdata)
    }else{
      target <- as.embeddings(newdata, rowname_repair = FALSE)
      available_tokens <- rownames(target)
      target <- lapply(available_tokens, function(tok){target[tok,]})
      names(target) <- available_tokens
    }
  }else{
    stop("`newdata` must be a character vector, a numeric vector, or an embeddings object.")
  }
  # retrieve and sort similarities
  top_n <- min(top_n, nrow(object))
  if (!each) {
    if (length(available_tokens) > 1) {
      target <- colMeans(target, na.rm = TRUE)
    }
    sims <- get_sims(object, y = list(sim = target), method = method, ...)$sim
    sims_order <- order(sims, decreasing = decreasing)
    if (include_self) {
      sims_order <- sims_order[1:top_n]
      object <- object[sims_order,]
    }else{
      sims_order <- sims_order[1:(top_n+length(available_tokens))]
      object <- object[sims_order,]
      object <- object[!(rownames(object) %in% available_tokens),]
    }
    if (get_sims) {
      tibble::tibble(doc_id = rownames(object), {{method}} := sims[sims_order])
    }else{
      as.embeddings(object, rowname_repair = FALSE)
    }
  }else{
    sims <- lapply(target, function(vec) get_sims(object, y = list(sim = vec), method = method, ...) )
    sims_order <- lapply(sims, function(sim) order(sim$sim, decreasing = decreasing))
    object <- lapply(sims_order, function(sim_order) object[sim_order,] )
    if (!include_self) {
      object <- mapply(function(x, token) {
        x[!(rownames(x) %in% token), ]
      }, object, available_tokens, SIMPLIFY = FALSE)
    }
    object <- lapply(object, function(x){as.embeddings(utils::head(x, top_n))})
    object[all_tokens %in% missing_tokens] <- NA
    names(object) <- all_tokens
    if (get_sims) {
      mapply(function(ob, sim, sim_order){
        sim_ordered <- sim[sim_order,]
        tibble::tibble(doc_id = rownames(ob), {{method}} := sim_ordered$sim[sim_ordered$doc_id %in% rownames(ob)])
      }, object, sims, sims_order, SIMPLIFY = FALSE)
    }else{
      object
    }
  }
}
