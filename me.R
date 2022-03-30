rm(list=ls())
## ----load_packages, message=FALSE----------------------------------------
library(tm)              # Framework for text mining.
library(qdap)            # Quantitative discourse analysis of transcripts.
library(qdapDictionaries)
library(dplyr)           # Data wrangling, pipe operator %>%().
library(RColorBrewer)    # Generate palette of colours for plots.
library(ggplot2)         # Plot word frequencies.
library(scales)          # Include commas in numbers.
library(Rgraphviz)       # Correlation plots.
library(tm.corpus.Reuters21578)  #

## ----additional_dependent_pacakges, echo=FALSE, message=FALSE------------
# These are dependencies that would otherwise be loaded as required.

library(magrittr)         #
library(stringr)

## ----list_sources--------------------------------------------------------
getSources()

## ----list_readers, out.lines=NULL----------------------------------------
getReaders()

## ----location_of_txt_docs------------------------------------------------
setwd("C:/Reuters21578")
cname0 <- file.path(".", "XML0")
cname0
cname <- file.path(".", "XML")

## ----folder_of_txt_docs--------------------------------------------------
length(dir(cname0))
dir(cname0)

#### Preprocess the Reuters-21578 XML archive 
## Usage: preprocess_Reuters_21578_XML(input, output, fixEnc = TRUE)

## The following command covert the 22 XML files into 21587 ascii files that only to beexcuted once.                           
##preprocess_Reuters_21578_XML(cname0,cname,fixEnc = F)

## ----load_corpus---------------------------------------------------------
# docs <- Corpus(DirSource(cname))
#  docs <- VCorpus(DirSource(cname), readerControl=list(reader = readReut21578XML))
reut21578 <- system.file("texts", "crude", package = "tm")
docs <- VCorpus(DirSource(reut21578), readerControl=list(reader = readReut21578XMLasPlain))
docs
class(docs)
class(docs[[1]])
summary(docs)


## ----read_pdf, eval=FALSE------------------------------------------------
## docs <- Corpus(DirSource(cname), readerControl=list(reader=readPDF))

## ----read_doc, eval=FALSE------------------------------------------------
## docs <- Corpus(DirSource(cname), readerControl=list(reader=readDOC))

## ----read_doc_options, eval=FALSE----------------------------------------
## docs <- Corpus(DirSource(cname), readerControl=list(reader=readDOC("-r -s")))

## ----out.lines=26--------------------------------------------------------
inspect(docs[16])


## ------------------------------------------------------------------------
viewDocs <- function(d, n) {d %>% extract2(n) %>% as.character() %>% writeLines()}
viewDocs(docs, 16)

## ------------------------------------------------------------------------
getTransformations()

## ----transform_slash-----------------------------------------------------
toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")

## ----eval=FALSE----------------------------------------------------------
## docs <- tm_map(docs, toSpace, "/|@|\\|")
## 

## ----out.lines=26--------------------------------------------------------
inspect(docs[16])

## ------------------------------------------------------------------------
docs <- tm_map(docs, content_transformer(tolower))

## ----out.lines=26--------------------------------------------------------
inspect(docs[16])

## ------------------------------------------------------------------------
docs <- tm_map(docs, removeNumbers)

## ----out.lines=26--------------------------------------------------------
viewDocs(docs, 16)

## ------------------------------------------------------------------------
docs <- tm_map(docs, removePunctuation)

## ----out.lines=26--------------------------------------------------------
viewDocs(docs, 16)

## ----remove_own_stopwords------------------------------------------------
# docs <- tm_map(docs, removeWords, c("department", "email"))

## ----out.lines=26--------------------------------------------------------
viewDocs(docs, 16)

## ------------------------------------------------------------------------
docs <- tm_map(docs, stripWhitespace)

## ----out.lines=26--------------------------------------------------------
viewDocs(docs, 16)

## ----specific_transforms-------------------------------------------------
toString <- content_transformer(function(x, from, to) gsub(from, to, x))
docs <- tm_map(docs, toString, "harbin institute technology", "HIT")
docs <- tm_map(docs, toString, "shenzhen institutes advanced technology", "SIAT")
docs <- tm_map(docs, toString, "chinese academy sciences", "CAS")

## ----out.lines=26--------------------------------------------------------
inspect(docs[16])

## ------------------------------------------------------------------------
docs <- tm_map(docs, stemDocument)

## ----out.lines=26--------------------------------------------------------
viewDocs(docs, 16)

## ----create_document_term_matrix, out.lines=20---------------------------
dtm <- DocumentTermMatrix(docs)

dtm

## ----inspect_dtm---------------------------------------------------------
inspect(dtm[1:5, 1000:1005])

