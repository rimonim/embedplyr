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
create_glove_file <- function(filepath) {
	embeddings_obj <- create_sample_embeddings()
	write.table(cbind(rownames(embeddings_obj), embeddings_obj), quote = FALSE,
							file = filepath, row.names = FALSE, col.names = FALSE, sep = " ")
}

# Function to create a small word2vec binary format file
create_word2vec_bin_file <- function(filepath) {
	embeddings_obj <- create_sample_embeddings()
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

# Begin tests
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
	expect_warning(embeddings_loaded <- read_embeddings(temp_file, words = words),
								 "Returning a NULL data.table.")
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
