create_sample_embeddings <- function() {
	tokens <- c("happy", "sad", "joyful")
	embeddings(runif(length(tokens) * 5), nrow = length(tokens),
						 dimnames = list(tokens, paste0("dim_", 1:5)))
}

test_that("emb handles missing tokens with .keep_missing = FALSE", {
	embeddings_obj <- create_sample_embeddings()
	newdata <- c("happy", "unknown", "sad")
	expect_warning(
		result <- emb(embeddings_obj, newdata, .keep_missing = FALSE),
		"1 items in `newdata` are not present in the embeddings object."
	)
	expect_true(is.embeddings(result))
	expect_equal(nrow(result), 2)
	expect_equal(rownames(result), c("happy", "sad"))
})

test_that("emb handles missing tokens with .keep_missing = TRUE", {
	embeddings_obj <- create_sample_embeddings()
	newdata <- c("happy", "unknown", "sad")
	expect_warning(
		result <- emb(embeddings_obj, newdata, .keep_missing = TRUE),
		"1 items in `newdata` are not present in the embeddings object."
	)
	expect_true(is.embeddings(result))
	expect_equal(nrow(result), 3)
	expect_equal(rownames(result), newdata)
	expect_true(all(!is.na(result["happy", ])))
	expect_true(all(!is.na(result["sad", ])))
	expect_true(all(is.na(result["unknown", ])))
})

test_that("emb handles duplicate tokens in newdata", {
	embeddings_obj <- create_sample_embeddings()
	newdata <- c("happy", "sad", "happy")
	result <- emb(embeddings_obj, newdata)
	expect_true(is.embeddings(result))
	expect_equal(nrow(result), 3)
	expect_equal(rownames(result), newdata)
	expect_equal(result[1, ], result[3, ])
})

test_that("emb handles empty strings in newdata", {
	embeddings_obj <- create_sample_embeddings()
	newdata <- c("happy", "", "sad")
	w <- capture_warnings(
		result <- emb(embeddings_obj, newdata, .keep_missing = TRUE)
	)
	expect_match(w, 'Replacing 1 empty strings with " "', all = FALSE)
	expect_match(w, '1 items in `newdata` are not present in the embeddings object.', all = FALSE)
	expect_true(is.embeddings(result))
	expect_equal(nrow(result), 3)
	expect_equal(rownames(result), c("happy", " ", "sad"))
	expect_true(all(!is.na(result["happy", ])))
	expect_true(all(!is.na(result["sad", ])))
	expect_true(all(is.na(result[" ", ])))
})

test_that("emb returns named vector when drop = TRUE and result is single row", {
	embeddings_obj <- create_sample_embeddings()
	newdata <- c("happy")
	result <- emb(embeddings_obj, newdata, drop = TRUE)
	expect_true(is.numeric(result))
	expect_equal(length(result), ncol(embeddings_obj))
	expect_equal(names(result), colnames(embeddings_obj))
})

test_that("emb returns embeddings object when drop = FALSE and result is single row", {
	embeddings_obj <- create_sample_embeddings()
	newdata <- c("happy")
	result <- emb(embeddings_obj, newdata, drop = FALSE)
	expect_true(is.embeddings(result))
	expect_equal(nrow(result), 1)
	expect_equal(rownames(result), newdata)
})

test_that("emb handles embeddings object with duplicate tokens", {
	embeddings_obj <- create_sample_embeddings()
	# Add a duplicate token
	rownames(embeddings_obj)[3] <- "happy"
	result <- emb(embeddings_obj, "happy", drop = FALSE)
	expect_true(is.embeddings(result))
	expect_equal(nrow(result), 1)
	expect_equal(rownames(result), "happy")
	# Check that the values are from the last occurrence
	expect_equal(result, embeddings_obj[3, , drop = FALSE])
})

test_that("emb handles newdata with non-character tokens", {
	embeddings_obj <- create_sample_embeddings()
	newdata <- c("happy", 123, "sad")
	expect_warning(
		result <- emb(embeddings_obj, newdata),
		"1 items in `newdata` are not present in the embeddings object."
	)
	expect_true(is.embeddings(result))
	expect_equal(nrow(result), 2)
	expect_equal(rownames(result), c("happy", "sad"))
})

test_that("emb handles NA values in newdata", {
	embeddings_obj <- create_sample_embeddings()
	newdata <- c("happy", NA, "sad")
	expect_warning(
		emb(embeddings_obj, newdata),
		"1 items in `newdata` are not present in the embeddings object."
	)
})

test_that("emb returns numeric() when result is empty and drop = TRUE", {
	embeddings_obj <- create_sample_embeddings()
	newdata <- c("unknown1", "unknown2")
	expect_warning(
		result <- emb(embeddings_obj, newdata, .keep_missing = FALSE, drop = TRUE),
		"2 items in `newdata` are not present in the embeddings object."
	)
	expect_true(is.numeric(result))
	expect_equal(length(result), 0)
})

test_that("emb handles multiple empty strings in newdata", {
	embeddings_obj <- create_sample_embeddings()
	newdata <- c("happy", "", "", "sad")
	result <- suppressWarnings( emb(embeddings_obj, newdata, .keep_missing = TRUE) )
	expect_true(is.embeddings(result))
	expect_equal(nrow(result), 4)
	expect_equal(rownames(result), c("happy", " ", " ", "sad"))
	expect_true(all(!is.na(result["happy", ])))
	expect_true(all(!is.na(result["sad", ])))
	expect_true(all(is.na(result[" ", ])))
})
