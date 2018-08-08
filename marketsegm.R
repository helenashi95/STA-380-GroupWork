
sm = read.csv('social_marketing.csv', header = TRUE)
#drop X column
sm <- sm[-c(1)]

# Center/scale the data
sm_scaled <- na.omit(sm) #scale(sm, center=TRUE, scale=TRUE)

#kmeans 
## first, consider just current events and politics
foodpol = sm_scaled[,c("food","politics")]
head(foodpol)
plot(foodpol)

# Use k-means to get 3 clusters
cluster_foodpol <- kmeans(foodpol, centers=3)


# Plot with labels
# type = 'n' just sets up the axes
plot(foodpol, xlim=c(-2,2.75), 
     type="n", xlab="food", ylab="politics")  
text(foodpol, labels=rownames(foodpol), 
     col=rainbow(3)[cluster_foodpol$cluster])

## same plot, but now with clustering on all protein groups
## change the number of centers to see what happens.
cluster_all <- kmeans(sm_scaled, centers=7, nstart=50)
names(cluster_all)

# Extract some of the information from the fitted model
cluster_all$centers
cluster_all$cluster

# Plot the clustering on the red-white meat axes
plot(sm_scaled[,"food"], sm_scaled[,"politics"], xlim=c(-2,2.75), 
     type="n", ylab="food", xlab="politics")
text(sm_scaled[,"food"], sm_scaled[,"politics"], labels=rownames(sm), 
     col=rainbow(7)[cluster_all$cluster]) ## col is all that differs from first plot


# Different variables
plot(sm_scaled[,"current_events"], sm_scaled[,"tv_film"], xlim=c(-2,2.75), 
     type="n", xlab="current events", ylab="tv film")
text(sm_scaled[,"current_events"], sm_scaled[,"tv_film"], labels=rownames(sm), 
     col=rainbow(7)[cluster_all$cluster]) ## col is all that differs from first plot

