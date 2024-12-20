current_model_path <- getOption("embeddings.model.path")
options(embeddings.model.path = tempdir())

quiet <- function(x) {
	sink(tempfile())
	on.exit(sink())
	invisible(force(x))
}

create_sample_embeddings <- function() {
	tokens <- c("word1", "word2", "word3")
	embeddings(c(0.1, 0.2, 0.3,
							 0.4, 0.5, 0.6,
							 0.7, 0.8, 0.9), nrow = 3, byrow = TRUE,
						 dimnames = list(tokens, paste0("dim", 1:3)))
}

# Function to create a small GloVe format file
create_glove_file <- function(filepath, embeddings_obj = NULL) {
	if (is.null(embeddings_obj)) {
		embeddings_obj <- create_sample_embeddings()
	}
	write.table(cbind(rownames(embeddings_obj), embeddings_obj), quote = FALSE,
							file = filepath, row.names = FALSE, col.names = FALSE, sep = " ")
}

# Function to create fastText file (like GloVe but with header specifying number of lines and number of dimensions)
create_fasttext_file <- function(filepath, embeddings_obj = NULL) {
	if (is.null(embeddings_obj)) {
		embeddings_obj <- create_sample_embeddings()
	}
	writeLines(paste0(nrow(embeddings_obj), " ", ncol(embeddings_obj)), filepath)
	write.table(cbind(rownames(embeddings_obj), embeddings_obj), quote = FALSE,
							file = filepath, row.names = FALSE, col.names = FALSE, sep = " ", append = TRUE)
}

# Function to create gzipped GloVe file
create_glove_gz_file <- function(filepath, embeddings_obj = NULL) {
	if (is.null(embeddings_obj)) {
		embeddings_obj <- create_sample_embeddings()
	}
	f <- gzfile(filepath, "w")
	write.table(cbind(rownames(embeddings_obj), embeddings_obj), quote = FALSE,
							file = f, row.names = FALSE, col.names = FALSE, sep = " ")
	close(f)
}

# Function to create a small word2vec binary format file
create_word2vec_bin_file <- function(filepath, embeddings_obj = NULL) {
	if (is.null(embeddings_obj)) {
		embeddings_obj <- create_sample_embeddings()
	}
	vocab_size <- nrow(embeddings_obj)
	vector_size <- ncol(embeddings_obj)

	con <- file(filepath, "wb")

	# Write header
	header <- paste(vocab_size, vector_size)
	writeChar(header, con, eos = NULL)
	writeBin(as.raw(0x0A), con)  # Write newline

	# Write each word and its vector
	for (i in 1:vocab_size) {
		word <- rownames(embeddings_obj)[i]
		writeChar(word, con, eos = NULL)
		writeBin(as.raw(0x20), con)  # Write space
		# Write vector components as 32-bit floats, little-endian
		writeBin(as.numeric(embeddings_obj[i, ]), con, size = 4, endian = "little")
	}

	close(con)
}

# function to create gzipped word2vec file
create_word2vec_gz_file <- function(filepath, embeddings_obj = NULL) {
	if (is.null(embeddings_obj)) {
		embeddings_obj <- create_sample_embeddings()
	}
	vocab_size <- nrow(embeddings_obj)
	vector_size <- ncol(embeddings_obj)

	con <- gzfile(filepath, "wb")

	# Write header
	header <- paste(vocab_size, vector_size)
	writeChar(header, con, eos = NULL)
	writeBin(as.raw(0x0A), con)  # Write newline

	# Write each word and its vector
	for (i in 1:vocab_size) {
		word <- rownames(embeddings_obj)[i]
		writeChar(word, con, eos = NULL)
		writeBin(as.raw(0x20), con)  # Write space
		# Write vector components as 32-bit floats, little-endian
		writeBin(as.numeric(embeddings_obj[i, ]), con, size = 4, endian = "little")
	}

	close(con)
}

# realistic tests (not for CRAN)
test_that("load_embeddings loads from Internet", {
	skip_on_cran()
	skip_if_not(curl::has_internet())
	# without save
	glove_test <- quiet(suppressMessages(load_embeddings("glove.6B.50d", save = FALSE)))
	red_blue <- cos_sim(predict(glove_test, "red"), predict(glove_test, "blue"))
	red_dimension <- cos_sim(predict(glove_test, "red"), predict(glove_test, "dimension"))
	expect_true(red_blue > red_dimension)
	# with save and words
	expect_warning(
		glove_test <- quiet(suppressMessages(load_embeddings("glove.6B.50d", words = c("red", "blue", "dimension")))),
		"Saving only a subset of words is not supported for original format"
		)
	expect_equal(nrow(glove_test), 3)
	expect_true(red_blue == cos_sim(predict(glove_test, "red"), predict(glove_test, "blue")))
})

