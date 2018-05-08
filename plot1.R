if (!file.exists("./data"))
    dir.create("./data")

if (!file.exists("./data/summarySCC_PM25.rds") || 
    !file.exists("./data/Source_Classification_Code.rds"))
    unzip("exdata_data_NEI_data.zip", exdir = "./data")

nei <- readRDS("./data/summarySCC_PM25.rds")
#scc <- readRDS("./data/Source_Classification_Code.rds")

neiTotalUs <- nei %>% group_by(year) %>% summarize(totalEmissions = sum(Emissions))

yRange <- range(neiTotalUs$totalEmissions / 1e6)

png(file = "plot1test.png", width = 512, height = 512)
plot(neiTotalUs$year, neiTotalUs$totalEmissions / 1e6, 
     type = "l", xlab = "year", 
     ylab = "total emissions, mln tons", 
     xaxp = c(1999, 2008, 3), yaxp = c(yRange, 3))
dev.off()
