library(mosaic)
library(quantmod)
library(foreach)

######################################################################################
########################### EVEN WEIGHTS #############################################
######################################################################################

# Import a few stocks
mystocks = c("SPY", "TLT", "LQD", "EEM", "VNQ")
getSymbols(mystocks)

# Adjust for splits and dividends
SPYa = adjustOHLC(SPY)
TLTa = adjustOHLC(TLT)
LQDa = adjustOHLC(LQD)
EEMa = adjustOHLC(EEM)
VNQa = adjustOHLC(VNQ)

# Look at close-to-close changes
#see if you get good/bad runs
plot(ClCl(VNQa))

# Combine close to close changes in a single matrix
all_returns = cbind(ClCl(SPYa),ClCl(TLTa),ClCl(LQDa), ClCl(EEMa), ClCl(VNQa))
head(all_returns)
all_returns = as.matrix(na.omit(all_returns))

# These returns can be viewed as draws from the joint distribution
pairs(all_returns)
plot(all_returns[,1], type='l')

# Look at the market returns over time
plot(all_returns[,3], type='l')

# An autocorrelation plot: nothing there
acf(all_returns[,3])

# The sample correlation matrix
cor(all_returns)


#### Now use a bootstrap approach
#### With more stocks

mystocks = c("SPY", "TLT", "LQD", "EEM", "VNQ")
myprices = getSymbols(mystocks, from = "2007-01-01")


# A chunk of code for adjusting all stocks
# creates a new object addind 'a' to the end
# For example, WMT becomes WMTa, etc
for(ticker in mystocks) {
  expr = paste0(ticker, "a = adjustOHLC(", ticker, ")")
  eval(parse(text=expr))
}

head(SPYa)

# Combine all the returns in a matrix
all_returns = cbind(	ClCl(SPYa),
                     ClCl(TLTa),
                     ClCl(LQDa),
                     ClCl(EEMa),
                     ClCl(VNQa))
head(all_returns)
all_returns = as.matrix(na.omit(all_returns))

# Compute the returns from the closing prices
pairs(all_returns)

# Sample a random return from the empirical joint distribution
# This simulates a random day
return.today = resample(all_returns, 1, orig.ids=FALSE)

# Update the value of your holdings
# Assumes an equal allocation to each asset
total_wealth = 100000
my_weights = c(0.2,0.2,0.2, 0.2, 0.2)
holdings = total_wealth*my_weights
holdings = holdings*(1 + return.today)

# Compute your new total wealth
total_wealth = sum(holdings)


# Now loop over two trading weeks
total_wealth = 100000
weights = c(0.2, 0.2, 0.2, 0.2, 0.2)
holdings = weights * total_wealth
n_days = 20
wealthtracker = rep(0, n_days) # Set up a placeholder to track total wealth
for(today in 1:n_days) {
  return.today = resample(all_returns, 1, orig.ids=FALSE)
  holdings = holdings + holdings*return.today
  total_wealth = sum(holdings)
  wealthtracker[today] = total_wealth
}
total_wealth
plot(wealthtracker, type='l')


# Now simulate many different possible scenarios  
initial_wealth = 100000
sim1 = foreach(i=1:5000, .combine='rbind') %do% {
  total_wealth = initial_wealth
  weights = c(0.2, 0.2, 0.2, 0.2, 0.2)
  holdings = weights * total_wealth
  n_days = 20
  wealthtracker = rep(0, n_days)
  for(today in 1:n_days) {
    return.today = resample(all_returns, 1, orig.ids=FALSE)
    holdings = holdings + holdings*return.today
    total_wealth = sum(holdings)
    wealthtracker[today] = total_wealth
  }
  wealthtracker
}

head(sim1)
hist(sim1[,n_days], 25)

# Profit/loss
mean(sim1[,n_days])
hist(sim1[,n_days]- initial_wealth, breaks=30)

# Calculate 5% value at risk
quantile(sim1[,n_days], 0.05) - initial wealth


###############################################################################
#########################~~~~SAFER MODEL~~~~~~~~~~~############################
##############################################################################

#safer investments are US Treasury bonds and Real Estate

rm(list=ls(all=TRUE))

mystocks = c("SPY", "TLT", "LQD", "EEM", "VNQ")
myprices = getSymbols(mystocks, from = "2007-01-01")


# A chunk of code for adjusting all stocks
# creates a new object addind 'a' to the end
# For example, WMT becomes WMTa, etc
for(ticker in mystocks) {
  expr = paste0(ticker, "a = adjustOHLC(", ticker, ")")
  eval(parse(text=expr))
}

head(SPYa)

# Combine all the returns in a matrix
all_returns = cbind(	ClCl(SPYa),
                     ClCl(TLTa),
                     ClCl(LQDa),
                     ClCl(EEMa),
                     ClCl(VNQa))
head(all_returns)
all_returns = as.matrix(na.omit(all_returns))

# Compute the returns from the closing prices
pairs(all_returns)

