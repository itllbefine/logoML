library(imager)

rm(list = ls())
gc()

# Set the path to your input and output directories
input_directory <- '~/logoML/Data/Unpadded/'
output_directory <- '~/logoML/Data/Pictures/'

png_files <- list.files(input_directory, pattern = "\\.png$", full.names = TRUE)

# Function to pad images
pad_images <- function(image_path) {

  # image_path <- png_files[131]

  img <- load.image(image_path)
  img_channels <- channels(img)
  
  alpha_channel <- array(1, dim = c(128, 128, 1, 1))
  # alpha_channel <- array(255, dim = c(dim(img)[1:2], 1, 1))

  # Check the number of color channels
  num_channels <- length(img_channels)
  
  # For some reason, load.iamge appears to invert grayscale images (chatGPT suggests this is to make them easier to see)
  # To uninvert, subtract the image from 1
  if(num_channels == 1){
    img <- cimg(array(c(1 - img[, ], 1 - img[, ], 1 - img[, ], alpha_channel), dim = c(128, 128, 1, 4)))
    
  } else if(num_channels == 2){
    
    img <- cimg(array(c(1 - img[, , 2], 1 - img[, , 2], 1 - img[, , 2], alpha_channel), dim = c(128, 128, 1, 4)))
    
  } else if(num_channels == 3){
    
    img <- cimg(array(c(img[, , 1], img[, , 2], img[, , 3], alpha_channel), dim = c(128, 128, 1, 4)))
  } 
  
  

  # Save the resized and padded image
  output_path <- file.path(output_directory, tools::file_path_sans_ext(basename(image_path))) %>% paste0(".png")
  imager::save.image(img, output_path)
}

# Loop through all PNG images in the input directory

for (image_path in png_files) {
  pad_images(image_path)
}
