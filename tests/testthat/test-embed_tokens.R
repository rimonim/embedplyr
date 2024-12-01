test_that("embed_tokens works with character vector input and embeddings model", {
	texts <- c("this says one thing", "and this says another")

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_tokens(texts, embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(names(result)[1:2], c("doc_id", "token"))
	expect_equal(nrow(result), sum(sapply(strsplit(texts, " "), length)))
	expect_true(all(paste0("dim_", 1:5) %in% names(result)))
})

test_that("embed_tokens returns list of embeddings when output_embeddings = TRUE", {
	texts <- c("this says one thing", "and this says another")

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_tokens(texts, embeddings_model, output_embeddings = TRUE)

	expect_true(is.list(result))
	expect_equal(length(result), length(texts))
	expect_true(all(sapply(result, is.embeddings)))
})

test_that("embed_tokens keeps missing tokens when .keep_missing = TRUE", {
	texts <- c("this says unknown_word", "and this says another")

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	expect_warning(result <- embed_tokens(texts, embeddings_model, .keep_missing = TRUE),
								 "1 tokens in `x` are not present in `model`.")

	expect_s3_class(result, "tbl_df")
	missing_tokens <- result$token[result$token == "unknown_word"]
	expect_equal(length(missing_tokens), 1)
	expect_true(all(is.na(result[result$token == "unknown_word", paste0("dim_", 1:5)])))
})

test_that("embed_tokens works with quanteda tokens object", {
	texts <- c("this says one thing", "and this says another")
	tokens_obj <- tokens(texts)

	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))

	result <- embed_tokens(tokens_obj, embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(names(result)[1:2], c("doc_id", "token"))
})

test_that("embed_tokens works with data frame input", {
	df <- data.frame(
		id = c("doc1", "doc2"),
		text = c("this says one thing", "and this says another"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))

	result <- embed_tokens(df, text_col = "text", model = embeddings_model, id_col = "id")

	expect_s3_class(result, "tbl_df")
	expect_equal(names(result)[1:2], c("id", "token"))
})

test_that("embed_tokens keeps all columns when .keep_all = TRUE", {
	df <- data.frame(
		id = c("doc1", "doc2"),
		text = c("this says one thing", "and this says another"),
		category = c("A", "B"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))

	result <- embed_tokens(df, text_col = "text", model = embeddings_model,
												 id_col = "id", .keep_all = TRUE)

	expect_s3_class(result, "data.frame")
	expect_true(all(c("id", "category", "token", paste0("dim_", 1:5)) %in% names(result)))
})

test_that("embed_tokens respects tolower = FALSE", {
	texts <- c("This says one thing", "And this says another")

	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))

	result_tolower <- embed_tokens(texts, embeddings_model, tolower = TRUE)
	expect_warning(result_no_tolower <- embed_tokens(texts, embeddings_model, tolower = FALSE), "2 tokens in `x` are not present in `model`.")

	expect_false(identical(result_tolower, result_no_tolower))
})

test_that("embed_tokens passes additional arguments to tokens()", {
	texts <- c("this says one thing!", "and this says another.")

	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))

	# Remove punctuation
	result <- embed_tokens(texts, embeddings_model, remove_punct = TRUE)

	expect_s3_class(result, "tbl_df")
	expect_false(any(grepl("[[:punct:]]", result$token)))
})

test_that("embed_tokens returns embeddings with NA values for missing tokens when .keep_missing = TRUE", {
	texts <- c("this says unknown_word", "and this says another")

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	expect_warning(result <- embed_tokens(texts, embeddings_model, output_embeddings = TRUE, .keep_missing = TRUE),
								 "1 tokens in `x` are not present in `model`.")

	expect_true(is.list(result))
	expect_equal(length(result), length(texts))

	# Check that the embeddings contain NA for missing tokens
	embeddings_doc1 <- result[[1]]
	expect_true("unknown_word" %in% rownames(embeddings_doc1))
	expect_true(all(is.na(embeddings_doc1["unknown_word", ])))
})

test_that("embed_tokens handles empty input", {
	texts <- character(0)

	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))

	result <- embed_tokens(texts, embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(nrow(result), 0)
})

test_that("embed_tokens throws error when model is invalid", {
	texts <- c("this says one thing", "and this says another")

	model <- list()  # Invalid model

	expect_error(embed_tokens(texts, model), "`model` must be an embeddings object.")
})

test_that("embed_tokens throws error when text_col is missing in data frame", {
	df <- data.frame(
		id = c("doc1", "doc2"),
		content = c("this says one thing", "and this says another"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))

	expect_error(
		embed_tokens(df, text_col = "text", model = embeddings_model, id_col = "id"),
		"Can't extract columns that don't exist."
	)
})

