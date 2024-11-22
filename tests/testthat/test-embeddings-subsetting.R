test_that("Indexing embeddings retains embeddings class when multiple rows remain", {
	mat <- matrix(1:9, nrow = 3)
	expect_warning(emb <- as.embeddings(mat), "unique row names not provided. Naming rows doc_1, doc_2, etc.")
	emb_sub <- emb[1:2, ]

	expect_s3_class(emb_sub, "embeddings")
	expect_equal(dim(emb_sub), c(2, 3))
})

test_that("Indexing embeddings with logical indices works correctly", {
	emb <- embeddings(1:9, nrow = 3)
	result <- emb[c(TRUE, FALSE, TRUE), ]
	expect_equal(rownames(result), c("doc_1", "doc_3"))

	# Length mismatch
	expect_error(emb[c(TRUE, FALSE, TRUE, TRUE), ], "logical subscript too long")
})

test_that("Indexing embeddings returns numeric vector when appropriate", {
	mat <- matrix(1:9, nrow = 3)
	expect_warning(emb <- as.embeddings(mat), "unique row names not provided. Naming rows doc_1, doc_2, etc.")
	emb_sub <- emb[1, 1]

	expect_false(is.embeddings(emb_sub))
	expect_equal(class(emb_sub), "integer")
})

test_that("Indexing embeddings to single row/column with drop = FALSE retains embeddings class", {
	mat <- matrix(1:9, nrow = 3)
	rownames(mat) <- c("a", "b", "c")
	emb <- as.embeddings(mat)
	emb_sub1 <- emb[1, , drop = FALSE]

	expect_s3_class(emb_sub1, "embeddings")
	expect_equal(dim(emb_sub1), c(1, 3))
	expect_equal(rownames(emb_sub1), "a")

	emb_sub2 <- emb[, 1, drop = FALSE]
	expect_s3_class(emb_sub2, "embeddings")
	expect_equal(dim(emb_sub2), c(3, 1))
	expect_equal(colnames(emb_sub2), "dim_1")
})

test_that("Indexing embeddings on duplicate rowname returns last", {
	emb <- embeddings(1:9, nrow = 3)
	rownames(emb) <- c("a", "b", "a")
	expect_equal(as.numeric(emb["a",]), c(3, 6, 9))
})

test_that("Indexing embeddings with missing i", {
	emb <- embeddings(1:12, nrow = 3)
	expect_equal(dim(emb[,]), c(3, 4))
})

test_that("Assignment to embeddings using numeric indices", {
	embeddings <- embeddings(1:12, nrow = 4)

	embeddings[1, ] <- c(100, 200, 300)
	expect_equal(as.numeric(embeddings[1, ]), c(100, 200, 300))
})

test_that("Assignment to embeddings using character indices", {
	embeddings <- embeddings(1:12, nrow = 4)

	embeddings["doc_2", ] <- c(400, 500, 600)
	expect_equal(as.numeric(embeddings["doc_2", ]), c(400, 500, 600))

	# Assignment to duplicate token (should affect last occurrence)
	rownames(embeddings)[3] <- "doc_1"
	embeddings["doc_1", ] <- c(700, 800, 900)
	expect_equal(as.numeric(embeddings[3, ]), c(700, 800, 900))
})

test_that("Assignment to embeddings with invalid indices", {
	embeddings <- embeddings(1:12, nrow = 4)

	# Numeric index out of bounds
	expect_error(embeddings[5, ] <- c(1, 2, 3), "subscript out of bounds")

	# Character index not found
	expect_error(embeddings["tokenX", ] <- c(1, 2, 3), "value for 'tokenX' not found")
})

test_that("Subsetting embeddings using subset function", {
	embeddings <- embeddings(1:12, nrow = 4)

	# Subset where dim1 > 5
	result <- subset(embeddings, embeddings[,"dim_1"] > 3)
	expect_true(is.embeddings(result))
	expect_equal(rownames(result), c("doc_4"))

	# Subset with logical expression
	result <- subset(embeddings, embeddings[,"dim_2"] == 6)
	expect_equal(rownames(result), "doc_2")
})

test_that("Subsetting embeddings with complex expressions", {
	embeddings <- embeddings(1:12, nrow = 4)

	result <- subset(embeddings, magnitude(embeddings) > 12)
	expect_equal(rownames(result), c("doc_3", "doc_4"))
})

test_that("Subsetting embeddings with NA values", {
	embeddings <- embeddings(1:12, nrow = 4)

	result <- subset(embeddings, c(TRUE, NA, FALSE, TRUE))
	expect_equal(rownames(result), c("doc_1", "doc_4"))
})
