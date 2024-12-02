create_sample_embeddings <- function() {
	tokens <- c("word1", "word2", "word3")
	embeddings(c(0.1, 0.2, 0.3,
							 0.4, 0.5, 0.6,
							 0.7, 0.8, 0.9
							 ), nrow = 3, byrow = TRUE,
						 dimnames = list(tokens, paste0("dim", 1:3)))
}

test_that("sim_matrix works with embeddings object and default method", {
	embeddings_obj <- create_sample_embeddings()
	result <- sim_matrix(embeddings_obj)
	expect_s3_class(result, "dist")
	expect_equal(length(result), choose(nrow(embeddings_obj), 2))
})

test_that("sim_matrix works with embeddings object and cosine method", {
	embeddings_obj <- create_sample_embeddings()
	result <- sim_matrix(embeddings_obj, method = "cosine")
	expect_s3_class(result, "dist")
	expect_equal(length(result), choose(nrow(embeddings_obj), 2))
})

test_that("sim_matrix works with embeddings object and euclidean method", {
	embeddings_obj <- create_sample_embeddings()
	result <- sim_matrix(embeddings_obj, method = "euclidean")
	expect_s3_class(result, "dist")
	expect_equal(length(result), choose(nrow(embeddings_obj), 2))
})

test_that("sim_matrix works with embeddings object and minkowski method", {
	embeddings_obj <- create_sample_embeddings()
	result <- sim_matrix(embeddings_obj, method = "minkowski", p = 3)
	expect_s3_class(result, "dist")
	expect_equal(length(result), choose(nrow(embeddings_obj), 2))
})

test_that("sim_matrix works with embeddings object and dot_prod method", {
	embeddings_obj <- create_sample_embeddings()
	result <- sim_matrix(embeddings_obj, method = "dot_prod")
	expect_s3_class(result, "dist")
	expect_equal(length(result), choose(nrow(embeddings_obj), 2))
})

test_that("sim_matrix works with embeddings object and custom method", {
	embeddings_obj <- create_sample_embeddings()
	custom_method <- function(x, y) sum(abs(x - y))
	result <- sim_matrix(embeddings_obj, method = custom_method)
	expect_s3_class(result, "dist")
	expect_equal(length(result), choose(nrow(embeddings_obj), 2))
})

test_that("sim_matrix works with matrix input", {
	embeddings_obj <- create_sample_embeddings()
	data_matrix <- as.matrix(embeddings_obj)
	result <- sim_matrix(data_matrix)
	expect_s3_class(result, "dist")
	expect_equal(length(result), choose(nrow(data_matrix), 2))
})

test_that("sim_matrix works with data.frame input and tidyselect columns", {
	embeddings_obj <- create_sample_embeddings()
	data_df <- as.data.frame(embeddings_obj)
	data_df$token <- rownames(embeddings_obj)
	result <- sim_matrix(data_df, cols = starts_with("dim"))
	expect_s3_class(result, "dist")
	expect_equal(length(result), choose(nrow(data_df), 2))
})

test_that("sim_matrix returns tidy output when tidy_output = TRUE", {
	embeddings_obj <- create_sample_embeddings()
	result <- sim_matrix(embeddings_obj, tidy_output = TRUE)
	expect_s3_class(result, "tbl_df")
	expect_equal(ncol(result), 3)
	expect_equal(nrow(result), choose(nrow(embeddings_obj), 2))
	expect_equal(names(result), c("doc_id_1", "doc_id_2", "cosine"))
})

test_that("sim_matrix returns correct values for cosine similarity", {
	embeddings_obj <- create_sample_embeddings()
	result <- sim_matrix(embeddings_obj, method = "cosine")
	manual_result <- sim_matrix(embeddings_obj, method = cos_sim)
	expect_equal(as.matrix(result), as.matrix(manual_result), tolerance = 1e-6)
})

test_that("sim_matrix handles single-row input", {
	embeddings_obj <- create_sample_embeddings()[1, , drop = FALSE]
	result <- sim_matrix(embeddings_obj)
	expect_s3_class(result, "dist")
	expect_equal(length(result), 0)
})