test_that("embed_tokens ignores missing tokens when .keep_missing = FALSE", {
	texts <- c("this says unknown_word", "and this says another")

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	expect_warning(result <- embed_tokens(texts, embeddings_model, .keep_missing = FALSE), "1 tokens in `x` are not present in `model`.")

	expect_false(any(result$token == "unknown_word"))
})

test_that("embed_tokens handles embeddings with NA values", {
	texts <- c("this says one thing", "and this says another")
	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))
	embeddings_model[1, 1] <- NA  # Introduce NA value

	result <- embed_tokens(texts, embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_true(any(is.na(result)))
})

test_that("embed_tokens works with quanteda corpus", {
	texts <- c("this says one thing", "and this says another")
	corpus_obj <- corpus(texts)

	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))

	result <- embed_tokens(corpus_obj, embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(names(result)[1:2], c("doc_id", "token"))
})

test_that("embed_tokens matches tokens case-sensitively when tolower = FALSE", {
	texts <- c("This says One thing", "And this says another")

	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))
	# Add uppercase versions to embeddings
	extra_tokens <- c("This", "One", "And")
	extra_embeddings <- matrix(runif(length(extra_tokens) * 5), nrow = length(extra_tokens),
														 dimnames = list(extra_tokens, paste0("dim_", 1:5)))
	embeddings_model <- rbind(embeddings_model, extra_embeddings)

	result <- embed_tokens(texts, embeddings_model, tolower = FALSE)

	expect_true(all(c("This", "One", "And") %in% result$token))
})

test_that("embed_tokens handles tokens with punctuation", {
	texts <- c("this says one thing!", "and this says another.")
	tokens_obj <- tokens(texts, what = "fasterword")

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing!", "and", "another."), paste0("dim_", 1:5)))

	result <- embed_tokens(tokens_obj, embeddings_model, remove_punct = FALSE)

	expect_true("thing!" %in% result$token)
	expect_true("another." %in% result$token)
})

test_that("embed_tokens assigns default doc_id when id_col is missing in data frame", {
	df <- data.frame(
		text = c("this says one thing", "and this says another"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))

	result <- embed_tokens(df, text_col = "text", model = embeddings_model)

	expect_s3_class(result, "tbl_df")
	expect_equal(names(result)[1], "doc_id")
})

test_that("embed_tokens handles tokens that repeat in documents", {
	texts <- c("this this this", "and and")
	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))

	result <- embed_tokens(texts, embeddings_model)

	expect_equal(nrow(result), 5)  # 3 tokens in first doc, 2 in second
})

test_that("embed_tokens only keeps doc_id, token, and embeddings when .keep_all = FALSE", {
	df <- data.frame(
		id = c("doc1", "doc2"),
		text = c("this says one thing", "and this says another"),
		category = c("A", "B"),
		stringsAsFactors = FALSE
	)

	embeddings_model <- embeddings(runif(35), nrow = 7, dimnames = list(c("this", "says", "one", "thing", "and", "another", "unknown_word"), paste0("dim_", 1:5)))

	result <- embed_tokens(df, text_col = "text", model = embeddings_model,
												 id_col = "id", .keep_all = FALSE)

	expect_s3_class(result, "tbl_df")
	expect_equal(names(result)[1:2], c("id", "token"))
	expect_false("category" %in% names(result))
})

test_that("embed_tokens with tokens object respects tolower = FALSE", {
	texts <- c("This Says One Thing", "And This Says Another")
	tokens_obj <- tokens(texts)

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))
	# Add uppercase tokens
	extra_tokens <- c("This", "One", "And")
	extra_embeddings <- matrix(runif(length(extra_tokens) * 5), nrow = length(extra_tokens),
														 dimnames = list(extra_tokens, paste0("dim_", 1:5)))
	embeddings_model <- rbind(embeddings_model, extra_embeddings)

	expect_warning(result <- embed_tokens(tokens_obj, embeddings_model, tolower = FALSE), "3 tokens in `x` are not present in `model`.")

	expect_true(all(c("This", "One", "And") %in% result$token))
})

test_that("embed_tokens handles empty documents", {
	texts <- c("", "and this says another")

	embeddings_model <- embeddings(runif(30), nrow = 6, dimnames = list(c("this", "says", "one", "thing", "and", "another"), paste0("dim_", 1:5)))

	result <- embed_tokens(texts, embeddings_model)

	expect_equal(nrow(result), 4)  # Only tokens from second document
})
