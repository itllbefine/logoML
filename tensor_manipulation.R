library(keras)
library(jpeg)
library(png)
# library(magick)
# library(EBImage)
library(dplyr)

rm(list = ls())
gc()


industries <- c('aircraft-manufacturers', 'airlines', 'airports', 'alcoholic-beverages', 'automakers', 'banks', 
                'beverages', 'chemicals', 'clothing', 'construction', 'delivery-services', 'e-commerce', 'electricity', 
                'financial-services', 'food', 'healthcare', 'hotels', 'insurance', 'internet', 'investment', 'media-press', 
                'mining', 'oil-gas', 'pharmaceuticals', 'ports', 'professional-services', 'railways', 'real-estate', 
                'restaurant-chains', 'retail', 'semiconductors', 'software', 'tech', 'telecommunication', 'tobacco', 'video-games')

image_folder <- '~/logoML/Data/Pictures/'
image_files <- list.files(image_folder, pattern = "\\.jpg$", full.names = TRUE)

train_files <- NULL
test_files <- NULL

# For reproducibility of sample() in for loop below
set.seed(666)

for(industry in industries){
  image_files_subset <- image_files[grep(industry, image_files)]
  train_indices <- sample(length(image_files_subset), 0.7 * length(image_files_subset))
  
  train_files_subset <- image_files_subset[train_indices]
  test_files_subset <- image_files_subset[-train_indices]
  
  train_files <- c(train_files, train_files_subset)
  test_files <- c(test_files, test_files_subset)
}


x <- readPNG(image_files[grep("automakers_53.jpg", image_files)]) # Tesla
# Below are examples of tensor manipulaion
# In this case, the channels of the output of readPNG are in order red, green, blue, and alpha
# x[, , 2][1000:2000] 
# x[100:110, 100:110, 2]
# x[60:80, 100:110, 2:3]
display(x[, , 1]) #


# Example integer labels
integer_labels <- c(0, 1, 2, 1, 0)

# Perform one-hot encoding
one_hot_labels <- to_categorical(integer_labels)

# Display the result
print(one_hot_labels)




