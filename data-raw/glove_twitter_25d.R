devtools::load_all()

options(embeddings.model.path = "~/Documents/data/embeddings")
glove_twitter_25d <- load_embeddings("glove.twitter.27B.25d")
top_words <- trillion_word[1:12000]
glove_twitter_25d <- emb(glove_twitter_25d, names(top_words))

usethis::use_data(glove_twitter_25d, overwrite = TRUE)
