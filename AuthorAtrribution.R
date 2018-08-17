## The tm library and related plugins comprise R's most popular text-mining stack.
## See http://cran.r-project.org/web/packages/tm/vignettes/tm.pdf
library(tm) 
library(magrittr)
library(slam)
library(proxy)
library(caret)


## tm has many "reader" functions.  Each one has
## arguments elem, language, id
## (see ?readPlain, ?readPDF, ?readXML, etc)
## This wraps another function around readPlain to read
## plain text documents in English.
readerPlain = function(fname){
  readPlain(elem=list(content=readLines(fname)), 
            id=fname, language='en') }

#############################################################################################
######################## SET-UP THE TRAINING CORPUS #########################################
#############################################################################################

## "globbing" = expanding wild cards in filename paths
authorlist_train = Sys.glob('../data/ReutersC50/C50train/*')
filelist_train = NULL
labels_train = NULL

#extract author names from authorlist_train
for(author in authorlist_train) {
  author_name = substring(author, first = 29) #get the author name from filename
  files_to_add = Sys.glob(paste0(author, '/*.txt')) #gets all the files per author
  filelist_train = append(filelist_train, files_to_add) #appends all the authors' files into whole filelist
  labels_train = c(labels_train, rep(author_name, length(files_to_add)))
}

#getting better names
traindocs = lapply(filelist_train, readerPlain)
names(traindocs) = filelist_train #really ugly long name
names(traindocs) = sub('.txt', '', names(traindocs))

#training corpus
train_corpus = Corpus(VectorSource(traindocs))
#names(train_corpus) = names(traindocs) ##ERROR IDK WHY THO


## Some pre-processing/tokenization steps.
## tm_map just maps some function to every document in the corpus #kind of like map in series
#making text in doc just lowercase words
my_documents_train = train_corpus
my_documents_train = tm_map(my_documents_train, content_transformer(tolower)) # make everything lowercase
my_documents_train = tm_map(my_documents_train, content_transformer(removeNumbers)) # remove numbers
my_documents_train = tm_map(my_documents_train, content_transformer(removePunctuation)) # remove punctuation
my_documents_train = tm_map(my_documents_train, content_transformer(stripWhitespace)) ## remove excess white-space

## Remove stopwords. Stopwords = words w/ little meaning
#Always be careful with this: one person's trash is another one's treasure.
my_documents_train = tm_map(my_documents_train, content_transformer(removeWords), stopwords("en"))


## create a training doc-term-matrix
DTM_train = DocumentTermMatrix(my_documents_train)
DTM_train # some basic summary statistics

## Finally, drop those terms that only occur in one or two documents
## This is a common step: the noise of the "long tail" (rare terms)
##	can be huge, and there is nothing to learn if a term occured once.
## Below removes those terms that have count 0 in >95% of docs.  
## Probably a bit stringent here... but only 50 docs!
DTM_train = removeSparseTerms(DTM_train, 0.95)
DTM_train # now ~ 1000 terms (versus ~3000 before)

#############################################################################################
######################## SET-UP THE TESTING CORPUS #########################################
#############################################################################################

# "globbing" = expanding wild cards in filename paths
authorlist_test = Sys.glob('../data/ReutersC50/C50test/*')
filelist_test = NULL
labels_test = NULL

#extract author names from authorlist_test
for(author in authorlist_test) {
  author_name = substring(author, first = 28) #get the author name from filename
  files_to_add = Sys.glob(paste0(author, '/*.txt')) #gets all the files per author
  filelist_test = append(filelist_test, files_to_add) #appends all the authors' files into whole filelist
  labels_test = append(labels_test, rep(author_name, length(files_to_add)))
}

#getting better names
testdocs = lapply(filelist_test, readerPlain)
names(testdocs) = filelist_test #really ugly long name
names(testdocs) = sub('.txt', '', names(testdocs))

#testing corpus
test_corpus = Corpus(VectorSource(testdocs))

## Some pre-processing/tokenization steps.
## tm_map just maps some function to every document in the corpus #kind of like map in series
#making text in doc just lowercase words
my_documents_test = test_corpus
my_documents_test = tm_map(my_documents_test, content_transformer(tolower)) # make everything lowercase
my_documents_test = tm_map(my_documents_test, content_transformer(removeNumbers)) # remove numbers
my_documents_test = tm_map(my_documents_test, content_transformer(removePunctuation)) # remove punctuation
my_documents_test = tm_map(my_documents_test, content_transformer(stripWhitespace)) ## remove excess white-space

## Remove stopwords. Stopwords = words w/ little meaning
#Always be careful with this: one person's trash is another one's treasure.
my_documents_test = tm_map(my_documents_test, content_transformer(removeWords), stopwords("en"))


## create a training doc-term-matrix
DTM_test = DocumentTermMatrix(my_documents_test)
DTM_test # some basic summary statistics

## Finally, drop those terms that only occur in one or two documents
## This is a common step: the noise of the "long tail" (rare terms)
##	can be huge, and there is nothing to learn if a term occured once.
## Below removes those terms that have count 0 in >95% of docs.  
## Probably a bit stringent here... but only 50 docs!
DTM_test = removeSparseTerms(DTM_test, 0.95)
DTM_test 

