Flights at ABIA
===============

### Best Time of Day

For all of the below analysis on delayed flights, we have standardized
the number of delayed flights with the total number of flights in the
given time period, and only considered delays longer than 20 minutes. We
did not want to include a large number of trivial delays of only a few
minutes. We also separated flights departing from those arriving in
Austin with the hope of isolating delays happening at ABIA from those
all around the country. When looking at time of day, delays esspecially
for arrivals increases towards the end of the day because of the effects
from delays in previous connecting flights that day. Interestingly,
departure delays spike at 11 AM, which might be caused by heavy air
traffic as many people don't want to fly early in the morning.

![](HW_2_files/figure-markdown_strict/Time%20of%20Day-1.png)

### Best Day of the Week

A similar analysis was run below for delayed flights by aggregating
across the day of the week. The delay frequencies seem to follow busy
times of air travel (Friday and Sunday/Monday). While people commonly
avoid flying on weekends in general, Saturday actually shows the lowest
percentage of delayed flights while Thursday has an unexpectedly high
number of delays. Again, arrival delays are consistently more common
than departures because they have a much larger number of influencing
factors in airports around the country.

![](HW_2_files/figure-markdown_strict/Day%20of%20the%20Week-1.png)

### Best Time of Year

Now looking at a weekly scale, we can see seasonal and event-driven
fluctuations in flight delays such as during the holidays, summer
vacations, and SXSW. An important observation to note that we have seen
in some form above, is that departure delays follow arrival delay
patterns almost exaclty, just to a lesser degree. If we assume a
majority of delayed departures from ABIA are caused by delayed arrivals,
the consistent difference between them can be interpreted as the arrival
delays that were compensated for at ABIA. The fall season has
significantly less delayed flights, likely to lower traffic in general.
Here we can see the gap between arrivals and departures approach zero as
the delay frequency approaches 5%. This may be the actual amount of
departures that were delayed due to issues at ABIA.

![](HW_2_files/figure-markdown_strict/Time%20of%20Year-1.png)

### Best Locations

Aggregating flights over the entire year, we can see the best and worst
airports in terms of flight delays to and from Austin. A majority of the
most delayed destinations are in the north of the country, which sees a
much higher rate of delays simply due to weather. As expected the
largest airports including JFK, Newark, and O'hare also show the most
flight delays going both ways. The exception to this is LAX, which shows
a surpsingly low rate of delays (under 10% overall). Other than LAX, the
least delayed airports are generally smaller than average.

    #Departures
    delayport = table(delayed$Dest)
    flightcounts = table(df[df$Origin=='AUS',]$Dest)
    delayport = as.matrix(rbind(delayport,flightcounts))
    delayport[1,] = delayport[1,]/delayport[2,]
    delayport = delayport[,-3]

    #Arrivals
    delayport.A = table(delayed.A$Origin)
    flightcounts.A = table(df[df$Origin!='AUS',]$Origin)
    delayport.A = as.matrix(rbind(delayport.A,flightcounts.A))
    delayport.A[1,] = delayport.A[1,]/delayport.A[2,]
    delayport.A = delayport.A[,-3]

    #Combine and plot
    portlist = intersect(colnames(delayport), colnames(delayport.A))
    portmatrix = matrix(0,nrow=2,ncol=length(portlist))
    rownames(portmatrix) = c('Departures', 'Arrivals')
    colnames(portmatrix) = portlist
    portmatrix[1,] = delayport[1,portlist]
    portmatrix[2,] = delayport.A[1,portlist]

    par(mfrow=c(2,2))
    barplot(sort(portmatrix[1,])[39:49], main='Most Delayed Destinations', col=rgb(0,0,1,1), ylab='% Delayed (20+ min)', ylim=c(0,.4), las=2)
    barplot(sort(portmatrix[1,])[1:10], main='Least Delayed Destinations',col=rgb(0,0,1,1/2), ylab='% Delayed (20+ min)', ylim=c(0,.4), las=2)
    barplot(sort(portmatrix[2,])[39:49], main='Most Delayed Arrivals',col=rgb(1,1/2,0,1), ylab='% Delayed (20+ min)', ylim=c(0,.4), las=2)
    barplot(sort(portmatrix[2,])[1:10], main='Least Delayed Arrivals',col=rgb(1,1/2,0,1/2), ylab='% Delayed (20+ min)', ylim=c(0,.4), las=2)

![](HW_2_files/figure-markdown_strict/Airports-1.png)

### Traffic

The histogram below shows the frequency of flights based on their flight
times. The majority of flights to and from Austin are less than one
hour, most of which go through Houston and Dallas. The next peak in
number of flights is in the 2.5 hour range and major airports within
this range include Pheonix, Denver, and Chicago. The far right tail
includes the longest flights to areas in the US such as Seattle and
Boston. These inferences are supported by the map below, which shows the
number of flights departing Austin by airport. The map for flights
arriving in Austin is virtually identical.

    ap = read.csv('C:/Users/Abraham/Documents/UT/MSBA/Intro Predictive Modeling/HW2/Airports.csv')

    ports = ap[ap$type=='large_airport',c('iata_code','latitude_deg','longitude_deg')]

    dforigin = merge(df, ports, by.x='Origin', by.y='iata_code')
    dfdest = merge(df, ports, by.x='Dest', by.y='iata_code')

    dfomap = summaryBy(dforigin~Origin+longitude_deg+latitude_deg, data=dforigin,FUN=length)
    dfomap = dfomap[dfomap$Origin!='AUS',]
    dfdmap = summaryBy(dfdest~Dest+longitude_deg+latitude_deg, data=dfdest,FUN=length)
    dfdmap = dfdmap[dfdmap$Dest!='AUS',]

    us <- c(left = -125, bottom = 25.75, right = -67, top = 49)
    map <- get_stamenmap(us, zoom = 5, maptype = "toner-lite")

    hist(df$ActualElapsedTime, breaks=35, xaxp  = c(0, 360, 6), xlim=c(0,360), main='Flight Times', xlab='Elapsed Time (min)', col = rgb(0,0,1,3/4))

