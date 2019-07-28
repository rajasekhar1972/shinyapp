server <- function(input, output) {
  
  
  
  pos_tab=function(){
    
    req(input$filename)
    
    library(udpipe)
    library(textrank)
    library(lattice)
    library(igraph)
    library(ggraph)
    library(ggplot2)
    library(wordcloud)
    library(stringr)
    
    file = readLines(input$filename$datapath)
    file  =  str_replace_all(file, "<.*?>", "")
    english_model = udpipe_load_model("./english-ewt-ud-2.4-190531.udpipe")
    pos_tab<- udpipe_annotate(english_model, x = file)
    pos_tab <- as.data.frame(pos_tab)
    #t[,c('sentence_id','sentence')]=list(NULL)
    #pos_tab = subset(pos_tab, upos %in% input$variable )
    
    #tab = subset(tab,upos %in% c('NOUN','ADJ','PROPN') )
    #t=tab
    return (pos_tab)
    #options = list(pageLength = 10))
    
    
    
  }
  
  output$selected_var <- renderText({ 
    paste("You have selected", input$filename$name)})
  
  
  output$selected_pos <- renderText({ 
    paste(input$variable)})
  
  output$postable <- renderDataTable({
    x = subset(pos_tab(), upos %in% input$variable, with=FALSE)
    x[,c('sentence_id','sentence')]=list(NULL)
    x[0:100,]
    
  })
  
  
  output$downloadData <- downloadHandler(
    
    filename = function() {paste("annotated_",input$filename, ".csv", sep = "")},
    content = function(file) {write.csv(pos_tab(), file, row.names = FALSE)
      
    })
  
  
  
  output$nouncloud =renderPlot({
    library(wordcloud)
    
    all_nouns = subset(pos_tab(), upos %in% "NOUN")
    top_nouns = txt_freq(all_nouns$lemma)
    
    wordcloud(words = top_nouns$key, 
              freq = top_nouns$freq, 
              min.freq = 2, 
              max.words = 100,
              random.order = FALSE, 
              colors = brewer.pal(6, "Dark2"))
    
  })
  
  output$verbcloud =renderPlot({
    library(wordcloud)
    all_verbs = subset(pos_tab(), upos %in% "VERB") 
    top_verbs = txt_freq(all_verbs$lemma)
    
    wordcloud(words = top_verbs$key, 
              freq = top_verbs$freq, 
              min.freq = 2, 
              max.words = 100,
              random.order = FALSE, 
              colors = brewer.pal(6, "Dark2"))
    
    
  })
  
  
  output$plot <- renderPlot({
    
    cooc2 <- cooccurrence(   
      #x=pos_tab(),
      x = subset(pos_tab(), upos %in% input$variable, with=FALSE),
      term = "lemma", 
      group = c("doc_id"))
    
    
    
    library(igraph)
    library(ggraph)
    library(ggplot2)
    
    
    b=NULL
    for (pos in input$variable){b=paste(b," ",pos)}
    
    wordnetwork <- head(cooc2, 50)
    wordnetwork <- igraph::graph_from_data_frame(wordnetwork) # needs edgelist in first 2 colms.
    
    ggraph(wordnetwork, layout = "fr") +  
      
      geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
      geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
      
      theme_graph(base_family = "Arial Narrow") +  
      theme(legend.position = "none") +
      
      
      
      
      labs(title = "Cooccurrences within 3 words distance", subtitle = b)
    
    
    
  })
  
}