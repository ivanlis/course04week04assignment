# Unpack files and read data
if (!file.exists("./data"))
    dir.create("./data")

if (!file.exists("./data/summarySCC_PM25.rds") || 
    !file.exists("./data/Source_Classification_Code.rds"))
    unzip("exdata_data_NEI_data.zip", exdir = "./data")

nei <- readRDS("./data/summarySCC_PM25.rds")
#scc <- readRDS("./data/Source_Classification_Code.rds")

library(dplyr)
# Compute total emissions by year
neiTotalUs <- nei %>% group_by(year) %>% summarize(totalEmissions = sum(Emissions))

# Plot the computed summary
png(file = "plot1.png", width = 512, height = 512)
plot(neiTotalUs$year, neiTotalUs$totalEmissions / 1e6, 
     type = "l", xlab = "year", 
     ylab = "total emissions, million tons", 
     xaxp = c(range(neiTotalUs$year), 3), 
     yaxp = c(range(neiTotalUs$totalEmissions / 1e6), 3))
title(main = "Total PM2.5 Emissions, United States")
dev.off()
