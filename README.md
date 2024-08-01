# KML File Processor

An R Shiny application for processing KML files and interpolating points. This application allows users to upload a KML file, specify a splitting interval, and download the interpolated points as a CSV file.

## Features

- Upload KML files
- Interpolate points using linear interpolation
- Specify splitting interval (in feet)
- Download interpolated points as a CSV file

## Requirements

- R
- R packages: shiny, sf, dplyr, geosphere

## Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/anurag1roy/kml-file-processor.git
    ```

2. Navigate to the project directory:

    ```bash
    cd kml-file-processor
    ```

3. Install the required R packages:

    ```R
    install.packages(c("shiny", "sf", "dplyr", "geosphere"))
    ```

## Usage

1. Run the Shiny application:

    ```R
    library(shiny)
    runApp("app.R")
    ```

2. Open your web browser and go to the URL displayed in the R console (usually `http://127.0.0.1:xxxx`).

3. Upload your KML file, specify the splitting interval, and download the interpolated points as a CSV file.

## Code Overview

- **app.R**: Main file containing the Shiny UI and server logic.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or suggestions, feel free to contact the project maintainer.

