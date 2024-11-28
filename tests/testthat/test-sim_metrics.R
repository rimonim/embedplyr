test_that("dot_prod computes dot product correctly", {
	x <- c(1, 2, 3)
	y <- c(4, 5, 6)
	expect_equal(dot_prod(x, y), sum(x * y))
})

test_that("dot_prod returns 0 for orthogonal vectors", {
	x <- c(1, 0)
	y <- c(0, 1)
	expect_equal(dot_prod(x, y), 0)
})

test_that("dot_prod handles negative values", {
	x <- c(-1, -2, -3)
	y <- c(4, 5, 6)
	expect_equal(dot_prod(x, y), sum(x * y))
})

test_that("dot_prod returns error for mismatched dimensions", {
	x <- c(1, 2, 3)
	y <- c(4, 5)
	expect_error(dot_prod(x, y), "x and y must have the same number of dimensions")
})

test_that("cos_sim computes cosine similarity correctly", {
	x <- c(1, 0)
	y <- c(0, 1)
	expect_equal(cos_sim(x, y), 0)
})

test_that("cos_sim returns 1 for identical vectors", {
	x <- c(1, 2, 3)
	expect_equal(cos_sim(x, x), 1)
})

test_that("cos_sim handles negative values", {
	x <- c(-1, -2, -3)
	y <- c(1, 2, 3)
	expected <- sum(x * y) / (sqrt(sum(x^2)) * sqrt(sum(y^2)))
	expect_equal(cos_sim(x, y), expected)
})

test_that("cos_sim handles zero vector inputs", {
	x <- c(0, 0, 0)
	y <- c(1, 2, 3)
	expect_warning(result <- cos_sim(x, y), "One of the vectors has zero length; returning NA")
	expect_true(is.na(result))
})

test_that("cos_sim returns error for mismatched dimensions", {
	x <- c(1, 2, 3)
	y <- c(4, 5)
	expect_error(cos_sim(x, y), "x and y must have the same number of dimensions")
})

test_that("euc_dist computes Euclidean distance correctly", {
	x <- c(1, 2)
	y <- c(4, 6)
	expected <- sqrt((1 - 4)^2 + (2 - 6)^2)
	expect_equal(euc_dist(x, y), expected)
})

test_that("euc_dist returns zero for identical vectors", {
	x <- c(1, 2, 3)
	expect_equal(euc_dist(x, x), 0)
})

test_that("euc_dist handles negative values", {
	x <- c(-1, -2, -3)
	y <- c(4, 5, 6)
	expected <- sqrt(sum((x - y)^2))
	expect_equal(euc_dist(x, y), expected)
})

test_that("euc_dist returns error for mismatched dimensions", {
	x <- c(1, 2, 3)
	y <- c(4, 5)
	expect_error(euc_dist(x, y), "x and y must have the same number of dimensions")
})

test_that("minkowski_dist computes Minkowski distance with p=1 (Manhattan distance)", {
	x <- c(1, 2, 3)
	y <- c(4, 5, 6)
	expected <- sum(abs(x - y))
	expect_equal(minkowski_dist(x, y, p = 1), expected)
})

test_that("minkowski_dist computes Minkowski distance with p=2 (Euclidean distance)", {
	x <- c(1, 2, 3)
	y <- c(4, 5, 6)
	expected <- euc_dist(x, y)
	expect_equal(minkowski_dist(x, y, p = 2), expected)
})

test_that("minkowski_dist computes Minkowski distance with p=Inf (Chebyshev distance)", {
	x <- c(1, 2, 3)
	y <- c(4, 5, 1)
	expected <- max(abs(x - y))
	expect_equal(minkowski_dist(x, y, p = Inf), expected)
})

test_that("minkowski_dist returns error for p < 1", {
	x <- c(1, 2, 3)
	y <- c(4, 5, 6)
	expect_error(minkowski_dist(x, y, p = 0.5), "p must be greater than or equal to 1")
})

test_that("minkowski_dist returns error for mismatched dimensions", {
	x <- c(1, 2)
	y <- c(3, 4, 5)
	expect_error(minkowski_dist(x, y), "x and y must have the same number of dimensions")
})

test_that("anchored_sim computes anchored similarity correctly", {
	x <- c(2, 2)
	pos <- c(4, 4)
	neg <- c(0, 0)
	expected <- 0.5  # x is halfway between neg and pos
	expect_equal(anchored_sim(x, pos, neg), expected)
})

test_that("anchored_sim returns 1 when x equals pos", {
	x <- c(4, 4)
	pos <- c(4, 4)
	neg <- c(0, 0)
	expect_equal(anchored_sim(x, pos, neg), 1)
})

