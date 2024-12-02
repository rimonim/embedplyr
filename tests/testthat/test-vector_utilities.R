test_that("project_points_onto_line works with simple 2D points", {
	points <- matrix(c(1, 2,
										 3, 4,
										 5, 6), ncol = 2, byrow = TRUE)
	line_start <- c(0, 0)
	line_end <- c(10, 0)

	projected <- project_points_onto_line(points, line_start, line_end)

	# Expected projections are along x-axis
	expected <- matrix(c(1, 0,
											 3, 0,
											 5, 0), ncol = 2, byrow = TRUE)

	expect_equal(projected, expected)
})

test_that("project_points_onto_line returns the same points if they are on the line", {
	points <- matrix(c(1, 0,
										 5, 0,
										 10, 0), ncol = 2, byrow = TRUE)
	line_start <- c(0, 0)
	line_end <- c(10, 0)

	projected <- project_points_onto_line(points, line_start, line_end)

	expect_equal(projected, points)
})

test_that("project_points_onto_line projects points beyond the line segment correctly", {
	points <- matrix(c(-5, 5,
										 15, -5), ncol = 2, byrow = TRUE)
	line_start <- c(0, 0)
	line_end <- c(10, 0)

	projected <- project_points_onto_line(points, line_start, line_end)

	expected <- matrix(c(-5, 0,
											 15, 0), ncol = 2, byrow = TRUE)

	expect_equal(projected, expected)
})

test_that("project_points_onto_line works with 3D points", {
	points <- matrix(c(1, 2, 3,
										 4, 5, 6,
										 7, 8, 9), ncol = 3, byrow = TRUE)
	line_start <- c(0, 0, 0)
	line_end <- c(10, 10, 10)

	projected <- project_points_onto_line(points, line_start, line_end)

	# Since the line is along (1,1,1), projected points should have equal coordinates
	t_values <- rowSums(points) / sum(line_end)
	expected <- t_values %*% t(line_end)

	expect_equal(projected, expected)
})

test_that("project_points_onto_line works when points are data frame", {
	points <- data.frame(x = c(1, 3, 5), y = c(2, 4, 6))
	line_start <- c(0, 0)
	line_end <- c(10, 0)

	projected <- project_points_onto_line(points, line_start, line_end)
	rownames(projected) <- NULL

	expected <- data.frame(x = c(1, 3, 5), y = c(0, 0, 0))

	expect_equal(projected, expected)
})

test_that("project_points_onto_line works when points are embeddings object", {
	points <- embeddings(c(1, 2,
												 3, 4,
												 5, 6), ncol = 2, byrow = TRUE)
	line_start <- c(0, 0)
	line_end <- c(10, 0)

	projected <- project_points_onto_line(points, line_start, line_end)

	expected <- embeddings(c(1, 0,
													 3, 0,
													 5, 0), ncol = 2, byrow = TRUE)

	expect_true(is.embeddings(projected))
	expect_equal(projected, expected)
})

test_that("project_points_onto_line works with a single point", {
	points <- matrix(c(3, 4), ncol = 2)
	line_start <- c(0, 0)
	line_end <- c(10, 0)

	projected <- project_points_onto_line(points, line_start, line_end)

	expected <- matrix(c(3, 0), ncol = 2)

	expect_equal(projected, expected)
})

test_that("project_points_onto_line handles zero-length line (identical start and end)", {
	points <- matrix(c(1, 2,
										 3, 4), ncol = 2, byrow = TRUE)
	line_start <- c(0, 0)
	line_end <- c(0, 0)

	projected <- project_points_onto_line(points, line_start, line_end)
	expect_true(all(is.nan(projected)))
})

test_that("project_points_onto_line handles mismatched dimensions", {
	points <- matrix(c(1, 2), ncol = 2)
	line_start <- c(0, 0, 0)
	line_end <- c(10, 0, 0)

	expect_error(project_points_onto_line(points, line_start, line_end),
							 "all arguments must have the same number of dimensions")
})

test_that("project_points_onto_line throws error with non-numeric inputs", {
	points <- matrix(c("a", "b",
										 "c", "d"), ncol = 2, byrow = TRUE)
	line_start <- c(0, 0)
	line_end <- c(10, 0)

	expect_error(project_points_onto_line(points, line_start, line_end),
							 "non-numeric argument")
})

