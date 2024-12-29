#' Save Embeddings in Fast-Loading Format
#'
#' Saves an embeddings object as a binary file that allows quick access to arbitrary rows
#'
#' @param x an embeddings object to save
#' @param file the name of a file or connection to save to

#' @export
write_embeddings <- function(x, file) {
	stopifnot("`x` is not an embeddings object" = is.embeddings(x))
	if (is.character(file)) conn <- file(file, "wb") else conn <- file
	on.exit(close(conn))
	writeBin(as.integer(ncol(x)), conn, endian = "little") # dimensions

	# write the index
	index <- attr(x, "token_index")
	if (nrow(x) >= 2^20) message("Saving token index...")
	saveRDS(index, conn)

	# write embeddings
	if (nrow(x) >= 2^20) message("Writing embeddings...")
	writeBin(as.numeric(t(x)), conn, size = NA_real_, endian = "little")
}
