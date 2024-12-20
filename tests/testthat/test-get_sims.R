test_that("get_sims.default computes similarities correctly with method 'cosine'", {
	# Create a sample matrix x
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	# Create a named list y with one vector
	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	# Call the function
	result <- get_sims.default(x, y, method = "cosine")

	# Check that result is a tibble
	expect_true(is_tibble(result))
	# Check the dimensions of the result
	expect_equal(nrow(result), nrow(x))
	expect_equal(ncol(result), length(y))

	# Compute expected values using cos_sim_mat_vec
	expected_values <- cos_sim_mat_vec(x, y_vec)
	# Compare the computed similarities
	expect_equal(result$similarity, expected_values)
})

test_that("get_sims.default handles multiple y vectors", {
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	y_vec1 <- runif(3)
	y_vec2 <- runif(3)
	y <- list(sim1 = y_vec1, sim2 = y_vec2)

	result <- get_sims.default(x, y, method = "cosine")

	expect_true(is_tibble(result))
	expect_equal(ncol(result), length(y))
	expect_equal(result$sim1, cos_sim_mat_vec(x, y_vec1))
	expect_equal(result$sim2, cos_sim_mat_vec(x, y_vec2))
})

test_that("get_sims.default handles custom method functions", {
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	y_vec <- runif(3)
	y <- list(custom_sim = y_vec)

	# custom similarity function
	custom_method <- function(x, y) sum((x - y)^2)

	result <- get_sims.default(x, y, method = custom_method)

	expect_true(is_tibble(result))
	expect_equal(ncol(result), length(y))

	# Compute expected values manually
	expected_values <- apply(x, 1, custom_method, y = y_vec)
	expect_equal(result$custom_sim, expected_values)

	# incorrect parameters
	expect_error(get_sims.default(x, y = list(custom_method = list(z = y_vec)), method = custom_method),
							 "y must provide appropriate arguments for method")
})

test_that("get_sims.default returns error for invalid x input", {
	x <- list(a = 1, b = 2)
	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	expect_error(get_sims.default(x, y), "x must be an embeddings object or numeric matrix")
})

test_that("get_sims.default returns error for invalid y input", {
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	y <- list()

	expect_error(get_sims.default(x, y), "`y` must be a named list with non-empty names.")
})

test_that("get_sims.default returns error for unknown method", {
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	expect_error(get_sims.default(x, y, method = "unknown_method"), "Unknown method 'unknown_method'. Supported methods are")
})

test_that("get_sims.default handles 'anchored' method correctly", {
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	pos_vec <- runif(3)
	neg_vec <- runif(3)
	y <- list(anchored_sim = list(pos = pos_vec, neg = neg_vec))

	result <- get_sims.default(x, y, method = "anchored")

	expect_true(is_tibble(result))
	expect_equal(ncol(result), 1)

	# Compute expected values using anchored_sim_mat_vec
	expected_values <- anchored_sim_mat_vec(x, pos_vec, neg_vec)
	expect_equal(result$anchored_sim, expected_values)
})

test_that("get_sims.default returns error when 'anchored' method is used with invalid y", {
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	y <- list(anchored_sim = runif(3))

	expect_error(get_sims.default(x, y, method = "anchored"), "For method 'anchored', each item in `y` must be a list with 'pos' and 'neg' vectors.")
})

test_that("get_sims.embeddings computes similarities correctly", {
	x_mat <- matrix(runif(30), nrow = 10, ncol = 3)
	rownames(x_mat) <- paste0("doc", 1:10)
	x <- as.embeddings(x_mat)

	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	result <- get_sims.embeddings(x, y, method = "cosine")

	expect_true(is_tibble(result))
	expect_equal(ncol(result), length(y) + 1)  # Including 'doc_id'
	expect_equal(result$doc_id, rownames(x))
	expect_equal(result$similarity, cos_sim_mat_vec(x, y_vec))
})

test_that("get_sims.data.frame computes similarities correctly", {
	df <- data.frame(
		id = paste0("doc", 1:10),
		dim1 = runif(10),
		dim2 = runif(10),
		dim3 = runif(10),
		stringsAsFactors = FALSE
	)

	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	result <- get_sims.data.frame(df, cols = dim1:dim3, y = y, method = "cosine")

	expect_true(is.data.frame(result))
	expect_equal(nrow(result), nrow(df))
	expect_equal(result$similarity, cos_sim_mat_vec(as.matrix(df[, c("dim1", "dim2", "dim3")]), y_vec))
})

test_that("get_sims.data.frame retains all columns when .keep_all = TRUE", {
	df <- data.frame(
		id = paste0("doc", 1:10),
		dim1 = runif(10),
		dim2 = runif(10),
		dim3 = runif(10),
		extra_col = letters[1:10],
		stringsAsFactors = FALSE
	)

	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	result <- get_sims.data.frame(df, cols = dim1:dim3, y = y, method = "cosine", .keep_all = TRUE)

	expect_true(is.data.frame(result))
	expect_equal(ncol(result), ncol(df) + length(y))
	expect_equal(names(result), c(names(df), names(y)))
})

