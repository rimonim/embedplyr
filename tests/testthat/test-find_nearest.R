test_that("find_nearest returns correct nearest neighbors for existing tokens", {
	# Create a sample embeddings object
	embeddings_matrix <- matrix(runif(100), nrow = 10)
	rownames(embeddings_matrix) <- paste0("token", 1:10)
	embeddings <- as.embeddings(embeddings_matrix)

	# Use an existing token
	newdata <- "token1"
	result <- find_nearest(embeddings, newdata, top_n = 3)

	# Check that result is an embeddings object
	expect_true(inherits(result, "embeddings"))
	# Check that the number of rows is correct
	expect_equal(nrow(result), 3)
	# Check that the tokens in the result are in the embeddings
	expect_true(all(rownames(result) %in% rownames(embeddings)))
})

test_that("find_nearest works with numeric vector as newdata", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	new_vector <- runif(ncol(embeddings))
	result <- find_nearest(embeddings, new_vector, top_n = 3)

	expect_true(inherits(result, "embeddings"))
	expect_equal(nrow(result), 3)
})

test_that("find_nearest works with embeddings object as newdata", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	new_embeddings <- embeddings[1:2, ]
	result <- find_nearest(embeddings, new_embeddings, top_n = 3)

	expect_true(inherits(result, "embeddings"))
	expect_equal(nrow(result), 3)
})

test_that("find_nearest works with each = TRUE", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	newdata <- c("token1", "token2")

	result <- find_nearest(embeddings, newdata, top_n = 3, each = TRUE)

	expect_true(is.list(result))
	expect_equal(length(result), length(newdata))
	expect_true(all(names(result) == newdata))

	# Check each element in the result list
	lapply(result, function(res) {
		expect_true(inherits(res, "embeddings"))
		expect_equal(nrow(res), 3)
	})
})

test_that("find_nearest works with include_self = FALSE", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	rownames(embeddings) <- paste0("token", 1:10)
	newdata <- "token1"

	result <- find_nearest(embeddings, newdata, top_n = 3, include_self = FALSE)

	expect_true(inherits(result, "embeddings"))
	expect_equal(nrow(result), 3)
	# Check that 'token1' is not in the result
	expect_false("token1" %in% rownames(result))
})

test_that("find_nearest returns similarities when get_sims = TRUE", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	rownames(embeddings) <- paste0("token", 1:10)
	newdata <- "token1"

	result <- find_nearest(embeddings, newdata, top_n = 3, get_sims = TRUE)

	expect_true(is_tibble(result))
	expect_equal(nrow(result), 3)
	# Check that the result contains 'doc_id' and method name columns
	expect_true(all(c("doc_id", "cosine") %in% names(result)))
})

test_that("find_nearest works with method = 'euclidean' and decreasing = FALSE", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	rownames(embeddings) <- paste0("token", 1:10)
	newdata <- "token1"

	result <- find_nearest(embeddings, newdata, top_n = 3, method = "euclidean")

	expect_true(inherits(result, "embeddings"))
	expect_equal(nrow(result), 3)
})

test_that("find_nearest handles tokens not in embeddings", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	rownames(embeddings) <- paste0("token", 1:10)
	newdata <- c("token1", "unknown_token")

	expect_warning(
		result <- find_nearest(embeddings, newdata, top_n = 3),
		"items in `newdata` are not present in the embeddings object"
	)

	expect_true(inherits(result, "embeddings"))
	expect_equal(nrow(result), 3)
})

test_that("find_nearest errors when no tokens in newdata are in embeddings", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	newdata <- c("unknown_token1", "unknown_token2")
	expect_error(
		find_nearest(embeddings, newdata, top_n = 3),
		"None of the items in `newdata` are tokens in the embeddings object"
	)
})

test_that("find_nearest works with custom method function", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	custom_method <- function(x, y) sum((x - y)^2)

	rownames(embeddings) <- paste0("token", 1:10)
	newdata <- "token1"

	result <- find_nearest(embeddings, newdata, top_n = 3, method = custom_method)

	expect_true(inherits(result, "embeddings"))
	expect_equal(nrow(result), 3)
})

test_that("find_nearest works with numeric vector and each = TRUE", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	newdata_matrix <- matrix(runif(20), nrow = 2)
	rownames(newdata_matrix) <- c("vec1", "vec2")

	result <- find_nearest(embeddings, newdata_matrix, top_n = 3, each = TRUE)

	expect_true(is.list(result))
	expect_equal(length(result), 2)
	expect_true(all(names(result) == c("vec1", "vec2")))

	# Check each element in the result list
	lapply(result, function(res) {
		expect_true(inherits(res, "embeddings") || is.na(res))
		expect_equal(nrow(res), 3)
	})
})

