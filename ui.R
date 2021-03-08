ui <- fluidPage(
  # tags$header(
  #   includeScript("Leaflet.glify-2.1.0/glify.js")
  # ),
  actionButton("go","Print values to server-side"),
  shinycssloaders::withSpinner(
    leafglOutput("mymap",height = "800px")
    ,size = 2,type = 6)
)