## ----dtm_matrix----------------------------------------------------------
class(dtm)
dim(dtm)

## ----create_term_document_matrix, out.lines=20---------------------------
tdm <- TermDocumentMatrix(docs)
tdm

## ------------------------------------------------------------------------
freq <- colSums(as.matrix(dtm))
length(freq)

## ----out.lines=10--------------------------------------------------------
ord <- order(freq)

# Least frequent terms.
freq[head(ord)]

## ------------------------------------------------------------------------
# Most frequent terms.
freq[tail(ord)]

## ------------------------------------------------------------------------
# Frequency of frequencies.
head(table(freq), 15)
tail(table(freq), 15)

## ----dtm_to_m------------------------------------------------------------
m <- as.matrix(dtm)
dim(m)

## ----save_csv, eval=FALSE------------------------------------------------
## write.csv(m, file="dtm.csv")

## ----remove_sparse_terms-------------------------------------------------
dim(dtm)
dtms <- removeSparseTerms(dtm, 0.9)
dim(dtms)

## ------------------------------------------------------------------------
inspect(dtms)

## ------------------------------------------------------------------------
freq <- colSums(as.matrix(dtms))
freq
table(freq)

## ----freq_terms_1000-----------------------------------------------------
findFreqTerms(dtm, lowfreq=1000)

## ----freq_terms_100------------------------------------------------------
findFreqTerms(dtm, lowfreq=100)

## ----assoc---------------------------------------------------------------
findAssocs(dtm, "data", corlimit=0.6)

## ----plot_correlations, echo=FALSE, out.width="\\textwidth", warning=FALSE, message=FALSE----
plot(dtm, 
     terms=findFreqTerms(dtm, lowfreq=1000)[1:50], 
     corThreshold=0.5)

## ----plot_correlations, eval=FALSE---------------------------------------
## plot(dtm,
##      terms=findFreqTerms(dtm, lowfreq=100)[1:50],
##      corThreshold=0.5)

## ----plot_correlations_optoins, echo=FALSE, out.width="\\textwidth", warning=FALSE----
plot(dtm, 
     terms=findFreqTerms(dtm, lowfreq=100)[1:50], 
     corThreshold=0.5,
     weighting=TRUE)

## ----plot_correlations, eval=FALSE---------------------------------------
## plot(dtm,
##      terms=findFreqTerms(dtm, lowfreq=100)[1:50],
##      corThreshold=0.5)

## ----word_count----------------------------------------------------------
freq <- sort(colSums(as.matrix(dtm)), decreasing=TRUE)
head(freq, 14)
wf   <- data.frame(word=names(freq), freq=freq)
head(wf)

## ----plot_freq, fig.width=12, out.width="\\textwidth"--------------------
library(ggplot2)
subset(wf, freq>500)                                                  %>%
  ggplot(aes(word, freq))                                              +
  geom_bar(stat="identity")                                            +
  theme(axis.text.x=element_text(angle=45, hjust=1))

## ----wordcloud, echo=FALSE, warning=FALSE, message=FALSE, out.width="0.75\\textwidth", crop=TRUE----
library(wordcloud)
set.seed(123)
wordcloud(names(freq), freq, min.freq=40)

## ----wordcloud, eval=FALSE-----------------------------------------------
## library(wordcloud)
## set.seed(123)
## wordcloud(names(freq), freq, min.freq=40)

## ----wordcloud_max_words, echo=FALSE, out.width="0.75\\textwidth", crop=TRUE----
set.seed(142)
wordcloud(names(freq), freq, max.words=100)

## ----wordcloud_max_words, eval=FALSE-------------------------------------
## set.seed(142)
## wordcloud(names(freq), freq, max.words=100)

## ----wordcloud_higher_freq, echo=FALSE, out.width="0.75\\textwidth", crop=TRUE----
set.seed(142)
wordcloud(names(freq), freq, min.freq=100)

## ----wordcloud_higher_freq, eval=FALSE-----------------------------------
## set.seed(142)
## wordcloud(names(freq), freq, min.freq=100)

## ----wordcloud_colour, echo=FALSE, out.width="0.75\\textwidth", crop=TRUE----
set.seed(142)
wordcloud(names(freq), freq, min.freq=100, colors=brewer.pal(6, "Dark2"))

## ----wordcloud_colour, eval=FALSE----------------------------------------
## set.seed(142)
## wordcloud(names(freq), freq, min.freq=100, colors=brewer.pal(6, "Dark2"))

## ----wordcloud_scale, echo=FALSE, warning=FALSE, out.width="0.75\\textwidth", crop=TRUE----
set.seed(142)
wordcloud(names(freq), freq, min.freq=100, scale=c(5, .1), colors=brewer.pal(6, "Dark2"))

