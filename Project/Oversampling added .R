#### Load libraries ####
library(tidyverse)
library(data.table)
library(caret)

### Load File ###
folder <- "./Project/Data/BankData"
# zip_file <- file.path(folder, "Base.csv.zip")
# unzip(zip_file, exdir = folder)

# Check that Base.csv is now in the folder
list.files(folder, pattern = "Base.csv")

baf_base <- fread(file.path(folder, "Base.csv"))

dim(baf_base)
names(baf_base)
head(baf_base)

### Check fraud distribution ###

table(baf_base$fraud_bool)

round(prop.table(table(baf_base$fraud_bool)) * 100, 2)

### Prepare target variable ###
# fraud_bool:
# 0 = Not Fraud
# 1 = Fraud

baf_model <- baf_base %>%
  mutate(
    fraud_status = ifelse(fraud_bool == 1, "Fraud", "Not_Fraud"),
    fraud_status = factor(fraud_status, levels = c("Fraud", "Not_Fraud"))
  ) %>%
  select(-fraud_bool)

# Convert character variables to factors
baf_model <- baf_model %>%
  mutate(across(where(is.character), as.factor))

# Check data
glimpse(baf_model)

# Check class imbalance
table(baf_model$fraud_status)

round(prop.table(table(baf_model$fraud_status)) * 100, 2)


### Train/Test Split.###

set.seed(123)

train_index <- createDataPartition(
  baf_model$fraud_status,
  p = 0.70,
  list = FALSE
)

train_data <- baf_model[train_index, ]
test_data <- baf_model[-train_index, ]

# Check class balance before oversampling
table(train_data$fraud_status)
round(prop.table(table(train_data$fraud_status)) * 100, 2)

table(test_data$fraud_status)
round(prop.table(table(test_data$fraud_status)) * 100, 2)


### Oversample Training Data Only ###

set.seed(123)

train_data_over <- upSample(
  x = train_data %>% select(-fraud_status),
  y = train_data$fraud_status,
  yname = "fraud_status"
)

### Confirm oversampling worked ###

table(train_data_over$fraud_status)

round(prop.table(table(train_data_over$fraud_status)) * 100, 2)

dim(train_data)
dim(train_data_over)
dim(test_data)


# Check class balance after oversampling
table(train_data_over$fraud_status)

round(prop.table(table(train_data_over$fraud_status)) * 100, 2)

# Check size of oversampled training data
dim(train_data_over)

train_data_over
test_data

### Save oversampled training data ###

saveRDS(
  train_data_over,
  file.path(folder, "Base_train_data_oversampled.rds")
)

saveRDS(
  test_data,
  file.path(folder, "Base_test_data_original.rds")
)

print("!!!DONE!!!")
