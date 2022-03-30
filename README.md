# textming
110-2 文字探勘
Text Mining: Homework 1
due on March 30, 2022
This homework asks you to analyze the famous Reuters-21578 corpus which consists of Reuters
newswires in 1987. aere are 21587 documents stored in 22 ûles. ae original test collection is available from http://www.daviddlewis.com/resources/testcollections/reuters21578 in the
format of sgml. For the convenience, I put the XML versions in e-learning. It would be much easier
for coding to preprocess the 22 XML ûles into 21587 text ûles via the command
preprocess Reuters 21578 XML(input, output, ûxEnc = TRUE)
You need to install the Rgraphviz package and it could be done via
if (!require("BiocManager", quietly = TRUE))
install.packages("BiocManager")
BiocManager::install("Rgraphviz")
Do the follows:
1. Read in all the documents as PlainTextDocument;
2. Explore the corpus;
3. Prepare the corpus including converting the text to lower case, removing numbers and punctuation, removing stop words, stemming and identifying synonyms;
4. Create a document term matrix;
5. Explore the Document Term Matrix by converting the document term matrix into a matrix
and summing the column counts;
6. Remove Sparse Terms;
7. Identify Frequent Items and Associations;
8. Draw Correlations Plots;
9. Plot Word Frequencies;
10. Draw Word Clouds
11. Perform quantitative analysis of text
