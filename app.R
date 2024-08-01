# Function to check and install missing packages
install_if_missing <- function(package) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package, dependencies = TRUE)
    library(package, character.only = TRUE)
  }
}

# List of required packages
required_packages <- c("shiny", "sf", "dplyr", "geosphere")

# Install and load required packages
lapply(required_packages, install_if_missing)

library(shiny)
library(sf)
library(dplyr)
library(geosphere)

# Function to interpolate points using linear interpolation
interpolate_points <- function(coords, interval) {
  # Select only the X and Y components (ignoring Z)
  coords <- coords[, c("X", "Y")]

  dists_ft <- calculate_distances(coords)
  cum_dists <- c(0, cumsum(dists_ft))

  # Create a sequence of distances for interpolation
  seq_dists <- seq(0, max(cum_dists), by = interval)

  # Linear interpolation for latitude and longitude
  lat_interp <- approx(cum_dists, coords[, 2], xout = seq_dists)$y
  lon_interp <- approx(cum_dists, coords[, 1], xout = seq_dists)$y

  new_coords <- cbind(lon_interp, lat_interp)

  return(data.frame(lat = new_coords[, 2], lon = new_coords[, 1], distance = seq_dists))
}

# Function to calculate distances between consecutive points
calculate_distances <- function(coords) {
  if (nrow(coords) < 2) {
    stop("Not enough points to calculate distances.")
  }

  dists <- vector("numeric", length = nrow(coords) - 1)
  for (i in 1:length(dists)) {
    dists[i] <- distVincentySphere(coords[i, ], coords[i + 1, ])
  }
  dists_ft <- dists * 3.28084  # Convert to feet
  return(dists_ft)
}

# Define UI for application
ui <- fluidPage(
  titlePanel("KML File Processor"),
  sidebarLayout(
    sidebarPanel(
      fileInput("kmlFile", "Upload KML File", accept = ".kml"),
      numericInput("intervalFt", "Enter the splitting interval (in feet):", value = 10, min = 1),
      downloadButton("downloadData", "Download CSV")
    ),
    mainPanel(
      verbatimTextOutput("status")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  interpolated_data <- reactiveVal(NULL)

  observeEvent(input$kmlFile, {
    req(input$kmlFile)
    kml_path <- input$kmlFile$datapath
    interval_ft <- input$intervalFt

    tryCatch({
      kml_data <- st_read(kml_path)

      # Filter only LINESTRING and MULTILINESTRING geometries
      line_geometries <- kml_data %>% filter(st_geometry_type(.) %in% c("LINESTRING", "MULTILINESTRING"))

      if (nrow(line_geometries) == 0) {
        stop("The KML file does not contain LINESTRING or MULTILINESTRING geometries.")
      }

      # Extract coordinates and layer names
      coords_list <- lapply(seq_len(nrow(line_geometries)), function(i) {
        geom <- line_geometries[i, ]
        coords <- st_coordinates(geom)
        layer_name <- if ("Name" %in% names(geom)) geom$Name else paste("Layer", i)
        list(coords = coords, name = layer_name)
      })

      # Debugging: Print out the coordinates and layer names
      print(coords_list)

      # Process each layer
      interpolated_layers <- lapply(coords_list, function(layer) {
        if (nrow(layer$coords) < 2) {
          return(NULL)
        }
        interpolated_df <- interpolate_points(layer$coords, interval_ft)
        interpolated_df$layer_name <- layer$name
        interpolated_df
      })

      interpolated_df <- do.call(rbind, interpolated_layers)
      interpolated_data(interpolated_df)

      output$status <- renderText("File processed successfully.")
    }, error = function(e) {
      output$status <- renderText(paste("An error occurred:", e$message))
    })
  })

  output$downloadData <- downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$kmlFile$name), "_interpolated.csv")
    },
    content = function(file) {
      write.csv(interpolated_data(), file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
