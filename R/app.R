# app.R

# Load the necessary packages
library(shiny)
library(leaflet) # Package for interactive maps
library(dplyr)# Package for data manipulation (used for map data)

# --- Define the User Interface (UI) ---
ui <- fluidPage(
  navbarPage(
    title = "danalitycs", # CHANGED: Webapp name changed to "danalitycs"
    
    # --- Tab 1: Home/Overview (Now includes a Map) ---
    tabPanel("Tab 1: Home (Map)",
             icon = icon("home"),
             h2("Welcome to the Home Tab with an Interactive Map"),
             p("Explore the map below, centered roughly on the United States."),
             
             # **Add the Leaflet Map Output**
             leafletOutput("homeMap", height = 400) 
    ),
    
    # --- Tab 2: Data Visualization ---
    tabPanel("Tab 2: Visualization", # MODIFIED: Content emptied
             icon = icon("chart-bar"),
             h2("Data Visualization"),
             p("This tab is currently empty.")
    ),
    
    # --- Tab 3: Data Table ---
    tabPanel("Tab 3: Data Table", # MODIFIED: Content emptied
             icon = icon("table"),
             h2("Explore the Data"),
             p("This tab is currently empty.")
    ),
    
    # --- Tab 4: About/Help ---
    tabPanel("Tab 4: About", # MODIFIED: Content emptied
             icon = icon("info-circle"),
             h2("About This App"),
             p("This tab is currently empty.")
    )
  )
)

# --- Define the Server Logic ---
server <- function(input, output) {
  
  # Logic for Tab 1: Home (Map)
  output$homeMap <- renderLeaflet({
    # Initial view: center on the US (approximate)
    leaflet() %>% 
      addTiles() %>% 
      setView(lng = -98.5795, lat = 39.8283, zoom = 4)
  })
}

# --- Run the application ---
shinyApp(ui = ui, server = server)