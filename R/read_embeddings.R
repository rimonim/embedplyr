#' Read Embeddings From a Text or Binary File
#'
#' Reads GloVe text format, fastText text format, word2vec binary format,
#' and most tabular formats (csv, tsv, etc.)
#'
#' @param path a file path or url
#' @param words optional list of words for which to retrieve embeddings.
#'
#' @details
#' If using a custom tabular format, the file must have tokens in the first
#' column and numbers in all other columns.
#'
#' @section Value:
#' An embeddings object (a numeric matrix with tokens as rownames)

#' @export
read_embeddings <- function(path, words = NULL) {
	path_format <- substring(path, regexpr("\\.([[:alnum:]]+)$", path) + 1L)
	if (path_format == "rds") {
		# rds (possibly a matrix)
		tmpFile = tempfile(fileext = ".rds", tmpdir = tempdir())
		on.exit(unlink(tmpFile), add = TRUE)
		utils::download.file(path, tmpFile)
		out <- as.embeddings(readRDS(tmpFile))
		if (is.character(words)) out <- emb(out, words)
	}else if (path_format == "bin" || grepl("\\.bin\\.", path) || grepl("word2vec", path)) {
		# word2vec binary format
		out <- tryCatch(
			read_word2vec(path, words = words),
			error = function(e) stop(
				conditionMessage(e),
				"\nThis file was assumed based on its name to be written in word2vec bin format. ",
				"This assumption may have been mistaken. "
			)
		)
	}else{
		if (grepl("numberbatch", path)) use_sys <- FALSE else use_sys <- TRUE
		out <- read_table_embeddings(path, words = words, use_sys = use_sys)
	}
	out
}

# check if a file is gzipped
#' @noRd
is_gzipped <- function(file) {
	if (is_url(file)) {
		# For URLs, check if the URL ends with .gz or .gzip
		return(grepl("\\.gz(ip)?$", file, ignore.case = TRUE))
	} else {
		# For local files, check the file signature for gzip magic numbers
		con <- file(file, "rb")
		magic <- readBin(con, "raw", n = 2)
		close(con)
		return(identical(magic, as.raw(c(0x1f, 0x8b))))
	}
}

#' @noRd
read_word2vec_word <- function(f, max_len = 50) {
	chars <- character(max_len)
	# read characters until whitespace or max_len
	for (i in seq_len(max_len)) {
		ch <- suppressWarnings( readChar(f, nchars = 1, useBytes = TRUE) )
		if (ch == " " || ch == "" || ch == "\n" || ch == "\t") break
		chars[i] <- ch
	}
	# collapse characters into string
	paste0(chars[1:i], collapse = "")
}


#' @noRd
read_word2vec <- function(path, words = NULL){
	# handle for HTTP requests
	h <- curl::new_handle()
	curl::handle_setopt(h, timeout = 10000);
	curl::handle_setheaders(h, "User-Agent" = "embedplyr (https://github.com/rimonim/embedplyr)")
	# open binary file in read mode
	is_gz <- is_gzipped(path)
	if (is_url(path)) {
		conn <- curl::curl(path, "rb")
		if (is_gz) {
			conn <- gzcon(conn)
		}
	} else {
		conn <- tryCatch({
			if (is_gz) {
				gzfile(path, "rb")
			} else {
				file(path, "rb")
			}
		}, error = function(e) {
			stop("Error opening file: ", conditionMessage(e))
		})
	}
	if (!isOpen(conn)) stop("Input file not found")
	on.exit(close(conn))
	# read header
	vocab_size <- as.numeric(read_word2vec_word(conn))
	dimensions <- as.numeric(read_word2vec_word(conn))
	# read word embeddings
	if (vocab_size >= 10000) {
		pb <- utils::txtProgressBar(0, vocab_size, style = 3)
		on.exit(close(pb), add = TRUE)
	}
	if (is.null(words)) {
		vocab <- character(vocab_size)
		mat <- matrix(0, nrow = vocab_size, ncol = dimensions)
		for (r in seq_len(vocab_size)) {
			if (r %% 10000 == 0) utils::setTxtProgressBar(pb, r)
			new_word <- read_word2vec_word(conn)
			new_vec <- readBin(conn, what = "numeric", size = 4, n = dimensions, endian = "little")
			if (nzchar(new_word)) {
				vocab[r] <- new_word
				mat[r,] <- new_vec
			}
		}
		rownames(mat) <- vocab
		mat <- as.embeddings(mat, rowname_repair = FALSE)
	}else{
		mat <- matrix(NA_real_, nrow = length(words), ncol = dimensions,
									dimnames = list(words))
		token_index <- new.env(hash = TRUE, parent = emptyenv())
		for (i in seq_along(words)) token_index[[words[i]]] <- i
		w <- 1L
		for (r in seq_len(vocab_size)) {
			if (r %% 10000 == 0) utils::setTxtProgressBar(pb, r)
			new_word <- read_word2vec_word(conn)
			new_vec <- readBin(conn, what = "numeric", size = 4, n = dimensions, endian = "little")
			if (nzchar(new_word) && exists(new_word, envir = token_index)) {
				mat[get(new_word, envir = token_index),] <- new_vec
				w <- w + 1L
				if (w == length(words)) {
					if (vocab_size >= 10000) utils::setTxtProgressBar(pb, vocab_size)
					break
				}
			}
		}
		mat <- as.embeddings(mat, rowname_repair = FALSE)
	}
	mat
}

