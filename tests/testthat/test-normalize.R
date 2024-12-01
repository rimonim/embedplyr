test_that("normalize.numeric works with a regular numeric vector", {
	vec <- c(3, 4)
	result <- normalize(vec)

	# Expected result
	expected <- vec / sqrt(sum(vec^2))

	expect_equal(result, expected)
	expect_equal(sqrt(sum(result^2)), 1)
})

test_that("normalize.numeric handles zero vector correctly", {
	vec <- c(0, 0, 0)
	expect_warning(result <- normalize(vec), "NaNs produced")
	expect_true(all(is.nan(result)))
})

test_that("normalize.numeric handles NA values", {
	vec <- c(NA, 4)

	result <- normalize(vec)
	expect_true(any(is.na(result)))
})

test_that("normalize.numeric handles Inf values", {
	vec <- c(Inf, 4)

	expect_warning(result <- normalize(vec), "NaNs produced")
	expect_true(any(is.na(result)))
})

test_that("normalize.numeric works with negative values", {
	vec <- c(-3, 4)
	result <- normalize(vec)

	expected <- vec / sqrt(sum(vec^2))
	expect_equal(result, expected)
	expect_equal(sqrt(sum(result^2)), 1)
})

test_that("normalize.numeric works with single element vector", {
	vec <- c(5)
	result <- normalize(vec)

	expected <- vec / sqrt(sum(vec^2))
	expect_equal(result, expected)
	expect_equal(abs(result), 1)
})

test_that("normalize.embeddings works with embeddings object", {
	embeddings <- embeddings(c(3, 4, 0, 0, 0, 5, 8, 15, 0), nrow = 3, , byrow = TRUE, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	result <- normalize(embeddings)
	expect_true(is.embeddings(result))

	# Check that each row has magnitude 1
	magnitudes <- sqrt(rowSums(result^2))
	expect_equal(as.numeric(magnitudes), c(1, 1, 1))
})

test_that("normalize.embeddings handles zero vectors", {
	embeddings <- embeddings(c(0, 0, 0, 0, 0, 0), nrow = 2)

	expect_warning(result <- normalize(embeddings), "NaNs produced")
	expect_true(all(is.nan(result)))
})

test_that("normalize.embeddings handles NA values", {
	embeddings <- embeddings(c(3, 4, 0, 0, 0, 5, 8, 15, 0), nrow = 3, , byrow = TRUE, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))
	embeddings[1, 1] <- NA

	result <- normalize(embeddings)
	expect_true(any(is.na(result)))
})

test_that("normalize.default works with a list of numeric vectors", {
	vec_list <- list(c(3, 4), c(5, 12), c(0, 0))
	expect_warning(result <- normalize(vec_list), "NaNs produced")

	expected <- lapply(vec_list, function(vec) {
		vec / sqrt(sum(vec^2))
	})

	expect_equal(result, expected)
	expect_equal(sqrt(sum(result[[1]]^2)), 1)
	expect_equal(sqrt(sum(result[[2]]^2)), 1)
	expect_true(all(is.nan(result[[3]])))
})

test_that("normalize.default works with a list of embeddings", {
	embeddings1 <- embeddings(c(3, 4, 0, 0, 0, 5, 8, 15, 0), nrow = 3, , byrow = TRUE, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))
	embeddings2 <- embeddings1 * 2
	embeddings_list <- list(embeddings1, embeddings2)

	result <- normalize(embeddings_list)

	# Check that each embedding in the list is normalized
	for (emb in result) {
		magnitudes <- sqrt(rowSums(emb^2))
		expect_equal(as.numeric(magnitudes), c(1, 1, 1))
	}
})

test_that("normalize.default throws error with invalid input", {
	expect_error(normalize("invalid input"), "x must be a numeric vector or an embeddings object")

	df <- data.frame(a = 1:3, b = 4:6)
	expect_error(normalize(df), "x must be a numeric vector or an embeddings object\nFor data frames and matrices, use normalize_rows().")
})

test_that("normalize_rows works with a data frame", {
	df <- data.frame(dim1 = c(3, 0, 5), dim2 = c(4, 0, 12))
	expect_warning(result <- normalize_rows(df), "NaNs produced")

	expected <- apply(df, 1, function(row) {
		row / sqrt(sum(row^2))
	})
	expected <- t(expected)

	expect_equal(as.matrix(result), expected)
})

test_that("normalize_rows works with a matrix", {
	mat <- matrix(c(3, 4, 0, 0, 5, 12), nrow = 3, byrow = TRUE)
	expect_warning(result <- normalize_rows(mat), "NaNs produced")

	expected <- apply(mat, 1, function(row) {
		row / sqrt(sum(row^2))
	})
	expected <- t(expected)

	expect_equal(result, expected)
})

