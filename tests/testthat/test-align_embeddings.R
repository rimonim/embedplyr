test_that("align_embeddings handles dimensionality reduction correctly", {
	x <- embeddings(rnorm(50), nrow = 10, ncol = 5)
	y <- embeddings(rnorm(30), nrow = 10, ncol = 3)

	expect_message(
		result <- align_embeddings(x, y),
		"Reducing dimensionality with PCA."
		)
	expect_equal(ncol(result), ncol(y))
	expect_equal(nrow(result), nrow(x))
})

test_that("align_embeddings handles matching rows correctly", {
	x <- embeddings(rnorm(30), nrow = 10, ncol = 3, dimnames = list(paste0("xtok", 1:10)))
	y <- embeddings(rnorm(30), nrow = 10, ncol = 3, dimnames = list(paste0("ytok", 1:10)))

	rownames(y)[1:5] <- rownames(x)[1:5]
	expect_message(
		result <- align_embeddings(x, y),
		"Aligning based on 5 matching rows."
		)

	expect_equal(ncol(result), ncol(y))
	expect_equal(nrow(result), nrow(x))
})

test_that("align_embeddings respects the matching parameter", {
	x <- embeddings(rnorm(30), nrow = 10, ncol = 3, dimnames = list(paste0("xtok", 1:10)))
	y <- embeddings(rnorm(30), nrow = 10, ncol = 3, dimnames = list(paste0("ytok", 1:10)))

	matching <- setNames(rownames(y)[1:5], rownames(x)[1:5])
	expect_message(
		result <- align_embeddings(x, y, matching),
		"Aligning based on 5 matching rows."
	)

	expect_equal(ncol(result), ncol(y))
	expect_equal(nrow(result), nrow(x))
})

test_that("align_embeddings handles NA values gracefully", {
	x <- embeddings(rnorm(30), nrow = 10, ncol = 3)
	y <- embeddings(rnorm(30), nrow = 10, ncol = 3)

	x[1, ] <- NA
	y[2, ] <- NA
	expect_message(
		result <- align_embeddings(x, y),
		"Aligning based on 8 matching rows."
	)

	expect_equal(ncol(result), ncol(y))
	expect_equal(nrow(result), nrow(x))
})
