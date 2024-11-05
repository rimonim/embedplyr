#' Load Embeddings Model From a Text or Binary File
#'
#' Reads GloVe text format, word2vec binary format, and most tabular formats (csv, tsv, etc.)
#'
#' @param path a file path
#'
#' @details
#' If using a custom tabular format, the file must have tokens in the first column and numbers in all other columns.
#'
#' @section Value:
#' An embeddings object (a numeric matrix with tokens as rownames)

#' @export
load_embeddings <- function(path) {
  path_format <- substring(path, regexpr("\\.([[:alnum:]]+)$", path) + 1L)
  # word2vec binary format
  if (path_format == "bin") {
    return(read_word2vec(path))
  }else{
    # read table with token embeddings
    x <- data.table::fread(path, quote = "", showProgress = TRUE)
    id <- as.vector(x[,1])
    duplicates <- duplicated(id)
    if (any(duplicates)) {
      warning("Tokens are not unique. Removing duplicates.")
      x <- x[!duplicates,]
      id <- as.vector(x[,1])
    }
    x <- x[,-1]
    if (!all(sapply(x, is.numeric))) {
      stop("Input is not numeric")
    }
    x <- as.matrix(x)
    # set row and column names
    rownames(x) <- id
    if (is.null(colnames(x))){
      colnames(x) <- paste0("dim_", 1:ncol(x))
    }
    # update class
    class(x) <- c("embeddings", "matrix", "array")
    return(x)
  }
}

#' @noRd
read_word2vec_word <- function(f, max_len = 50) {
  number_str <- ""
  for (i in 1:max_len) {
    ch <- readChar(f, nchars = 1, useBytes = TRUE)
    if (ch %in% c(" ", "\n", "\t")) break
    number_str <- paste0(number_str, ch)
  }
  number_str
}

#' @noRd
read_word2vec <- function(path){
  # open binary file in read mode
  f <- file(path, "rb")
  if (!isOpen(f)) stop("Input file not found")
  # read header
  vocab_size <- as.numeric(read_word2vec_word(f))
  dimensions <- as.numeric(read_word2vec_word(f))
  # read word embeddings
  vocab <- character(vocab_size)
  mat <- matrix(0, nrow = vocab_size, ncol = dimensions)
  for (r in 1:vocab_size) {
    vocab[r] <- read_word2vec_word(f)
    mat[r,1:dimensions] <- readBin(f, what = "numeric", size = 4, n = dimensions, endian = "little")
  }
  close(f)
  # output embeddings object
  rownames(mat) <- vocab
  as.embeddings(mat)
}
