### The purpose of this code is to learn how to apply machine learning to pictures.
### I have a hypothesis that a company's logo is sufficient to ascertain its industry with 90+% accuracy.

# devtools::install_version("keras", version = "2.9.0", dependencies = TRUE)
# devtools::install_version("reticulate", version = "1.34.0", dependencies = TRUE) # Latest version messes up to_categorical 

# install.packages("reticulate")
# install.packages("keras")

library(keras)
# library(magick)
# library(imager)
# library(png)
library(EBImage)
library(dplyr)
library(reticulate)

rm(list = ls())
gc()


industries <- c('aircraft-manufacturers', 'airlines', 'airports', 'alcoholic-beverages', 'automakers', 'banks', 
                'beverages', 'chemicals', 'clothing', 'construction', 'delivery-services', 'e-commerce', 'electricity', 
                'financial-services', 'food', 'healthcare', 'hotels', 'insurance', 'internet', 'investment', 'media-press', 
                'mining', 'oil-gas', 'pharmaceuticals', 'ports', 'professional-services', 'railways', 'real-estate', 
                'restaurant-chains', 'retail', 'semiconductors', 'software', 'tech', 'telecommunication', 'tobacco', 'video-games')

image_folder <- '~/logoML/Data/Pictures/'
image_files <- list.files(image_folder, pattern = "\\.png$", full.names = TRUE)

train_files <- NULL
test_files <- NULL

# For reproducibility of sample() in for loop below
set.seed(666)

for(industry in industries){
  # industry <- industries[33]
  
  image_files_subset <- image_files[grep(industry, image_files)]
  train_indices <- sample(length(image_files_subset), 0.7 * length(image_files_subset))
  
  train_files_subset <- image_files_subset[train_indices]
  test_files_subset <- image_files_subset[-train_indices]
  
  train_files <- c(train_files, train_files_subset)
  test_files <- c(test_files, test_files_subset)
}

train_images <- lapply(train_files, readImage)
test_images <- lapply(test_files, readImage)

train_stack <- abind(train_images, along = 4) %>% array_reshape(., c(length(train_images), 128, 128, 4))
dim(train_stack)
# train_stack <- aperm(combine(train_images), c(4, 1, 2, 3))

test_stack <- abind(test_images, along = 4)
test_stack <- array_reshape(test_stack, c(length(test_images), 128, 128, 4))

# Alpha channel breaks keras sequential
train_stack <- train_stack[, , , 1:3]
test_stack <- test_stack[, , , 1:3]


# \/\/ One hot encoding converts categories to binary values, in this case over the 36 industries used
#  \/

industry_mapping <- setNames(1:length(industries), industries)

one_hot_encode_industry <- function(file_name, industry_mapping){
  industry <- industries[grep(paste(industries, collapse = "|"), file_name)]
  industry_label <- industry_mapping[industry]
  one_hot_label <- to_categorical(industry_label, num_classes = length(industries))
  # one_hot_label <- grep(industry_label, industries)
  return(one_hot_label)
} 

train_labels <- lapply(train_files, one_hot_encode_industry, industry_mapping)%>%
  do.call(rbind, .)

test_labels <- lapply(test_files, one_hot_encode_industry, industry_mapping) %>%
  do.call(rbind, .)

#  /\
# /\/\ End one hot encoding

# Build the CNN model
model <- keras_model_sequential() %>%
  layer_conv_2d(filters = 32, kernel_size = c(3, 3), activation = 'relu', input_shape = c(128, 128, 3)) %>%
  layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = 'relu') %>%
  layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_flatten() %>%
  layer_dense(units = 128, activation = 'relu') %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 36, activation = 'softmax')  # Adjust the number of units based on your output classes (36)

# Compile the model
model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_adam(),
  metrics = c('accuracy')
)

# # Train the model
# history <- model %>% fit(
#   train_images, train_labels,
#   epochs = 10,  # Adjust the number of epochs based on your needs
#   batch_size = 36,  # Adjust the batch size based on your needs
#   validation_data = list(test_images, test_labels)
# )

history <- model %>% fit(
  train_stack, train_labels,
  epochs = 10,  # Adjust the number of epochs based on your needs
  batch_size = 36,  # Adjust the batch size based on your needs
  validation_data = list(test_stack, test_labels)
)

# Evaluate the model on the test set
eval_result <- model %>% evaluate(test_stack, test_labels)

# Print the evaluation results
print(eval_result)


