test_that("embeddings constructor works", {
  embeddings <- embeddings(data = 1:6, nrow = 2, ncol = 3, dimnames = list(c("token1", "token2")))

  expect_true(is.embeddings(embeddings))
  expect_equal(dim(embeddings), c(2, 3))
  expect_equal(rownames(embeddings), c("token1", "token2"))

  # Verify token_index
  token_index <- attr(embeddings, "token_index")
  expect_equal(ls(token_index), c("token1", "token2"))

  tokens <- c("token1", "token2", "token3")
  mat <- matrix(1:9, nrow = 3, dimnames = list(tokens, paste0("dim_",1:3)))
  emb <- embeddings(1:9, nrow = 3, dimnames = list(tokens))
  expect_equal(emb, as.embeddings(mat))
  expect_equal(as.matrix(emb), mat)
})

test_that("as.embeddings works with numeric matrix", {
  mat <- matrix(1:6, nrow = 2)
  rownames(mat) <- c("token1", "token2")
  colnames(mat) <- c("dim1", "dim2", "dim3")
  emb <- as.embeddings(mat)

  expect_s3_class(emb, "embeddings")
  expect_equal(dim(emb), dim(mat))
  expect_equal(rownames(emb), rownames(mat))
  expect_equal(colnames(emb), colnames(mat))
  expect_true(is.embeddings(emb))
})

test_that("as.embeddings error for non-numeric matrix", {
  mat <- matrix(c("a", "b", "c", "d"), nrow = 2)
  expect_error(as.embeddings(mat), "Input is not numeric")
})

test_that("as.embeddings works with numeric vector", {
  vec <- 1:5
  emb <- as.embeddings(vec)

  expect_s3_class(emb, "embeddings")
  expect_equal(dim(emb), c(1, length(vec)))
  expect_equal(rownames(emb), "doc_1")
})

test_that("as.embeddings.numeric error for array input", {
  arr <- array(1:8, dim = c(2, 2, 2))
  expect_error(as.embeddings(arr), "High dimensional arrays cannot be coerced to embeddings.")
})

test_that("as.embeddings works with data.frame", {
  df <- data.frame(token = c("happy", "sad"),
                   dim1 = c(1.0, 0.5),
                   dim2 = c(0.5, 1.0))
  emb <- as.embeddings(df, id_col = "token")

  expect_s3_class(emb, "embeddings")
  expect_equal(rownames(emb), c("happy", "sad"))
  expect_equal(colnames(emb), c("dim1", "dim2"))
  expect_equal(emb["happy", "dim1"], 1.0)
  expect_true(is.embeddings(emb))

  # Check token_index
  token_index <- attr(emb, "token_index")
  expect_equal(ls(token_index), c("happy", "sad"))

  expect_warning(emb <- as.embeddings(df[,2:3]), "unique row names not provided. Naming rows doc_1, doc_2, etc.")
  expect_s3_class(emb, "embeddings")
  expect_equal(colnames(emb), c("dim1", "dim2"))
  expect_true(is.embeddings(emb))
})

test_that("as.embeddings error for non-numeric columns in data.frame", {
  df <- data.frame(token = c("happy", "sad"),
                   dim1 = c(1.0, 0.5),
                   dim2 = c("a", "b"))
  expect_error(as.embeddings(df, id_col = "token"), "Input contains non-numeric columns other than id_col")
})

test_that("as.embeddings error for id_col not in data.frame", {
  df <- data.frame(dim1 = c(1.0, 0.5), dim2 = c(0.5, 1.0))
  expect_error(as.embeddings(df, id_col = "token"), "undefined columns selected")
})

test_that("as.embeddings keeps duplicates when rowname_repair = TRUE", {
  mat <- matrix(1:6, nrow = 3, dimnames = list(c("this", "that", "this")))
  emb <- as.embeddings(mat, rowname_repair = FALSE)
  expect_equal(rownames(emb), rownames(mat))
})