#' @noRd
read_table_embeddings <- function(path, words = NULL, use_sys = TRUE, timeout = 1000){
	# turn quoting off for glove files
	quote <- ifelse(grepl("glove", path), "", "\"")
	# read table with token embeddings
	if (is.character(words)) {
		if (grepl("\\.zip$", path, ignore.case = TRUE)) {
			warning("Line by line file reading is not supported for zip files. Loading full file before filtering words.")
			x <- suppressWarnings( data.table::fread(path, quote = quote, showProgress = TRUE) )
			x <- x[x[[1]] %in% words,]
		}else{
			x <- fread_filtered(path, words = words, use_sys = use_sys, showProgress = TRUE)
			if (nrow(x) == 0){
				x <- data.table::fread(path, quote = quote, nrows = 0, showProgress = TRUE)
			}
		}
	}else{
		x <- suppressWarnings( data.table::fread(path, quote = quote, showProgress = TRUE) )
	}
	id <- x[[1]]

	# remove duplicates
	duplicates <- duplicated(id)
	if (any(duplicates)) {
		warning("Tokens are not unique. Removing duplicates.")
		x <- x[!duplicates,]
		id <- x[[1]]
	}
	# coerce to numeric matrix
	x <- x[,-1]
	if (!all(vapply(x, is.numeric, TRUE))) {
		stop("Input is not numeric")
	}
	x <- as.matrix(x)
	# set row and column names
	rownames(x) <- id
	if (all(colnames(x)[-1] == paste0("V",3:(ncol(x)+1L)))) colnames(x) <- NULL
	# update class
	return(as.embeddings(x))
}

# check if a string is a URL
#' @noRd
is_url <- function(x) {
	grepl("^(http|https|ftp)://", x)
}

