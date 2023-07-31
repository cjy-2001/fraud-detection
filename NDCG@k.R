
library(tidyverse)
library(broom)
library(ISLR)
library(pROC)
#library(StatRank)

home <- read_csv("uscecchini28.csv")

# home %>% 
#   select(fyear, misstate) %>% 
#   filter(fyear == 1990) %>% 
#   summarise(percent = sum(misstate == 1)/n())
# home %>% 
#   select(fyear, misstate) %>%
#   filter(fyear == 2000) %>% 
#   summarise(percent = sum(misstate == 1)/n())


# home2 <- home %>% 
#   select(fyear, misstate) %>%
#   group_by(fyear) %>% 
#   mutate(percent = sum(misstate == 1)/n())
# 
# home2 %>% 
#   ggplot(aes(x = fyear, y = percent)) + 
#   geom_line () +
#   geom_point() +
#   labs(x = "Year", y = "Fraud Percentage") + 
#   ggtitle("Yearly Fraud Percentage over Time") + 
#   theme(plot.title = element_text(hjust = 0.5))

# Passage of the Sarbanes-Oxley Act on July 30, 2002 (Enron Company)


# smp_size <- floor(0.70 * nrow(home))
# 
# train_ind <- sample(seq_len(nrow(home)), size = smp_size)
# 
# train <- home[train_ind, ]
# test <- home[-train_ind, ]


split_train_test <- function (year, data) {
  train <<- data %>%
    filter(fyear <= year - 2)

  test <<- data %>%
    filter(fyear == year)
}


# Use model to make predictions
# write a function takes input test year; split the test and training data
# split_train_test <- function (year) {return two data set}
# for (yr in 2003:2008){split_train_test(year)}
# Fit the logistic model and compute an AUC

result <- c(0)
i = 1

for (yr in 2003:2008){
  split_train_test(yr, home)

  default_model <- glm(formula = misstate ~ act + ap + at + ceq + che + cogs + csho +   dlc + dltis + dltt + ib + invt + ivao + ivst + lct + lt + ppegt + pstk + rect + sale + sstk + txp + prcc_f, data = train, family = "binomial") 
  
  pred_prob <- predict(default_model, newdata = test, type = "response") # predicted probabilities
  pred_class_labels <- ifelse(pred_prob > 0.5, "Yes", "No") # convert to labels
  
roc_obj <- roc(predictor = pred_prob, 
               response = test$misstate)

plot(roc_obj, legacy.axes = TRUE)

result[i] = auc(roc_obj)

i <- i + 1
}


NDCG <- function (k, Relevance, Predicted) {
# Calculate DCG@K
  DCGk <- 0
  for (i in 1:k){
    # Assign each observation's relevance value
    rel <- Predicted[i]
    # Sum up DCG values 
    DCGk = DCGk +(2^(rel) - 1)/(log2(i + 1))
  }

# Calculate ideal DCG@K
  iDCGk <- 0
  for (j in 1:k){
    # Similar to the previous for loop, we want to assign each observation's relevance value, except in this case all relevance scores are already ranked from highest to lowest (because it's ideal)
    rel <- Relevance[j]
    iDCGk = iDCGk +(2^(rel) - 1)/(log2(j + 1))
  }
  
  # Print out DCG@k and iDCG@k values
  cat("DCG of the predicted order is", DCGk, "\nDCG of the ideal order(iDCG) is", iDCGk, "\n")
  # Compute NDCG@k
  return(DCGk/iDCGk)
}


# First, define a function DCG which can calculate the DCG score
DCG <- function (k, ranking){
  DCG <- 0
  for (i in 1:k){
  DCG = DCG +(2^(ranking[i]) - 1)/(log2(i + 1))
  }
  return(DCG)
}

# Then implement the DCG function into the main NDCG function
NDCG2 <- function (k, Relevance, Predicted) {
# Calculate DCG@K
  DCGk <- DCG(k, Predicted)

# Calculate ideal DCG@K
  iDCGk <- DCG(k, Relevance)

  cat("DCG of the predicted order is", DCGk, "\nDCG of the ideal order(iDCG) is", iDCGk, "\n")
  return(DCGk/iDCGk)
}


# Adding prediction to a test set
default_model <- glm(formula = misstate ~ act + ap + at + ceq + che + cogs + csho +   dlc + dltis + dltt + ib + invt + ivao + ivst + lct + lt + ppegt + pstk + rect + sale + sstk + txp + prcc_f, data = train, family = "binomial") 

# In this case, k = the number of top 1% firms in a test year
k <- floor(0.01*nrow(test))

# Ideal order
RelevanceLevel <- sort(test$misstate, decreasing = TRUE)

# Recommendations order
testpred <- test %>% 
    mutate(pred = pred_prob <- predict(default_model, newdata = test, type = "response")) %>%
    arrange(desc(pred))
PredictedRank <- testpred$misstate

NDCG(k, RelevanceLevel, PredictedRank)
NDCG2(k, RelevanceLevel, PredictedRank)

# The logit method's NDCG@k value from the paper is 0.028
