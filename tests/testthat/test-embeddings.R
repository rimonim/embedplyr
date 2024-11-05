test_that("Coercion to embeddings and checking for matrix", {
  expect_true(is.embeddings(as.embeddings(matrix(1:10, nrow = 2))))
})

test_that("Coercion to embeddings and checking for dataframe", {
    expect_true(is.embeddings(as.embeddings(data.frame(token = c("A", "B"), x = 1:2, y = 3:4))))
})

test_that("User input token_col", {
    expect_equal(
        rownames(
            as.embeddings(data.frame(letter = c("A", "B"), x = 1:2, y = 3:4), id_col = "letter")
            ),
        c("A", "B")
        )
})
