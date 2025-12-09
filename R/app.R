# app.R

# Load the necessary packages
library(shiny)
library(leaflet) 
library(dplyr)
library(here)   

# 1. SOURCE THE EXTERNAL DATA PROCESSOR FILE
source(here("R", "data_processor.R")) 


# --- Define the User Interface (UI) ---
ui <- fluidPage(
  navbarPage(
    title = "danalitycs",
    
    # --- Tab 1: Home/Overview (Map and Slider ONLY) ---
    tabPanel("Tab 1: Home (Map)",
             icon = icon("home"),
             h2("Welcome to the Home Tab with an Interactive Map"),
             
             # Map Output (Placed first, above controls)
             leafletOutput("homeMap", height = 400),
             
             # Controls Row (Slider ONLY)
             fluidRow(
               # The column is now 12 to take up the full width since the button is gone
               column(12, 
                      uiOutput("dateSliderUI") 
               )
             ),
             
             p("Explore the map above, showing events filtered by the selected year."),
             
             # Debug Output
             textOutput("debugOutput")
    ),
    
    # --- Tab 2, 3, 4 (Empty) ---
    tabPanel("Tab 2: Visualization", 
             icon = icon("chart-bar"),
             h2("Data Visualization"),
             p("This tab is currently empty.")
    ),
    tabPanel("Tab 3: Data Table", 
             icon = icon("table"),
             h2("Explore the Data"),
             p("This tab is currently empty.")
    ),
    tabPanel("Tab 4: About", 
             icon = icon("info-circle"),
             h2("About This App"),
             p("This tab is currently empty.")
    )
  )
)

# --- Define the Server Logic ---
server <- function(input, output, session) {
  
  # Removed: animate_state reactive value
  # Removed: animation_timer reactiveTimer
  
  # 2. Call the function once and store the data list reactively
  all_data <- reactive({
    isolate({
      read_all_data() 
    })
  })
  
  # Reactive expression to get the specific EMDAT data frame and clean the Year column
  emdat_data <- reactive({
    data_list <- all_data()
    req(data_list, data_list$emdat)
    
    data_frame <- data_list$emdat
    
    # CRITICAL FIX: Use the R-safe column name "Start.Year"
    if (!"Start.Year" %in% names(data_frame)) {
      warning("Error: 'emdat.csv' does not contain the expected column named 'Start.Year'.")
      return(NULL)
    }
    
    # Data cleaning/conversion for the "Start.Year" column
    data_frame %>%
      mutate(Start.Year = as.numeric(as.character(Start.Year))) %>%
      filter(!is.na(Start.Year)) 
  })
  
  # Dynamic Slider UI based on Data
  output$dateSliderUI <- renderUI({
    data <- emdat_data()
    req(data)
    
    min_year <- min(data$Start.Year, na.rm = TRUE)
    max_year <- max(data$Start.Year, na.rm = TRUE)
    
    # Define boundaries 
    slider_min <- ifelse(min_year < 2000, 2000, min_year)
    slider_max <- ifelse(max_year > 2025, 2025, max_year)
    
    # Create the single-value slider input
    sliderInput(
      inputId = "currentYear",
      label = "Select Year:",
      min = slider_min,
      max = slider_max,
      value = slider_min, 
      sep = "", 
      step = 1
    )
  })
  
  # Removed: All animation-related observers (input$playButton, reactiveTimer)
  
  # Filtered Data (Reactive Expression) - Filters for the single selected year
  filtered_data <- reactive({
    data <- emdat_data()
    req(input$currentYear, data) 
    
    data %>%
      filter(Start.Year == input$currentYear)
  })
  
  # DEBUG OUTPUT
  output$debugOutput <- renderText({
    data <- emdat_data()
    req(input$currentYear)
    if (is.null(data)) {
      return("Status: Data loading failed or 'Start.Year' column missing.")
    } else {
      count <- nrow(filtered_data())
      return(paste("Status: Data loaded successfully. Selected Year:", input$currentYear, ". Events found:", count))
    }
  })
  
  # Logic for Tab 1: Home (Map) - Initial map creation
  output$homeMap <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>% 
      setView(lng = -98.5795, lat = 39.8283, zoom = 4)
  })
  
  # Observer to update the map markers whenever the year changes
  observe({
    data_to_plot <- filtered_data()
    
    # ASSUMPTION: Data has columns named 'Latitude' and 'Longitude'
    req(all(c("Latitude", "Longitude") %in% names(data_to_plot)))
    
    proxy <- leafletProxy("homeMap", session) %>%
      
      # FIX: Use clearShapes() to reliably remove old circles
      clearShapes() %>% 
      
      addCircles(
        data = data_to_plot,
        lng = ~Longitude, 
        lat = ~Latitude,
        radius = 50000, 
        color = "#1f78b4",
        fillOpacity = 0.5,
        popup = ~paste("Year:", Start.Year)
      )
  })
  
}

# --- Run the application ---
shinyApp(ui = ui, server = server)