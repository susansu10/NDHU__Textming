---
title: HW3  
tags: 文字探勘
---
> 課程：文字探勘_HW3 - 林金龍
> 學號：410821204
> 姓名：杜昉紜
> 系級：資工三


[TOC]

# 作業描述
> 本次作業實作將所有實作紀錄、程式碼、圖檔都記錄在`hackmd`上，網址為：
> https://hackmd.io/@410821204/Bym45oOF9


This exercise asks you to plot the wordcloud for 「唐詩3百首」。

You shall need the following R packages: dplyr, tidytext, jiebaR, stringr, wordcloud2, ggplot2, tidyr, scales and find 「結合 jiebar 與 Tidy text 套件, 處理中文文字資料」 useful:
http://rstudio-pubs-static.s3.amazonaws.com/480176_a93ec4f372774fdb85c1eda7b5b99706.html

In specific, do the follows:
**1. Read in 「唐詩3百首」。
2. Convert the document into data-frame format with 3 columns: 「詩名」, 「作者」, 「詩文」。
3. Perform word segmentation (斷詞)。
4. Remove stop_words.
5. Count number of poem by each author. Plot the results.
6. Count words in 「詩名」 and 「詩文」 respectively.
7. Plot word cloud for 「詩名」 and 「詩文」 respectively**

## 1. Read in 「唐詩3百首」
### 程式碼如下：
> 我把`唐詩三百首.txt`放在桌面上，所以要設`R`目前工作目錄
```r=
rm(list=ls())

#Read in 「唐詩3百首」

setwd("C:/Users/user/Desktop")
tang = as.tibble(readLines("tang.txt",encoding="UTF-8"))
colnames(tang) <- c("text")
tang
```
### 執行結果如下：
> 可以看到他成功抓到了我們的`唐詩三百首`
![](https://i.imgur.com/9R8I3oX.png)


## 2. Convert the document into data-frame format with 3 columns: 「詩名」, 「作者」, 「詩文」
### 程式碼如下：
```r=
#Convert the document into data-frame format with 3 columns: 
#「詩名」，「作者」，「詩文」。

by_name <- tang %>%
 filter(str_detect(text,pattern="(^詩名)")) %>%
 mutate(name = str_extract(text, pattern = "(?<=詩名:).*"))  
# extract everything after 詩名:
 
by_author <- tang %>%
 filter(str_detect(text,pattern="作者")) %>%
 mutate(author = str_extract(text, pattern = "(?<=作者:).*")) 
## extract everything after 作者:
 
by_poem <- tang %>%
  mutate( text1 = str_replace(text, pattern="\\(...\\)", "") ) %>%  
# 去除()中3 個字
 filter(str_detect(text1,pattern="詩文")) %>%
mutate(poem = str_extract(text1, pattern = "(?<=詩文:).*")) 

tang300 <- cbind(by_name$text, by_author$text,by_poem$text) 
# extract everything after 詩文: or (押＊韻)
colnames(tang300) <- c("詩名","作者","詩文")
tang300 <- as.tibble(tang300)
tang300
```
### 執行結果如下：
> 我們可以看到他把`唐詩三百首`依照`詩名` `作者` `詩文`做區分
![](https://i.imgur.com/XOw2x6Y.png)

## 3. Perform word segmentation (斷詞)
### 程式碼如下：
```r=
#Perform word segmentation (斷詞)。

jieba_tokenizer = worker()
segment(tang300$詩文, jieba_tokenizer)
```
### 執行結果如下：
> 可以看到詩文都有斷詞了
![](https://i.imgur.com/wOFI7ON.png)


## 4. Remove stop_words
### 程式碼如下：
> 這裡要注意，如果`source = "misc"`不能辨識就要重新安裝`stopwords`
```r=
#Remove stop\_words.
#用百度停用詞辭庫
#install.packages('stopwords', depend=TRUE)
library(stopwords)
ch_stop <- stopwords("zh", source = "misc")
tokens <- segment(tang300$詩文, jieba_tokenizer)
res  <- filter_segment(tokens, ch_stop)
tokens <- res[nchar(res)>1]
tokens
```
### 執行結果如下：
> 我們可以看到第一列`逢`有被刪掉，代表成功執行`Remove stop_words`
![](https://i.imgur.com/UED27ky.png)


## 5. Count number of poem by each author. Plot the results.
### 程式碼如下：
```r=
#Count number of poem by each author. Plot the results.
tang300
table(tang300$作者)
```
### 執行結果如下：
> 我們可以看到，很明顯`作者元結`有兩首詩，而在底下有算出來。
![](https://i.imgur.com/s6DaUlb.png)



## 6. Count words in 「詩名」 and 「詩文」 respectively
### 程式碼如下：
> 先進行斷詞，再來是`Remove stop_words`，最後才是`Count words`
```r=
#「詩名」
jieba_tokenizer = worker()
name_word <- segment(tang300$詩名, jieba_tokenizer)
name_w <- filter_segment(name_word, ch_stop)
name_word <- res[nchar(name_w)>1]
f_name <- freq(name_word)
f_name
table(segment(name_word, jieba_tokenizer))
```
### 執行結果如下：
![](https://i.imgur.com/SoN09Kj.png)

![](https://i.imgur.com/dtWTnZe.png)

### 程式碼如下：
> 先進行斷詞，再來是`Remove stop_words`，最後才是`Count words`
```r=
#「詩文」
jieba_tokenizer = worker()
poem_word <- segment(tang300$詩文, jieba_tokenizer)
poem_w <- filter_segment(poem_word, ch_stop)
poem_word <- res[nchar(poem_w)>1]
f_poem <- freq(poem_word)
f_poem
table(segment(poem_word, jieba_tokenizer))
```
### 執行結果如下：
![](https://i.imgur.com/L1JnH6u.png)

![](https://i.imgur.com/lAPfxMJ.png)


## 7. Plot word cloud for 「詩名」 and 「詩文」 respectively
### 程式碼如下：
> 這次印兩個星星的文字雲，它會自動在電腦裡產生`html`檔
```r=
#Plot word cloud for 「詩名」 and 「詩文」 respectively
#「詩文」
plot_f_poem <- f_poem[1:150,]
wordcloud2(plot_f_poem, size = 0.8, shape = "star")

#「詩名」
plot_f_name <- f_name[1:100,]
wordcloud2(plot_f_name, size = 0.8, shape = "star")

```
### 執行結果如下：
![](https://i.imgur.com/vjRhcJD.png)

![](https://i.imgur.com/4aaZBup.png)

## 8. 自己另外實作
> 最後感謝老師，輸出個`LOVE`的文字雲
> 注意`html`檔要重新整理才會出現! 
### 程式碼如下：
```r=
letterCloud(f_name, word = "LOVE", size = 0.7)
```
### 執行結果如下：
![](https://i.imgur.com/mLRPVye.png)

---
# 程式碼
```r=
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
```
![](https://i.imgur.com/yo5HHar.png)