# Sample a random return from the empirical joint distribution
# This simulates a random day
return.today = resample(all_returns, 1, orig.ids=FALSE)

# Update the value of your holdings
# TLT and VNQ are safer than others (Treasury and Real Estate safe)
#Split 80/20 safe/risky
total_wealth = 100000
my_weights = c(0.667,0.4,0.667, 0.666, 0.4)
holdings = total_wealth*my_weights
holdings = holdings*(1 + return.today)

# Compute your new total wealth
total_wealth = sum(holdings)


# Now loop over two trading weeks
total_wealth = 100000
weights = c(0.667,0.4,0.667, 0.666, 0.4)
holdings = weights * total_wealth
n_days = 20
wealthtracker = rep(0, n_days) # Set up a placeholder to track total wealth
for(today in 1:n_days) {
  return.today = resample(all_returns, 1, orig.ids=FALSE)
  holdings = holdings + holdings*return.today
  total_wealth = sum(holdings)
  wealthtracker[today] = total_wealth
}
total_wealth
plot(wealthtracker, type='l')


# Now simulate many different possible scenarios  
initial_wealth = 100000
sim1 = foreach(i=1:5000, .combine='rbind') %do% {
  total_wealth = initial_wealth
  weights = c(0.667,0.4,0.667, 0.666, 0.4)
  holdings = weights * total_wealth
  n_days = 20
  wealthtracker = rep(0, n_days)
  for(today in 1:n_days) {
    return.today = resample(all_returns, 1, orig.ids=FALSE)
    holdings = holdings + holdings*return.today
    total_wealth = sum(holdings)
    wealthtracker[today] = total_wealth
  }
  wealthtracker
}

head(sim1)
hist(sim1[,n_days], 25)

# Profit/loss
mean(sim1[,n_days])
hist(sim1[,n_days]- initial_wealth, breaks=30)

# Calculate 5% value at risk
quantile(sim1[,n_days], 0.05) - initial_wealth
#OR IS IT SWITCHED?

###############################################################################
#########################~~~~RISKY MODEL~~~~~~~~~~~############################
##############################################################################

#Risky Models are equities and bonds

rm(list=ls(all=TRUE))

mystocks = c("SPY", "TLT", "LQD", "EEM", "VNQ")
myprices = getSymbols(mystocks, from = "2007-01-01")


# A chunk of code for adjusting all stocks
# creates a new object addind 'a' to the end
# For example, WMT becomes WMTa, etc
for(ticker in mystocks) {
  expr = paste0(ticker, "a = adjustOHLC(", ticker, ")")
  eval(parse(text=expr))
}

head(SPYa)

# Combine all the returns in a matrix
all_returns = cbind(	ClCl(SPYa),
                     ClCl(TLTa),
                     ClCl(LQDa),
                     ClCl(EEMa),
                     ClCl(VNQa))
head(all_returns)
all_returns = as.matrix(na.omit(all_returns))

# Compute the returns from the closing prices
pairs(all_returns)

# Sample a random return from the empirical joint distribution
# This simulates a random day
return.today = resample(all_returns, 1, orig.ids=FALSE)

# Update the value of your holdings
# TLT and VNQ are safer than others (Treasury and Real Estate safe)
#Split 80/20 safe/risky
total_wealth = 100000
my_weights = c(0.26, 0.1, 0.27, 0.27, 0.1)
holdings = total_wealth*my_weights
holdings = holdings*(1 + return.today)

# Compute your new total wealth
total_wealth = sum(holdings)


# Now loop over two trading weeks
total_wealth = 100000
weights = c(0.26, 0.1, 0.27, 0.27, 0.1)
holdings = weights * total_wealth
n_days = 20
wealthtracker = rep(0, n_days) # Set up a placeholder to track total wealth
for(today in 1:n_days) {
  return.today = resample(all_returns, 1, orig.ids=FALSE)
  holdings = holdings + holdings*return.today
  total_wealth = sum(holdings)
  wealthtracker[today] = total_wealth
}
total_wealth
plot(wealthtracker, type='l')


# Now simulate many different possible scenarios  
initial_wealth = 100000
sim1 = foreach(i=1:5000, .combine='rbind') %do% {
  total_wealth = initial_wealth
  weights = c(0.26, 0.1, 0.27, 0.27, 0.1)
  holdings = weights * total_wealth
  n_days = 20
  wealthtracker = rep(0, n_days)
  for(today in 1:n_days) {
    return.today = resample(all_returns, 1, orig.ids=FALSE)
    holdings = holdings + holdings*return.today
    total_wealth = sum(holdings)
    wealthtracker[today] = total_wealth
  }
  wealthtracker
}

head(sim1)
hist(sim1[,n_days], 25)

# Profit/loss
mean(sim1[,n_days]) 
hist(sim1[,n_days]- initial_wealth, breaks=30)

# Calculate 5% value at risk
quantile(sim1[,n_days], 0.05) - initial_wealth 
#OR IS IT SWITCHED?
