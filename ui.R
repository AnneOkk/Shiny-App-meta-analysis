library(shiny)
library(DT)
library(rdrop2)
library(rsconnect)
setwd("/Users/anne/Dropbox/Studies/Career\ Exploration/RCode/ShinyApp/")
getwd()

token <- drop_auth()
saveRDS(token, "droptoken.rds")
# Upload droptoken to your server
# ******** WARNING ********
# Losing this file will give anyone 
# complete control of your Dropbox account
# You can then revoke the rdrop2 app from your
# dropbox account and start over.
# ******** WARNING ********
# read it back with readRDS
token <- readRDS("droptoken.rds")
# Then pass the token to each drop_ function
drop_acc(dtoken = token)

outputDir <- "responses"

# Define UI
ui <- shinyUI(fluidPage(
  tags$head(
    tags$style(
      HTML(".shiny-notification {
             position:fixed;
             top: calc(20%);
             left: calc(10%);
             }
             "
      )
    )
  ),
  titlePanel("Upload unpublished data sets - Meta-analysis Career Exploration"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      fileInput('target_upload', 'Choose file to upload (CSV or txt)',
                accept = c(
                  'text/csv',
                  'text/comma-separated-values',
                  '.csv'
                )),
      textInput("description", "Short file description (e.g., Correlation Table)", ""),
      tags$hr(),
      radioButtons("disp", "Display",
                   choices = c(Head = "head",
                               All = "all"),
                   selected = "head"),
      checkboxInput("header", "Header", TRUE),
      radioButtons("separator","Separator: ",
                   choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                   selected = "," ,inline=TRUE),
      DT::dataTableOutput("sample_table"),
      actionButton("submit", "Submit"),
      tags$hr(),
      textInput("caption", "Please enter your last name", ""),
      tags$hr(),
      h3("Info"),
      p("On this web page you may upload unpublished data related to career exploration as measured by Stumpf and colleagues (1983)."),
      p("Please add a short file description and your name, so we can retrace each individual contributioin."),
      h3("Contact"),
      p("Please do not hesitate to contact me if you have any questions about the meta-analysis project."),
      
    ),
    mainPanel(
      
      # Output: Data file ----
      tableOutput("contents")
      
    )
  )
)
)