# CRAN-friendly tests
test_that("load_embeddings reads GloVe format correctly", {
	model_name <- "glove.test.3d"
	temp_dir <- tempdir()
	temp_file <- file.path(temp_dir, paste0(model_name, ".txt"))

	# Create a small GloVe format file
	create_glove_file(temp_file)

	# Mock supported_models to point to our local file
	local_mocked_bindings(supported_models = c(glove.test.3d = temp_file))

	# Run load_embeddings
	embeddings_loaded <- suppressMessages( load_embeddings(model_name, dir = temp_dir, save = FALSE) )

	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(3, 3))
	expect_equal(rownames(embeddings_loaded), c("word1", "word2", "word3"))
})

test_that("load_embeddings reads word2vec binary format correctly", {
	model_name <- "word2vec.test.3d"
	temp_dir <- tempdir()
	temp_file <- file.path(temp_dir, paste0(model_name, ".bin"))

	# Create a small word2vec binary format file
	create_word2vec_bin_file(temp_file)

	# Mock supported_models to point to our local file
	local_mocked_bindings(supported_models = c(word2vec.test.3d = temp_file))

	# Run load_embeddings
	embeddings_loaded <- suppressMessages(quiet( load_embeddings(model_name, dir = temp_dir, save = FALSE) ))

	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(3, 3))
	expect_equal(rownames(embeddings_loaded), c("word1", "word2", "word3"))
})

test_that("read_embeddings reads GloVe format correctly", {
	# Create a temporary GloVe format file
	temp_file <- tempfile(fileext = ".txt")
	create_glove_file(temp_file)

	embeddings_loaded <- read_embeddings(temp_file)
	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(3, 3))
	expect_equal(rownames(embeddings_loaded), c("word1", "word2", "word3"))
})

test_that("read_embeddings reads word2vec binary format correctly", {
	# Create a temporary word2vec binary format file
	temp_file <- tempfile(fileext = ".bin")
	create_word2vec_bin_file(temp_file)

	embeddings_loaded <- quiet( read_embeddings(temp_file) )
	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(3, 3))
	expect_equal(rownames(embeddings_loaded), c("word1", "word2", "word3"))
})

test_that("load_embeddings filters words correctly when 'words' parameter is used", {
	model_name <- "glove.test.3d"
	temp_dir <- tempdir()
	temp_file <- file.path(temp_dir, paste0(model_name, ".txt"))

	# Create a small GloVe format file
	create_glove_file(temp_file)

	# Mock supported_models to point to our local file
	local_mocked_bindings(supported_models = c(glove.test.3d = temp_file))

	words <- c("word1", "word3")

	# Run load_embeddings
	embeddings_loaded <- suppressMessages( load_embeddings(model_name, dir = temp_dir, words = words, save = FALSE) )

	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(2, 3))
	expect_equal(rownames(embeddings_loaded), words)
})

test_that("load_embeddings handles unknown file formats", {
	model_name <- "unknown.format"
	temp_dir <- tempdir()
	temp_file <- file.path(temp_dir, paste0(model_name, ".unknown"))

	# Create a temporary file with unknown format
	writeLines("some random content", temp_file)

	# Mock supported_models to point to our local file
	local_mocked_bindings(supported_models = c(unknown.format = temp_file))

	expect_error(
		suppressMessages( load_embeddings(model_name, dir = temp_dir, save = FALSE) ),
		"Input is not numeric"
	)
})

test_that("read_embeddings handles words not present in the file", {
	# Create a temporary GloVe format file
	temp_file <- tempfile(fileext = ".txt")
	create_glove_file(temp_file)

	words <- c("word4", "word5")
	embeddings_loaded <- suppressMessages( suppressWarnings( read_embeddings(temp_file, words = words) ) )
	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(0, 3))
})

test_that("read_word2vec reads only specified words when 'words' parameter is used", {
	# Create a temporary word2vec binary format file
	temp_file <- tempfile(fileext = ".bin")
	create_word2vec_bin_file(temp_file)

	words <- c("word1", "word3")
	embeddings_loaded <- quiet( read_word2vec(temp_file, words = words) )

	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(2, 3))
	expect_equal(rownames(embeddings_loaded), words)
})

test_that("load_embeddings reads from and writes to RDS", {
	model_name <- "word2vec.test.3d"
	temp_dir <- tempdir()
	temp_file <- file.path(temp_dir, paste0(model_name, ".bin"))

	# Create a small word2vec binary format file
	create_word2vec_bin_file(temp_file)

	# Mock supported_models to point to our local file
	local_mocked_bindings(supported_models = c(word2vec.test.3d = temp_file))

	# Run load_embeddings
	embeddings_loaded <- suppressWarnings(suppressMessages(quiet( load_embeddings(model_name, dir = temp_dir, format = "rds") )))

	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(3, 3))
	expect_equal(rownames(embeddings_loaded), c("word1", "word2", "word3"))

	# Read saved embeddings
	expect_warning(
		embeddings_loaded <- suppressMessages(quiet( load_embeddings(model_name, dir = temp_dir) )),
		"More than one file matches `model`. Using the first one."
	)
	file.remove(temp_file)
	embeddings_loaded <- suppressMessages(quiet( load_embeddings(model_name, dir = temp_dir, words = c("word1", "word2", "word3")) ))

	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(3, 3))
	expect_equal(rownames(embeddings_loaded), c("word1", "word2", "word3"))
})

