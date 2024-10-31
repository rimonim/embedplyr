#' Load Embeddings Model From File
#'
#' @param path a file path
#' @param dimensions the dimensionality of the embeddings. The defaults assumes
#' that this information is included in the file name as per the standard for
#' GloVe models.
#'
#' @details
#' The file must have tokens in the first column and numbers in all other columns.
#'
#' @section Value:
#' An embeddings object (a numeric matrix with tokens as rownames)

#' @export
load_embeddings <- function(path, dimensions = as.numeric(str_extract(path, "[:digit:]+(?=d\\.txt)"))) {

  # matrix with token embeddings
  pretrained_mod <- data.table::fread(
    path,
    quote = "",
    col.names = c("token", paste0("dim_", 1:dimensions))
  ) |>
    distinct(token, .keep_all = TRUE) |>
    remove_rownames() |>
    column_to_rownames("token")

  if (!all(apply(pretrained_mod, 2, is.numeric))) {
    stop("Input is not numeric")
  }

  pretrained_mod <- as.matrix(pretrained_mod)

  # update class to "embeddings" (required for `predict.embeddings` function)
  class(pretrained_mod) <- c("embeddings", "matrix", "array")
  pretrained_mod
}