test_that("as.embeddings.data.frame keeps duplicates when rowname_repair = TRUE", {
  df <- data.frame(token = c("happy", "sad", "happy"),
                   dim1 = c(1.0, 0.5, 1.0),
                   dim2 = c(0.5, 1.0, 0.5))
  emb <- as.embeddings(df, id_col = "token", rowname_repair = FALSE)
  expect_equal(rownames(emb), df$token)
})

test_that("is.embeddings returns FALSE for non-embeddings objects", {
  mat <- matrix(1:6, nrow = 2)
  expect_false(is.embeddings(mat))
})

test_that("is_matrixlike works correctly", {
  mat <- matrix(1:6, nrow = 2)
  expect_true(is_matrixlike(mat))

  df <- data.frame(a = 1:3, b = 2:4)
  expect_true(is_matrixlike(df))

  non_numeric_df <- data.frame(a = 1:3, b = c("x", "y", "z"))
  expect_false(is_matrixlike(non_numeric_df))

  arr <- array(1:8, dim = c(2, 2, 2))
  expect_false(is_matrixlike(arr))

  v <- 1:5
  expect_false(is_matrixlike(v))

  l <- list(a = 1, b = 2)
  expect_false(is_matrixlike(l))
})

test_that("as.embeddings assigns default rownames and colnames if missing or non-unique", {
  mat <- matrix(1:6, nrow = 2)
  expect_warning(emb <- as.embeddings(mat), "unique row names not provided. Naming rows doc_1, doc_2, etc.")

  expect_equal(rownames(emb), c("doc_1", "doc_2"))
  expect_equal(colnames(emb), paste0("dim_", 1:3))

  mat <- matrix(1:6, nrow = 2)
  rownames(mat) <- c("same", "same")
  colnames(mat) <- c("same", "same", "same")
  expect_warning(emb <- as.embeddings(mat), "unique row names not provided. Naming rows doc_1, doc_2, etc.")

  expect_equal(rownames(emb), c("doc_1", "doc_2"))
  expect_equal(colnames(emb), paste0("dim_", 1:3))
})

test_that("as.embeddings works with Matrix objects", {
  skip_if_not_installed("Matrix")
  mat <- Matrix::Matrix(1:6, nrow = 2)
  expect_warning(emb <- as.embeddings(mat), "unique row names not provided. Naming rows doc_1, doc_2, etc.")

  expect_s3_class(emb, "embeddings")
  expect_true(is.matrix(emb))
})

test_that("as.embeddings errors with unacceptable input class", {
  x <- "not acceptable"
  expect_error(as.embeddings(x), "No method for coercing objects of class 'character' to embeddings.")
})

test_that("as.embeddings handles empty objects", {
  mat <- matrix(numeric(0), nrow = 0, ncol = 0)
  emb <- as.embeddings(mat)

  expect_s3_class(emb, "embeddings")
  expect_equal(dim(emb), c(0, 0))

  df <- data.frame(token = character(0), dim1 = numeric(0))
  emb <- as.embeddings(df, id_col = "token")

  expect_s3_class(emb, "embeddings")
  expect_equal(dim(emb), c(0, 1))
})

test_that("embeddings object creation builds correct token_index", {
  tokens <- c("tok1", "tok2", "tok3")
  emb <- embeddings(1:9, nrow = 3, dimnames = list(tokens))
  expect_true(is.embeddings(emb))

  # Check that the token_index is an environment
  token_index <- attr(emb, "token_index")
  expect_true(is.environment(token_index))

  # Ensure all tokens are in the token_index
  expect_equal(ls(token_index), tokens)

  # Check that the indices match the row positions
  indices <- sapply(tokens, function(tok) token_index[[tok]])
  expect_equal(as.numeric(indices), 1:3)
})

test_that("as.embeddings handles duplicated rownames with warning", {
  tokens <- c("token1", "token1", "token2")
  mat <- matrix(1:9, nrow = 3, dimnames = list(tokens))

  expect_warning(embeddings <- as.embeddings(mat), "unique row names not provided")

  # Check that new rownames are assigned
  expect_equal(rownames(embeddings), paste0("doc_", 1:3))

  # Verify token_index reflects new rownames
  token_index <- attr(embeddings, "token_index")
  expect_equal(sort(ls(token_index)), paste0("doc_", 1:3))
})