test_that("load_embeddings turns use_sys off for numberbatch files", {
	model_name <- "numberbatch.file"
	temp_dir <- tempdir()
	file.remove(list.files(temp_dir, full.names = TRUE, pattern = "file"))
	temp_file <- file.path(temp_dir, paste0(model_name, ".txt"))

	# Create a small GloVe format file
	create_glove_file(temp_file)

	# Mock supported_models to point to our local file
	local_mocked_bindings(supported_models = c(numberbatch.file = temp_file))

	words <- c("word1", "word3")

	# Run load_embeddings
	embeddings_loaded <- suppressMessages( load_embeddings(model_name, dir = temp_dir, words = words, save = FALSE) )

	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(2, 3))
	expect_equal(rownames(embeddings_loaded), words)

	expect_warning(
		embeddings_nonefound <- suppressMessages( read_embeddings(temp_file, words = c("word4")) ),
		"No embeddings found for items in `words`"
	)
	expect_equal(dim(embeddings_nonefound), c(0, 3))
})

test_that("load_embeddings uses informative header when use_sys = FALSE", {
	model_name <- "numberbatch.file"
	temp_dir <- tempdir()
	temp_file <- file.path(temp_dir, paste0(model_name, ".txt"))

	# Create a small fastText format file
	create_fasttext_file(temp_file)

	# Mock supported_models to point to our local file
	local_mocked_bindings(supported_models = c(numberbatch.file = temp_file))

	words <- c("word1", "word3")
	# read_embeddings
	embeddings_read <- read_embeddings(temp_file)
	expect_true(is.embeddings(embeddings_read))
	expect_equal(dim(embeddings_read), c(3, 3))

	# Run load_embeddings
	embeddings_loaded <- suppressWarnings( suppressMessages( load_embeddings(model_name, dir = temp_dir, words = words, save = FALSE) ) )

	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(2, 3))
	expect_equal(rownames(embeddings_loaded), words)
})

test_that("load_embeddings handles gzipped files when use_sys = FALSE", {
	model_name <- "numberbatch.file"
	temp_dir <- tempdir()
	file.remove(list.files(temp_dir, full.names = TRUE, pattern = "file"))
	temp_file <- file.path(temp_dir, paste0(model_name, ".txt.gz"))

	# Create a small GloVe format file
	create_glove_gz_file(temp_file)

	# Mock supported_models to point to our local file
	local_mocked_bindings(supported_models = c(numberbatch.file = temp_file))

	# Run load_embeddings
	embeddings_loaded <- suppressMessages( load_embeddings(model_name, dir = temp_dir, save = FALSE) )

	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(3, 3))
	expect_equal(rownames(embeddings_loaded), c("word1", "word2", "word3"))
})

test_that("read_embeddings handles gzipped GloVe files", {
	# Create a temporary gzipped GloVe format file
	temp_file <- tempfile(fileext = ".txt.gz")
	create_glove_gz_file(temp_file)

	embeddings_loaded <- suppressMessages( read_embeddings(temp_file, words = c("word1", "word3")) )
	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(2, 3))
	expect_equal(rownames(embeddings_loaded), c("word1", "word3"))
})

test_that("read_embeddings handles gzipped word2vec files", {
	# Create a temporary gzipped word2vec binary format file
	temp_file <- tempfile(fileext = ".bin.gz")
	create_word2vec_gz_file(temp_file)

	embeddings_loaded <- read_embeddings(temp_file)
	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(3, 3))
	expect_equal(rownames(embeddings_loaded), c("word1", "word2", "word3"))
})

test_that("read_embeddings handles csv format", {
	# Create a temporary csv format file
	temp_file <- tempfile(fileext = ".csv")
	create_glove_file(temp_file)

	embeddings_loaded <- read_embeddings(temp_file)
	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(3, 3))
	expect_equal(rownames(embeddings_loaded), c("word1", "word2", "word3"))
})

test_that("read_embeddings handles zip archives", {
	# Create a temporary zip archive with a GloVe format file
	temp_file <- tempfile(fileext = ".zip")
	temp_dir <- tempdir()
	temp_file_in <- file.path(temp_dir, "glove.txt")
	create_glove_file(temp_file_in)
	zip(temp_file, temp_file_in, flags="-q")

	embeddings_loaded <- read_embeddings(temp_file)
	expect_true(is.embeddings(embeddings_loaded))
	expect_equal(dim(embeddings_loaded), c(3, 3))
	expect_equal(rownames(embeddings_loaded), c("word1", "word2", "word3"))
})

options(embeddings.model.path = current_model_path)
