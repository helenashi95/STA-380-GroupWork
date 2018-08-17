library(tidyverse)
library(arules)
library(arulesViz)

## 1c. Cast this variable as a special arules "transactions" class
groceries <- read.transactions(file='groceries.txt',format='basket',sep = ',', rm.duplicates = TRUE, )

View(groceries)
str(groceries)
summary(groceries)
# Each row is a basket/transation; we have 8935 baskets (rows) and 169 items (columns)

## Visualization: barplot of top 20 items and frequency 
itemFrequencyPlot(groceries,topN=20,type="absolute",col='grey',xlab='Item',main='Frequency of Item Purchased')

## 2. Running the 'apriori' algorithm 
grules = apriori(groceries, 
                     parameter=list(support=.005, confidence=.5, maxlen=5))
# absolute minimum support count: 49

summary(grules)

# 873 rules (support > .005 & confidence >.1 & length (# items) <= 5; parameters from playlists.R)
# 22 rules (support > .005 & confidence >.6 & length (# items) <= 5
### 120 rules (support > .005 & confidence >.5 & length (# items) <= 5
# 15 rules (support > .01 & confidence >.5 & length (# items) <= 5
# 5622 rules (support > .001 & confidence >.5 & length (# items) <= 5

inspect(grules)

#### BELOW PARAMETERS WILL CHANGE BASED ON WHAT WE CHOOSE FOR SUPPORT AND CONFIDENCE ###

## 2a. Choose a subset (???)
inspect(subset(grules, subset=lift > 2.3)) # mean of lift, 55 rules
inspect(subset(grules, subset=confidence > 0.6)) # 22 rules
inspect(subset(grules, subset=lift > 2.3 & confidence > 0.6)) #22 rules

# 3. plot all the rules in (support, confidence) space
plot(grules)

# 3a. can swap the axes and color scales
plot(grules, measure = c("support", "lift"), shading = "confidence")

# 3b. "two key" plot: coloring is by size (order) of item set
plot(grules, method='two-key plot')

# 3c. can now look at subsets driven by the plot
inspect(subset(grules, support > 0.015)) #looked like most points < 0.015, 2 rules
inspect(subset(grules, confidence > 0.65)) #looked like most poins < 0.65, 3 rules

# 4. graph-based visualization
sub1 = subset(grules, subset=confidence > 0.01 & support > 0.005)
summary(sub1)
plot(sub1, method='graph') # graph for 100 rules

# 4a. graph for 100 rules 
plot(head(sub1, 100, by='lift'), method='graph') 

# 4b. export
# saveAsGraph(head(musicrules, n = 1000, by = "lift"), file = "grules.graphml")
