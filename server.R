#
# This is the server logic of a Shiny web application. 
#
#

library(shiny)
library(tm)
library(stylo)
library(data.table)
library(RWeka)
library(stringr)
library(dplyr)

shinyServer(
    function(input,output) {
        
        # Display text user provided
        returnText <- eventReactive(input$button, {
            paste(input$text)
        })
        output$outText <- renderText({ returnText() })
        
        # Display clean version of user text
        adjustedText <- eventReactive(input$button, {
            tail(txt.to.words(cleanUserInput(input$text)), 3)
        })
        output$interpretText <- renderText({ adjustedText() })
        
        # Get list of predicted words
        nextWord <- eventReactive(input$button, {
            getPredictionWord(input$text, input$words)
        })
        output$table <- renderTable({ nextWord() })
        
        
    }
    
)