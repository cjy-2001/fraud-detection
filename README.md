# Fraud Detection Project

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> This project focuses on building a machine learning model to detect fraudulent publicly traded U.S. firms. Various techniques are utilized, and the model's performance is evaluated based on precision, recall, and the area under the ROC curve.

## Table of Contents
- [Background](#background)
- [Install](#install)
- [Project Overview](#project-overview)
- [RUSBoost](#rusboost)
- [Result](#result)
- [References](#references)

## Background

This project is inspired by a study aimed at developing a novel out-of-sample fraud prediction model using ensemble learning techniques. Previous studies have focused on publicly traded U.S. firms' sample data over the period 1991–2008. The dataset was split into training and testing sets to maintain the model's intertemporal nature. In addition to their own prediction model derived from the RUSBoost method, they evaluated two benchmark models. One is a logistic regression model, and the other is a support vector machine model from Cecchini et al[1]. By implementing AUC and NDCG@k performance evaluation metrics, they demonstrated that their proposed RUSBoost model could yield more reliable predictions.

## Install

To set up this project, clone the repository and install the required R packages:

```bash
git clone git@github.com:cjy-2001/Fraud-Detection-Project.git
Rscript -e "install.packages(c('package1', 'package2'))"
```

## Project Overview

- Brief explanation of AUC and NDCG@k (wrote own function for NDCG@k).
- Explanation of how RUSBoost works and why we use it.
- Running of RUSBoost on the dataset, discussing parameters used and different numbers of trees attempted.
- Recreated some tables from the paper and discussed what these show.
- Results from RUSBoost, discussing differences between years.
- Discussion of the unusual ROC curve for 2008.
- Future steps include running RUSBoost on other datasets and experimenting with Support Vector Learning.


## RUSBoost

-Why do we need RUSBoost?

It is common to have largely skewed training data. In our case, the fraud firms are unevenly represented, and model constructed with the goal of detecting a can achieve a correct classification rate of 99% by classifying all firms as being non-fraud. However, that model is meaningless to us as our goal is to identify fraudulent firms as much as possible.

-How does RUSBoost work?

It combines both Data Resampling and Boosting (ensemble learning) techniques. As for the Data Reseampling, RUSBoost implements Undersampling technique, which means removing examples from the majority class. Meanwhile, RUSBoost uses Adaptive Boosting (Adaboosting). The Adaboosting mechanism works as following: as initial learners are weak, subsequent ones can be tweaked in favor for those wrongly identified observations; and then it combines the result of multiple “weak learners” based on weight. 

Therefore, RUSBoost reconciles undersampling’s problem by using boosting to offset the loss of information. Comparing to its brother SMOTEBoost, or as being a variant of SMOTEBoost, RUSBoost is more cost effective and less time consuming, as it provides a simple and efficient method for improving classification performance when training data is imbalanced. 

## Result

The models' average AUC value is similar to the paper's, except for the poor performance in 2008. Except for the years 2003, 2004, and 2005, our models generally do not perform well on the NDCG@k metric. Our models have a much higher average sensitivity, indicating that they are doing a better job. Our models have a slightly lower precision score.

The general trend is that the overall accuracy rate declines over the years, but this does not explain why the 2008 model is so unusual. This requires further investigation.

## References

[1] M. Cecchini, H. Aytug, G. J. Koehler, and P. Pathak, "A Support Vector Machine-Based Model for Detecting Top Management Fraud," in Proceedings of the 45th Annual Hawaii International Conference on System Sciences, 2012.<br />
[2] Y. Bao, B. Ke, B. Li, J. Yu, and J. Zhang, "Detecting Accounting Fraud in Publicly Traded U.S. Firms Using a Machine Learning Approach," Journal of Accounting Research, vol. 58, no. 1, pp. 199-235, 2020.<br />
[3] C. Seiffert, T. M. Khoshgoftaar, J. Van Hulse, and A. Napolitano, "RUSBoost: Improving Classification Performance when Training Data is Skewed," Florida Atlantic University, Boca Raton, Florida, USA, n.d.<br />
[4] JarFraud, "FraudDetection," GitHub, no commit ID given. [Online]. Available: https://github.com/JarFraud/FraudDetection.
