test_that("format.embeddings formats embeddings correctly with default parameters", {
	mat <- matrix(runif(50), nrow = 10)
	rownames(mat) <- paste0("token", 1:10)
	colnames(mat) <- paste0("dim", 1:5)
	emb <- as.embeddings(mat)

	formatted <- format(emb)

	expect_true(is.matrix(formatted))
	expect_true(is.character(formatted))
	expect_equal(nrow(formatted), min(getOption("embeddings.print.n", 10), nrow(emb)))
})

test_that("format.embeddings respects the 'n' parameter", {
	mat <- matrix(runif(100), nrow = 20)
	rownames(mat) <- paste0("token", 1:20)
	colnames(mat) <- paste0("dim", 1:5)
	emb <- as.embeddings(mat)

	formatted <- format(emb, n = 5)
	expect_equal(nrow(formatted), 5)
})

test_that("format.embeddings rounds numbers correctly with 'round' parameter", {
	mat <- matrix(runif(10), nrow = 2)
	rownames(mat) <- c("token1", "token2")
	colnames(mat) <- c("dim1", "dim2", "dim3", "dim4", "dim5")
	emb <- as.embeddings(mat)

	formatted <- format(emb, round = 3)
	numeric_values <- as.numeric(formatted)
	expect_false(any(is.na(numeric_values)))
	expect_true(all(abs(numeric_values - round(numeric_values, 3)) < .Machine$double.eps^0.5))
})

test_that("format.embeddings handles long column names by truncating", {
	mat <- matrix(runif(50), nrow = 10)
	rownames(mat) <- paste0("token", 1:10)
	long_names <- paste0("very_long_name_", 1:5)
	colnames(mat) <- long_names
	emb <- as.embeddings(mat)

	round = 2L
	formatted <- format(emb, round = round)
	truncated_colnames <- colnames(formatted)
	expect_true(all(nchar(truncated_colnames) <= round + 4L))
})

test_that("format.embeddings adds ellipsis when not all columns are shown", {
	mat <- matrix(runif(200), nrow = 10, ncol = 20)
	rownames(mat) <- paste0("token", 1:10)
	colnames(mat) <- paste0("dim", 1:20)
	emb <- as.embeddings(mat)

	formatted <- format(emb)
	if (ncol(formatted) < ncol(emb)) {
		expect_true(all(grepl("^\\.+", formatted[, ncol(formatted)])))
	}
})

if (requireNamespace("purrr", quietly=TRUE)) {
	test_that("print.embeddings outputs the correct header message", {
		mat <- matrix(runif(50), nrow = 10)
		rownames(mat) <- paste0("token", 1:10)
		colnames(mat) <- paste0("dim", 1:5)
		emb <- as.embeddings(mat)

		get_print_message <- function(x) capture.output(print(x), type = "message")
		get_print_message <- purrr::quietly(get_print_message)
		output <- get_print_message(emb)
		expect_equal(output$messages, pillar::style_subtle("# 5-dimensional embeddings with 10 rows\n"))
	})
}

test_that("print.embeddings respects the 'n' parameter", {
	mat <- matrix(runif(100), nrow = 20)
	rownames(mat) <- paste0("token", 1:20)
	colnames(mat) <- paste0("dim", 1:5)
	emb <- as.embeddings(mat)

	output <- suppressMessages(capture.output(print(emb, n = 5)))
	expect_equal(length(output) - 1, 5)  # Subtract header line
})

test_that("print.embeddings uses options(embeddings.print.n) when 'n' is NULL", {
	old_option <- getOption("embeddings.print.n")
	options(embeddings.print.n = 7)
	mat <- matrix(runif(100), nrow = 20)
	rownames(mat) <- paste0("token", 1:20)
	colnames(mat) <- paste0("dim", 1:5)
	emb <- as.embeddings(mat)

	output <- suppressMessages(capture.output(print(emb)))
	expect_equal(length(output) - 1, 7)  # Subtract header line

	options(embeddings.print.n = old_option)
})

test_that("print.embeddings handles zero-row embeddings", {
	mat <- matrix(numeric(0), nrow = 0, ncol = 5)
	colnames(mat) <- paste0("dim", 1:5)
	emb <- as.embeddings(mat)

	output <- suppressMessages(capture.output(print(emb)))
	expect_true(grepl("<0 x 5 embeddings>", output))
})

test_that("print.embeddings handles zero-column embeddings", {
	mat <- matrix(numeric(0), nrow = 5, ncol = 0)
	rownames(mat) <- paste0("token", 1:5)
	emb <- as.embeddings(mat)

	output <- suppressMessages(capture.output(print(emb)))
	expect_true(grepl("<5 x 0 embeddings>", output))
})