summary(Terms(DTM_test) %in% Terms(DTM_train))

#to deal with words in test set that aren't in training set...

# A suboptimal but practical solution: ignore words you haven't seen before
# can do this by pre-specifying a dictionary in the construction of a DTM
DTM_test2 = DocumentTermMatrix(test_corpus,
                               control = list(dictionary=Terms(DTM_train)))
summary(Terms(DTM_test2) %in% Terms(DTM_train))



#############################################################################################
######################## NAIVE BAYES #########################################
#############################################################################################

# construct TF IDF weights
tfidf_train = weightTfIdf(DTM_train)
tfidf_test = weightTfIdf(DTM_test2)

#convert DTM_train and DTM test into matrices
X_train = as.matrix(tfidf_train)
X_test = as.matrix(tfidf_test)

#apply Laplace smoothing factor and get term level weights
smooth_count = 1/nrow(X_train)
for(i in 1:50){
  w_name = paste("w", labels_train[i], sep = "_")
  temp = colSums(X_train[(50*(i-1)+1):(50*i),] + smooth_count)
  assign(w_name, temp/sum(temp))
}

#predict author name of test data
#predict by calculating log probabilities of test documents across all authors
#authors of highest value are the most probably author
pred = matrix(, nrow = 2550, ncol = 51) #2550 docs, 50 authors 
for (i in 1:2550){
  for(j in 1:50){
    w_name <- paste("w", labels_test[j], sep = "_")
    pred[i,j] = sum(X_test[i,]*log(get(w_name)))
  }
}

pred[1:10, 1:10] #predictions

for (i in 2550){
  pred[i, 51] = which.max(pred[i,]) #get idxmax of the row and stores in col 51
  #max log pred = most likely to be this author
  #pred[,51] gives all NA which is messing it all up :(
}

#BUT!!something wrong with dimensions??
#Problem = each row of pred is the same number
#Row 51 is NA even though which.max should have which author had max log

predicted = NULL
predicted = cbind((rep(1:50, each = 50)), pred[,51])
predicted$actual_author <- rep(1:50, each = 50)
predicted$pred_author <- pred[,51] 
predicted

#run confusion matrix
confusionMatrix(predicted$actual_author, predicted$pred_author)
#pred_author is ALL NA :'(

#also did cosine similarity and PCA from his code, but it doesn't look very good or predict author so idk
'''

# cosine similarity
i = 1
j = 3
sum(tfidf_train[i,] * (tfidf_train[j,]))/(sqrt(sum(tfidf_train[i,]^2)) * sqrt(sum(tfidf_train[j,]^2)))


# the full set of cosine similarities
# two helper functions that use some linear algebra for the calculations
cosine_sim_docs = function(dtm) {
  crossprod_simple_triplet_matrix(t(dtm))/(sqrt(col_sums(t(dtm)^2) %*% t(col_sums(t(dtm)^2))))
}

# use the function to compute pairwise cosine similarity for all documents
cosine_sim_mat = cosine_sim_docs(tfidf_train)
# Now consider a query document
content(traindocs[[18]]) #the content of article 17 from simon
cosine_sim_mat[18,] #matrix of cosine similarity btwn [17] and other docs

sort(cosine_sim_mat[18,], decreasing=TRUE) #Doc 18 has the greatest cosine similarity w/ Doc 257
content(traindocs[[18]])
content(traindocs[[257]])

#####
# Cluster documents
#####
'''
'''
# define the cosine distance
cosine_dist_mat = proxy::dist(as.matrix(tfidf_train), method='cosine')
tree_train = hclust(cosine_dist_mat)
plot(tree_train)
clust5 = cutree(tree_train, k=5)

# inspect the clusters
which(clust5 == 1)
content(traindocs[[1]])
content(traindocs[[4]])
content(traindocs[[5]])



####
# Dimensionality reduction
####

# Now PCA on term frequencies
X = as.matrix(tfidf_train)
summary(colSums(X))
scrub_cols = which(colSums(X) == 0)
X = X[,-scrub_cols]

pca_train = prcomp(X, scale=TRUE)
plot(pca_train) 

# Look at the loadings
pca_train$rotation[order(abs(pca_train$rotation[,1]),decreasing=TRUE),1][1:25]
pca_train$rotation[order(abs(pca_train$rotation[,2]),decreasing=TRUE),2][1:25]

'''
## Look at the first two PCs..
##We've now turned each document into a single pair of numbers -- massive dimensionality reduction
'''
pca_train$x[,1:2]

plot(pca_train$x[,1:2], xlab="PCA 1 direction", ylab="PCA 2 direction", bty="n",
     type='n')
text(pca_train$x[,1:2], labels = 1:length(traindocs), cex=0.7)


# Now look at the word view
# 5-dimensional word vectors
word_vectors = pca_train$rotation[,1:5]

word_vectors[1,]

d_mat = dist(word_vectors)
'''
