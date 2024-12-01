test_that("textstat_embedding works with simple dfm and embeddings model", {
	texts <- c("this says one thing", "and this one says another one")
	dfm_obj <- dfm(tokens(texts))

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- textstat_embedding(dfm_obj, embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), ndoc(dfm_obj))
	expect_true(all(c("doc_id", paste0("dim_", 1:5)) %in% names(result)))
})

test_that("textstat_embedding returns embeddings object when output_embeddings = TRUE", {
	texts <- c("this says one thing", "and this one says another one")
	dfm_obj <- dfm(tokens(texts))

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- textstat_embedding(dfm_obj, embeddings_model, output_embeddings = TRUE)

	expect_true(is.embeddings(result))
	expect_equal(nrow(result), ndoc(dfm_obj))
	expect_equal(rownames(result), docnames(dfm_obj))
})

test_that("textstat_embedding works with method = 'sum'", {
	texts <- c("this says one thing", "and this one says another one")
	dfm_obj <- dfm(tokens(texts))

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- textstat_embedding(dfm_obj, embeddings_model, method = "sum")

	# Manually compute the expected sums
	expected <- matrix(0, nrow = ndoc(dfm_obj), ncol = ncol(embeddings_model))
	colnames(expected) <- colnames(embeddings_model)

	for (doc in seq_len(ndoc(dfm_obj))) {
		expected[doc, ] <- colSums(embeddings_model * as.numeric(dfm_obj[doc,]))
	}

	expect_equal(as.matrix(result[,-1]), expected)
})

test_that("textstat_embedding works with method = 'median'", {
	skip_if_not_installed("Gmedian")
	texts <- c("this says one thing", "and this says another")
	dfm_obj <- dfm(tokens(texts))

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- textstat_embedding(dfm_obj, embeddings_model, method = "median")

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), ndoc(dfm_obj))
})

test_that("textstat_embedding handles missing words in embeddings model", {
	texts <- c("this says one thing", "unknown word")
	dfm_obj <- dfm(tokens(texts))

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	expect_warning(result <- textstat_embedding(dfm_obj, embeddings_model), "2 items in `newdata` are not present in the embeddings object.")

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), ndoc(dfm_obj))
	# Check that the embedding for the second document is zero or NA
	second_doc_embedding <- as.numeric(result[2, -1])
	expect_true(all(second_doc_embedding == 0))
})

test_that("textstat_embedding applies weighting correctly", {
	texts <- c("this says one thing", "and this says another")
	dfm_obj <- dfm(tokens(texts))

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))
	# Assign weights to tokens
	weights <- c("this" = 2, "says" = 0.5, "one" = 1, "thing" = 1.5, "and" = 1, "another" = 1)

	result <- textstat_embedding(dfm_obj, embeddings_model, w = weights)

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), ndoc(dfm_obj))
})

test_that("textstat_embedding throws error with invalid method", {
	texts <- c("this says one thing", "and this says another")
	dfm_obj <- dfm(tokens(texts))

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	expect_error(
		textstat_embedding(dfm_obj, embeddings_model, method = "invalid"),
		"'invalid' is not a recognized averaging method"
	)
})

test_that("embed_docs works with character vector and embeddings model", {
	texts <- c("this says one thing", "and this says another")

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_docs(texts, embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), length(texts))
	expect_true(all(c("doc_id", paste0("dim_", 1:5)) %in% names(result)))
})

test_that("embed_docs returns embeddings object when output_embeddings = TRUE", {
	texts <- c("this says one thing", "and this says another")

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_docs(texts, embeddings_model, output_embeddings = TRUE)

	expect_true(is.embeddings(result))
	expect_equal(nrow(result), length(texts))
})

test_that("embed_docs works with custom model function", {
	texts <- c("this says one thing", "and this one says another one")

	custom_model <- function(texts, ...) {
		# Simple example: return length of each text
		data.frame(length = nchar(texts))
	}

	result <- embed_docs(texts, custom_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), length(texts))
	expect_equal(names(result), c("doc_id", "length"))
})

test_that("embed_docs works with data frame input", {
	df <- data.frame(
		id = c("doc1", "doc2"),
		text = c("this says one thing", "and this says another"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_docs(df, text_col = "text", model = embeddings_model, id_col = "id")

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), nrow(df))
	expect_true(all(c("id", paste0("dim_", 1:5)) %in% names(result)))
})

test_that("embed_docs keeps all columns when .keep_all = TRUE", {
	df <- data.frame(
		id = c("doc1", "doc2"),
		text = c("this says one thing", "and this says another"),
		category = c("A", "B"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_docs(df, text_col = "text", model = embeddings_model,
											 id_col = "id", .keep_all = TRUE)

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), nrow(df))
	expect_true(all(c("id", "category", paste0("dim_", 1:5)) %in% names(result)))
})

