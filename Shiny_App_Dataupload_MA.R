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

# Define server logic
server <- shinyServer(function(input, output) {
  output$contents <- renderTable({
    upload <- input$target_upload
    if (is.null(upload))
      return(NULL)
    df <- read.csv(upload$datapath, header =  input$header, sep = input$separator)
    if(input$disp == "head") {
      return(head(df))
    }
    else {
      return(df)
    }
    
  })
  
  df_products_upload <- reactive({
    inFile <- input$target_upload
    if (is.null(inFile))
      return(NULL)
    df <- read.csv(inFile$datapath, header = TRUE,sep = input$separator)
    return(df)
  })
  
  observeEvent(input$submit, {
    showNotification("Thank you very much! Your file has been uploaded.", duration = 30, type = "message")})
  
  
  observeEvent(input$submit, {
    saveData <- function(df) {
      # Create a unique file name
      fileName <- sprintf("%s_%s.csv",  input$caption, input$description)
      # Write the data to a temporary file locally
      filePath <- file.path(tempdir(), fileName)
      write.csv(df, filePath, row.names = FALSE, quote = TRUE)
      # Upload the file to Dropbox
      drop_upload(filePath, path = outputDir)
    }
      saveData(df_products_upload())
  }
  )
  
  output$responses <- DT::renderDataTable({
    input$submit
    DT::datatable(df)
    loadData <- function() {
      # Read all the files into a list
      filesInfo <- drop_dir(outputDir)
      filePaths <- filesInfo$path
      df <- lapply(filePaths, drop_read_csv, stringsAsFactors = FALSE)
      # Concatenate all data together into one data.frame
      df <- do.call(rbind, df)
    }
    loadData()
  })
}
)

# Run the application 
shinyApp(ui = ui, server = server)