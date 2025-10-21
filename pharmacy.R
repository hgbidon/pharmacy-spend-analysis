# Install dependencies if needed
# install.packages(c("readr","dplyr","ggplot2","lubridate","tidymodels","vip"))

library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)
library(tidymodels)
library(vip)

## Load your six CSVs
# Read my CSV (adjust path)
# hanag_wdy1xo1\OneDrive\Documentos\archive
setwd("C:/Users/hanag_wdy1xo1/OneDrive/Documentos/archive")
doctor <- read.csv("DOCTOR1(1).csv")
drugs <- read.csv("DRUGS.csv")
insurance <- read.csv("INSURANCE.csv")
patient <- read.csv("PATIENT1(1).csv")
prescriptions <- read.csv("PRESCRIPTIONS.csv")
supplier <- read.csv("SUPPLIER.csv")

# Join all files
df_full <- prescriptions %>%
  left_join(patient, by = "patientID") %>%
  left_join(doctor, by = "physID") %>%
  left_join(drugs, by = "NDC") %>%
  left_join(supplier, by = "supID") %>%
  left_join(insurance, by = c("insurance" = "name"))

# Compute derived metrics
df_full <- df_full %>%
  mutate(
    birthdate = mdy(birthdate),
    age = floor(interval(birthdate, Sys.Date()) / years(1)),
    total_cost = qty * sellPrice,
    gross_margin = (sellPrice - purchasePrice) * qty,
    high_spend_flag = if_else(total_cost > 500, "High", "Normal"),
    coPay_flag = if_else(coPay == "Yes", 1, 0)
  ) %>%
  select(patientID, firstName, lastName, gender, age, insurance, coPay_flag,
         physID, name.x, NDC, brandName, dosage, qty, days, refills, status,
         total_cost, gross_margin, high_spend_flag, sellPrice, purchasePrice)

## Exploratory Data Analysis
# Basic Summary
summary(df_full)
glimpse(df_full)

# Top 10 Most Common Drugs
df_full %>%
  count(brandName, sort = TRUE) %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(brandName, n), y = n)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 Most Prescribed Drugs", x = "Drug", y = "Count")

# Spend by Insurance Type
df_full %>%
  group_by(insurance) %>%
  summarise(avg_cost = mean(total_cost, na.rm = TRUE)) %>%
  ggplot(aes(x = reorder(insurance, avg_cost), y = avg_cost, fill = insurance)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(title = "Average Prescription Cost by Insurance", x = "Insurance", y = "Average Cost ($)")

# Age vs Total Cost
ggplot(df_full, aes(x = age, y = total_cost)) +
  geom_point(alpha = 0.6, color = "darkred") +
  geom_smooth(method = "lm", se = FALSE, color = "black") +
  labs(title = "Age vs Total Prescription Cost", x = "Age", y = "Total Cost ($)")

# Correlation Between Quantity, Days, and Cost
df_full %>%
  select(qty, days, refills, total_cost) %>%
  cor(use = "complete.obs")

## Predictive Modeling — “High Spend Prescription” Classification
# Prepare Data
df_model <- df_full %>%
  filter(!is.na(high_spend_flag), !is.na(age), !is.na(gender)) %>%
  mutate(
    gender = factor(gender),
    high_spend_flag = factor(high_spend_flag)
  ) %>%
  select(high_spend_flag, age, gender, coPay_flag, qty, days, refills, sellPrice, purchasePrice)

# Train/Test Split
set.seed(123)
split <- initial_split(df_model, prop = 0.8, strata = high_spend_flag)
train <- training(split)
test <- testing(split)

# Recipe + Model
rec <- recipe(high_spend_flag ~ ., data = train) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_numeric_predictors())

rf_mod <- rand_forest(trees = 200, mtry = 4, min_n = 2) %>%
  set_engine("ranger") %>%
  set_mode("classification")

wf <- workflow() %>%
  add_model(rf_mod) %>%
  add_recipe(rec)

fit <- fit(wf, data = train)

# ✅ Make sure rf_fit exists
rf_fit <- wf %>% fit(data = train)

# ✅ Generate predictions
pred <- rf_fit %>%
  predict(new_data = test, type = "prob") %>%
  bind_cols(rf_fit %>% predict(new_data = test)) %>%
  bind_cols(test)

# ✅ Check structure
head(pred)

library(yardstick)

# Accuracy (uses predicted class)
accuracy(pred, truth = high_spend_flag, estimate = .pred_class)

# ROC AUC (uses probabilities)
roc_auc(pred, truth = high_spend_flag, .pred_High)

# Confusion matrix
conf_mat(pred, truth = high_spend_flag, estimate = .pred_class)

# ROC curve visualization
roc_curve(pred, truth = high_spend_flag, .pred_High) %>%
  autoplot()

metrics_all <- bind_rows(
  accuracy(pred, truth = high_spend_flag, estimate = .pred_class),
  roc_auc(pred, truth = high_spend_flag, .pred_High)
)
metrics_all

bind_rows(
  accuracy(pred, truth = high_spend_flag, estimate = .pred_class),
  roc_auc(pred, truth = high_spend_flag, .pred_High)
)

library(tidymodels)
library(vip)

# 1) Define RF with importance ON
rf_mod <- rand_forest(trees = 200, mtry = 4, min_n = 2) %>%
  set_engine("ranger", importance = "impurity") %>%   # << key!
  set_mode("classification")

# 2) Build a FRESH workflow (don’t reuse the old one)
wf_new <- workflow() %>%
  add_recipe(rec) %>%
  add_model(rf_mod)

# 3) Fit
rf_fit <- wf_new %>% fit(data = train)

# 4) Sanity check: do we have importance?
extract_fit_engine(rf_fit)$variable.importance  # should NOT be NULL

# 5) Plot VIP
rf_fit %>%
  extract_fit_parsnip() %>%
  vip(num_features = 10) +
  labs(title = "Top 10 Predictors of High Pharmacy Spend",
       subtitle = "Random forest (ranger) impurity importance")
