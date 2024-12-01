test_that("reduce_dimensionality works with embeddings object", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	result <- reduce_dimensionality(embeddings, reduce_to = 2)

	expect_true(is.embeddings(result))
	expect_equal(ncol(result), 2)
	expect_equal(colnames(result), c("PC1", "PC2"))

	# Ensure that the rownames are preserved
	expect_equal(rownames(result), rownames(embeddings))
})

test_that("reduce_dimensionality reduces dimensions based on tol when reduce_to is NULL", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	result <- reduce_dimensionality(embeddings, tol = 0.1)

	# Number of columns may vary based on tol
	expect_true(ncol(result) <= ncol(embeddings))
	expect_true(is.embeddings(result))
})

test_that("reduce_dimensionality with output_rotation = TRUE returns rotation components", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	rotation <- reduce_dimensionality(embeddings, reduce_to = 2, output_rotation = TRUE)

	expect_true(is.list(rotation))
	expect_named(rotation, c("rotation", "center", "scale"))
	expect_equal(ncol(rotation$rotation), 2)
})

test_that("reduce_dimensionality applies custom_rotation correctly", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	rotation <- reduce_dimensionality(embeddings, reduce_to = 2, output_rotation = TRUE)

	# Apply custom rotation to new data
	new_embeddings <- embeddings * 2  # Some transformation
	result <- reduce_dimensionality(new_embeddings, custom_rotation = rotation)

	expect_true(is_matrixlike(result))
	expect_equal(ncol(result), 2)
	expect_equal(colnames(result), colnames(rotation$rotation))
})

test_that("reduce_dimensionality works with center = FALSE and scale = FALSE", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	result <- reduce_dimensionality(embeddings, reduce_to = 2, center = FALSE, scale = FALSE)

	expect_true(is.embeddings(result))
	expect_equal(ncol(result), 2)
})

test_that("reduce_dimensionality handles embeddings with NA values", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))
	embeddings[1, 1] <- NA

	expect_warning(result <- reduce_dimensionality(embeddings, reduce_to = 2),
								 "Input data contains missing values. Rows dropped in output.")

	# Rows with NA values should be dropped
	expect_true(is.embeddings(result))
	expect_equal(nrow(result), nrow(embeddings) - 1)
})

test_that("reduce_dimensionality works with a list of embeddings", {
	embeddings1 <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))
	embeddings2 <- embeddings1 * 2  # Different embeddings
	embeddings_list <- list(embeddings1, embeddings2)

	result <- reduce_dimensionality(embeddings_list, reduce_to = 2)

	expect_equal(length(result), 2)
	expect_true(all(sapply(result, is.embeddings)))
	expect_equal(ncol(result[[1]]), 2)
})

test_that("reduce_dimensionality.data.frame works with tidyselect columns", {
	df <- tibble(
		id = c("a", "b", "c", "d"),
		dim1 = c(1, 5, 9, 13),
		dim2 = c(2, 6, 10, 14),
		dim3 = c(3, 7, 11, 15),
		dim4 = c(4, 8, 12, 16),
		category = c("x", "y", "x", "y")
	)

	result <- reduce_dimensionality(df, cols = starts_with("dim"), reduce_to = 2)

	# Check that non-selected columns are preserved
	expect_true(all(c("id", "category") %in% names(result)))
	# Check that reduced dimensions are present
	expect_true(all(c("PC1", "PC2") %in% names(result)))
	expect_equal(ncol(result), 4)
})

test_that("reduce_dimensionality.default throws error with invalid input", {
	expect_error(reduce_dimensionality("invalid input"), "character object cannot be reduced.")
})

test_that("reduce_dimensionality with output_rotation = TRUE returns custom_rotation that can be reused", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	rotation <- reduce_dimensionality(embeddings, reduce_to = 2, output_rotation = TRUE)
	expect_true(is.list(rotation))

	# Apply the rotation to the same embeddings
	result <- reduce_dimensionality(embeddings, custom_rotation = rotation)
	expect_equal(ncol(result), 2)
	expect_equal(colnames(result), colnames(rotation$rotation))
})

test_that("reduce_dimensionality with custom_rotation overrides other parameters", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	rotation <- reduce_dimensionality(embeddings, reduce_to = 2, output_rotation = TRUE)

	# Try changing reduce_to, center, scale (should have no effect)
	result <- reduce_dimensionality(embeddings, reduce_to = 3, center = FALSE, scale = TRUE, custom_rotation = rotation)

	expect_equal(ncol(result), ncol(rotation$rotation))
	expect_equal(colnames(result), colnames(rotation$rotation))
})

test_that("reduce_dimensionality handles zero variance dimensions", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))
	embeddings[, 4] <- 1  # Zero variance in the fourth dimension

	result <- reduce_dimensionality(embeddings, reduce_to = 3)

	# The dimension with zero variance should be ignored
	expect_true(ncol(result) <= 3)
})

test_that("reduce_dimensionality handles reduce_to greater than number of dimensions", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	result <- reduce_dimensionality(embeddings, reduce_to = 10)

	# Should not exceed original number of dimensions
	expect_true(ncol(result) <= ncol(embeddings))
})