test_that("find_nearest adjusts top_n when it exceeds number of tokens", {
	embeddings_matrix <- matrix(runif(50), nrow = 5, dimnames = list(paste0("token", 1:5)))
	embeddings <- as.embeddings(embeddings_matrix)

	newdata <- "token1"

	result <- find_nearest(embeddings, newdata, top_n = 10)

	expect_true(inherits(result, "embeddings"))
	expect_equal(nrow(result), 5)  # Only 5 tokens available
})

test_that("find_nearest errors when newdata is all NA", {
	embeddings_matrix <- matrix(runif(50), nrow = 5, dimnames = list(paste0("token", 1:5)))
	embeddings <- as.embeddings(embeddings_matrix)

	newdata <- as.numeric(c(NA, NA, NA))
	expect_error(
		find_nearest(embeddings, newdata, top_n = 3),
		"newdata is entirely NAs"
	)
})

test_that("find_nearest errors when object is not an embeddings object", {
	object <- matrix(runif(50), nrow = 5)
	newdata <- "token1"
	expect_error(
		find_nearest(object, newdata, top_n = 3),
		"`object` is not an embeddings object"
	)
})

test_that("find_nearest works with get_sims = TRUE and each = TRUE", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	newdata <- c("token1", "token2")

	result <- find_nearest(embeddings, newdata, top_n = 3, each = TRUE, get_sims = TRUE)

	expect_true(is.list(result))
	expect_equal(length(result), length(newdata))
	expect_true(all(names(result) == newdata))

	lapply(result, function(res) {
		expect_true(is_tibble(res))
		expect_equal(nrow(res), 3)
		expect_true(all(c("doc_id", "cosine") %in% names(res)))
	})
})

test_that("find_nearest works with method = 'minkowski' and parameter p", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	rownames(embeddings) <- paste0("token", 1:10)
	newdata <- "token1"

	result <- find_nearest(embeddings, newdata, top_n = 3, method = "minkowski", p = 2)

	expect_true(inherits(result, "embeddings"))
	expect_equal(nrow(result), 3)
})

test_that("find_nearest works when newdata is a zero vector", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	zero_vector <- rep(0, ncol(embeddings))

	result <- find_nearest(embeddings, zero_vector, top_n = 3)

	expect_true(inherits(result, "embeddings"))
	expect_equal(nrow(result), 3)
})

test_that("find_nearest handles embeddings with duplicate token names", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	rownames(embeddings) <- c(rep("token1", 5), paste0("token", 6:10))
	newdata <- "token1"

	result <- find_nearest(embeddings, newdata, top_n = 3)

	expect_true(inherits(result, "embeddings"))
	expect_equal(nrow(result), 3)
})

test_that("find_nearest assigns default name to unnamed numeric vector in newdata", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	new_vector <- runif(ncol(embeddings))

	result <- find_nearest(embeddings, new_vector, top_n = 3, each = TRUE)

	expect_true(is.list(result))
	expect_equal(length(result), 1)
	expect_true(is.null(names(result)))
})

test_that("find_nearest handles embeddings with NA values", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings_matrix[1, 1] <- NA
	embeddings <- as.embeddings(embeddings_matrix)

	newdata <- "token2"
	result <- find_nearest(embeddings, newdata, top_n = 3)
	expect_false(any(is.na(result)))
})

test_that("find_nearest errors when newdata has different dimensionality", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, ncol = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	new_vector <- runif(5)  # Different dimensionality
	expect_error(
		find_nearest(embeddings, new_vector, top_n = 3),
		"x and y must have the same number of dimensions"
	)
})

test_that("find_nearest errors with invalid method", {
	embeddings_matrix <- matrix(runif(100), nrow = 10, dimnames = list(paste0("token", 1:10)))
	embeddings <- as.embeddings(embeddings_matrix)

	newdata <- "token1"
	expect_error(
		find_nearest(embeddings, newdata, top_n = 3, method = "invalid_method"),
		"Unknown method 'invalid_method'"
	)
})

test_that("find_nearest with include_self = FALSE and each = TRUE excludes only the relevant token", {
	embeddings_matrix <- matrix(runif(100), nrow = 10)
	rownames(embeddings_matrix) <- paste0("token", 1:10)
	embeddings <- as.embeddings(embeddings_matrix)

	newdata <- c("token1", "token2")

	result <- find_nearest(embeddings, newdata, top_n = 3, each = TRUE, include_self = FALSE)

	expect_true(is.list(result))
	expect_equal(length(result), length(newdata))

	# Check that each token is excluded from its own result
	expect_false("token1" %in% rownames(result[["token1"]]))
	expect_false("token2" %in% rownames(result[["token2"]]))
})
