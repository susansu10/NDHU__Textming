#install.packages('stopwords', depend=TRUE)
require(dplyr)
require(tidytext)
require(jiebaR)
require(gutenbergr)
library(stringr)
library(wordcloud2)
library(ggplot2)
library(tidyr)
library(scales)
library(tibble)

rm(list=ls())

#Read in 「唐詩3百首」

setwd("C:/Users/user/Desktop")
tang = as.tibble(readLines("tang.txt",encoding="UTF-8"))
colnames(tang) <- c("text")
tang

#Convert the document into data-frame format with 3 columns: 「詩名」，「作者」，「詩文」。

by_name <- tang %>%
 filter(str_detect(text,pattern="(^詩名)")) %>%
 mutate(name = str_extract(text, pattern = "(?<=詩名:).*"))  # extract everything after 詩名:
 
by_author <- tang %>%
 filter(str_detect(text,pattern="作者")) %>%
 mutate(author = str_extract(text, pattern = "(?<=作者:).*")) ## extract everything after 作者:
 
by_poem <- tang %>%
  mutate( text1 = str_replace(text, pattern="\\(...\\)", "") ) %>%  # 去除()中3 個字
 filter(str_detect(text1,pattern="詩文")) %>%
mutate(poem = str_extract(text1, pattern = "(?<=詩文:).*")) 

tang300 <- cbind(by_name$text, by_author$text,by_poem$text) # extract everything after 詩文: or (押＊韻)
colnames(tang300) <- c("詩名","作者","詩文")
tang300 <- as.tibble(tang300)
tang300

#Perform word segmentation (斷詞)。

jieba_tokenizer = worker()
segment(tang300$詩文, jieba_tokenizer)

#Remove stop\_words.
#用百度停用詞辭庫
#install.packages('stopwords', depend=TRUE)
library(stopwords)
ch_stop <- stopwords("zh", source = "misc")
tokens <- segment(tang300$詩文, jieba_tokenizer)
res  <- filter_segment(tokens, ch_stop)
tokens <- res[nchar(res)>1]
tokens


#Count number of poem by each author. Plot the results.
tang300
table(tang300$作者)

#Count words in 「詩名」 and 「詩文」 respectively.
#「詩文」
jieba_tokenizer = worker()
poem_word <- segment(tang300$詩文, jieba_tokenizer)
poem_w <- filter_segment(poem_word, ch_stop)
poem_word <- res[nchar(poem_w)>1]
f_poem <- freq(poem_word)
f_poem
table(segment(poem_word, jieba_tokenizer))

#「詩名」
jieba_tokenizer = worker()
name_word <- segment(tang300$詩名, jieba_tokenizer)
name_w <- filter_segment(name_word, ch_stop)
name_word <- res[nchar(name_w)>1]
f_name <- freq(name_word)
f_name
table(segment(name_word, jieba_tokenizer))

#Plot word cloud for 「詩名」 and 「詩文」 respectively
#「詩文」
plot_f_poem <- f_poem[1:150,]
wordcloud2(plot_f_poem, size = 0.8, shape = "star")

#「詩名」
plot_f_name <- f_name[1:100,]
wordcloud2(plot_f_name, size = 0.8, shape = "star")

letterCloud(f_name, word = "LOVE", size = 0.7)