## ----wordcloud_scale, eval=FALSE-----------------------------------------
## set.seed(142)
## wordcloud(names(freq), freq, min.freq=100, scale=c(5, .1), colors=brewer.pal(6, "Dark2"))

## ----wordcloud_rotate, echo=FALSE, warning=FALSE, out.width="0.75\\textwidth", crop=TRUE----
set.seed(142)
dark2 <- brewer.pal(6, "Dark2")
wordcloud(names(freq), freq, min.freq=100, rot.per=0.2, colors=dark2)

## ----wordcloud_rotate, eval=FALSE----------------------------------------
## set.seed(142)
## dark2 <- brewer.pal(6, "Dark2")
## wordcloud(names(freq), freq, min.freq=100, rot.per=0.2, colors=dark2)

## ----library_qdap, echo=FALSE, messages=FALSE----------------------------
library(qdap)

## ----qdap_create_word_list-----------------------------------------------
words <- dtm                                                          %>%
  as.matrix                                                           %>%
  colnames                                                            %>%
  (function(x) x[nchar(x) < 20])

## ----qdap_word_length, out.lines=11--------------------------------------
length(words)
head(words, 15)
summary(nchar(words))
table(nchar(words))
dist_tab(nchar(words))

## ----qdap_word_length_plot, echo=FALSE, fig.height=4---------------------
data.frame(nletters=nchar(words))                                     %>%
  ggplot(aes(x=nletters))                                              + 
  geom_histogram(binwidth=1)                                           +
  geom_vline(xintercept=mean(nchar(words)), 
             colour="green", size=1, alpha=.5)                         + 
  labs(x="Number of Letters", y="Number of Words")

## ----qdap_word_length_plot, eval=FALSE-----------------------------------
## data.frame(nletters=nchar(words))                                     %>%
##   ggplot(aes(x=nletters))                                              +
##   geom_histogram(binwidth=1)                                           +
##   geom_vline(xintercept=mean(nchar(words)),
##              colour="green", size=1, alpha=.5)                         +
##   labs(x="Number of Letters", y="Number of Words")

## ----qdap_letter_freq_plot, echo=FALSE, fig.height=4---------------------
library(dplyr)
library(stringr)

words                                                        %>%
  str_split("")                                                       %>%
  sapply(function(x) x[-1])                                           %>%
  unlist                                                              %>%
  dist_tab                                                            %>%
  mutate(Letter=factor(toupper(interval),
                       levels=toupper(interval[order(freq)])))        %>%
  ggplot(aes(Letter, weight=percent))                                  + 
  geom_bar()                                                           +
  coord_flip()                                                         +
  labs(y="Proportion")                                                   +
  scale_y_continuous(breaks=seq(0, 12, 2), 
                     label=function(x) paste0(x, "%"), 
                     expand=c(0,0), limits=c(0,12))

## ----qdap_letter_freq_plot, eval=FALSE-----------------------------------
## library(dplyr)
## library(stringr)
## 
## words                                                        %>%
##   str_split("")                                                       %>%
##   sapply(function(x) x[-1])                                           %>%
##   unlist                                                              %>%
##   dist_tab                                                            %>%
##   mutate(Letter=factor(toupper(interval),
##                        levels=toupper(interval[order(freq)])))        %>%
##   ggplot(aes(Letter, weight=percent))                                  +
##   geom_bar()                                                           +
##   coord_flip()                                                         +
##   labs(y="Proportion")                                                   +
##   scale_y_continuous(breaks=seq(0, 12, 2),
##                      label=function(x) paste0(x, "%"),
##                      expand=c(0,0), limits=c(0,12))

## ----qdap_count_position_plot, echo=FALSE, fig.height=7, fig.width=9-----
words                                                                 %>%
  lapply(function(x) sapply(letters, gregexpr, x, fixed=TRUE))        %>%
  unlist                                                              %>%
  (function(x) x[x!=-1])                                              %>%
  (function(x) setNames(x, gsub("\\d", "", names(x))))                %>%
  (function(x) apply(table(data.frame(letter=toupper(names(x)), 
                                      position=unname(x))),
                     1, function(y) y/length(x)))                     %>%
  qheat(high="green", low="yellow", by.column=NULL, 
        values=TRUE, digits=3, plot=FALSE)                             +
  labs(y="Letter", x="Position") + 
  theme(axis.text.x=element_text(angle=0))                             +
  guides(fill=guide_legend(title="Proportion"))

