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
  expect_error(as.embeddings(arr), "array object cannot be coerced to embeddings.")
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

  emb <- as.embeddings(df[,2:3])
  expect_s3_class(emb, "embeddings")
  expect_equal(colnames(emb), c("dim1", "dim2"))
  expect_true(is.embeddings(emb))
})

test_that("as.embeddings error for non-numeric columns in data.frame", {
  df <- data.frame(token = c("happy", "sad"),
                   dim1 = c(1.0, 0.5),
                   dim2 = c("a", "b"))
  expect_error(as.embeddings(df), "Input contains non-numeric columns other than id_col")
})

test_that("as.embeddings error for id_col not in data.frame", {
  df <- data.frame(dim1 = c(1.0, 0.5), dim2 = c(0.5, 1.0))
  expect_error(as.embeddings(df, id_col = "token"), "Can't find column `token` in `.data`.")
})

test_that("is.embeddings returns FALSE for non-embeddings objects", {
  mat <- matrix(1:6, nrow = 2)
  expect_false(is.embeddings(mat))
})

test_that("as.matrix.embeddings removes 'embeddings' class", {
  emb <- as.embeddings(matrix(1:6, nrow = 2))
  mat2 <- as.matrix(emb)

  expect_false(inherits(mat2, "embeddings"))
  expect_true(is.matrix(mat2))
})

test_that("Subsetting embeddings retains embeddings class when multiple rows remain", {
  mat <- matrix(1:9, nrow = 3)
  emb <- as.embeddings(mat)
  emb_sub <- emb[1:2, ]

  expect_s3_class(emb_sub, "embeddings")
  expect_equal(dim(emb_sub), c(2, 3))
})

test_that("Subsetting embeddings returns numeric vector when appropriate", {
  mat <- matrix(1:9, nrow = 3)
  emb <- as.embeddings(mat)
  emb_sub <- emb[1, 1]

  expect_false(is.embeddings(emb_sub))
  expect_equal(class(emb_sub), "integer")
})

test_that("Setting rownames and colnames on embeddings", {
  mat <- matrix(1:6, nrow = 2)
  emb <- as.embeddings(mat)
  rownames(emb) <- c("token1", "token2")
  colnames(emb) <- c("dim1", "dim2", "dim3")

  expect_equal(rownames(emb), c("token1", "token2"))
  expect_equal(colnames(emb), c("dim1", "dim2", "dim3"))
  expect_s3_class(emb, "embeddings")
})

test_that("as_tibble.embeddings converts embeddings to tibble", {
  mat <- matrix(1:6, nrow = 2)
  rownames(mat) <- c("token1", "token2")
  emb <- as.embeddings(mat)
  tbl <- tibble::as_tibble(emb, rownames = "token")

  expect_s3_class(tbl, "tbl_df")
  expect_equal(tbl$token, c("token1", "token2"))
  expect_equal(tbl$dim_1, c(1, 2))
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

test_that("as.embeddings assigns default rownames and colnames if missing", {
  mat <- matrix(1:6, nrow = 2)
  emb <- as.embeddings(mat)

  expect_equal(rownames(emb), c("doc_1", "doc_2"))
  expect_equal(colnames(emb), paste0("dim_", 1:3))
})

test_that("as.embeddings works with Matrix objects", {
  skip_if_not_installed("Matrix")
  mat <- Matrix::Matrix(1:6, nrow = 2)
  emb <- as.embeddings(mat)

  expect_s3_class(emb, "embeddings")
  expect_true(is.matrix(emb))
})

test_that("as.embeddings errors with unacceptable input class", {
  x <- "not acceptable"
  expect_error(as.embeddings(x), "character object cannot be coerced to embeddings.")
})

test_that("Subsetting embeddings to single row/column with drop = FALSE retains embeddings class", {
  mat <- matrix(1:9, nrow = 3)
  rownames(mat) <- c("a", "b", "c")
  emb <- as.embeddings(mat)
  emb_sub1 <- emb[1, , drop = FALSE]

  expect_s3_class(emb_sub1, "embeddings")
  expect_equal(dim(emb_sub1), c(1, 3))
  expect_equal(rownames(emb_sub1), "a")

  emb_sub2 <- emb[, 1, drop = FALSE]
  expect_s3_class(emb_sub2, "embeddings")
  expect_equal(dim(emb_sub2), c(3, 1))
  expect_equal(colnames(emb_sub2), "dim_1")
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