test_that("get_sims.data.frame excludes embedding columns when .keep_all = 'except.embeddings'", {
	df <- data.frame(
		id = paste0("doc", 1:10),
		dim1 = runif(10),
		dim2 = runif(10),
		dim3 = runif(10),
		extra_col = letters[1:10],
		stringsAsFactors = FALSE
	)

	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	result <- get_sims.data.frame(df, cols = dim1:dim3, y = y, method = "cosine", .keep_all = "except.embeddings")

	expect_true(is.data.frame(result))
	expect_equal(ncol(result), ncol(df) - 3 + length(y))  # Exclude embedding columns
	expect_equal(names(result), c("id", "extra_col", names(y)))
})

test_that("get_sims.data.frame returns only similarity columns when .keep_all = FALSE", {
	df <- data.frame(
		id = paste0("doc", 1:10),
		dim1 = runif(10),
		dim2 = runif(10),
		dim3 = runif(10),
		extra_col = letters[1:10],
		stringsAsFactors = FALSE
	)

	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	result <- get_sims.data.frame(df, cols = dim1:dim3, y = y, method = "cosine", .keep_all = FALSE)

	expect_true(is_tibble(result))
	expect_equal(ncol(result), length(y))
	expect_equal(names(result), names(y))
})

test_that("get_sims.data.frame returns error when selected columns are not numeric", {
	df <- data.frame(
		id = paste0("doc", 1:10),
		dim1 = letters[1:10],
		dim2 = letters[1:10],
		dim3 = letters[1:10],
		stringsAsFactors = FALSE
	)

	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	expect_error(get_sims.data.frame(df, cols = dim1:dim3, y = y, method = "cosine"), "Selected columns must be numeric.")
})

test_that("get_sims.data.frame returns error for invalid .keep_all value", {
	df <- data.frame(
		id = paste0("doc", 1:10),
		dim1 = runif(10),
		dim2 = runif(10),
		dim3 = runif(10),
		stringsAsFactors = FALSE
	)

	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	expect_error(get_sims.data.frame(df, cols = dim1:dim3, y = y, method = "cosine", .keep_all = "invalid"), "`.keep_all` must be TRUE, FALSE, or 'except.embeddings'.")
})

test_that("get_sims.default handles empty x", {
	x <- matrix(numeric(0), nrow = 0, ncol = 3)
	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	result <- get_sims.default(x, y, method = "cosine")

	expect_true(is_tibble(result))
	expect_equal(nrow(result), 0)
})

test_that("get_sims.default returns error when dimensions do not match", {
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	y_vec <- runif(4)  # Different length
	y <- list(similarity = y_vec)

	expect_error(get_sims.default(x, y, method = "cosine"), "x and y must have the same number of dimensions")
})

test_that("get_sims.default handles method functions that take additional arguments", {
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	custom_method <- function(x, y, p) sum(abs(x - y)^p)

	result <- get_sims.default(x, y, method = custom_method, p = 2)

	expect_true(is_tibble(result))
	expected_values <- apply(x, 1, custom_method, y = y_vec, p = 2)
	expect_equal(result$similarity, expected_values)
})

test_that("get_sims.default returns error when required arguments are missing in custom method", {
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	y <- list(similarity = list(a = 1))

	custom_method <- function(x, y, a, b) x + y + a + b

	expect_error(get_sims.default(x, y, method = custom_method), 'argument "y" is missing, with no default')
})

test_that("get_sims.default returns error when y_item is not appropriate for method", {
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	y <- list(similarity = list(pos = runif(3)))

	expect_error(get_sims.default(x, y, method = "cosine"), "y must provide appropriate arguments for method")
})

test_that("get_sims.default returns error when method is not character or function", {
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	y <- list(similarity = runif(3))

	expect_error(get_sims.default(x, y, method = 123), "`method` must be one of")
})

test_that("get_sims.data.frame handles tidyselect column specification", {
	df <- data.frame(
		id = paste0("doc", 1:10),
		embedding1 = runif(10),
		embedding2 = runif(10),
		embedding3 = runif(10),
		stringsAsFactors = FALSE
	)

	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	result <- get_sims.data.frame(df, cols = starts_with("embedding"), y = y, method = "cosine")

	expect_true(is.data.frame(result))
	expect_equal(nrow(result), nrow(df))
	expect_equal(result$similarity, cos_sim_mat_vec(as.matrix(df[,2:4]), y_vec))
})

test_that("get_sims.data.frame works with grouped data frames", {
	df <- data.frame(
		group = rep(1:2, each = 5),
		dim1 = runif(10),
		dim2 = runif(10),
		dim3 = runif(10),
		stringsAsFactors = FALSE
	)

	df_grouped <- dplyr::group_by(df, group)

	y_vec <- runif(3)
	y <- list(similarity = y_vec)

	result <- get_sims.data.frame(df_grouped, cols = dim1:dim3, y = y, method = "cosine")

	expect_true(is_tibble(result))
	expect_equal(nrow(result), nrow(df))
	expect_true("group" %in% names(result))
	expect_equal(ncol(dplyr::group_keys(result)), 1)
})

test_that("get_sims.default handles method 'minkowski' with parameter p", {
	x <- matrix(runif(30), nrow = 10, ncol = 3)
	y_vec <- runif(3)
	y <- list(distance = y_vec)

	result <- get_sims.default(x, y, method = "minkowski", p = 3)

	expect_true(is_tibble(result))
	expected_values <- minkowski_dist_mat_vec(x, y_vec, p = 3)
	expect_equal(result$distance, expected_values)
})
