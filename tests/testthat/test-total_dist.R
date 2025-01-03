test_that("total_dist computes Euclidean distance correctly", {
	x <- embeddings(rnorm(30), nrow = 10, ncol = 3)
	y <- embeddings(rnorm(30), nrow = 10, ncol = 3)

	result <- total_dist(x, y, method = "euclidean")
	expect_true(is.numeric(result))
	expect_equal(result, sum(sapply(1:10, function(i) euc_dist(x[i,], y[i,]))))

	result <- total_dist(x, y, average = TRUE)
	expect_equal(result, mean(sapply(1:10, function(i) euc_dist(x[i,], y[i,]))))
})

test_that("total_dist handles custom matching correctly", {
	x <- embeddings(rnorm(30), nrow = 10, ncol = 3)
	y <- embeddings(rnorm(30), nrow = 10, ncol = 3)

	matching <- setNames(rownames(y)[1:5], rownames(x)[1:5])
	expect_message(
		result <- total_dist(x, y, matching = matching, method = "euclidean"),
		"Computing metric based on 5 matching rows."
	)
	expect_equal(result, sum(sapply(1:5, function(i) euc_dist(x[i,], y[i,]))))
})

test_that("total_dist handles custom method functions", {
	x <- embeddings(rnorm(30), nrow = 10, ncol = 3)
	y <- embeddings(rnorm(30), nrow = 10, ncol = 3)

	custom_method <- function(x, y) sqrt(sum((x - y)^2))
	result <- total_dist(x, y, method = custom_method)

	expect_true(is.numeric(result))
	expect_equal(result, sum(sapply(1:10, function(i) custom_method(x[i,], y[i,]))))
})

test_that("average_sim calls total_dist with correct defaults", {
	x <- embeddings(rnorm(30), nrow = 10, ncol = 3)
	y <- embeddings(rnorm(30), nrow = 10, ncol = 3)

	result <- average_sim(x, y)
	expect_equal(result, mean(sapply(1:10, function(i) cos_sim(x[i,], y[i,]))))
})

test_that("total_dist methods work", {
	x <- embeddings(rnorm(30), nrow = 10, ncol = 3)
	y <- embeddings(rnorm(30), nrow = 10, ncol = 3)

	result <- euc_dist_parallel(x, y)
	expect_equal(as.vector(result), sapply(1:10, function(i) euc_dist(x[i,], y[i,])))
	result <- minkowski_dist_parallel(x, y, p = 2)
	expect_equal(as.vector(result), sapply(1:10, function(i) minkowski_dist(x[i,], y[i,], p = 2)))
	result <- cos_sim_squished_parallel(x, y)
	expect_equal(as.vector(result), sapply(1:10, function(i) cos_sim(x[i,], y[i,])*0.5 + 0.5))
	result <- dot_prod_parallel(x, y)
	expect_equal(as.vector(result), sapply(1:10, function(i) dot_prod(x[i,], y[i,])))
})

test_that("total_dist throws proper errors", {
	x <- embeddings(rnorm(30), nrow = 10, ncol = 3)
	y <- embeddings(rnorm(40), nrow = 10, ncol = 4)
	expect_error(
		total_dist(x, y),
		"x and y must have the same number of dimensions"
	)
	expect_error(
		total_dist(x, x, method = "typo"),
		"Unknown method"
	)
})
