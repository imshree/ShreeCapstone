cleanUserData <- function(x, flag = TRUE) {
    
    x <- tolower(x)   # Convert all characters to lower case
    x <- gsub("[^a-z ]", "", x) # Remove numbers or foreign characters.
    x <- gsub("#\\S+", "", x) # Remove twitter hashtags
    x <- gsub("\\brt\\b", "", x) # Remove "rt"
    x <- replaceContracttions(x) # Replace contractions
    
    load("profanity.RData") # Remove profanity and 'stopwords'
    
    x <- removeWords(x, profanity)
    
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