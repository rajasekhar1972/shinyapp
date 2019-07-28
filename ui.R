library(shiny)

ui <- fluidPage(
  
  titlePanel("Natural Language Processing"),
  sidebarLayout(
    sidebarPanel(
      
      fileInput("filename", "Upload your file", multiple = FALSE, accept = NULL,
                width = NULL, buttonLabel = "Browse...",
                placeholder = "No file selected"),
      
      
      checkboxGroupInput("variable", "Parts of Speech:",
                         c("Adjective" = "ADJ",
                           "Noun"="NOUN",
                           "Proper Noun"= "PROPN",
                           "Adverb"="ADV",
                           "Verb"="VERB"),
                         c("ADJ","NOUN","PROPN")
      ),
      
      downloadButton("downloadData", "Download")
      
      
    ),
    
    mainPanel(
      
      tabsetPanel(
        
        tabPanel("Description" ,
                 
                 titlePanel("Description"),
                 
                 fluidRow(column(12,(includeHTML("desc.htm"))))
                 
        ),
        tabPanel("Annotated text", dataTableOutput(outputId = "postable")),
        tabPanel("Wordclouds",
                 fluidRow(column(6,plotOutput("nouncloud")),
                          column(6,plotOutput("verbcloud")))
                 #fluidRow(column(6,plotOutput("verbcloud"),offset=6))
        ),
        
        #"Wordclouds",plotOutput("wordcloud")),
        tabPanel("Co-occurences", plotOutput("plot")) 
      )
      
      #verbatimTextOutput("selected_pos")
      
      
      
    )
    
  )
  
)