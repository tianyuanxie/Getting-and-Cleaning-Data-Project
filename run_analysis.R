##download and unzip the dataset
setwd('C:/Courses/coursera/03 Data cleaning/project')
filename <- "activity_dataset.zip"
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename, mode = 'wb')
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}

##change the working directory 
setwd('C:/Courses/coursera/03 Data cleaning/project/UCI HAR Dataset')

##1. create test and train datasets and merge them together 
test = read.table('./test/X_test.txt')
test_sub = read.table('./test/subject_test.txt')
test_act = read.table('./test/Y_test.txt')
testall = cbind(test_sub, test_act, test)

train = read.table('./train/X_train.txt')
train_sub = read.table('./train/subject_train.txt')
train_act = read.table('./train/Y_train.txt')
trainall = cbind(train_sub, train_act, train)

mergeall = rbind(trainall, testall)

##2. extract mean and standard deviation
feature = read.table('features.txt')
feature[, 2] = as.character(feature[, 2])
name <- c(c('subject', 'activity'), feature[,2])
colnames(mergeall) <- name
meanorstd <- grep("-(mean|std)\\(\\)", names(mergeall))
mean_std <- c(c(1, 2), meanorstd)
extract <- mergeall[, mean_std]

##3. Uses descriptive activity names to name the activities in the data set
activitylabel = read.table('activity_labels.txt')
for(i in 1:6) {
    extract[,2] <- gsub(i, activitylabel[i, 2], extract[, 2])
    i <- i+1
}

##4. Appropriately labels the data set with descriptive variable names
label <- names(extract)
label <- gsub("-mean", "Mean", label)
label <- gsub("-std", "StandardDeviation", label)
label <- gsub("[()]", "", label)
label <- gsub("BodyBody", "Body", label)
label <- gsub("^t", "Time", label)
label <- gsub("^f", "Frequency", label)
label <- gsub("Acc", "Acceleration", label)
label <- gsub("GyroJerk", "AngularVelocity", label)
label <- gsub("Jerk", "Linear", label)
label <- gsub("Mag", "Magnitude", label)
label <- gsub("Gyro", "Angular", label)
names(extract) <- label

##5. creates a independent tidy data set with 
##the average of each variable for each activity and each subject.
library(plyr)
tidydata <- ddply(extract, c('subject', 'activity'), numcolwise(mean))
write.table(tidydata, 'TidyData.txt')
