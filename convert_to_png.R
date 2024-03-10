library(magick)

# Set your input and output directories
input_directory <- "~/logoML/Data/JPEGs/"
output_directory <- '~/logoML/Data/Pictures/'

# List all .jpg files in the input directory
jpg_files <- list.files(input_directory, pattern = "\\.jpg$", full.names = TRUE)

# Function to convert .jpg to .png
convert_jpg_to_png <- function(input_file, output_directory) {
  # Read the image
  image <- image_read(input_file)
  
  # Generate the output file name with .png extension
  output_file <- file.path(output_directory, tools::file_path_sans_ext(basename(input_file))) %>%
    paste0(., ".png")
  
  # Write the image as .png
  image_write(image, output_file)
  
  cat("Converted", input_file, "to", output_file, "\n")
}

# Apply the conversion function to all .jpg files
for (jpg_file in jpg_files) {
  convert_jpg_to_png(jpg_file, output_directory)
}
