server <- function(input, output, session) {
  
  output$mymap <- renderLeaflet(m)
  
  observeEvent(input$mymap_click, { # update the location selectInput on map clicks
    p <- input$mymap_click
    print(p)
  })
  observeEvent(input$go,{
    print(names(input))
  })
  
  
  
}