test_that("token_index_add updates the token index after adding tokens", {
  emb <- embeddings(1:6, nrow = 2, dimnames = list(c("token1", "token2")))

  # Add new tokens
  new_tokens <- c("token3", "token4")
  new_mat <- matrix(7:12, nrow = 2, dimnames = list(new_tokens))
  emb <- rbind(emb, new_mat)

  # Update token_index
  emb <- token_index_add(emb, new_tokens)

  # Verify updated token_index
  token_index <- attr(emb, "token_index")
  expect_equal(sort(ls(token_index)), c("token1", "token2", "token3", "token4"))
  expect_equal(token_index[["token3"]], 3)
  expect_equal(token_index[["token4"]], 4)
})

test_that("build_token_index builds the correct token index", {
  tokens <- c("tokenA", "tokenB")
  mat <- matrix(1:4, nrow = 2, dimnames = list(tokens))
  embeddings <- as.embeddings(mat)

  # Remove token_index and rebuild
  attr(embeddings, "token_index") <- NULL
  embeddings <- build_token_index(embeddings)

  # Verify token_index
  token_index <- attr(embeddings, "token_index")
  expect_equal(sort(ls(token_index)), tokens)
})

test_that("as.embeddings with rebuild_token_index = FALSE", {
  tokens <- c("tokenX", "tokenY")
  emb <- embeddings(1:4, nrow = 2, dimnames = list(tokens))
  attr(emb, "token_index")[["tokenY"]] <- 1
  emb <- as.embeddings(emb, rebuild_token_index = FALSE)

  # token_index should be NULL
  expect_equal(attr(emb, "token_index")[["tokenY"]], 1)

  # Manually rebuild token_index
  emb <- build_token_index(emb)
  expect_equal(ls(attr(emb, "token_index")), tokens)
})

test_that("Modifying rownames updates the token_index", {
  mat <- matrix(1:4, nrow = 2, dimnames = list(c("token1", "token2")))
  embeddings <- as.embeddings(mat)

  # Modify rownames
  rownames(embeddings) <- c("new_token1", "new_token2")

  # Verify token_index is updated
  token_index <- attr(embeddings, "token_index")
  expect_equal(ls(token_index), c("new_token1", "new_token2"))
  expect_equal(token_index[["new_token1"]], 1)
})

test_that("External modification of rownames invalidates token_index", {
  mat <- matrix(1:4, nrow = 2, dimnames = list(c("token1", "token2")))
  embeddings <- as.embeddings(mat)

  # Modify rownames externally
  attr(embeddings, "dimnames")[[1]] <- c("ext_token1", "ext_token2")

  # Token index should be rebuilt
  embeddings <- as.embeddings(embeddings, rebuild_token_index = TRUE)

  # Verify token_index
  token_index <- attr(embeddings, "token_index")
  expect_equal(ls(token_index), c("ext_token1", "ext_token2"))
})

test_that("Subsetting embeddings updates token_index", {
  mat <- matrix(1:9, nrow = 3, dimnames = list(c("token1", "token2", "token3")))
  embeddings <- as.embeddings(mat)

  # Subset embeddings
  embeddings_subset <- embeddings[c("token1", "token3"), ]

  # Verify token_index
  token_index <- attr(embeddings_subset, "token_index")
  expect_equal(ls(token_index), c("token1", "token3"))
  expect_equal(token_index[["token3"]], 2)
})

test_that("Subsetting with missing tokens results in error", {
  mat <- matrix(1:6, nrow = 2, dimnames = list(c("token1", "token2")))
  embeddings <- as.embeddings(mat)

  expect_error(embeddings_subset <- embeddings[c("token1", "tokenX"), ], "value for 'tokenX' not found")
})
