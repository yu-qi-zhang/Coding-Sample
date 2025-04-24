# Here is a R script for three aims
#1 reading mutiple pdf files by looping
#2 picking required information from text to form a dataframe
#3 exporting specific formats of data files

setwd("~/Desktop/BirthdataUS")
library(pdftools)
library(tidyverse)
library(readr)
library(gtools)
library(plyr)
library(dplyr)
library(tibble)

# set path
folder<-"~/Desktop/BirthdataUS"
files<-list.files(folder,pattern="\\.pdf",full.names = TRUE)

state <- c("total","CA","ID","IL","NY","TX")
ALLBD<-data.frame(state=state)

# set the order first
list <- mixedsort(files, decreasing = F)
print(list)

# Read all pdf in path
for (file in list) {
  # Convert to text and select by strings
  Birth <- pdf_text(file)
  strBirth=readr::read_lines(Birth)
  subBirth<-strBirth[6:82]
  select<- subBirth[grepl(pattern = "reporting|United|California|Idaho|Illinois|York|Texas",subBirth)]
  select<- select[!grepl(pattern = "Table|ercent",select)]
  
  # Deal with spaces and splits
  Bstr<-gsub("[.]", " ", select)
  Bstr<-gsub("[,]", "", Bstr)
  Bstr<-gsub("[,]", "", Bstr)
  Bstr<-gsub("Total of reporting areas","Total", Bstr)
  Bstr<-gsub("United States","Total", Bstr)
  Bstr<-gsub("Total ","Total", Bstr)
  Bstr<-gsub("New York","NY", Bstr)
  Bstr <- trimws(Bstr)
  Bstr<-gsub("\\s+",";",Bstr)
  vecB<- strsplit(Bstr,";")
  
  # Make dataframs and cbind
  BD<-as.data.frame(do.call(rbind, vecB))  
  BD<-BD[1:6,]
  BD<- subset(BD, select = c("V2"))
  ALLBD<- cbind(ALLBD,BD)
}

# Rename by year
for (i in 2:28) {
  colnames(ALLBD)[i] <- i+1994
  colnames(ALLBD)[i] <- paste0("births",colnames(ALLBD)[i] )
}


# To generate vars. transpose 
long<-t(ALLBD)
long<-data.frame(long)
colnames(long)=long[1,]
long<-long[-c(1),]
long<-long %>%
  mutate_if(is.character,as.numeric)

long$triplicate<-long$CA+long$ID+long$IL+long$NY+long$TX
long$nontrip<-long$total-long$triplicate

# Transpose to wide form
full<-t(long)
full<-data.frame(full)


library(tidyr)

# Convert row names into a column
long <- long %>%
  rownames_to_column(var = "year") %>%
  mutate(year = as.numeric(gsub("birth", "", year)))  

# Export as long form dta and wide form excel
library(foreign)
write.dta(long,'birthlong.dta')

library(openxlsx)
write.xlsx(full,'birth.xlsx',rowNames=TRUE)