![](HW_2_files/figure-markdown_strict/Maps-1.png)

    ggmap(map) + geom_point(aes(x = longitude_deg, y = latitude_deg, size = Dest.length), data = dfdmap, color='blue', alpha=0.5)  + 
      theme(legend.title=element_blank()) +
      ggtitle("Number of Departing Flights") +xlab("") + ylab("") 

![](HW_2_files/figure-markdown_strict/Maps-2.png)

Association Rules
=================

The plot below shows the overall prior frequencies of items in our
dataset of transactions. Whole milk is the most frequenly purchased by a
considerable margin, followed by vegetables, rolls/buns, soda, and so
on. Before looking for associations, we know that many of these items
will have to be frequently purchased together, so we would want a
significant confidence in any rules we find in predicting these items.

![](HW_2_files/figure-markdown_strict/unnamed-chunk-2-1.png)

After trying different combinations, we decided on a support metric of
0.005 and confidence of 0.5 when creating our association rules. We also
limited the length of the item list in the each rule to five items. The
confidence was the most important factor to consider, given the high
frequency of some of the items discussed before. A confidence of 0.5
means that all rules follow the format of "Given this item list there is
at least a 50% chance of the person also buying X." These parameters
yielded a set of 120 assocation rules shown below. The highest
confidence rules have a lift of between 2 and 3 times above the prior
probabilities. There is also a large numbers of rules at this level of
lift with a confidence barely above 50%. However, we felt that 120
assocation rules provides a reasonable amount of predictive itemsets and
predicted items. Also, the highest lift rules all have relatively low
support as expected because the most informative rules should be less
common.

    ## Apriori
    ## 
    ## Parameter specification:
    ##  confidence minval smax arem  aval originalSupport maxtime support minlen
    ##         0.5    0.1    1 none FALSE            TRUE       5   0.005      1
    ##  maxlen target   ext
    ##       5  rules FALSE
    ## 
    ## Algorithmic control:
    ##  filter tree heap memopt load sort verbose
    ##     0.1 TRUE TRUE  FALSE TRUE    2    TRUE
    ## 
    ## Absolute minimum support count: 49 
    ## 
    ## set item appearances ...[0 item(s)] done [0.00s].
    ## set transactions ...[169 item(s), 9835 transaction(s)] done [0.01s].
    ## sorting and recoding items ... [120 item(s)] done [0.00s].
    ## creating transaction tree ... done [0.01s].
    ## checking subsets of size 1 2 3 4 done [0.01s].
    ## writing ... [120 rule(s)] done [0.00s].
    ## creating S4 object  ... done [0.00s].

    ## To reduce overplotting, jitter is added! Use jitter = 0 to prevent jitter.

![](HW_2_files/figure-markdown_strict/unnamed-chunk-3-1.png)

The rules shown below have the highest support and confidence,
respectively, and they all contain Whole Milk on the right hand side of
the rule. While we know whole milk is already the most commonly
purchased product, the lift on all of these rules is above 2, meaning
that the conditional probability of a person getting whole milk is
double that of the probability before they have any other items.

    ##     lhs                          rhs          support    confidence
    ## [1] {tropical fruit,yogurt}   => {whole milk} 0.01514997 0.5173611 
    ## [2] {other vegetables,yogurt} => {whole milk} 0.02226741 0.5128806 
    ##     lift     count
    ## [1] 2.024770 149  
    ## [2] 2.007235 219

    ##     lhs                     rhs              support confidence     lift count
    ## [1] {butter,                                                                  
    ##      whipped/sour cream} => {whole milk} 0.006710727      0.660 2.583008    66
    ## [2] {other vegetables,                                                        
    ##      pip fruit,                                                               
    ##      root vegetables}    => {whole milk} 0.005490595      0.675 2.641713    54
    ## [3] {root vegetables,                                                         
    ##      tropical fruit,                                                          
    ##      yogurt}             => {whole milk} 0.005693950      0.700 2.739554    56

A network graph of our 120 association rules in Gephi is shown below.
Whole milk, root vegetables, other vegetables, and yogurt appear as the
most frequently predicted items from our rules. However, they are not
all necessarily the most purchased products overall. Rolls and Soda do
not appear significant in associations, even though they are relatively
common in item baskets. Whole milk is again the most predicted item by
far, and a grocery store can leverage this since it is already the most
commonly purchased item by promoting deals with known associated
products such as root vegetables and yogurt (seen above).

![](HW_2_files/figure-markdown_strict/GroceryRules.png)
