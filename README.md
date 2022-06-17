---
title: HW2  
tags: 文字探勘 
---
> 課程：文字探勘_HW2 - 林金龍
> 學號：410821204
> 姓名：杜昉紜
> 系級：資工三


[TOC]

# 作業描述
> 本次作業實作將所有實作紀錄、程式碼、圖檔都記錄在`hackmd`上，網址為：
> https://hackmd.io/@410821204/rJJoDiOFc


This exercise asks you to perform topic modeling for 4 books:
1. The Adventures of Tom Sawyer, by Mark Twain
2. Little Women by Louisa May Alcott
3. The Time Machine by H. G. Wells
4. Sense and Sensibility by Jane Austen

You shall need the following R packages: dplyr, gutenbergr, tidytext, stringr, topicmodels, ggplot2 and find Julia Silge and David Robinson R Project useful:
https://juliasilge.github.io/tidytext/articles/topic_modeling.html

In specific, do the follows:
**1. Download these four books from Project Gutenbergr.
2. Use tidytext’s unnest tokensto divide these four books into chapters and treat them as documents
3. Count number of words in each document.
4. Convert the document into a document-term-matrix.
5. Use the topicmodels package to create a four topic LDA model.
6. Find the top 5 terms within each topic.
7. Visualize the word count for each topic.
8. Find out which topics are associated with each document and check if we could put the chapters back together in the correct books.**

If any one of the book above does not have "Chapter", you could either (1) find a way
to perform the job anyway; or (2) substitute another one with "Chapter" of your own
choice; or (3) manually add "Chapter" to the book.

---
# 程式碼說明
## 1. Download these four books from `Project Gutenbergr`
#### 首先我們利用程式碼到 https://www.gutenberg.org/ 去下載我們要的四本書
> #### 由於老師要求下載的四本書，有一本書我無法做處理，所以將書替換成了`Men of Invention and Industry`

