library(data.table)
library(shiny)
rw()
setwd("~/git/District-Explorer/data")
options(stringsAsFactors=FALSE)

load("districts.RData")



# Old data
olddata <- copy(districts@data)

unname(unlist(olddata[,lapply(.SD,class)]))

# 2016 data
newdata <- data.table(read.csv("district2016.csv"))

unname(unlist(newdata[,lapply(.SD,class)]))



# 2016 field names
fnames <- data.table(read.csv("district2016.lyt.csv"))
names(newdata) <- as.character(fnames$Description)

names(newdata)[!grepl(":",names(newdata))]
names(olddata)


# convert 2016 names to match
grep(":",names(olddata),value=TRUE)
grep(":",names(newdata),value=TRUE)
names(newdata)[!grepl(":",names(newdata))]


names(newdata) <- gsub("STAAR:","TESTING: STAAR -",names(newdata))
names(newdata) <- gsub("REVENUE:","TAX & REVENUE:", names(newdata))
names(newdata)[grepl("REVENUE",names(newdata))&!grepl("TAX & REVENUE:",names(newdata))] <- paste0("TAX & REVENUE: ",names(newdata)[grepl("REVENUE",names(newdata))&!grepl("TAX & REVENUE:",names(newdata))])
names(newdata)[grepl("TAX",names(newdata))&!grepl("TAX & REVENUE:",names(newdata))] <- paste0("TAX & REVENUE: ",names(newdata)[grepl("TAX",names(newdata))&!grepl("TAX & REVENUE:",names(newdata))] )
names(newdata)[grepl("EXPENDI",names(newdata))&!grepl("EXPENDITURE:",names(newdata))] <- paste0("EXPENDITURE: ",names(newdata)[grepl("EXPENDI",names(newdata))&!grepl("EXPENDITURE:",names(newdata))])
names(newdata)[grepl("SAT-|ACT-",names(newdata))&!grepl("TESTING:",names(newdata))] <- paste0("TESTING: ",names(newdata)[grepl("SAT-|ACT-",names(newdata))&!grepl("TESTING:",names(newdata))])
names(newdata)[grepl("GRADUATION RATE",names(newdata))] <- paste0("STUDENTS: ",names(newdata)[grepl("GRADUATION RATE",names(newdata))])
names(newdata)[names(newdata)=="NUMBER OF STUDENTS PER TOTAL STAFF"] <- "STAFF: NUMBER OF STUDENTS PER TOTAL STAFF"
names(newdata)[names(newdata)=="TOTAL STUDENTS"] <- "STUDENTS: TOTAL STUDENTS"
names(newdata)[names(newdata)=="FUND BALANCE"] <- "TAX & REVENUE: FUND BALANCE"
names(newdata)[names(newdata)=="NUMBER OF STUDENTS PER TEACHER"] <- "STAFF: NUMBER OF STUDENTS PER TEACHER"
names(newdata)[grepl("DROPOUT",names(newdata))] <- paste0("STUDENTS: ",names(newdata)[grepl("DROPOUT",names(newdata))]) 
names(newdata)[names(newdata)=="ATTENDANCE RATE (2014-15)"] <- "STUDENTS: ATTENDANCE RATE (2014-15)"
names(newdata)[names(newdata)=="TOTAL STAFF FTE"] <- "STAFF: TOTAL STAFF FTE"
names(newdata)[names(newdata)=="TOTAL TEACHER FTE"] <- "STAFF: TOTAL TEACHER FTE"



groups[groups=="SALARY"] <- "AVERAGE SALARY"


# 2016 variables
newvars <- lapply(groups, function(x) {
	tmp <- grep(paste("^",x,sep=""), names(newdata), value=TRUE)
	# tmp[!grepl("TAX|REVENUE",tmp)]
})
names(newvars) <- groups
newvars$STUDENTS <- newvars$STUDENTS[!grepl("STAFF",newvars$STUDENTS)]

# newvars$`TAX & REVENUE` <- grep("TAX|REVENUE",names(newdata),value=TRUE)


setkey(newdata, `DISTRICT NUMBER`)
setkey(olddata, `DISTRICT NUMBER`)

newdata <- newdata[olddata[,.SD,.SDcols=c(names(olddata)[102:117],"DISTRICT NUMBER")]]
setkey(newdata, rownum)


for(i in 6:102) 
{
     newdata[[i]] <- as.numeric(newdata[[i]])
}


districts@data <- newdata
variables <- newvars




save(districts, variables, groups, categories, file="districts2016.RData")


setwd("..")
runApp()
