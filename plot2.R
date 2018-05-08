if (!file.exists("./data"))
    dir.create("./data")

if (!file.exists("./data/summarySCC_PM25.rds") || 
    !file.exists("./data/Source_Classification_Code.rds"))
    unzip("exdata_data_NEI_data.zip", exdir = "./data")

nei <- readRDS("./data/summarySCC_PM25.rds")
#scc <- readRDS("./data/Source_Classification_Code.rds")

library(dplyr)

neiTotalBaltimore <- nei %>% filter(fips == "24510") %>% 
    group_by(year) %>% summarize(totalEmissions = sum(Emissions))

png(file = "plot2.png", width = 512, height = 512)
plot(neiTotalBaltimore$year, neiTotalBaltimore$totalEmissions / 1e3, 
     type = "l", xlab = "year", 
     ylab = "total emissions, thousand tons", 
     xaxp = c(range(neiTotalBaltimore$year), 3), 
     yaxp = c(range(neiTotalBaltimore$totalEmissions / 1e3), 3))
title(main = "Total PM2.5 Emissions, Baltimore City")
dev.off()
