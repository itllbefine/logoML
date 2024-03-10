library(magick)
library(tidyverse)

image_folder <- '~/logoML/Data/Pictures/'
image_files <- list.files(image_folder, pattern = "\\.png$", full.names = TRUE)

images <- lapply(image_files, image_read)

num_images_per_row <- 50
num_rows <- ceiling(length(images) / num_images_per_row)

# Arrange images into rows
rows <- lapply(split(images, rep(1:num_rows, each = num_images_per_row, length.out = length(images))), function(row_images) {
  image_append(do.call(c, row_images), stack = FALSE)
})

# Stack rows vertically
mosaic_hq <- image_append(do.call(c, rows), stack = TRUE)

output_file <- '~/logoML/Data/mosaic_hq.png'
image_write(mosaic, output_file)

mosaic <- image_resize(mosaic_hq, "800x600")  # Adjust the size based on your preferences

output_file <- '~/logoML/Data/mosaic.png'
image_write(mosaic, output_file)


