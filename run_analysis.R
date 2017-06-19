filename <- "data.zip"

## download the file if it is not already downloaded
if(!file.exists(filename)){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url, destfile = filename)
}

## unzip the file it is not already unzipped
if(!file.exists("UCI HAR Dataset")){
  unzip(filename)
}

## read the activity labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

## read the features
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## extract the indices and names of mean and standard deviation features
meanStdIndex <- grep(".*mean.*|.*std.*", features[,2])
meanStdNames <- features[meanStdIndex, 2]

## rename the feature names with more descriptive names
meanStdNames <- gsub('-mean', 'Mean', meanStdNames)
meanStdNames <- gsub('-std', 'StandardDeviation', meanStdNames)
meanStdNames <- gsub('[-()]', '', meanStdNames)
meanStdNames <- gsub("^t", "time", meanStdNames)
meanStdNames <- gsub("^f", "frequency", meanStdNames)
meanStdNames <- gsub("Acc", "Accelerometer", meanStdNames)
meanStdNames <- gsub("Gyro", "Gyroscope", meanStdNames)
meanStdNames <- gsub("Mag", "Magnitude", meanStdNames)

## read the train and test datasets for observations with mean or standard deviation
train <- read.table("UCI HAR Dataset/train/X_train.txt")[meanStdIndex]
test <- read.table("UCI HAR Dataset/test/X_test.txt")[meanStdIndex]

## name the train and test dataset columns
colnames(train) <- meanStdNames
colnames(test) <- meanStdNames

## read the activity for test and train datasets
trainY <- read.table("UCI HAR Dataset/train/Y_train.txt")
colnames(trainY) <- "activity"
testY <- read.table("UCI HAR Dataset/test/y_test.txt")
colnames(testY) <- "activity"

## read the subjects for train and test datasets
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
colnames(trainSubjects)<-"subject"
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
colnames(testSubjects)<-"subject"

## combine the data with activity and subjects
train <- cbind(trainY, trainSubjects, train)
test <- cbind(testY, testSubjects, test)

## combine the train and test datasets
tidy <- rbind(train, test)

## factorize activity with labels to provide descriptive labels
tidy$activity <- factor(tidy$activity, levels = activityLabels[,1], labels = activityLabels[,2])

## create a new dataset with the mean for each activity and subject
tidy2<-aggregate(tidy[,3:81],by=list(activity=tidy$activity, subject=tidy$subject),mean)

## write the new dataset into a file
write.table(tidy2, './tidyData.txt',row.names=FALSE,sep='\t')
