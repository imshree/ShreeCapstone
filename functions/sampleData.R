sampleData <- function(tempData, percent = 0.05) {
    
    numOfLines <- length(tempData)
    
    tempData <- sample(tempData, size = numOfLines * percent, replace = FALSE)
    
    return(tempData)
}