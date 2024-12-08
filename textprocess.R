# PPHA 30536 1 - Data and Programming for Public Policy II - R Programming 
# Data Skills 2 - R
## Fall Quarter 2024
# Date: 12.06.24
# Student: Natalia Zorrilla
# Final Project - Text Process
## Due: December 7, 2024 before midnight on Gradescope
############################################################################################################

#THIS PART OF THE PROJECT WILL FOCUS ON SENTIMENT ANALYSIS OF THE REPORT TREATEMENT NOT TRAUMA

#All sentiment plots in this script will be automatically saved in the current working directory. 
#To replicate this project, please set your working directory in this initial stage. 
setwd("/Users/Natalia/Documents/The University of Chicago/Harris School of Public Policy/MPP/Fall quarter 2024/PPHA 30536 1 - Data and Programming for Public Policy II - R Programming /Assignments/Final project")

#install.packages(c("rvest", "httr", "tidyverse", "tidytext", "textdata", "sentimentr", "pdftools"))

library(rvest)
library(httr)
library(tidyverse)
library(tidytext)
library(textdata)
library(sentimentr)
library(pdftools)
#Clear all objects
rm(list=ls())

#### Part 1: Web scrapping to access the report  

#Access the website
report_url <- "https://www.chicago.gov/city/en/sites/treatment-not-trauma/home.html"

#read the HTML of the webpage
webpage <- read_html(report_url)

#extract the PDF link
pdf_link <- webpage %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl("MHSE-Report-May-31-2024.pdf", .)]

#Print the link to verify that it's not empty or has repetitive links
#print(pdf_link)

#if multiple links are found, use the first one (as in this case)
if(length(pdf_link) > 0) {
  pdf_link <- pdf_link[1]
} else {
  stop("PDF link not found.")
}

#Combine the relative URL with the base URL
pdf_full_link <- paste0("https://www.chicago.gov", pdf_link)

#Print the full link to confirm (if needed)
#print(pdf_full_link)

#Define the path to save the PDF in the current working directory
#Note: as mentioned before, if you need to save it in a different directory, make the necessary changes
pdf_path <- file.path(getwd(), "MHSE-Report-May-31-2024.pdf")

#Download the PDF using the full link
response <- GET(pdf_full_link, write_disk(pdf_path, overwrite = TRUE))

############################################################################################################
#### Part 2: Sentiment analysis
#NOTE: Remember, all sentiment plots in this script will be automatically saved in the current working directory. 

#Extract text from the downloaded PDF
pdf_text <- pdf_text(pdf_path)

#Combine text from all pages into one string
pdf_text_combined <- paste(pdf_text, collapse = " ")

#Convert the text to a dataframe (for tokenization)
text_df <- tibble(text = pdf_text_combined)

#Tokenization - separate the text into individual words
word_tokens_df <- unnest_tokens(text_df, word_tokens, text, token = "words")
head(count(word_tokens_df, word_tokens, sort = TRUE))

#Remove stopwords
no_sw_df <- anti_join(word_tokens_df, stop_words, by = c("word_tokens" = "word"))
count(no_sw_df, word_tokens, sort = TRUE)  # Keep what's not in stop_words

#Tokenize the text into sentences
sentence_tokens_df <- unnest_tokens(text_df, sent_tokens, text, token = "sentences")

#Word tokenization again, removing stop words
TNT_tokens <- unnest_tokens(text_df, word_tokens, text, token = "words")
TNT_tokens <- TNT_tokens %>% anti_join(stop_words, by = c("word_tokens" = "word"))

#Group by word and count occurrences
TNT_tokens <- TNT_tokens %>%
  group_by(word_tokens) %>%
  summarise(n_text = n())

#Add a new column for proportion of each word in the document
TNT_tokens <- TNT_tokens %>%
  mutate(prop_text = n_text / sum(n_text))

#Sentiment analysis - load sentiment lexicons
sentiment_nrc <- get_sentiments("nrc") %>% rename(nrc = sentiment)
sentiment_afinn <- get_sentiments("afinn") %>% rename(afinn = value)
sentiment_bing <- get_sentiments("bing") %>% rename(bing = sentiment)

#Join the sentiment lexicons to the tokenized words
no_sw_df_nrc <- no_sw_df %>% left_join(sentiment_nrc, by = c("word_tokens" = "word"))
no_sw_df_afinn <- no_sw_df %>% left_join(sentiment_afinn, by = c("word_tokens" = "word"))
no_sw_df_bing <- no_sw_df %>% left_join(sentiment_bing, by = c("word_tokens" = "word"))

#NRC Sentiment Plot
nrc_plot <- ggplot(data = filter(no_sw_df_nrc, !is.na(nrc))) +
  geom_bar(aes(nrc), stat = "count", fill = "cornflowerblue") +
  scale_x_discrete(guide = guide_axis(angle = 45)) +
  labs(
    title = "'Treatment Not Trauma' Report: Sentiment Distribution - NRC Lexicon",
    x = "Sentiment Category",
    y = "Count",
    caption = "Source: City of Chicago: https://www.chicago.gov/city/en/sites/treatment-not-trauma/home.html"
  ) +
  theme_minimal() +
  theme(
    plot.caption = element_text(size = 8)
  )

#Save NRC plot
ggsave(filename = "TNT_nrc_plot.png", plot = nrc_plot)

#AFINN Sentiment Plot
affin_plot <- ggplot(data = filter(no_sw_df_afinn, !is.na(afinn))) +
  geom_bar(aes(afinn), stat = "count", fill = "salmon") +
  labs(
    title = "'Treatment Not Trauma' Report: Sentiment Score Distribution - AFINN Lexicon",
    x = "Sentiment Score",
    y = "Count",
    subtitle = "On a scale of -5 (negative) to +5 (positive)",
    caption = "Source: City of Chicago: https://www.chicago.gov/city/en/sites/treatment-not-trauma/home.html"
  ) +
  theme_minimal() +
  theme(
    plot.caption = element_text(size = 8)
  )

#Save AFINN plot
ggsave(filename = "TNT_afinn_plot.png", plot = affin_plot)

#Bing Sentiment plot
bing_plot <- ggplot(data = filter(no_sw_df_bing, !is.na(bing))) +
  geom_bar(aes(bing), stat = "count", fill = "lightgreen") +
  labs(
    title = "'Treatment Not Trauma' Report: Sentiment Distribution - Bing Lexicon",
    x = "Sentiment Category",
    y = "Count",
    caption = "Source: City of Chicago: https://www.chicago.gov/city/en/sites/treatment-not-trauma/home.html"
  ) +
  theme_minimal() +
  theme(
    plot.caption = element_text(size = 8)
  )

ggsave(filename = "TNT_bing_plot.png", plot = bing_plot)

#Sentiment analysis
sentence_tokens_df <- unnest_tokens(text_df, sent_tokens, text, token = "sentences")
sentence_sentiment <- sentiment(sentence_tokens_df$sent_tokens)

#summary statistics
sentiment_summary <- sentence_sentiment %>%
  summarise(
    mean_sentiment = mean(sentiment),
    median_sentiment = median(sentiment),
    sd_sentiment = sd(sentiment),
    min_sentiment = min(sentiment),
    max_sentiment = max(sentiment)
  )

print(sentiment_summary)