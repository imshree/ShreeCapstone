getPredictionWord <- function(inPhrase, outWords = 5, flag = TRUE) {
    
    userWords <- txt.to.words(cleanUserInput(inPhrase, flag))
    numOfWords <- length(userWords)
    
    # If user input is blank space or is filtered out, return common unigrams
    if (numOfWords==0){
        lastWord <- as.data.frame(as.character(data1gram$word[1:outWords]))
        return(lastWord)
    }
    
    # Cuts user input down to the last 3 words
    if (numOfWords > 3) {
        numOfWords <- 3
        userWords <- tail(userWords, numOfWords)
    }
    
    # This for loop searches for matches, removes common results if necessary
    matchLength <- NULL
    matchList <- NULL
    for (i in numOfWords:1) {
        tmpResults <- NULL
        tmpResults <- getNextWord(tail(userWords, i))
        
        if (is.na(tmpResults[1])) {
            matchLength <- c(matchLength, 0)
        } else {
            
            removeLogic <- tmpResults %in% matchList
            matchList <- c(matchList, tmpResults[!removeLogic])
            
            matchLength <- c(matchLength, length(tmpResults[!removeLogic]))
            rm(removeLogic, tmpResults)
        }
        if (sum(matchLength) > outWords) {break}
        
    }
    
    if (sum(matchLength)==0) {
        lastWord <- as.data.frame(as.character(data1gram$word[1:outWords]))
        return(lastWord)
    }
    
    # this code removes zero from the term matchLength
    # reverseInd is used to trim the user input for the getMatchProb function
    reverseInd <- numOfWords:1
    reverseInd <- reverseInd[!(matchLength %in% 0)]
    matchLength <- matchLength[!(matchLength %in% 0)]
    
    stepDown <- NULL
    for (i in 1:length(matchLength) ) {
        
        if(matchLength[i]!=0){
            
            if (i==1){
                stepDown <- c(stepDown, rep(log(1), matchLength[i]) )
            } else {
                stepDown <- c(stepDown, rep(log(0.4^(i-1)), matchLength[i]))
            }
            
        } else {
            stepDown <- c(stepDown, NULL)
        }
        
    }
    
    # Add comments
    if (length(matchList)>20) {
        matchList <- matchList[1:20]
        stepDown <- stepDown[1:20]
    }
    
    # Calculate log probability
    prob <- NULL
    for (i in 1:length(unique(stepDown))) {
        temp <- NULL
        temp <- stepDown %in% unique(stepDown)[i]
        
        prob <- c(prob, getMatchProb( matchList[temp], tail(userWords, reverseInd[i]) ))
    }
    
    # Create data frame of results, sort results
    bestGuess <- data.frame( word=matchList, logProb=as.numeric(prob+stepDown), stringsAsFactors = FALSE )
    bestGuess <- arrange(bestGuess, desc(logProb))
    return(bestGuess[1:outWords,])
    
}