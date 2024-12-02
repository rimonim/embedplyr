test_that("make_embedding_weights handles named vector input", {
	embeddings <- embeddings(runif(20), nrow = 4, dimnames = list(c("happy", "joy", "smile", "enjoy"), paste0("dim_", 1:5)))
	custom_weights <- c(happy = 0.5, joy = 0.3, smile = 0.2)
	expect_warning(result <- make_embedding_weights(rownames(embeddings), custom_weights),
								 "Replacing 1 unspecified weights with the minimum value in w")
	expect_named(result, rownames(embeddings))
	expect_equal(result[["happy"]], 0.5)
	expect_equal(result[["joy"]], 0.3)
	expect_equal(result[["smile"]], 0.2)
	expect_equal(result[["enjoy"]], min(custom_weights, na.rm = TRUE))
})

test_that("make_embedding_weights handles 'trillion_word'", {
	embeddings <- embeddings(runif(10), nrow = 2, dimnames = list(c("happy", "unknown_word"), paste0("dim_", 1:5)))
	expect_warning(result <- make_embedding_weights(rownames(embeddings), "trillion_word"),
								 "Replacing 1 unspecified weights with the minimum value in w")
	expect_named(result, rownames(embeddings))
	expect_equal(result["happy"], trillion_word["happy"])
	expect_equal(result[["unknown_word"]], min(trillion_word))
})

test_that("make_embedding_weights handles 'trillion_word_sif'", {
	embeddings <- embeddings(runif(15), nrow = 3, dimnames = list(c("happy", "unknown_word", "another_unknown"), paste0("dim_", 1:5)))
	expect_warning(result <- make_embedding_weights(rownames(embeddings), "trillion_word_sif"),
								 "Replacing 2 unspecified weights with the minimum value in w")
	expect_named(result, rownames(embeddings))
	expect_true(all(result >= 0 & result <= 1)) # SIF weights are normalized
	expect_equal(result[["unknown_word"]], (0.005*1024908267229)/((0.005*1024908267229) + min(trillion_word)))
})

test_that("average_embedding calculates mean embeddings correctly", {
	embeddings <- embeddings(runif(20), nrow = 4, dimnames = list(c("happy", "joy", "smile", "enjoy"), paste0("dim_", 1:5)))
	result <- average_embedding(embeddings, method = "mean")
	expect_equal(length(result), ncol(embeddings))
	expect_named(result, colnames(embeddings))
})

test_that("average_embedding calculates weighted mean embeddings correctly", {
	embeddings <- embeddings(runif(20), nrow = 4, dimnames = list(c("happy", "joy", "smile", "enjoy"), paste0("dim_", 1:5)))
	weights <- c(happy = 0.5, joy = 0.3, smile = 0.2)
	expect_warning(result <- average_embedding(embeddings, w = weights, method = "mean"),
								 "Replacing 1 unspecified weights with the minimum value in w")
	expect_equal(length(result), ncol(embeddings))
	expect_named(result, colnames(embeddings))
})

test_that("average_embedding calculates sum embeddings correctly", {
	embeddings <- embeddings(runif(20), nrow = 4, dimnames = list(c("happy", "joy", "smile", "enjoy"), paste0("dim_", 1:5)))
	result <- average_embedding(embeddings, method = "sum")
	expect_equal(length(result), ncol(embeddings))
	expect_named(result, colnames(embeddings))
})

test_that("average_embedding calculates weighted sum embeddings correctly", {
	embeddings <- embeddings(runif(15), nrow = 3, dimnames = list(c("happy", "joy", "smile"), paste0("dim_", 1:5)))
	weights <- c(happy = 0.5, joy = 0.3, smile = 0.2)
	result <- average_embedding(embeddings, w = weights, method = "sum")
	expect_equal(length(result), ncol(embeddings))
	expect_named(result, colnames(embeddings))
})

test_that("average_embedding calculates median embeddings correctly", {
	embeddings <- embeddings(runif(20), nrow = 4, dimnames = list(c("happy", "joy", "smile", "enjoy"), paste0("dim_", 1:5)))
	result <- average_embedding(embeddings, method = "median")
	expect_equal(length(result), ncol(embeddings))
	expect_named(result, colnames(embeddings))
})

test_that("average_embedding calculates weighted median embeddings correctly", {
	embeddings <- embeddings(runif(15), nrow = 3, dimnames = list(c("happy", "joy", "smile"), paste0("dim_", 1:5)))
	weights <- c(happy = 0.5, joy = 0.3, smile = 0.2)
	result <- average_embedding(embeddings, w = weights, method = "median")
	expect_equal(length(result), ncol(embeddings))
	expect_named(result, colnames(embeddings))
})

test_that("average_embedding handles lists of embeddings", {
	embeddings_list <- list(embeddings(runif(20), nrow = 4, dimnames = list(c("happy", "joy", "smile", "enjoy"), paste0("dim_", 1:5))), embeddings(runif(20), nrow = 4, dimnames = list(c("happy", "joy", "smile", "enjoy"), paste0("dim_", 1:5))))
	result <- average_embedding(embeddings_list)
	expect_true(is.list(result))
	expect_equal(length(result), length(embeddings_list))
	expect_equal(length(result[[1]]), ncol(embeddings_list[[1]]))
})

test_that("average_embedding throws error for unsupported methods", {
	embeddings <- embeddings(runif(20), nrow = 4, dimnames = list(c("happy", "joy", "smile", "enjoy"), paste0("dim_", 1:5)))
	expect_error(average_embedding(embeddings, method = "unsupported"),
							 "'unsupported' is not a recognized averaging method")
})

test_that("average_embedding handles missing weights gracefully", {
	embeddings <- embeddings(runif(20), nrow = 4, dimnames = list(c("happy", "joy", "smile", "enjoy"), paste0("dim_", 1:5)))
	expect_warning(result <- average_embedding(embeddings, w = c(happy = 1), method = "mean"),
								 "Replacing 3 unspecified weights with the minimum value in w")
	expect_equal(length(result), ncol(embeddings))
})

test_that("average_embedding handles NA values in embeddings", {
	embeddings <- embeddings(runif(20), nrow = 4, dimnames = list(c("happy", "joy", "smile", "enjoy"), paste0("dim_", 1:5)))
	embeddings[1, 1] <- NA
	result <- average_embedding(embeddings, method = "mean", na.rm = TRUE)
	expect_equal(length(result), ncol(embeddings))
	expect_false(any(is.na(result)))
})

test_that("average_embedding handles empty embeddings", {
	embeddings <- embeddings(matrix(numeric(0), nrow = 0, ncol = 5,
																	dimnames = list(character(0), paste0("dim_", 1:5))))
	result <- average_embedding(embeddings, method = "mean")
	expect_equal(length(result), ncol(embeddings))
	expect_true(all(is.na(result)))
})

test_that("average_embedding works with Gmedian::Weiszfeld for weighted median", {
	embeddings <- embeddings(runif(15), nrow = 3, dimnames = list(c("happy", "joy", "smile"), paste0("dim_", 1:5)))
	weights <- c(happy = 0.5, joy = 0.3, smile = 0.2)
	result <- average_embedding(embeddings, w = weights, method = "median")
	expect_equal(length(result), ncol(embeddings))
	expect_named(result, colnames(embeddings))
})
