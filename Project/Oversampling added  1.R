#### Load libraries ####
library(tidyverse)
library(data.table)
library(caret)
library(rpart)
library(rpart.plot)
library(pROC)

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

head(train_data_over)
glimpse(test_data)

### Save oversampled training data ###

saveRDS(
  train_data_over,
  file.path(folder, "Base_train_data_oversampled.rds")
)

saveRDS(
  test_data,
  file.path(folder, "Base_test_data_original.rds")
)

### Confirm the dataset ###
exists("train_data_over")
exists("test_data")

dim(train_data_over)
dim(test_data)

table(train_data_over$fraud_status)
table(test_data$fraud_status)

### create Target Variable ###
train_data_over$fraud_status <- factor(
  train_data_over$fraud_status,
  levels = c("Not_Fraud", "Fraud")
)

test_data$fraud_status <- factor(
  test_data$fraud_status,
  levels = c("Not_Fraud", "Fraud")
)

table(train_data_over$fraud_status)
table(test_data$fraud_status)

### Desicion Tree Model ###
set.seed(123)

tree_model <- rpart(
  fraud_status ~ .,
  data = train_data_over,
  method = "class",
  control = rpart.control(
    cp = 0.001,
    maxdepth = 5
  )
)

print(tree_model)

rpart.plot(
  tree_model,
  type = 3,
  extra = 104,
  fallen.leaves = TRUE,
  main = "Decision Tree for Bank Account Fraud"
)

### Test the Prediction of the D.T. ###
tree_prob <- predict(
  tree_model,
  newdata = test_data,
  type = "prob"
)[, "Fraud"]

# using 50% threshold
tree_pred_50 <- ifelse(tree_prob >= 0.50, "Fraud", "Not_Fraud")

tree_pred_50 <- factor(
  tree_pred_50,
  levels = c("Not_Fraud", "Fraud")
)

# Confusion Matrix
confusionMatrix(
  tree_pred_50,
  test_data$fraud_status,
  positive = "Fraud"
)


### trying a lower threshold for increased accuracy ###
evaluate_model <- function(actual, predicted_prob, threshold) {
  predicted_class <- ifelse(predicted_prob >= threshold, "Fraud", "Not_Fraud")
  predicted_class <- factor(
    predicted_class,
    levels = c("Not_Fraud", "Fraud")
  )
  actual <- factor(
    actual,
    levels = c("Not_Fraud", "Fraud")
  )
  cm <- confusionMatrix(
    predicted_class,
    actual,
    positive = "Fraud"
  )
  data_frame(
    Threshold = threshold,
    Accuracy = round(as.numeric(cm$overall["Accuracy"]), 4),
    Precision = round(as.numeric(cm$byClass["Pos Pred Value"]), 4),
    Recall = round(as.numeric(cm$byClass["Recall"]), 4),
    F1 = round(as.numeric(cm$byClass["F1"]), 4)
  )
}

tree_threshold_results <- bind_rows(
  evaluate_model(test_data$fraud_status, tree_prob, 0.50),
  evaluate_model(test_data$fraud_status, tree_prob, 0.30),
  evaluate_model(test_data$fraud_status, tree_prob, 0.20),
  evaluate_model(test_data$fraud_status, tree_prob, 0.10),
) %>%
  mutate(Model = "Decision Tree")

tree_threshold_results

### ROC Curve and AUC for D.T. ###
tree_roc <- roc(
  response = test_data$fraud_status,
  predictor = tree_prob,
  levels = c("Not_Fraud", "Fraud")
)

auc(tree_roc)

plot(
  tree_roc,
  main = "ROC Curve for Decision Tree Fraud Model"
)



#### logistic Regression Model using oversampling ###
logit_model <- glm(
  fraud_status ~ .,
  data = train_data_over,
  family = binomial()
)
summary(logit_model)

# L.R. Predictions Test
logit_prob <- predict(
  logit_model,
  newdata = test_data,
  type = "response"
)

head(logit_prob)

## L. R. Results
logit_threshold_results <- bind_rows(
  evaluate_model(test_data$fraud_status, logit_prob, 0.50),
  evaluate_model(test_data$fraud_status, logit_prob, 0.30),
  evaluate_model(test_data$fraud_status, logit_prob, 0.20),
  evaluate_model(test_data$fraud_status, logit_prob, 0.10),
) %>%
  mutate(Model = "Logistic Regression")

logit_threshold_results

### ROC Curve and AUC for L.R. ###
logit_roc <- roc(
  response = test_data$fraud_status,
  predictor = logit_prob,
  levels = c("Not_Fraud", "Fraud")
)

auc(logit_roc)

plot(
  logit_roc,
  main = "ROC Curve for Logiswtic Regression Fraud Model"
)


### Model Comparison (D.T. and Logistic Regression) ###

model_comparison <- bind_rows(
  tree_threshold_results,
  logit_threshold_results,
) %>%
  select(Model, Threshold, Accuracy, Precision, Recall, F1)

model_comparison

print("!!!DONE!!!")
