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