test_that("sim_matrix handles non-numeric data", {
	data_df <- data.frame(
		token = c("word1", "word2"),
		dim1 = c("a", "b"),
		dim2 = c("c", "d")
	)
	expect_error(sim_matrix(data_df, cols = starts_with("dim")), "Selected columns must be numeric.")
})

test_that("sim_matrix handles unknown method", {
	embeddings_obj <- create_sample_embeddings()
	expect_error(sim_matrix(embeddings_obj, method = "unknown_method"), "Unknown method")
})

test_that("sim_matrix handles additional parameters for methods", {
	embeddings_obj <- create_sample_embeddings()
	result <- sim_matrix(embeddings_obj, method = "minkowski", p = 1)
	expect_s3_class(result, "dist")
})

test_that("sim_matrix handles missing values in embeddings", {
	embeddings_obj <- create_sample_embeddings()
	embeddings_obj[1, 1] <- NA
	result <- sim_matrix(embeddings_obj)
	expect_s3_class(result, "dist")
})

test_that("sim_matrix with tidy_output = TRUE returns correct column names", {
	embeddings_obj <- create_sample_embeddings()
	result <- sim_matrix(embeddings_obj, tidy_output = TRUE)
	expect_equal(names(result), c("doc_id_1", "doc_id_2", "cosine"))
})

test_that("sim_matrix with custom method and tidy_output = TRUE", {
	embeddings_obj <- create_sample_embeddings()
	custom_method <- function(x, y) sum(abs(x - y))
	result <- sim_matrix(embeddings_obj, method = custom_method, tidy_output = TRUE)
	expect_s3_class(result, "tbl_df")
	expect_equal(ncol(result), 3)
	expect_equal(nrow(result), choose(nrow(embeddings_obj), 2))
	expect_equal(names(result), c("doc_id_1", "doc_id_2", "cosine"))
})

test_that("sim_matrix with data.frame input and tidyselect columns", {
	embeddings_obj <- create_sample_embeddings()
	data_df <- as_tibble(embeddings_obj, rownames = "token")
	result <- sim_matrix(data_df, cols = starts_with("dim"), tidy_output = TRUE)
	expect_s3_class(result, "tbl_df")
	expect_equal(ncol(result), 3)
	expect_equal(nrow(result), choose(nrow(data_df), 2))
})

test_that("sim_matrix with data.frame input and incorrect columns", {
	data_df <- data.frame(
		token = c("word1", "word2"),
		feature1 = c(0.1, 0.2),
		feature2 = c(0.3, 0.4)
	)
	expect_error(sim_matrix(data_df, cols = starts_with("dim")), "Selected columns must be numeric.")
})

test_that("sim_matrix with embeddings object and anchored method", {
	embeddings_obj <- create_sample_embeddings()
	expect_error(sim_matrix(embeddings_obj, method = "anchored"), "Unknown method")
})

test_that("sim_matrix handles large datasets efficiently", {
	skip_on_cran()
	# Create a larger embeddings object
	set.seed(123)
	tokens <- paste0("word", 1:100)
	data <- matrix(rnorm(100 * 50), nrow = 100, dimnames = list(tokens, paste0("dim", 1:50)))
	embeddings_obj <- as.embeddings(data)
	# Measure execution time
	start_time <- Sys.time()
	result <- sim_matrix(embeddings_obj, method = "cosine")
	end_time <- Sys.time()
	expect_true(difftime(end_time, start_time, units = "secs") < 5)
})

test_that("sim_matrix with identical rows returns expected results", {
	embeddings_obj <- create_sample_embeddings()
	embeddings_obj[2, ] <- embeddings_obj[1, ]
	result <- sim_matrix(embeddings_obj, method = "cosine", tidy_output = TRUE)
	identical_cosine <- result$cosine[which(result$doc_id_1 == "word1" & result$doc_id_2 == "word2")]
	expect_equal(identical_cosine, 1)
})