test_that("anchored_sim returns 0 when x equals neg", {
	x <- c(0, 0)
	pos <- c(4, 4)
	neg <- c(0, 0)
	expect_equal(anchored_sim(x, pos, neg), 0)
})

test_that("anchored_sim handles zero-length anchored vector", {
	x <- c(1, 2)
	pos <- c(1, 2)
	neg <- c(1, 2)
	expect_warning(result <- anchored_sim(x, pos, neg), "Anchored vector has zero length; returning NA")
	expect_true(is.na(result))
})

test_that("anchored_sim returns error for mismatched dimensions", {
	x <- c(1, 2)
	pos <- c(3, 4)
	neg <- c(5)
	expect_error(anchored_sim(x, pos, neg), "x, pos, and neg must have the same number of dimensions")
})

test_that("dot_prod_mat_vec computes dot product for each row", {
	x <- matrix(1:6, nrow = 2)
	y <- c(1, 1, 1)
	expected <- x %*% y
	result <- dot_prod_mat_vec(x, y)
	expect_equal(result, expected)
})

test_that("dot_prod_mat_vec handles negative values", {
	x <- matrix(c(-1, -2, -3, -4, -5, -6), nrow = 2)
	y <- c(1, 2, 3)
	expected <- x %*% y
	result <- dot_prod_mat_vec(x, y)
	expect_equal(result, expected)
})

test_that("dot_prod_mat_vec returns error for mismatched dimensions", {
	x <- matrix(1:6, nrow = 2)
	y <- c(1, 1)
	expect_error(dot_prod_mat_vec(x, y), "x and y must have the same number of dimensions")
})

test_that("cos_sim_mat_vec computes cosine similarity for each row", {
	x <- matrix(c(1, 0, 0, 1, 1, 0), nrow = 2, byrow = TRUE)
	y <- c(1, 0, 0)
	expected <- c(1, sqrt(1/2))
	result <- cos_sim_mat_vec(x, y)
	expect_equal(result, expected)
})

test_that("cos_sim_mat_vec handles zero vectors", {
	x <- matrix(c(0, 0, 0, 1, 1, 1), nrow = 2, byrow = TRUE)
	y <- c(1, 1, 1)
	result <- cos_sim_mat_vec(x, y)
	expect_true(is.na(result[1]))
	expect_false(is.na(result[2]))
})

test_that("cos_sim_mat_vec returns error for mismatched dimensions", {
	x <- matrix(1:6, nrow = 2)
	y <- c(1, 1)
	expect_error(cos_sim_mat_vec(x, y), "x and y must have the same number of dimensions")
})

test_that("cos_sim_squished_mat_vec squishes cosine similarity to [0,1]", {
	x <- matrix(c(1, 0, 0, -1, 0, 0), nrow = 2, byrow = TRUE)
	y <- c(1, 0, 0)
	result <- cos_sim_squished_mat_vec(x, y)
	expect_equal(result, c(1, 0))
})

test_that("cos_sim_squished_mat_vec handles zero vectors", {
	x <- matrix(c(0, 0, 0, 1, 1, 1), nrow = 2, byrow = TRUE)
	y <- c(1, 1, 1)
	result <- cos_sim_squished_mat_vec(x, y)
	expect_true(is.na(result[1]))
	expect_false(is.na(result[2]))
})

test_that("euc_dist_mat_vec computes Euclidean distance for each row", {
	x <- matrix(c(1, 2, 3, 4, 5, 6), nrow = 2, byrow = TRUE)
	y <- c(1, 2, 3)
	expected <- c(0, euc_dist(y, 4:6))
	result <- euc_dist_mat_vec(x, y)
	expect_equal(result, expected)
})

test_that("euc_dist_mat_vec handles mismatched dimensions", {
	x <- matrix(1:6, nrow = 2)
	y <- c(1, 1)
	expect_error(euc_dist_mat_vec(x, y), "x and y must have the same number of dimensions")
})

test_that("minkowski_dist_mat_vec computes Minkowski distance with p=1", {
	x <- matrix(c(1, 2, 3, 4, 5, 6), nrow = 2, byrow = TRUE)
	y <- c(1, 2, 3)
	expected <- c(0, sum(abs(c(4,5,6)-c(1,2,3))))
	result <- minkowski_dist_mat_vec(x, y, p = 1)
	expect_equal(result, expected)
})

test_that("minkowski_dist_mat_vec computes Minkowski distance with p=2", {
	x <- matrix(c(1, 2, 3, 4, 5, 6), nrow = 2, byrow = TRUE)
	y <- c(1, 2, 3)
	expected <- c(0, sqrt(sum((c(4,5,6)-c(1,2,3))^2)))
	result <- minkowski_dist_mat_vec(x, y, p = 2)
	expect_equal(result, expected)
})