test_that("format.embeddings handles embeddings with one row", {
	mat <- matrix(runif(5), nrow = 1)
	rownames(mat) <- "token1"
	colnames(mat) <- paste0("dim", 1:5)
	emb <- as.embeddings(mat)

	formatted <- format(emb)
	expect_equal(nrow(formatted), 1)
	expect_equal(rownames(formatted), "token1")
})

test_that("format.embeddings handles embeddings with one column", {
	mat <- matrix(runif(10), nrow = 10, ncol = 1)
	rownames(mat) <- paste0("token", 1:10)
	colnames(mat) <- "dim1"
	emb <- as.embeddings(mat)

	formatted <- format(emb)
	expect_equal(ncol(formatted), 1)
	expect_equal(colnames(formatted), "dim1")
})

test_that("print.embeddings handles empty embeddings", {
	mat <- matrix(numeric(0), nrow = 0, ncol = 0)
	emb <- as.embeddings(mat)

	output <- suppressMessages(capture.output(print(emb)))
	expect_true(grepl("<0 x 0 embeddings>", output))
})

test_that("format.embeddings handles custom row names", {
	mat <- matrix(runif(50), nrow = 10)
	custom_names <- paste0("custom_", 1:10)
	rownames(mat) <- custom_names
	colnames(mat) <- paste0("dim", 1:5)
	emb <- as.embeddings(mat)

	formatted <- format(emb)
	expect_equal(rownames(formatted), custom_names[1:min(10, nrow(emb))])
})

test_that("format.embeddings handles 'n' larger than number of rows", {
	mat <- matrix(runif(30), nrow = 3)
	rownames(mat) <- paste0("token", 1:3)
	colnames(mat) <- paste0("dim", 1:10)
	emb <- as.embeddings(mat)

	formatted <- format(emb, n = 10)
	expect_equal(nrow(formatted), 3)
})

test_that("print.embeddings uses default 'round' when not specified", {
	mat <- matrix(runif(50), nrow = 10)
	rownames(mat) <- paste0("token", 1:10)
	colnames(mat) <- paste0("dim", 1:5)
	emb <- as.embeddings(mat)

	output_default <- suppressMessages(capture.output(print(emb)))
	output_round_2 <- suppressMessages(capture.output(print(emb, round = 2)))

	expect_equal(output_default, output_round_2)
})

test_that("print.embeddings is sensitive to 'width' options", {
	old_width <- getOption("width")
	options(width = 40)
	mat <- matrix(runif(50), nrow = 10)
	rownames(mat) <- paste0("token", 1:10)
	colnames(mat) <- paste0("dim", 1:5)
	emb <- as.embeddings(mat)

	output <- suppressMessages(capture.output(print(emb)))
	# With smaller width, fewer columns should be printed
	expect_true(length(output) > 1)
	options(width = old_width)
})

test_that("format.embeddings handles NA values in data", {
	mat <- matrix(runif(50), nrow = 10)
	mat[5, 5] <- NA
	rownames(mat) <- paste0("token", 1:10)
	colnames(mat) <- paste0("dim", 1:5)
	emb <- as.embeddings(mat)

	formatted <- format(emb)
	expect_true(any(formatted == "  NA"))
})

test_that("format.embeddings correctly handles single numeric value", {
	mat <- matrix(3.1415, nrow = 1, ncol = 1)
	rownames(mat) <- "token1"
	colnames(mat) <- "dim1"
	emb <- as.embeddings(mat)

	formatted <- format(emb, round = 2)
	expect_equal(formatted[1, 1], "3.14")
})

test_that("format.embeddings handles when 'screen_width' is very small", {
	old_width <- getOption("width")
	options(width = 20)
	mat <- matrix(runif(50), nrow = 10)
	rownames(mat) <- paste0("t", 1:10)
	colnames(mat) <- paste0("d", 1:5)
	emb <- as.embeddings(mat)

	formatted <- format(emb)
	expect_true(ncol(formatted) >= 1)
	options(width = old_width)
})


test_that("format.embeddings handles embeddings with special characters in names", {
	mat <- matrix(runif(20), nrow = 4)
	rownames(mat) <- c("tok\nen1", "to\ten2", "token3", "token4")
	colnames(mat) <- c("dim1", "dim\n2", "dim3", "dim4", "dim5")
	emb <- as.embeddings(mat)

	formatted <- format(emb)
	expect_equal(nrow(formatted), 4)
	expect_equal(ncol(formatted), min(5, ncol(emb)))
})

