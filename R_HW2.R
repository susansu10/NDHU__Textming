#install.packages('reshape2', depend=TRUE)
library(dplyr)
library(tidytext)
library(stringr)
library(tidyr)
library(gutenbergr)
titles <- c("The Adventures of Tom Sawyer", "Little Women",
            "Men of Invention and Industry", "Sense and Sensibility")
books <- gutenberg_works(title %in% titles) %>%
  gutenberg_download(meta_fields = "title")
books

by_chapter <- books %>%
  group_by(title) %>%
  mutate(chapter = cumsum(str_detect(text, regex("^chapter ", ignore_case = TRUE)))) %>%
  ungroup() %>%
  filter(chapter > 0)

by_chapter_word <- by_chapter %>%
  unite(title_chapter, title, chapter) %>%
  unnest_tokens(word, text)

word_counts <- by_chapter_word %>%
  anti_join(stop_words) %>%
  count(title_chapter, word, sort = TRUE)
word_counts

chapters_dtm <- word_counts %>%
  cast_dtm(title_chapter, word, n)

chapters_dtm

library(topicmodels)
chapters_lda <- LDA(chapters_dtm, k = 4, control = list(seed = 1234))
chapters_lda

chapters_lda_td <- tidy(chapters_lda)
chapters_lda_td

top_terms <- chapters_lda_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms

library(ggplot2)
theme_set(theme_bw())

top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(term, beta)) +
  geom_bar(stat = "identity") +
  scale_x_reordered() +
  facet_wrap(~ topic, scales = "free_x")

chapters_lda_gamma <- tidy(chapters_lda, matrix = "gamma")
chapters_lda_gamma

chapters_lda_gamma <- chapters_lda_gamma %>%
  separate(document, c("title", "chapter"), sep = "_", convert = TRUE)
chapters_lda_gamma

ggplot(chapters_lda_gamma, aes(gamma, fill = factor(topic))) +
  geom_histogram() +
  facet_wrap(~ title, nrow = 2)

chapter_classifications <- chapters_lda_gamma %>%
  group_by(title, chapter) %>%
  top_n(1, gamma) %>%
  ungroup() %>%
  arrange(gamma)

chapter_classifications

book_topics <- chapter_classifications %>%
  count(title, topic) %>%
  group_by(topic) %>%
  top_n(1, n) %>%
  ungroup() %>%
  transmute(consensus = title, topic)

book_topics

chapter_classifications %>%
  inner_join(book_topics, by = "topic") %>%
  count(title, consensus)