test_that("project_points_onto_line preserves row and column names", {
	data <- matrix(c(1, 2,
									 3, 4), ncol = 2, byrow = TRUE)
	rownames(data) <- c("point1", "point2")
	colnames(data) <- c("x", "y")
	points <- data
	line_start <- c(0, 0)
	line_end <- c(10, 0)

	projected <- project_points_onto_line(points, line_start, line_end)

	expect_equal(rownames(projected), rownames(points))
	expect_equal(colnames(projected), colnames(points))
})

test_that("project_points_onto_line handles points with repeated coordinates", {
	points <- matrix(c(1, 2,
										 1, 2,
										 1, 2), ncol = 2, byrow = TRUE)
	line_start <- c(0, 0)
	line_end <- c(10, 0)

	projected <- project_points_onto_line(points, line_start, line_end)

	expected <- matrix(c(1, 0,
											 1, 0,
											 1, 0), ncol = 2, byrow = TRUE)

	expect_equal(projected, expected)
})

test_that("project_points_onto_line works with high-dimensional data", {
	set.seed(123)
	points <- matrix(rnorm(50), ncol = 5)
	line_start <- rep(0, 5)
	line_end <- rep(1, 5)

	projected <- project_points_onto_line(points, line_start, line_end)

	# Check that projected points lie along the line
	# Since the line is along (1,1,1,1,1), projected points should have equal coordinates
	diffs <- apply(projected, 1, function(row) diff(range(row)))
	expect_true(all(abs(diffs) < 1e-6))
})

test_that("project_points_onto_line projects points onto the line", {
	points <- matrix(runif(6), ncol = 2)
	line_start <- c(0, 0)
	line_end <- c(1, 1)

	projected <- project_points_onto_line(points, line_start, line_end)

	# Check that the vector from line_start to projected point is parallel to the line direction
	line_direction <- line_end - line_start
	for (i in 1:nrow(points)) {
		vector_to_point <- projected[i, ] - line_start
		cross_prod <- vector_to_point[1] * line_direction[2] - vector_to_point[2] * line_direction[1]
		expect_true(abs(cross_prod) < 1e-6)
	}
})

test_that("project_points_onto_line works with non-standard line direction", {
	points <- matrix(c(1, 2,
										 3, 4), ncol = 2, byrow = TRUE)
	line_start <- c(1, 1)
	line_end <- c(4, 2)

	projected <- project_points_onto_line(points, line_start, line_end)

	# Manually compute expected projections
	line_direction <- line_end - line_start
	line_direction <- line_direction / sqrt(sum(line_direction^2))
	expected <- sapply(1:nrow(points), function(i) {
		t <- sum((points[i, ] - line_start) * line_direction)
		line_start + t * line_direction
	})
	expected <- t(expected)

	expect_equal(projected, expected)
})

test_that("project_points_onto_line works with line having negative direction components", {
	points <- matrix(c(1, 2,
										 3, 4), ncol = 2, byrow = TRUE)
	line_start <- c(5, 5)
	line_end <- c(0, 0)

	projected <- project_points_onto_line(points, line_start, line_end)

	# Line direction is negative of standard
	expected <- matrix(c(1.5, 1.5,
											 3.5, 3.5), ncol = 2, byrow = TRUE)

	expect_equal(projected, expected)
})

test_that("project_points_onto_line handles points with zero coordinates", {
	points <- matrix(c(0, 0,
										 0, 5,
										 5, 0), ncol = 2, byrow = TRUE)
	line_start <- c(0, 0)
	line_end <- c(10, 0)

	projected <- project_points_onto_line(points, line_start, line_end)

	expected <- matrix(c(0, 0,
											 0, 0,
											 5, 0), ncol = 2, byrow = TRUE)

	expect_equal(projected, expected)
})

test_that("project_points_onto_line works when line does not start at origin", {
	points <- matrix(c(3, 4), ncol = 2)
	line_start <- c(1, 1)
	line_end <- c(4, 5)

	projected <- project_points_onto_line(points, line_start, line_end)

	# Manually compute expected projection
	line_direction <- line_end - line_start
	t_value <- sum((points - line_start) * line_direction) / sum(line_direction^2)
	expected <- line_start + t_value * line_direction

	expect_equal(as.numeric(projected), expected)
})
