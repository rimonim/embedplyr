#' Formatting and Printing for Embeddings Objects
#'
#' Since the numerical content of embeddings is generally not very informative
#' to the naked eye, the default formatting of matrices is often cumbersome.
#' As such, embeddings objects print in a format that allows quick visualization
#' of dimensionality and row names.
#'
#' @param x the embeddings object to be formatted
#' @param ... arguments to be passed to methods
#' @param n integer. How many rows should be printed? Defaults to `getOption("max.print")`
#' @param round integer. the number of decimal places to be displayed
#'
#' @method format embeddings
#' @export
format.embeddings <- function(x, ..., n = getOption("max.print"), round = 2) {
    screen_width <- getOption("width")
    n <- min(n, nrow(x))
    longest_rowname <- max(max(nchar(rownames(x)[1:n])), 3L) + 2L
    show_cols <- floor((screen_width - longest_rowname)/6) - 2L
    show_cols <- min(show_cols, ncol(x))
    longest_colname <- max(nchar(colnames(x)[1:show_cols]))
    if(longest_colname > 6){
        show_cols <- floor((screen_width - longest_rowname)/longest_colname) - 2L
        show_cols <- min(show_cols, ncol(x))
    }
    x_out <- x[1:n, 1:show_cols]
    x_out <- round(x_out, round)
    x_out <- apply(x_out, 2, as.character)
    x_out[x[1:n, 1:show_cols] >= 0] <- paste0(" ", x_out[x[1:n, 1:show_cols] >= 0])
    if(show_cols < ncol(x)){
        x_out <- cbind(x_out, rep("...", n))
    }
    rownames(x_out) <- rownames(x)[1:n]
    x_out
}

#' @noRd
#' @method print embeddings
#' @export
print.embeddings <- function(x, ...) {
    x <- as.embeddings(x)
    args <- list(...)
    if("n" %in% names(args)){
        n <- args$n
    }else{
        n <- getOption("max.print")
    }
    cat(pillar::style_subtle(paste0("# ", ncol(x),"-dimensional embeddings with ",nrow(x)," rows\n")))
    print(format(x, n = n), quote = FALSE)
}
