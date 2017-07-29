
########################################################################
######### Getting and cleaning data - class assignment
######### Run this script to download, extract, and tidy the file
######### This script will generate a summary of the data with respect
######### to activity and subject.
######### For more details, please see readme.md and codebook.md
########################################################################




library(dplyr)



########################################################################
######### Download and unzip the zip file.
########################################################################



if(!file.exists("./data")) {
  dir.create("./data")
}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

## Unzip the file

unzip(zipfile="./data/Dataset.zip",exdir="./data")



########################################################################
######### Merges the training and the test sets to create one data set.
########################################################################



################# Read data from the files into the variables

# Read activity files

table_activity_test <- read.table(file.path("./data/UCI HAR Dataset/test/Y_test.txt"), header=FALSE)
table_activity_train <- read.table(file.path("./data/UCI HAR Dataset/train/Y_train.txt"), header=FALSE)


# Read the subject files
table_subject_test <- read.table(file.path("./data/UCI HAR Dataset/test/subject_test.txt"), header=FALSE)
table_subject_train <- read.table(file.path("./data/UCI HAR Dataset/train/subject_train.txt"), header=FALSE)


# Read the features files
table_features_test <- read.table(file.path("./data/UCI HAR Dataset/test/x_test.txt"), header=FALSE)
table_features_train <- read.table(file.path("./data/UCI HAR Dataset/train/x_train.txt"), header=FALSE)


################ Merge the data

table_activity_merged <- bind_rows(table_activity_test, table_activity_train)
table_subject_merged <- bind_rows(table_subject_test, table_subject_train)
table_features_merged <- bind_rows(table_features_test, table_features_train)


################ Rename the data

names(table_activity_merged) <- "activity"
names(table_subject_merged) <- "subject"
table_features_names <- read.table("./data/UCI HAR Dataset/features.txt", head=FALSE)
names(table_features_merged) <- table_features_names$V2


############### Combine the data

combined_data <- bind_cols(table_features_merged, table_subject_merged, table_activity_merged)
names(combined_data)


#################################################################################################
######### Extracts only the measurements on the mean and standard deviation for each measurement.
#################################################################################################

subset_table_features_names <- table_features_names$V2[grep(("mean\\(\\)|std\\(\\)"),table_features_names$V2)]

selected_names <- c(as.character(subset_table_features_names), "subject", "activity")
extracted_data <- subset(combined_data, select=selected_names)


#################################################################################################
######### Uses descriptive activity names to name the activities in the data set
#################################################################################################


activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt",header = FALSE)
character_activity_labels <- activity_labels$V2

extracted_data_factored <- extracted_data
extracted_data_factored$activity <- factor(extracted_data_factored$activity, labels = as.character(character_activity_labels))



#################################################################################################
###################### Appropriately labels the data set with descriptive variable names.
#################################################################################################


names(extracted_data_factored)<-gsub("^t", "time", names(extracted_data_factored))
names(extracted_data_factored)<-gsub("^f", "frequency", names(extracted_data_factored))
names(extracted_data_factored)<-gsub("Acc", "Accelerometer", names(extracted_data_factored))
names(extracted_data_factored)<-gsub("Gyro", "Gyroscope", names(extracted_data_factored))
names(extracted_data_factored)<-gsub("Mag", "Magnitude", names(extracted_data_factored))


#################################################################################################
###################### From the data set in step 4, creates a second, independent tidy data set
###################### with the average of each variable for each activity and each subject.
#################################################################################################

tidy_data <- aggregate(. ~activity + subject, extracted_data_factored, mean)
write.table(tidy_data, file = "tidy_data.txt", row.name=FALSE)