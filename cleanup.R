### This script will clean images in a folder by looking for blanks and duplicates

library(imager)
# library(EBImage)
library(dplyr)
library(edgeR)
library(SPUTNIK)

rm(list = ls())
gc()

industries <- c('aircraft-manufacturers', 'airlines', 'airports', 'alcoholic-beverages', 'automakers', 'banks', 
                'beverages', 'chemicals', 'clothing', 'construction', 'delivery-services', 'e-commerce', 'electricity', 
                'financial-services', 'food', 'healthcare', 'hotels', 'insurance', 'internet', 'investment', 'media-press', 
                'mining', 'oil-gas', 'pharmaceuticals', 'ports', 'professional-services', 'railways', 'real-estate', 
                'restaurant-chains', 'retail', 'semiconductors', 'software', 'tech', 'telecommunication', 'tobacco', 'video-games')

image_folder <- '~/logoML/Data/Pictures/'
image_files <- list.files(image_folder, pattern = "\\.jpg$", full.names = TRUE)

for(industry in industries){
  
  # industry <- industries[6]
  
  image_files_subset <- image_files[grep(industry, image_files)]
  
  images_df <- expand.grid(image_name_1 = image_files_subset, image_name_2 = image_files_subset) %>%
    filter(image_name_1 != image_name_2)

  images_df$image_name_1 <- as.vector(images_df$image_name_1)
  images_df$image_name_2 <- as.vector(images_df$image_name_2)
  
  # Find duplicates as an unordered combination
  sorted_df <- t(apply(images_df, 1, function(row) sort(row)))
  images_df <- images_df[!duplicated(sorted_df), ]
  
  # images_df <- image_names_df
  
  # images_df$image_1 <- lapply(images_df$image_name_1, load.image)
  # images_df$image_2 <- lapply(images_df$image_name_2, load.image)
  
  # Add a blank column to hold the result of SSIM in tryCatch loop below
  images_df$similarity <- 0
  
  for (i in 1:nrow(images_df)){
    tryCatch({
      
      image_1 <- unlist(load.image(images_df$image_name_1[i]))
      image_2 <- unlist(load.image(images_df$image_name_2[i]))
      
      # Calculate difference and store result
      images_df$similarity[i] <- SSIM(image_1, image_2)
      
    }, error = function(e) {
      # Handle the error, e.g., print a message
      # cat("Error in SSIM calculation for row", i, ":", conditionMessage(e), "\n")
    })
  }

  # If the similarity is > 0.9, assume it's the same image and remove from folder
  # Note: hashing is way faster if you want images that are 100% the same
  
  repeated_images <- images_df$image_name_2[which(images_df$similarity > .9)]

  for (file_path in repeated_images) {
    if (file.exists(file_path)) {
      unlink(file_path, recursive = FALSE)
      cat("File removed:", file_path, "\n")
    } else {
      cat("File not found:", file_path, "\n")
    }
  }
}

# library(digest)
# 
# image_folder <- '~/logoML/Data/Pictures/'
# image_files <- list.files(image_folder, pattern = "\\.jpg$", full.names = TRUE)
# 
# # file_hashes <- sapply(image_files, function(file) digest(file, algo = "md5"))
# # 
# # duplicate_indices <- duplicated(file_hashes) | duplicated(file_hashes, fromLast = TRUE)
# # duplicate_files <- image_files[duplicate_indices]
# 
# 
# # Function to calculate hash for file content
# calculate_file_hash <- function(file_path) {
#   file_content <- readBin(file_path, what = "raw", n = file.info(file_path)$size)
#   digest(file_content, algo = "md5")
# }
# 
# # Calculate hashes for file content
# file_hashes <- sapply(image_files, calculate_file_hash)
# 
# # Identify duplicates
# duplicate_indices <- duplicated(file_hashes) | duplicated(file_hashes, fromLast = TRUE)
# duplicate_files <- image_files[duplicate_indices]
# 
# # Print the result
# print(duplicate_files)
# 
# # banks_331 & banks_313 (construction_119 and electricity_219 look similar)
# # investment_472 and investment_473
# 
# image_1 <- unlist(load.image(image_files[grep("investment_472.jpg", image_files)]))
# image_2 <- unlist(load.image(image_files[grep("investment_473.jpg", image_files)]))
# 
# SSIM(image_1, image_2)