test_that("minkowski_dist_mat_vec handles p=Inf", {
	x <- matrix(c(1, 2, 3, 4, 5, 6), nrow = 2, byrow = TRUE)
	y <- c(1, 2, 3)
	expected <- c(0, max(abs(c(4,5,6)-c(1,2,3))))
	result <- minkowski_dist_mat_vec(x, y, p = Inf)
	expect_equal(result, expected)
})

test_that("minkowski_dist_mat_vec returns error for p < 1", {
	x <- matrix(1:6, nrow = 2)
	y <- c(1, 2, 3)
	expect_error(minkowski_dist_mat_vec(x, y, p = 0.5), "p must be greater than or equal to 1")
})

test_that("anchored_sim_mat_vec computes anchored similarity for each row", {
	x <- matrix(c(2, 2, 0, 0), nrow = 2, byrow = TRUE)
	pos <- c(4, 4)
	neg <- c(0, 0)
	expected <- c(0.5, 0)
	result <- anchored_sim_mat_vec(x, pos, neg)
	expect_equal(result, expected)
})

test_that("anchored_sim_mat_vec handles zero-length anchored vector", {
	x <- matrix(c(1, 2, 3, 4), nrow = 2, byrow = TRUE)
	pos <- c(1, 2)
	neg <- c(1, 2)
	result <- anchored_sim_mat_vec(x, pos, neg)
	expect_true(all(is.na(result)))
})

test_that("anchored_sim_mat_vec returns error for mismatched dimensions", {
	x <- matrix(1:6, nrow = 2)
	pos <- c(1, 2)
	neg <- c(3)
	expect_error(anchored_sim_mat_vec(x, pos, neg), "x, pos, and neg must have the same number of dimensions")
})

test_that("cos_sim handles NA values in inputs", {
	x <- c(NA, 1, 2)
	y <- c(1, 2, 3)
	result <- cos_sim(x, y)
	expect_true(is.na(result))
})

test_that("euc_dist handles NA values in inputs", {
	x <- c(NA, 2, 3)
	y <- c(1, 2, 3)
	result <- euc_dist(x, y)
	expect_true(is.na(result))
})

test_that("euc_dist handles Inf values in inputs", {
	x <- c(Inf, 2, 3)
	y <- c(1, 2, 3)
	result <- euc_dist(x, y)
	expect_true(is.infinite(result))
})

test_that("minkowski_dist handles NA values", {
	x <- c(NA, 2, 3)
	y <- c(1, 2, 3)
	result <- minkowski_dist(x, y)
	expect_true(is.na(result))
})

test_that("minkowski_dist handles Inf values", {
	x <- c(Inf, 2, 3)
	y <- c(1, 2, 3)
	result <- minkowski_dist(x, y)
	expect_true(is.infinite(result))
})

test_that("anchored_sim handles NA values in inputs", {
	x <- c(NA, 1)
	pos <- c(1, 2)
	neg <- c(0, 0)
	result <- anchored_sim(x, pos, neg)
	expect_true(is.na(result))
})

test_that("cos_sim_mat_vec handles NA values in matrix input", {
	x <- matrix(c(NA, 2, 3, 4, 5, 6), nrow = 2, byrow = TRUE)
	y <- c(1, 2, 3)
	result <- cos_sim_mat_vec(x, y)
	expect_true(is.na(result[1]))
	expect_false(is.na(result[2]))
})

test_that("euc_dist_mat_vec handles NA values in matrix input", {
	x <- matrix(c(NA, 2, 3, 4, 5, 6), nrow = 2, byrow = TRUE)
	y <- c(1, 2, 3)
	result <- euc_dist_mat_vec(x, y)
	expect_true(is.na(result[1]))
	expect_false(is.na(result[2]))
})

test_that("minkowski_dist_mat_vec handles NA values in matrix input", {
	x <- matrix(c(NA, 2, 3, 4, 5, 6), nrow = 2, byrow = TRUE)
	y <- c(1, 2, 3)
	result <- minkowski_dist_mat_vec(x, y)
	expect_true(is.na(result[1]))
	expect_false(is.na(result[2]))
})

test_that("anchored_sim_mat_vec handles NA values in matrix input", {
	x <- matrix(c(NA, 2, 1, 2), nrow = 2, byrow = TRUE)
	pos <- c(1, 2)
	neg <- c(0, 0)
	result <- anchored_sim_mat_vec(x, pos, neg)
	expect_true(is.na(result[1]))
	expect_false(is.na(result[2]))
})

