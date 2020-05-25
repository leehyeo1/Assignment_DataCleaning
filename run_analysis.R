# To download the data file from web and save it in local 
if(!file.exists("./data")) {dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/recogDt.zip")

# To unzip the file we downloaded
zFilepath <- "./data/recogDt.zip"
unzDt <- "./data"
unzip(zFilepath, exdir = unzDt)

# Load the data into R separately
testSub <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
testX <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
testY <- read.table("./data/UCI HAR Dataset/test/y_test.txt")

trainSub <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
trainX <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
trainY <- read.table("./data/UCI HAR Dataset/train/y_train.txt")

# According to some information from README.md and feature.txt file, variable names for both 'x_train.txt' and 
# 'x_test.txt' are available in 'features.txt'
# So I extract variable names from the file
namesvar <- read.table("./data/UCI HAR Dataset/features.txt")

# column names of both X files are corresponding to values of second variable of 'namesvar'
colnames(testX) <- namesvar$V2
colnames(trainX) <- namesvar$V2

# data frames, '-sub', represent subject numbers
colnames(trainSub) <- "subject"
colnames(testSub) <- "subject"

# data frames, '-Y', reresent label of activity
colnames(testY) <- "activity"
colnames(trainY) <- "activity"

# Question 1: merges the training and the test sets to create ONE data set
        # First step: to merge the data for each group
mergedTest <- data.frame(cbind(testSub, testY, testX))
mergedTrain <- data.frame(cbind(trainSub, trainY, trainX))

        # Second step: to merge data of entire groups 
mergedAll <- data.frame(rbind(mergedTest,mergedTrain))

# Since class of variables, 'subject' and 'activity', are integer vector, they needed to be factored for convenience
mergedAll$subject <- factor(mergedAll$subject)
mergedAll$activity <- factor(mergedAll$activity)

# 'dplyr' package(which is faster than base R)is used further steps so let's see if the R has it.
# If R doesn't have it, intall and load it to R
if(!"dplyr" %in% rownames(installed.packages())) {install.packages(dplyr)}
library(dplyr)

# Question 2: to extract only the measurements on the mean and standard deviation for each measurement
        # First step: since I already named all the variables, I only need to find out all columns having 'mean' or 'std' 
        # in their names
i <- grep("[Mm][Ee][Aa][Nn]|[Ss][Tt][Dd]", names(mergedAll))
        # what 'i' tells us is an integer vector representing the locations of columns that I am looking for
        # Second step: first and second column represent subject and activity numbers repectively
mergedAll <- select(mergedAll, 1:2, i)

# Question 3: uses descriptive activity names to name the activities in the data set
        # First step: descriptive activity names can be found in 'activity_labels.txt'
        # Considering any (possible) modification in activity names and numbers in a file, I will just load the file
        # and establish the table having descriptive names
actLb <- read.table("./data/UCI HAR Dataset/activity_labels.txt", col.names = c("num", "label"), colClasses = "character")
        # Second step: using 'gsub' command and 'for' loop to substitute numbers to descriptive names
for(i in 1:length(actLb$num)) {
        mergedAll$activity <- gsub(actLb$num[i], actLb$label[i], mergedAll$activity)
}

# Question 4: appropriately lables the data set with descriptive variable names
        # this HAD BEEN DONE in the process of making data readable and tidy at the BEGINNING OF THIS SCRIPT
        # it has been done like this:
        # descriptive names of variables were found in 'features.txt'
                # namesvar <- read.table("./data/UCI HAR Dataset/features.txt")
                # colnames(testX) <- namesvar$V2
                # colnames(trainX) <- namesvar$V2
        # and each data sets are merged afterwards

# Question 5: from the data set in step 4, creates a second, independent tidy data set with the average of each variable 
# for each activity and each subject
        # First step: is to convert 'activity' variable to factor variable
mergedAll$activity <- factor(mergedAll$activity)
        # Second step: is to use aggregate function
newTidyDt <- aggregate(.~ subject + activity, data = mergedAll, FUN = mean)
newTidyDt <- arrange(newTidyDt, subject, activity)
        # Third step: according to the principle of tidy data, another data set should be saved in different file
write.table(newTidyDt, file = "./data/avgTidyDt.txt")