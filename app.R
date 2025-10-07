#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
require(shiny)
require(soiltexture)
require(shinythemes)
# Define UI for application that draws a histogram
ui <- fluidPage(
  theme = shinythemes::shinytheme("superhero")
  ,

    # Application title
    titlePanel("USDA Soil Texture"),
    # # Instructions for the user 
    p("Enter the percentages of sand, silt, and clay.
          Their sum should be 100."),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
          
            numericInput(
              inputId = "CLAY",
              label = "Clay %",
              value = 10,
              min = 0,
              max = 100,
              step = 1,
              width = "50%"
            ), 
            numericInput("SAND", "Sand %", 35, 0, 100, 1, "50%"),
            numericInput("SILT", "Silt %", 55, 0, 100, 1, "50%"),
            h4("TOTAL"),
            textOutput("sum_output"),
            
            # Add a download button for the plot
            downloadButton("downloadPlot", "Download Plot")
            
        ),
        

        # # The main panel for the soil texture calculator and plot
        mainPanel(
           
       
        
        plotOutput("soil_plot", width = "100%", height = "600px"
                   
                    )
        ),
        
        position = c("left", "right")
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  safe_inputs <- reactive({
    # Collect and clean inputs
    inputs <- list(SAND = input$SAND, CLAY = input$CLAY, SILT = input$SILT)
    
    # Replace any NA or NULL with 0
    cleaned_inputs <- lapply(inputs, function(x) {
      if (is.null(x) || is.na(x)) {
        return(0)
      } else {
        return(x)
      }
    })
    
    return(cleaned_inputs)
  })
  

  # Reactive expression to get the sum of soil components
  soil_sum <- reactive({
    data <- safe_inputs()
    sum(data$SAND, data$CLAY, data$SILT)
  })
  
  output$sum_output <-  renderText({
    paste(soil_sum(), "%")
  })
  # Create a reactive data frame for the soil data, normalizing the values
  soil_data <- reactive({
    data <- safe_inputs()
    CLAY_val <- data$CLAY
    SAND_val <- data$SAND
    SILT_val <- data$SILT
    
    total_sum <- sum(CLAY_val, SAND_val, SILT_val)
    
    # Avoid division by zero
    if (total_sum == 0) {
      return(data.frame(CLAY = 0, SILT = 0, SAND = 0))
    }
    # Normalize the values so they sum to 100
    normalized_clay <- (CLAY_val / total_sum) * 100
    normalized_silt <- (SILT_val / total_sum) * 100
    normalized_sand <- (SAND_val / total_sum) * 100
    
    data.frame(
      CLAY = normalized_clay,
      SILT = normalized_silt,
      SAND = normalized_sand
    )
    
   
})
  # Reactive to check if we have any non-zero data (to decide if the point should be drawn)
  has_data <- reactive({
    soil_sum() > 0
  })
  # 2. PLOTTING: Two-step plot to always draw the triangle
  output$soil_plot <- renderPlot({
    plot_data <- soil_data()
    # STEP 1: Always draw the empty triangle grid
    TT.plot(
            class.sys = "USDA.TT"
            
        ) 
    
    
    # STEP 2: Conditionally add the data point if the sum is greater than 0
    if (has_data()) {
      TT.plot(
        class.sys = "USDA.TT",
        tri.data = plot_data,
        col = "red",
        pch = 16,
        cex = 2,
        add = TRUE # Adds the point to the existing triangle plot
       
      )
    }
  })
  
  # 3. DOWNLOAD HANDLER: Replicates the two-step plot logic
  # ----------------------------------------------------
  
  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste("soil_triangle-", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      # Open a graphics device and plot to it
      png(file, width = 1200, height = 1000, res = 150, bg = "white")
      
      # STEP 1: Draw the empty triangle grid
      TT.plot(
        class.sys = "USDA.TT"
        
      )
      # STEP 2: Conditionally add the data point
      if (has_data()) {
        TT.plot(
          class.sys = "USDA.TT",
          tri.data = soil_data(),
          col = "red",
          pch = 19,
          cex = 2,
          add = TRUE
        )
      }
      # Close the graphics device to save the file
      dev.off()
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)