## ----qdap_count_position_plot, eval=FALSE--------------------------------
## words                                                                 %>%
##   lapply(function(x) sapply(letters, gregexpr, x, fixed=TRUE))        %>%
##   unlist                                                              %>%
##   (function(x) x[x!=-1])                                              %>%
##   (function(x) setNames(x, gsub("\\d", "", names(x))))                %>%
##   (function(x) apply(table(data.frame(letter=toupper(names(x)),
##                                       position=unname(x))),
##                      1, function(y) y/length(x)))                     %>%
##   qheat(high="green", low="yellow", by.column=NULL,
##         values=TRUE, digits=3, plot=FALSE)                             +
##   labs(y="Letter", x="Position") +
##   theme(axis.text.x=element_text(angle=0))                             +
##   guides(fill=guide_legend(title="Proportion"))

## ----eval=FALSE----------------------------------------------------------
## devtools::install_github("lmullen/gender-data-pkg")

## ------------------------------------------------------------------------
name2sex(qcv(graham, frank, leslie, james, jacqui, jack, kerry, kerrie))

## ------------------------------------------------------------------------
## install.packages("tmcn.word2vec", repos="http://R-Forge.R-project.org")
library(tmcn.word2vec)
model <- word2vec(system.file("examples", "rfaq.txt", package = "tmcn.word2vec"))
distance(model$model_file, "the")

## ----review_prepare_corpus, eval=FALSE-----------------------------------
## # Required packages
## 
## library(tm)
## library(wordcloud)
## 
## # Locate and load the Corpus.
## 
## cname <- file.path(".", "corpus", "txt")
## docs <- Corpus(DirSource(cname))
## 
## docs
## summary(docs)
## inspect(docs[1])
## 
## # Transforms
## 
## toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
## docs <- tm_map(docs, toSpace, "/|@|\\|")
## 
## docs <- tm_map(docs, content_transformer(tolower))
## docs <- tm_map(docs, removeNumbers)
## docs <- tm_map(docs, removePunctuation)
## docs <- tm_map(docs, removeWords, stopwords("english"))
## docs <- tm_map(docs, removeWords, c("own", "stop", "words"))
## docs <- tm_map(docs, stripWhitespace)
## 
## toString <- content_transformer(function(x, from, to) gsub(from, to, x))
## docs <- tm_map(docs, toString, "specific transform", "ST")
## docs <- tm_map(docs, toString, "other specific transform", "OST")
## 
## docs <- tm_map(docs, stemDocument)
## 

## ----review_analyse_corpus, eval=FALSE-----------------------------------
## # Document term matrix.
## 
## dtm <- DocumentTermMatrix(docs)
## inspect(dtm[1:5, 1000:1005])
## 
## # Explore the corpus.
## 
## findFreqTerms(dtm, lowfreq=100)
## findAssocs(dtm, "data", corlimit=0.6)
## 
## freq <- sort(colSums(as.matrix(dtm)), decreasing=TRUE)
## wf   <- data.frame(word=names(freq), freq=freq)
## 
## library(ggplot2)
## 
## p <- ggplot(subset(wf, freq>500), aes(word, freq))
## p <- p + geom_bar(stat="identity")
## p <- p + theme(axis.text.x=element_text(angle=45, hjust=1))
## 
## # Generate a word cloud
## 
## library(wordcloud)
## wordcloud(names(freq), freq, min.freq=100, colors=brewer.pal(6, "Dark2"))

## ------------------------------------------------------------------------
library(lda)
# From demo(lda)
library("ggplot2")
library("reshape2")
data(cora.documents)
data(cora.vocab)
theme_set(theme_bw())  
set.seed(8675309)
K <- 10 ## Num clusters
result <- lda.collapsed.gibbs.sampler(cora.documents,
                                       K,  ## Num clusters
                                       cora.vocab,
                                       25,  ## Num iterations
                                       0.1,
                                       0.1,
                                       compute.log.likelihood=TRUE) 
## Get the top words in the cluster
top.words <- top.topic.words(result$topics, 5, by.score=TRUE)
## Number of documents to display
N <- 10

topic.proportions <- t(result$document_sums) / colSums(result$document_sums)

topic.proportions <-
   topic.proportions[sample(1:dim(topic.proportions)[1], N),]

topic.proportions[is.na(topic.proportions)] <-  1 / K

colnames(topic.proportions) <- apply(top.words, 2, paste, collapse=" ")

topic.proportions.df <- melt(cbind(data.frame(topic.proportions),
                                   document=factor(1:N)),
                             variable.name="topic",
                             id.vars = "document")  

ggplot(topic.proportions.df, aes(x=topic, y=value, fill=topic)) +
    geom_bar(stat="identity") +
    theme(axis.text.x = element_text(angle=45, hjust=1, size=7),
          legend.position="none") +  
    coord_flip() +
    facet_wrap(~ document, ncol=5)

