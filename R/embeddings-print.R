#' Formatting and Printing for Embeddings Objects
#'
#' Since the numerical content of embeddings is generally not very informative
#' to the naked eye, the default formatting of matrices is often cumbersome.
#' As such, embeddings objects print in a format that allows quick visualization
#' of dimensionality and row names.
#'
#' @param x the embeddings object to be formatted
#' @param ... arguments to be passed to methods
#' @param n integer. How many rows should be printed? Defaults to 10. This value
#' can be permanently customized by setting `options(embeddings.print.n = n)`.
#' @param round integer. the number of decimal places to be displayed
#'
#' @importFrom pillar style_subtle
#' @examples
#' print(glove_twitter_25d, n = 5)
#'
#' @method format embeddings
#' @importFrom rlang %||%
#' @export
format.embeddings <- function(x, ..., n = NULL, round = 2L) {
  # how many columns to show
  screen_width <- getOption("width", 80)
  colwidth <- round + 4L
  rowname_maxwidth <- 15L
  n <- min(n %||% getOption("embeddings.print.n", 10), nrow(x))
  longest_rowname <- min(max(nchar(rownames(x)[1:n]), 3L), rowname_maxwidth) + 2L
  show_cols <- floor((screen_width - longest_rowname)/colwidth) - 2L
  show_cols <- min(show_cols, ncol(x))
  # subset to be shown
  x_out <- x[1:n, 1:show_cols, drop = FALSE]
  # character matrix
  if (is.null(dim(x_out))) {
    x_out <- matrix(sprintf(paste0("%.",round,"f"), x_out), nrow = nrow(x))
    colnames(x_out) <- colnames(x)[1:show_cols]
  }else{
    x_out <- matrix(sprintf(paste0("%.",round,"f"), x_out), nrow = nrow(x_out), ncol = ncol(x_out),
                    dimnames = list(rownames(x_out), colnames(x_out)))
  }
  # truncate long column names
  colnames(x_out) <- ifelse(nchar(colnames(x_out)) > colwidth - 1L, paste0(substr(colnames(x_out), 1, colwidth-3L), ".."), colnames(x_out))
  # add dots for unshown columns
  if(show_cols < ncol(x)){
    x_out <- cbind(x_out, rep(paste0(c("...", rep(" ", colwidth-4L)), collapse = ""), n))
  }
  rownames(x_out) <- rownames(x)[1:n]
  # truncate long row names
  rownames(x_out) <- ifelse(nchar(rownames(x_out)) > rowname_maxwidth, paste0(substr(rownames(x_out), 1, rowname_maxwidth-2L), ".."), rownames(x_out))
  format(x_out, justify = "right")
}

#' @noRd
#' @importFrom rlang %||%
#' @method print embeddings
#' @export
print.embeddings <- function(x, n = NULL, round = 2, ...) {
  args <- list(...)
  n <- n %||% getOption("embeddings.print.n", 10)
  message(pillar::style_subtle(paste0("# ", ncol(x),"-dimensional embeddings with ",nrow(x)," rows")))
  if (any(dim(x) == 0)) return(cat("<", paste(dim(x), collapse = " x "), " embeddings>", sep = ""))
  print(format(x, n = n, round = round), quote = FALSE)
}