test_that("embed_docs returns embeddings object when output_embeddings = TRUE with data frame input", {
	df <- data.frame(
		id = c("doc1", "doc2"),
		text = c("this says one thing", "and this says another"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_docs(df, text_col = "text", model = embeddings_model,
											 id_col = "id", output_embeddings = TRUE)

	expect_true(is.embeddings(result))
	expect_equal(nrow(result), nrow(df))
	expect_equal(rownames(result), df$id)
})

test_that("embed_docs respects tolower = FALSE", {
	texts <- c("This says one thing", "And this says another")

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result_tolower <- embed_docs(texts, embeddings_model, tolower = TRUE)
	expect_warning(result_no_tolower <- embed_docs(texts, embeddings_model, tolower = FALSE), "2 items in `newdata` are not present in the embeddings object.")

	expect_false(identical(result_tolower, result_no_tolower))
})

test_that("embed_docs throws error when model function returns incorrect output", {
	texts <- c("this says one thing", "and this says another")

	custom_model <- function(texts, ...) {
		# Return incorrect number of rows
		data.frame(length = nchar(texts[1]))
	}

	expect_error(
		embed_docs(texts, custom_model),
		"`model` must be either an embeddings object or a function that outputs a dataframe with the same number of rows as `x`"
	)
})

test_that("embed_docs assigns default doc_id when id_col is missing", {
	df <- data.frame(
		text = c("this says one thing", "and this says another"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_docs(df, text_col = "text", model = embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(names(result)[1], "doc_id")
})

test_that("embed_docs handles missing words in embeddings model", {
	texts <- c("this says one thing", "unknown word")

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	expect_warning(result <- embed_docs(texts, embeddings_model), "2 items in `newdata` are not present in the embeddings object.")

	# Check that the embedding for the second document is zero or NA
	second_doc_embedding <- as.numeric(result[2, -1])
	expect_true(all(second_doc_embedding == 0))
})

test_that("textstat_embedding handles empty dfm", {
	dfm_obj <- dfm(tokens(character(0)))

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- textstat_embedding(dfm_obj, embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), 0)
})

test_that("embed_docs handles empty character vector", {
	texts <- character(0)

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_docs(texts, embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), 0)
})

test_that("embed_docs throws error when text_col is missing in data frame", {
	df <- data.frame(
		id = c("doc1", "doc2"),
		content = c("this says one thing", "and this says another"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	expect_error(
		embed_docs(df, text_col = "text", model = embeddings_model, id_col = "id"),
		"Can't extract columns that don't exist."
	)
})

test_that("textstat_embedding handles dfm with all tokens missing in embeddings model", {
	texts <- c("unknown word", "other unknown word")
	dfm_obj <- dfm(tokens(texts))

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	expect_warning(result <- textstat_embedding(dfm_obj, embeddings_model), "3 items in `newdata` are not present in the embeddings object.")

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), ndoc(dfm_obj))
	expect_true(all(rowSums(result[, -1]) == 0))
})

test_that("embed_docs handles custom model function and output_embeddings = FALSE", {
	texts <- c("this says one thing", "and this says another")

	custom_model <- function(texts, ...) {
		data.frame(length = nchar(texts))
	}

	result <- embed_docs(texts, custom_model, output_embeddings = FALSE)

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), length(texts))
})

test_that("embed_docs throws error when model is not embeddings or function", {
	texts <- c("this says one thing", "and this says another")

	model <- list()  # Invalid model

	expect_error(
		embed_docs(texts, model),
		"`model` must be either an embeddings object or a function that outputs a dataframe with the same number of rows as `x`"
	)
})

test_that("embed_docs assigns default doc_id when id_col is missing in data frame", {
	df <- data.frame(
		text = c("this says one thing", "and this says another"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_docs(df, text_col = "text", model = embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(names(result)[1], "doc_id")
})

test_that("textstat_embedding handles embeddings with NA values", {
	texts <- c("this says one thing", "and this says another")
	dfm_obj <- dfm(tokens(texts))

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))
	embeddings_model[1, 1] <- NA  # Introduce NA value

	result <- textstat_embedding(dfm_obj, embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), ndoc(dfm_obj))
})

test_that("embed_docs passes additional arguments to tokens()", {
	texts <- c("This says one thing!", "And this says another.")

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	# Remove punctuation
	result <- embed_docs(texts, embeddings_model, remove_punct = TRUE)

	expect_s3_class(result, "tbl_df")
})

test_that("embed_docs passes additional arguments to custom model function", {
	texts <- c("this says one thing", "and this says another")

	custom_model <- function(texts, multiplier = 1, ...) {
		data.frame(length = nchar(texts) * multiplier)
	}

	result <- embed_docs(texts, custom_model, multiplier = 2)

	expect_s3_class(result, "tbl_df")
	expect_equal(result$length, nchar(texts) * 2)
})

test_that("embed_docs assigns correct doc_id with non-default id_col", {
	df <- data.frame(
		doc_id = c("doc1", "doc2"),
		text = c("this says one thing", "and this says another"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_docs(df, text_col = "text", model = embeddings_model, id_col = "doc_id")

	expect_s3_class(result, "tbl_df")
	expect_equal(result$doc_id, df$doc_id)
})

test_that("embed_docs only keeps doc_id and embeddings when .keep_all = FALSE", {
	df <- data.frame(
		id = c("doc1", "doc2"),
		text = c("this says one thing", "and this says another"),
		category = c("A", "B"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_docs(df, text_col = "text", model = embeddings_model,
											 id_col = "id", .keep_all = FALSE)

	expect_s3_class(result, "tbl_df")
	expect_equal(names(result), c("id", paste0("dim_", 1:5)))
})
