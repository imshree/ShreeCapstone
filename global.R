# Load libraries, break large data frame into separate NGram dataframes
library(data.table)
load("divideNGram.RData")
inData <- fread("NGramSortedFinal.txt", sep = "\t", header=TRUE, data.table = FALSE)
data1gram <- inData[gram1[1]:gram1[2], ]
data2gram <- inData[gram2[1]:gram2[2], ]
data3gram <- inData[gram3[1]:gram3[2], ]
data4gram <- inData[gram4[1]:gram4[2], ]
rm(inData, gram1, gram2, gram3, gram4)

source('getPredictionWord.R')

cleanUserInput <- function(x, flag = TRUE) {
    
    x <- tolower(x) # Convert all characters to lower case
    x <- gsub("[^a-z ]", "", x) # Remove numbers or foreign characters.
    x <- gsub("#\\S+", "", x) # Remove twitter hashtags
    x <- gsub("\\brt\\b", "", x) # Remove "rt"
    x <- replaceContractions(x) # Replace contractions
    
    load("profanity.RData")
    x <- removeWords(x, profanity)
    
    # Remove 'stopwords' based on user input
    if (flag) {
        x <- removeWords(x, stopwords("english"))
    }
    
    x <- replaceSingleWord(x) # Replace single letters with full words
    
    tmpData <- stripWhitespace(x) # Remove extra blank space
}


replaceContractions <- function(x) {
    # Replace common contractions
    
    # Exceptions
    x <- gsub("i'm", "i am", x)
    x <- gsub("can't", "cannot", x)
    x <- gsub("won't", "will not", x)
    x <- gsub("ain't", "am not", x)
    x <- gsub("what's", "what is", x)
    x <- gsub("it's", "it is", x)
    
    # Common occurences
    x <- gsub("'d", " would", x)
    x <- gsub("'re", " are", x)
    x <- gsub("n't", " not", x)
    return(x)
}


replaceSingleWord <- function (x) {
    # Transform "i will b there" to "i will be there", etc.
    x <- gsub("\\bb\\b", "be", x)
    x <- gsub("\\bc\\b", "see", x)
    x <- gsub("\\br\\b", "are", x)
    x <- gsub("\\bu\\b", "you", x)
    x <- gsub("\\by\\b", "why", x)
    x <- gsub("\\bo\\b", "oh", x)
}


getNGramsData <- function(dw, n) {
    # Create list of nGrams based on string of text
    rawNGram <- NGramTokenizer(dw, Weka_control(min = n, max = n))
    
    # Using NGramTokenizer adds 'c word' to our corpus. The following code ensures this is removed.
    removeEntry <- grep("\\bc \\b",rawNGram)
    
    if (length(removeEntry) > 0) {
        rawNGram <- rawNGram[-c(removeEntry)]
    }
    return(rawNGram)
}


getNextWord <- function(userWords) {
    
    lastWord <- NA
    comparePhrase <- paste("^", paste(userWords, collapse = " "), "\\b", sep = "")
    
    # Use appropriate NGram table to find matches to user input
    if (length(userWords)==3) {
        rawMatch <- grep(comparePhrase, data4gram$word)
        lastWord <- word(data4gram$word[rawMatch], -1)
    }
    
    if (length(userWords)==2) {
        rawMatch <- grep(comparePhrase, data3gram$word)
        lastWord <- word(data3gram$word[rawMatch], -1)
    }
    
    if (length(userWords)==1) {
        rawMatch <- grep(comparePhrase, data2gram$word)
        lastWord <- word(data2gram$word[rawMatch], -1)
    }
    
    return(lastWord)
    
}


getMatchProb <- function(predictedWord, userIn) {
    
    # Create one string phrase
    phraseIn <- paste(userIn, collapse=" ")
    
    # Get unigram probability
    temp <- data1gram$word %in% userIn
    unigramCount <- data1gram$freq[temp] / sum(data1gram$freq)
    rm(temp)
    
    # Break input into bigrams
    bigrams <- getNGramsData(phraseIn,2)
    
    # cycle through bigrams, calculate count term
    if (length(bigrams) != 0) {
        term1 <- NULL
        for (i in 1:length(bigrams)){
            comparePhrase <- paste("^", paste(bigrams[i], collapse = " "), "\\b", sep = "")
            term1 <- c( term1, log( (data2gram$freq[grep(comparePhrase, data2gram$word)] / sum(data2gram$freq) ) / unigramCount[i]) )
        }
    } else {
        term1 <- NULL
    }
    
    # Get bigram counts based on previously matched words
    # Associate relative probability with matched words
    relativeProb <- NULL
    for (i in 1:length(predictedWord)) {
        comparePhrase <- NULL
        comparePhrase <- paste("^", paste(tail(userIn, 1), predictedWord[i], collapse = " "), "\\b", sep = "")
        relativeProb <- c(relativeProb, as.numeric(sum(term1) + log( (data2gram$freq[grep(comparePhrase, data2gram$word)] / sum(data2gram$freq) ) / tail(unigramCount, 1) )))
    }
    return(relativeProb)
    
}