test_that("reduce_dimensionality handles embeddings with only one dimension", {
	embeddings <- embeddings(data = 1:4, nrow = 4, ncol = 1,
													 dimnames = list(c("token1", "token2", "token3", "token4"), "dim1"))

	result <- reduce_dimensionality(embeddings, reduce_to = 1)

	expect_true(is.embeddings(result))
	expect_equal(ncol(result), 1)
})

test_that("reduce_dimensionality handles embeddings with missing values", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))
	embeddings[2, 3] <- NA

	expect_warning(result <- reduce_dimensionality(embeddings, reduce_to = 2),
								 "Input data contains missing values. Rows dropped in output.")

	expect_true(is.embeddings(result))
	expect_equal(nrow(result), nrow(embeddings) - 1)
})

test_that("reduce_dimensionality works with scale = TRUE", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	result <- reduce_dimensionality(embeddings, reduce_to = 2, scale = TRUE)

	expect_true(is.embeddings(result))
	expect_equal(ncol(result), 2)
})

test_that("reduce_dimensionality works with center = FALSE", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	result <- reduce_dimensionality(embeddings, reduce_to = 2, center = FALSE)

	expect_true(is.embeddings(result))
	expect_equal(ncol(result), 2)
})

test_that("reduce_dimensionality works with tol specified", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	result <- reduce_dimensionality(embeddings, tol = 0.5)

	expect_true(is.embeddings(result))
	expect_true(ncol(result) <= ncol(embeddings))
})

test_that("reduce_dimensionality works with list and custom_rotation", {
	embeddings1 <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))
	embeddings2 <- embeddings1 * 2
	embeddings_list <- list(embeddings1, embeddings2)

	rotation <- reduce_dimensionality(embeddings1, reduce_to = 2, output_rotation = TRUE)

	result <- reduce_dimensionality(embeddings_list, custom_rotation = rotation)

	expect_equal(length(result), 2)
	expect_true(all(sapply(result, is_matrixlike)))
	expect_equal(ncol(result[[1]]), 2)
})

test_that("reduce_dimensionality handles empty embeddings object", {
	embeddings <- embeddings(data = numeric(0), nrow = 0, ncol = 4,
													 dimnames = list(character(0), paste0("dim", 1:4)))

	expect_error(reduce_dimensionality(embeddings, reduce_to = 2), "a dimension is zero")
})

test_that("reduce_dimensionality outputs columns named PC1, PC2, etc.", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	result <- reduce_dimensionality(embeddings, reduce_to = 3)

	expect_equal(colnames(result), c("PC1", "PC2", "PC3"))
})

test_that("reduce_dimensionality.data.frame applies custom_rotation correctly", {
	df <- tibble(
		id = c("a", "b", "c", "d"),
		dim1 = c(1, 5, 9, 13),
		dim2 = c(2, 6, 10, 14),
		dim3 = c(3, 7, 11, 15),
		dim4 = c(4, 8, 12, 16),
		category = c("x", "y", "x", "y")
	)

	rotation <- reduce_dimensionality(df, cols = starts_with("dim"), reduce_to = 2, output_rotation = TRUE)

	new_df <- df
	new_df$dim1 <- new_df$dim1 * 2  # Modify data

	result <- reduce_dimensionality(new_df, cols = starts_with("dim"), custom_rotation = rotation)

	# Check that the result contains the same non-selected columns
	expect_true(all(c("id", "category") %in% names(result)))
	expect_equal(ncol(result), 4)
})

test_that("Rotation from one embeddings can be applied to another", {
	embeddings1 <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))
	embeddings2 <- embeddings(data = 17:32, nrow = 4, ncol = 4, byrow = TRUE,
														dimnames = list(c("token5", "token6", "token7", "token8"), paste0("dim", 1:4)))

	rotation <- reduce_dimensionality(embeddings1, reduce_to = 2, output_rotation = TRUE)

	result <- reduce_dimensionality(embeddings2, custom_rotation = rotation)

	expect_true(is_matrixlike(result))
	expect_equal(ncol(result), 2)
})

test_that("reduce_dimensionality throws error if custom_rotation dimensions do not match", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	# Create a rotation from embeddings with fewer dimensions
	small_embeddings <- embeddings[, 1:2]
	rotation <- reduce_dimensionality(small_embeddings, reduce_to = 2, output_rotation = TRUE)

	expect_error(reduce_dimensionality(embeddings, custom_rotation = rotation),
							 "non-conformable arguments")
})

test_that("reduce_dimensionality.data.frame handles missing values", {
	df <- tibble(
		id = c("a", "b", "c", "d"),
		dim1 = c(1, NA, 9, 13),
		dim2 = c(2, 6, 10, 14),
		dim3 = c(3, 7, NA, 15),
		dim4 = c(4, 8, 12, 16)
	)

	expect_warning(result <- reduce_dimensionality(df, cols = starts_with("dim"), reduce_to = 2),
								 "Input data contains missing values. Rows dropped in output.")

	expect_equal(nrow(result), nrow(df) - 2)
})

test_that("reduce_dimensionality preserves rownames", {
	embeddings <- embeddings(data = 1:16, nrow = 4, byrow = TRUE, dimnames = list(paste0("token", 1:4), paste0("dim", 1:4)))

	result <- reduce_dimensionality(embeddings, reduce_to = 2)

	expect_equal(rownames(result), rownames(embeddings))
})