> #### 另外再此均不列出會用到的`library` (程式套件)，後面全部程式碼展現才會顯示到。
#### 程式碼如下：
```r=
titles <- c("The Adventures of Tom Sawyer", "Little Women",
            "Men of Invention and Industry", "Sense and Sensibility")
books <- gutenberg_works(title %in% titles) %>%
  gutenberg_download(meta_fields = "title")
books
```
#### 執行結果如下：
![](https://i.imgur.com/GaCn0DB.png)

## 2. Use tidytext’s `unnest` tokens to divide these four books into chapters and treat them as documents
## Count number of words in each document.
> 這裡老師的2、3步驟都會說明到，所以寫在一起。
#### 1. 接下來進行資料的先前處理，我們將它們分成章節
##### 程式碼如下：
```r=
by_chapter <- books %>%
  group_by(title) %>%
  mutate(chapter = cumsum(str_detect(text, regex("^chapter ", ignore_case = TRUE)))) %>%
  ungroup() %>%
  filter(chapter > 0)
```

#### 2. 使用`tidytext` `unnest_tokens`將它們分成單詞

##### 程式碼如下：
```r=
by_chapter_word <- by_chapter %>%
  unite(title_chapter, title, chapter) %>%
  unnest_tokens(word, text)

by_chapter_word <- by_chapter %>%
  unite(title_chapter, title, chapter) %>%
  unnest_tokens(word, text)
```

#### 3. 刪除停用詞`stop_words`，並計算每個章節單字量，將每一章視為一個單獨的`documents`，每個章節的名稱都類似於 `Men of Invention and Industry_21`。. 
##### 程式碼如下：
```r=
word_counts <- by_chapter_word %>%
  anti_join(stop_words) %>%
  count(title_chapter, word, sort = TRUE)
word_counts
```
##### 執行結果如下：
我們可以看到在紅框中，他會顯示單一章節裡哪個單字量出現最多次。

例如：
在`Men of Invention and Industry`中出現最多次的單字是`bianconi`，且單字量為`102`。
> 可以注意到的是，因為 ==sort = True==，所以他會==從大排到小==
![](https://i.imgur.com/9fawPx4.png)

## 3. Convert the document into a document-term-matrix.
> 因為在之後用`LDA`的時候會用到`topicmodels`的套件，但`topicmodels`需要的是`document-term-matrix`，因此需要把目前`tidy form`轉換成`document-term-matrix`
##### 程式碼如下：
```r=
chapters_dtm <- word_counts %>%
  cast_dtm(title_chapter, word, n)

chapters_dtm
```
##### 執行結果如下：
![](https://i.imgur.com/UplF8b8.png)

## 4. Use the topicmodels package to create a four topic LDA model.
> 現在可以用`topicmodels`的套件去構建`LDA model`
##### 程式碼如下：
```r=
chapters_lda <- LDA(chapters_dtm, k = 4, control = list(seed = 1234))
chapters_lda
```
##### 執行結果如下：
> 我們知道了有4個主題，因為有4本書
![](https://i.imgur.com/aLWsV6e.png)


## 5. Find the top 5 terms within each topic.
##### 程式碼如下：
```r=
chapters_lda_td <- tidy(chapters_lda)
chapters_lda_td
```
##### 執行結果如下：
> beta 是從該主題生成該術語的概率。
![](https://i.imgur.com/z5v0pHc.png)



使用 `dplyr` `top_n`來查找每個主題中的前 5 個術語：
##### 程式碼如下：
```r=
top_terms <- chapters_lda_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms
```
##### 執行結果如下：
![](https://i.imgur.com/dv6XUsO.png)


## 6. Visualize the word count for each topic.
> 把模型可視化
##### 程式碼如下：
```r=
theme_set(theme_bw())

top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(term, beta)) +
  geom_bar(stat = "identity") +
  scale_x_reordered() +
  facet_wrap(~ topic, scales = "free_x")
```
##### 執行結果如下：
![](https://i.imgur.com/Ka8FmWd.png)


## 7. Find out which topics are associated with each document and check if we could put the chapters back together in the correct books.

#### 1. 設置matrix = "gamma"返回一個經過整理的版本，每行一個文檔一個主題。
##### 程式碼如下：
```r=
chapters_lda_gamma <- tidy(chapters_lda, matrix = "gamma")
chapters_lda_gamma
```
##### 執行結果如下：
![](https://i.imgur.com/TR2c9tK.png)

#### 2. 將文檔名稱重新分離為標題和章節
##### 程式碼如下：
```r=
chapters_lda_gamma <- chapters_lda_gamma %>%
  separate(document, c("title", "chapter"), sep = "_", convert = TRUE)
chapters_lda_gamma
```
##### 執行結果如下：
![](https://i.imgur.com/BAJQbqb.png)

#### 3. 檢查每個章節的正確率
##### 程式碼如下：
```r=
ggplot(chapters_lda_gamma, aes(gamma, fill = factor(topic))) +
  geom_histogram() +
  facet_wrap(~ title, nrow = 2)
```
##### 執行結果如下：
> 發現`Sense and Sensibility`相較於其他書，較多章節被唯一地標識為一個主題
![](https://i.imgur.com/VGLxrCd.png)

#### 4. 通過找到每個共識書來確定之前的可視化是正確的
##### 程式碼如下：
```r=
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
```
##### 執行結果如下：
![](https://i.imgur.com/ZS3PMNB.png)

![](https://i.imgur.com/k7HJmVR.png)


#### 5. 看看哪些章節被誤認了
##### 程式碼如下：
```r=
chapter_classifications %>%
  inner_join(book_topics, by = "topic") %>%
  count(title, consensus)
```
##### 執行結果如下：
> 看到`The Adventures of Tom Sawyer`中只有幾章被錯誤分類。對於無監督聚類來說還不錯！
![](https://i.imgur.com/6z6Nlw1.png)

---
# 全部程式碼
```r=
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
```
![](https://i.imgur.com/yo5HHar.png)