test_that("normalize_rows throws error with invalid input", {
	expect_error(normalize_rows("invalid input"), "x must be a dataframe or matrix")

	vec <- c(1, 2, 3)
	expect_error(normalize_rows(vec), "x must be a dataframe or matrix")
})

test_that("normalize_rows.data.frame works with tidyselect columns", {
	df <- tibble(
		id = c("a", "b", "c"),
		dim1 = c(3, 0, 5),
		dim2 = c(4, 0, 12),
		other = c("x", "y", "z")
	)
	expect_warning(result <- normalize_rows(df, cols = starts_with("dim")), "NaNs produced")

	# Expected normalized columns
	normalized_dims <- apply(df %>% dplyr::select(starts_with("dim")), 1, function(row) {
		row / sqrt(sum(row^2))
	})
	normalized_dims <- t(normalized_dims)

	expected <- dplyr::bind_cols(
		df %>% dplyr::select(-starts_with("dim")),
		as_tibble(normalized_dims)
	)

	expect_equal(result, expected)
})

test_that("normalize_rows.data.frame handles no columns selected", {
	df <- tibble(
		id = c("a", "b", "c"),
		other = c("x", "y", "z")
	)

	result <- normalize_rows(df, cols = starts_with("dim"))

	expect_equal(result, df)
})

test_that("normalize_rows handles rows with zero vectors", {
	mat <- matrix(c(0, 0, 3, 4, 0, 0), nrow = 3, byrow = TRUE)

	expect_warning(result <- normalize_rows(mat), "NaNs produced")
	expect_true(all(is.nan(result[1, ])))
	expect_true(all(is.nan(result[3, ])))
	expect_equal(sqrt(sum(result[2, ]^2)), 1)
})

test_that("normalize_rows handles NA values", {
	mat <- matrix(c(3, 4, NA, NA), nrow = 2)
	result <- normalize_rows(mat)

	expect_true(any(is.na(result)))
})

test_that("normalize.embeddings works even if token_index is missing", {
	embeddings <- embeddings(c(3, 4, 0, 0, 0, 5, 8, 15, 0), nrow = 3, , byrow = TRUE, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))
	attr(embeddings, "token_index") <- NULL

	result <- normalize(embeddings)

	expect_true(is.embeddings(result))
	expect_true(!is.null(attr(result, "token_index")))
	magnitudes <- sqrt(rowSums(result^2))
	expect_equal(as.numeric(magnitudes), c(1, 1, 1))
})

test_that("normalize.default handles empty list", {
	result <- normalize(list())
	expect_equal(result, list())
})

test_that("normalize.default handles list with mixed types", {
	vec <- c(3, 4)
	embeddings <- embeddings(c(3, 4, 0, 0, 0, 5, 8, 15, 0), nrow = 3, , byrow = TRUE, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))
	lst <- list(vec, embeddings)

	result <- normalize(lst)

	expect_equal(length(result), 2)
	expect_equal(result[[1]], normalize(vec))
	expect_true(is.embeddings(result[[2]]))
})

test_that("normalize_rows.data.frame handles no numeric columns selected", {
	df <- data.frame(
		id = c("a", "b"),
		other = c("x", "y"),
		stringsAsFactors = FALSE
	)

	result <- normalize_rows(df, cols = where(is.numeric))

	expect_equal(result, df)
})

test_that("normalize works with high-dimensional embeddings", {
	embeddings <- embeddings(runif(1000), nrow = 10)

	result <- normalize(embeddings)

	magnitudes <- sqrt(rowSums(result^2))
	expect_equal(as.numeric(magnitudes), rep(1, 10))
})

test_that("normalize.numeric throws error with multi-dimensional array", {
	arr <- array(1:8, dim = c(2, 2, 2))

	expect_error(normalize(arr), "x must be a numeric vector, an embeddings object, or a dataframe with one embedding per row")
})

test_that("normalize.default suggests normalize_rows for data frames", {
	df <- data.frame(a = 1:3, b = 4:6)

	expect_error(normalize(df), "x must be a numeric vector or an embeddings object\nFor data frames and matrices, use normalize_rows().")
})

test_that("normalize_rows.data.frame works with tidyselect helpers", {
	df <- tibble(
		id = c("a", "b"),
		dim1 = c(3, 5),
		dim2 = c(4, 12),
		other = c("x", "y")
	)

	result <- normalize_rows(df, cols = c(dim1, dim2))

	expected_dims <- apply(df %>% dplyr::select(dim1, dim2), 1, function(row) {
		row / sqrt(sum(row^2))
	})
	expected_dims <- t(expected_dims)

	expected <- dplyr::bind_cols(
		df %>% dplyr::select(-dim1, -dim2),
		as_tibble(expected_dims)
	)

	expect_equal(result, expected)
})