# read tabular from file or url, ignoring lines that don't start with a word in `words`
#' @noRd
fread_filtered <- function(file, words, use_sys = TRUE, ..., timeout = 1000) {
	# check system
	on_windows <- .Platform$OS.type == "windows"

	# check for the required system commands
	sys_commands_available <- if (on_windows) {
		all(nzchar(Sys.which(c("curl", "findstr"))))
	}else{
		all(nzchar(Sys.which(c("curl", "gunzip", "awk"))))
	}

	# is file gzipped?
	is_gz <- is_gzipped(file)
	# is file url
	is_url <- is_url(file)
	# expand file path
	file <- path.expand(file)
	if (use_sys && sys_commands_available) {
		wordfile <- tempfile()
		on.exit(unlink(wordfile), add = TRUE)
		if (on_windows) {
			file_format <- substring(file, regexpr("\\.([[:alnum:]]+)$", file) + 1L)
			delim <- if (file_format == "csv") "," else if (file_format == "tsv") "\t" else " "
			if (is_url) {
				if (is_gz) {
					# gz files must be downloaded in order to be unzipped
					tmpFile = tempfile(fileext = paste0(".", file_format), tmpdir = tempdir())
					utils::download.file(file, tmpFile, mode = "wb")
					file <- tmpFile
					on.exit(unlink(tmpFile), add = TRUE)
				}
			}else{
				file <- normalizePath(file, winslash = "\\", mustWork = FALSE)
			}
			# unzip file if necessary
			if (is_gz) {
				if (!requireNamespace("R.utils", quietly = TRUE)) stop("read_embeddings() requires 'R.utils' package to read gzipped files. Please install 'R.utils' using 'install.packages('R.utils')'.")
				R.utils::decompressFile(file, decompFile <- tempfile(tmpdir = tempdir()),
																ext = NULL, FUN = gzfile, remove = FALSE)
				file <- decompFile
				on.exit(unlink(decompFile), add = TRUE)
			}
			# write words to temporary file
			writeLines(paste0("^", words, delim), wordfile)
			# write shell command
			if (is_url(file)) {
				cmd <- paste0(
					"curl -L -s ", shQuote(file), " | ",
					"findstr /r /G:", shQuote(wordfile)
				)
			} else {
				cmd <- paste0("findstr /r /G:", shQuote(wordfile), " ", shQuote(file))
			}
		}else{
			awk_script <- "NR==FNR{words[$1]=1;next} words[$1]"
			# write words to temporary file
			writeLines(words, wordfile)
			# write shell command
			if (is_url(file)) {
				if (is_gz) {
					cmd <- paste(
						"curl -L -s", shQuote(file), "|",
						"gunzip -c |",
						"awk", shQuote(awk_script),
						shQuote(wordfile), "-"
					)
				} else {
					cmd <- paste(
						"curl -L -s", shQuote(file), "|",
						"awk", shQuote(awk_script),
						shQuote(wordfile), "-"
					)
				}
			} else {
				# Local file
				if (is_gz) {
					cmd <- paste(
						"gunzip -c", shQuote(file), "|",
						"awk", shQuote(awk_script),
						shQuote(wordfile), "-"
					)
				} else {
					cmd <- paste(
						"awk", shQuote(awk_script),
						shQuote(wordfile), shQuote(file)
					)
				}
			}
		}

		# Read data and finish up
		data <- data.table::fread(cmd = cmd, ...)
		unlink(wordfile)
		return(data)
	} else {
		# R-only version
		# handle for HTTP requests
		h <- curl::new_handle()
		curl::handle_setopt(h, timeout = 10000);
		curl::handle_setheaders(h, "User-Agent" = "embedplyr (https://github.com/rimonim/embedplyr)")
		# open connection
		if (is_url(file)) {
			conn <- tryCatch({
				if (is_gz) {
					gzcon(curl::curl(file, "rb", handle = h))
				} else {
					curl::curl(file, "rt", handle = h)
				}
			}, error = function(e) {
				stop("Error opening URL: ", conditionMessage(e))
			})
		} else {
			conn <- tryCatch({
				if (is_gz) {
					gzfile(file, "rt")
				} else {
					file(file, "rt")
				}
			}, error = function(e) {
				stop("Error opening file: ", conditionMessage(e))
			})
		}
		on.exit(close(conn))

		# hash table for matching words
		token_index <- new.env(hash = TRUE, parent = emptyenv())
		for (i in seq_along(words)) token_index[[words[i]]] <- i

		# process lines one at a time
		filtered_lines <- character(length(words))
		w <- 1
		message("Processing file...")
		line <- readLines(conn, n = 1, warn = FALSE)
		if (!is.na(numlines <- suppressWarnings(as.numeric(strsplit(line, " ")[[1]]))[1])) {
			# number of rows is known from space delimited header
			if (numlines >= 10000) {
				pb <- utils::txtProgressBar(0, numlines, style = 3)
				on.exit(close(pb), add = TRUE)
			}
			for (i in seq_len(numlines)) {
				line <- readLines(conn, n = 1, warn = FALSE)
				if (exists(sub(" .*", "", line), envir = token_index)) {
					filtered_lines[w] <- line
					if (w == length(words)) {
						if (numlines >= 10000) utils::setTxtProgressBar(pb, numlines)
						break
					}
					w <- w + 1
				}
				if (i %% 10000 == 0) utils::setTxtProgressBar(pb, i)
			}
		}else{
			if (exists(sub(" .*", "", line), envir = token_index)) {
				filtered_lines[w] <- line
				w <- w + 1L
			}
			while (length(line <- readLines(conn, n = 1, warn = FALSE)) > 0) {
				if (exists(sub(" .*", "", line), envir = token_index)) {
					filtered_lines[w] <- line
					w <- w + 1
				}
			}
		}

		# check if any lines were matched
		if (length(filtered_lines) == 0 || all(grepl("^\\s*$", filtered_lines))) {
			warning("No embeddings found for items in `words`")
			return(data.table::data.table())
		}

		# convert filtered lines to a data.table
		data <- data.table::fread(text = filtered_lines, header = FALSE, ...)

		return(data)
	}
}
