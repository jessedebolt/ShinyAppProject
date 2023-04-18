# Load libraries
library(shiny)
library(leaflet)
library(dplyr)
library(shinyWidgets)
library(DT)
library(shinythemes)

# Load data
college <- read.csv("college_pell2.csv")

# User Interface
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.min.css")
  ),
  
  tags$footer( HTML("<footer><b> Made with 'Shiny' by Jesse DeBolt ©2023</b></footer>"), align="left", style="position:absolute; bottom:0; width:95%; height:50px; color: #000000; padding: 0px; background-color: transparent; z-index: 1000;"),

  #  themeSelector(),

    # Application title
    titlePanel("US College Selection"),
        
    # Sidebar with a selectors, etc. for data filtering
    sidebarLayout(
        sidebarPanel(
          # Drop down for state
          pickerInput("state", "State", 
                      choices = unique(college$state),
                      options = list(`actions-box` = TRUE),
#                      selected = unlist(college$state), 
                      selected = "OR",
                      multiple = TRUE),

          # Drop down for public/private
          pickerInput("ownership", "Public or Private", 
                      choices = unique(college$ownership),
                      options = list(`actions-box` = TRUE),
#                      selected = unlist(college$ownership),
                      selected = "Public",
                      multiple = TRUE),
          
          # Drop down for adminRate          
          pickerInput("gender","Coed or Male/Female", 
                      choices = unique(college$gender), 
                      options = list(`actions-box` = TRUE),
                      selected = "COED",
                      multiple = FALSE),

          # Checkbox for graduate
          checkboxInput("graduate", "Graduate program available",
                        value = FALSE), 
          
          # Add submit button for reactive update
          submitButton("Update Tabs")),
        
        mainPanel(
          # Main panel with two tabs
          tabsetPanel(
            tabPanel("Map", leafletOutput("map")),
            tabPanel("Datatable", DT::dataTableOutput("datatable"))
          )
        )
    )
)



# Define server logic
server <- function(input, output) {

  # Create filtered data based on selections
  data_filtered <- reactive({
    college %>%
    filter(state == input$state,
           ownership == input$ownership,
           gender == input$gender,
           graduate_program == input$graduate
    )
  })
  
    output$map <- renderLeaflet({

        # Generate leaflet map
        leaflet(data_filtered()) %>%
        addTiles() %>%
        addMarkers(~longitude, ~latitude, popup = ~school_name)
          # addMarkers(~longitude, ~latitude, 
          #            popup = paste(college$school_name, "<br>",
          #                          "Website:", college$school_webpage))
        })
    
    
    # Create a DT::datatable
    output$datatable <- DT::renderDataTable({
      datatable(data = data_filtered(), caption = 'US colleges with noted criteria',
                extensions = c("Scroller", "Buttons"), 
                options = list(autoFill = TRUE, pageLength = 5, 
                               fixedColumns.left = 2, # !!! NOT working
                               deferRender = TRUE, rownames = FALSE, 
                               scrollX = TRUE, scrollY = "500px",
                               scroller = TRUE, dom = "Bfrtip",
                               buttons = c("copy", "csv", "excel", "pdf", "print"),
                               columnDefs = list(list(className = 'dt-head-center',
                                                      targets = 0:47),
                                                 list(className = 'dt-body-left',
                                                      targets = 1:47))),
                class = 'cell-boarder stripe hover'
                
                ) %>%
        formatStyle(columns = c(1:47), 
                     fontWeight = "bold")
    })
}


# Run the application 
shinyApp(ui = ui, server = server)
