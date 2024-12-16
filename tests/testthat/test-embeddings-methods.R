test_that("as.matrix.embeddings removes 'embeddings' class", {
	expect_warning(emb <- as.embeddings(matrix(1:6, nrow = 2)), "unique row names not provided. Naming rows doc_1, doc_2, etc.")
	mat2 <- as.matrix(emb)

	expect_false(inherits(mat2, "embeddings"))
	expect_true(is.matrix(mat2))
})

test_that("Setting rownames and colnames on embeddings", {
	mat <- matrix(1:6, nrow = 2)
	expect_warning(emb <- as.embeddings(mat), "unique row names not provided. Naming rows doc_1, doc_2, etc.")
	rownames(emb) <- c("token1", "token2")
	colnames(emb) <- c("dim1", "dim2", "dim3")

	expect_equal(rownames(emb), c("token1", "token2"))
	expect_equal(colnames(emb), c("dim1", "dim2", "dim3"))
	expect_s3_class(emb, "embeddings")
})

test_that("as_tibble.embeddings converts embeddings to tibble", {
	mat <- matrix(1:6, nrow = 2)
	rownames(mat) <- c("token1", "token2")
	emb <- as.embeddings(mat)
	tbl <- tibble::as_tibble(emb, rownames = "token")

	expect_s3_class(tbl, "tbl_df")
	expect_equal(tbl$token, c("token1", "token2"))
	expect_equal(tbl$dim_1, c(1, 2))
})

test_that("Using rbind maintains correct token_index", {
	mat1 <- matrix(1:4, nrow = 2, dimnames = list(c("token1", "token2")))
	embeddings1 <- as.embeddings(mat1)

	mat2 <- matrix(5:8, nrow = 2, dimnames = list(c("token3", "token4")))
	embeddings2 <- as.embeddings(mat2)

	embeddings_combined <- rbind(embeddings1, embeddings2)

	# Verify token_index
	token_index <- attr(embeddings_combined, "token_index")
	expect_equal(sort(ls(token_index)), c("token1", "token2", "token3", "token4"))
	expect_equal(token_index[["token3"]], 3)
})

test_that("rownames<-.embeddings assigns new rownames and updates token_index", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	# Assign new unique rownames
	rownames(embeddings) <- c("new_token1", "new_token2", "new_token3")

	expect_equal(rownames(embeddings), c("new_token1", "new_token2", "new_token3"))

	# Check that token_index is updated
	token_index <- attr(embeddings, "token_index")
	expect_equal(sort(ls(token_index)), c("new_token1", "new_token2", "new_token3"))
	expect_equal(token_index[["new_token1"]], 1)

	# Assign duplicate rownames
	rownames(embeddings) <- c("dup_token", "dup_token", "dup_token")

	# Verify that embeddings handles duplicate rownames
	expect_equal(rownames(embeddings), c("dup_token", "dup_token", "dup_token"))

	# Check token_index (only the last occurrence)
	token_index <- attr(embeddings, "token_index")
	expect_equal(ls(token_index), "dup_token")
	expect_equal(token_index[["dup_token"]], 3)
})

test_that("dimnames<-.embeddings assigns new dimnames and updates token_index", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	# Assign new dimnames
	dimnames(embeddings) <- list(c("new_token1", "new_token2", "new_token3"),
															 c("new_dim1", "new_dim2", "new_dim3"))

	expect_equal(rownames(embeddings), c("new_token1", "new_token2", "new_token3"))
	expect_equal(colnames(embeddings), c("new_dim1", "new_dim2", "new_dim3"))

	# Check that token_index is updated
	token_index <- attr(embeddings, "token_index")
	expect_equal(sort(ls(token_index)), c("new_token1", "new_token2", "new_token3"))

	# Assign NULL dimnames
	dimnames(embeddings) <- NULL

	expect_null(dimnames(embeddings))

	# Check that token_index is empty
	token_index <- attr(embeddings, "token_index")
	expect_equal(length(ls(token_index)), 0)
})

test_that("rownames<-.embeddings assigns new dimnames and updates token_index", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	# Assign new dimnames
	rownames(embeddings) <- c("new_token1", "new_token2", "new_token3")

	expect_equal(rownames(embeddings), c("new_token1", "new_token2", "new_token3"))
	expect_equal(colnames(embeddings), c("dim1", "dim2", "dim3"))

	# Check that token_index is updated
	token_index <- attr(embeddings, "token_index")
	expect_equal(sort(ls(token_index)), c("new_token1", "new_token2", "new_token3"))
})

