
library(tidyverse)
library(rusboost)
library(pROC)
load("C:/Users/cjy2001/OneDrive - Middlebury College/Middlebury Academic/Fall 2021/Project/Final_Data.RData")

# Plot all predictors and see if it changes dramatically in year 2008 (for loop one by one)
# Add some comments for for loops 
# Add some descriptions in between codes


new_yearly_auc <- NULL

for (i in 1:6) {
  roc_obj <- roc(predictor = yearly_preds[[i]]$prob[,2], 
               response = yearly_test_set[[i]]$misstate)
  new_yearly_auc[i] = auc(roc_obj)
  plot(roc_obj, legacy.axes = TRUE)
}


threshold <- seq(0.01, 1, by = 0.01) # Setting threshold vectors
new_sensitivity <- NULL
one_minus_specificity <- NULL

# Append observation's probability
new_test_8 <- cbind(test_8, year8_preds_3000$prob) %>% 
  rename("Yes" = "2", "No" = "1")


# Change the code chunk's setting "error" to be true so R will not stop executing when there is an error

for (i in 1:length(threshold)) {
  print(threshold[i]) # Let user know progress of the for loop so it can indicate the threshold at which the for loop should stop
  new_test_8 <- new_test_8 %>%
    mutate(preds = case_when(new_test_8$Yes >= threshold[i] ~ "Yes",
                           TRUE ~ "No")) #Add predicted fraudulence based on a threshold value to the train data frame and relabel it (so we can use it to construct confusion matrix)

#Confusion Matrix
new_result <- table(new_test_8$misstate, new_test_8$preds)[2:1, 2:1]
# Since I reverse the matrix every time, it will report an error when there is only one single column in the table, which means at that threshold, all companies will be predicted to be non-fraudulent. Therefore, I can use that feature along with the previous "print" function to know the specific stopping threshold.

# Sensitivity = TP/P
# Specificity = TN/N
new_sensitivity[i] <- new_result[1,1]/sum(new_result[1,])
one_minus_specificity[i] <- 1 - new_result[2,2]/sum(new_result[2,])
# Calculate the values on the x-axis and y-axis of the ROC curve so I can construct the curve manually 
}


new_test_8 <- new_test_8 %>%
  mutate(preds = case_when(new_test_8$Yes >= 0.54 ~ "Yes",
                         TRUE ~ "No"))
table(new_test_8$misstate, new_test_8$preds)

new_test_8 <- new_test_8 %>%
  mutate(preds = case_when(new_test_8$Yes >= 0.55 ~ "Yes",
                         TRUE ~ "No"))

table(new_test_8$misstate, new_test_8$preds)


ggplot() + 
  geom_point(aes(x = one_minus_specificity, y = new_sensitivity)) +
  geom_abline(intercept =0 , slope = 1)

data.frame(threshold = threshold[1:54], one_minus_specificity, new_sensitivity) %>% 
  filter(one_minus_specificity > 0.38 & one_minus_specificity < 0.875) %>% 
  arrange(one_minus_specificity)

hist(year8_preds_3000$votes[,2])
hist(year3_preds_3000$votes[,2])


library(reshape2)

data2 <- data %>% 
  mutate(misstate = as.numeric(as.character(misstate)))
#sapply(data2, class)

# stats <- data %>% 
#   filter(fyear < 2009) %>% 
#   group_by(fyear) %>%
#   summarise(across(.cols = everything(), mean, na.rm=TRUE))

# datatest <- data2 %>% 
#   filter(fyear == 2003) %>% 
#   select(misstate)
# 
# lapply(datatest, mean, na.rm = TRUE)

stats2 <- aggregate(data2[,2:51], list(data2$fyear), mean, na.rm=TRUE)

melted = melt(stats2, id.vars="Group.1", na.rm = TRUE)

melted %>% 
  ggplot() +
    geom_line(aes(x = Group.1, y = value, group = variable))
