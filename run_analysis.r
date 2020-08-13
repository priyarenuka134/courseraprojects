library(dplyr)

# Check for data and download/unzip if necessary
zipfilename <- "ProjectData.zip"
unzipdirectory <- "UCI HAR Dataset"

if(!file.exists(zipfilename)){
  datalocation <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"    
  download.file(url = datalocation, destfile = zipfilename, method = "curl")
}

if(!file.exists(unzipdirectory)){
  unzip(zipfilename)
}
test_data <- read.table("./UCI HAR Dataset/test/X_test.txt")
test_labels <- read.table("./UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("./UCI HAR Dataset/test/subject_test.txt")
train_data <- read.table("./UCI HAR Dataset/train/X_train.txt")
train_labels <- read.table("./UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("./UCI HAR Dataset/train/subject_train.txt")
combine_data <- rbind(test_data, train_data)
combine_labels <- rbind(test_labels, train_labels)
combine_subjects <- rbind(test_subjects, train_subjects)
features <- read.table("./UCI HAR Dataset/features.txt")
meanstdcols <- grep("(.*)mean[^F]|std(.*)",features[,2])
dataMeanStd <- combine_data[,meanstdcols] 
activitynames <- read.table("./UCI HAR Dataset/activity_labels.txt")
activies <- right_join(activitynames, combine_labels, by = "V1")
activies <- select(activies, activity = V2) #Fulfills Step 3
dataLabels <- as.vector(features[meanstdcols, 2])
dataLabels <- sub("mean\\(\\)","Mean",dataLabels)
dataLabels <- sub("std\\(\\)","SD",dataLabels)
names(dataMeanStd) <- dataLabels
combine_subjects$V1 <- as.factor(combine_subjects$V1)
names(combine_subjects) <- "subject"
combineall <- bind_cols(combine_subjects, activies, dataMeanStd)
meansummary <- combineall %>% arrange(subject, activity) %>% group_by(subject, activity) %>% summarize_each(funs(mean))
summaryLabels <- c("Subject", "Activity", paste("Mean", dataLabels, sep = "_"))
names(meansummary) <- summaryLabels
write.table(meansummary, file = "finalTidySummary.txt")