test_that("dim<-.embeddings throws an error when attempting to change dimensions", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	expect_error(dim(embeddings) <- c(9, 1),
							 "Cannot change dimensions of an embeddings object directly.")
})

test_that("unique.embeddings removes duplicate rows and updates token_index", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	# Add duplicate rows
	embeddings <- rbind(embeddings, embeddings[2, , drop = FALSE])

	# Now embeddings has 4 rows, with one duplicate
	expect_equal(nrow(embeddings), 4)

	# Check that rownames may not be unique
	expect_equal(rownames(embeddings), c("token1", "token2", "token3", "token2"))

	# Call unique on embeddings
	embeddings_unique <- unique(embeddings)

	expect_true(is.embeddings(embeddings_unique))
	expect_equal(nrow(embeddings_unique), 3)

	# Check that token_index is updated
	token_index <- attr(embeddings_unique, "token_index")
	expect_equal(sort(ls(token_index)), c("token1", "token2", "token3"))

	# Check that embeddings_unique contains unique rows
	expect_equal(rownames(embeddings_unique), c("token1", "token2", "token3"))
})

test_that("t.embeddings transposes the embeddings object and updates appropriately", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	embeddings_t <- t(embeddings)

	expect_true(is.embeddings(embeddings_t))

	# Check dimensions
	expect_equal(dim(embeddings_t), c(3, 3))

	# Now the rownames should be the original column names
	expect_equal(rownames(embeddings_t), c("dim1", "dim2", "dim3"))

	# And the colnames should be the original rownames (tokens)
	expect_equal(colnames(embeddings_t), c("token1", "token2", "token3"))

	# Check that token_index is updated accordingly
	token_index <- attr(embeddings_t, "token_index")
	expect_equal(sort(ls(token_index)), c("dim1", "dim2", "dim3"))
})

# Test 9: Ensuring methods handle NULL rownames appropriately
test_that("Methods handle NULL rownames appropriately", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	# Assign NULL rownames
	rownames(embeddings) <- NULL

	expect_null(rownames(embeddings))

	# Check that token_index is empty
	token_index <- attr(embeddings, "token_index")
	expect_equal(length(ls(token_index)), 0)

	# Test as.matrix
	embeddings_matrix <- as.matrix(embeddings)
	expect_true(is.matrix(embeddings_matrix))

	# Test as_tibble
	embeddings_tbl <- as_tibble(embeddings, rownames = "token")
	expect_true(is_tibble(embeddings_tbl))
	expect_true(all(is.numeric(as.numeric(embeddings_tbl$token))))
})

test_that("Changing column names does not affect token_index", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	colnames(embeddings) <- c("new_dim1", "new_dim2", "new_dim3")

	expect_equal(colnames(embeddings), c("new_dim1", "new_dim2", "new_dim3"))

	# Token index should remain the same
	token_index <- attr(embeddings, "token_index")
	expect_equal(sort(ls(token_index)), c("token1", "token2", "token3"))
})

test_that("unique.embeddings works with MARGIN = 2", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	# Duplicate a column
	embeddings[,3] <- embeddings[,2]
	colnames(embeddings)[3] <- "dim2"  # Duplicate column name

	# Call unique on embeddings with MARGIN = 2
	embeddings_unique <- unique(embeddings, MARGIN = 2)

	expect_true(is.embeddings(embeddings_unique))
	expect_equal(ncol(embeddings_unique), 2)

	expect_equal(colnames(embeddings_unique), c("dim1", "dim2"))
})

test_that("Double transpose returns to original embeddings", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	embeddings_t <- t(embeddings)
	embeddings_tt <- t(embeddings_t)

	expect_true(is.embeddings(embeddings_tt))
	expect_equal(embeddings_tt, embeddings)
})

test_that("Methods maintain embeddings class", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	# After unique
	embeddings_unique <- unique(embeddings)
	expect_true(is.embeddings(embeddings_unique))

	# After transpose
	embeddings_t <- t(embeddings)
	expect_true(is.embeddings(embeddings_t))

	# After rbind
	embeddings_combined <- rbind(embeddings, embeddings)
	expect_true(is.embeddings(embeddings_combined))
})

test_that("Attempting to change dimensions throws an error", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	expect_error(dim(embeddings) <- c(1, 9), "Cannot change dimensions of an embeddings object directly.")
})

test_that("as_tibble.embeddings works with additional arguments", {
	embeddings <- embeddings(1:9, nrow = 3, dimnames = list(paste0("token", 1:3), paste0("dim", 1:3)))

	embeddings_tbl <- as_tibble(embeddings, .name_repair = "unique")
	expect_true(is_tibble(embeddings_tbl))
})
