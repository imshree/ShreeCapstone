getNGramsData <- function(words, n) {
    rawNGramData <- NGramTokenizer(words, Weka_control(min = n, max = n))
    rmEntry <- grep("\\bc \\b",rawNGramData)
    
    if (length(rmEntry) > 0) {
        rawNGramData <- rawNGramData[-c(rmEntry)]
    }
    return(rawNGramData)
}