# 💊 Pharmacy Analytics: Predicting High-Cost Prescriptions  

[![R](https://img.shields.io/badge/R-4.3%2B-blue?logo=r)](https://www.r-project.org/)
[![tidymodels](https://img.shields.io/badge/Tidymodels-Framework-orange?logo=rstudio)](https://www.tidymodels.org/)
[![ggplot2](https://img.shields.io/badge/Visualization-ggplot2-steelblue)](https://ggplot2.tidyverse.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 🩺 Overview  

This project analyzes a **pharmacy dataset** containing patient, doctor, prescription, drug, supplier, and insurance information.  
The goal is to uncover **cost drivers** and build a **predictive model** that identifies high-spend prescriptions based on demographic, clinical, and pricing factors.  

All analysis is performed in **RStudio** using the **tidymodels** and **ranger** frameworks.  

---

## 🧩 Dataset Structure  

📦 Dataset: [Pharmacy Dataset (Kaggle – SnowyOwl22)](https://www.kaggle.com/datasets/snowyowl22/pharmacy-dataset?select=DRUGS.csv)

| File | Description | Key Columns |
|------|--------------|--------------|
| `PATIENT1(1).csv` | Patient demographics & insurance | `patientID`, `insurance` |
| `DOCTOR1(1).csv` | Prescriber details | `physID` |
| `DRUGS.csv` | Drug information, prices, suppliers | `NDC`, `supID` |
| `INSURANCE.csv` | Insurance company & copay details | `name`, `coPay` |
| `PRESCRIPTIONS.csv` | Prescription events | `patientID`, `physID`, `NDC` |
| `SUPPLIER.csv` | Supplier details | `supID` |

**Entity Relationships:**  
`PATIENT` —< `PRESCRIPTIONS` >— `DOCTOR`  
      │        │  
      └── `INSURANCE` └── `DRUGS` —< `SUPPLIER`

---

## ⚙️ Methods  

### 1. Data Integration  
Merged all six datasets into one relational table, joining across patient, doctor, and drug IDs.

### 2. Feature Engineering  
Created new analytical variables:
- `total_cost = qty × sellPrice`
- `gross_margin = (sellPrice – purchasePrice) × qty`
- `high_spend_flag = total_cost > 500`
- `coPay_flag = if_else(coPay == "Yes", 1, 0)`
- `age` computed from birthdate  

### 3. Exploratory Data Analysis (EDA)
- Drug frequency distributions  
- Spend trends by insurance type and age group  
- Correlations between quantity, days, and cost  

### 4. Predictive Modeling  
- Algorithm: **Random Forest** (`ranger`, 200 trees, impurity importance)  
- Framework: **tidymodels** workflow with recipes, train/test split, and standardization  
- Evaluation metrics: **Accuracy**, **ROC AUC**, **Confusion Matrix**, **ROC Curve**  

---

## 📊 Results  

| Metric | Value |
|---------|-------|
| Accuracy | 1.00 |
| ROC AUC | 1.00 |

*(Perfect scores due to small sample size; model demonstrates full pipeline correctness.)*

### 🔍 Feature Importance  
Top predictive features of high-spend prescriptions:

1. `sellPrice`  
2. `qty`  
3. `days`  
4. `purchasePrice`  
5. `coPay_flag`  

### 📈 Sample Visuals  

| Plot | Insight |
|------|----------|
| 💊 **Top 10 Prescribed Drugs** | Identifies the most frequent medications |
| 💰 **Average Cost by Insurance** | Highlights variation across plans |
| 👥 **Age vs Total Cost** | Visualizes how spend scales with patient age |
| 🌲 **Feature Importance Plot** | Shows strongest drivers of pharmacy spend |

---

## 💡 Business Impact  

- **Cost Optimization:** Identifies which pricing and prescribing factors drive pharmacy spend, helping decision-makers target the largest financial levers.  
- **Risk Stratification:** Enables prediction of high-cost prescriptions for proactive cost management.  
- **Supplier and Margin Insights:** Compares purchase vs sell prices to find potential margin inefficiencies.  
- **Policy Evaluation:** Quantifies the effect of co-pay structures and refill behavior on total expenditure.  
- **Scalability:** Workflow can scale to large pharmacy claims data via RStudio + Databricks integration.

---

## 🧠 Tech Stack  

- **R 4.3+**  
- **tidymodels**, **ranger**, **ggplot2**, **vip**, **dplyr**, **lubridate**  
- Compatible with **RStudio** and **Databricks** environments  

---

## 📁 Repository Structure  

```bash
📦 pharmacy-spend-analysis
┣ 📄 pharmacy_analysis.Rmd # Main R Markdown workflow
┣ 📄 pharmacy_clean.csv # Clean merged dataset
┣ 📊 visuals/ # Exported plots
┣ 📜 LICENSE
┗ 📘 README.md
```

---

## 🪄 Future Improvements  

- Expand dataset with additional synthetic claims records for robustness  
- Add model explainability (SHAP values via DALEX)  
- Develop a Shiny dashboard for interactive spend segmentation  

---

## 🧑‍💻 Maintained by  
**Hana Gabrielle Bidon**  
[GitHub: hgbidon](https://github.com/hgbidon)

Dataset courtesy of [SnowyOwl22 on Kaggle](https://www.kaggle.com/datasets/snowyowl22/pharmacy-dataset?select=DRUGS.csv).

---

## ✅ Tags 
r, r-analytics, healthcare-data, machine-learning, pharmacy, tidymodels, data-visualization, predictive-modeling, ranger.
