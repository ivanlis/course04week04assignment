if (!file.exists("./data"))
    dir.create("./data")

if (!file.exists("./data/summarySCC_PM25.rds") || 
    !file.exists("./data/Source_Classification_Code.rds"))
    unzip("exdata_data_NEI_data.zip", exdir = "./data")

nei <- readRDS("./data/summarySCC_PM25.rds")
scc <- readRDS("./data/Source_Classification_Code.rds")

library(dplyr)

# Extract all the SCC values related to coal combustion
sccCoal <- scc$SCC[grep(pattern = "coal", x = scc$EI.Sector, ignore.case = TRUE, value = FALSE)]
# Extract data on the pollutants whose ids are among what we've just found
neiCoal <- nei[nei$SCC %in% sccCoal, c("Emissions", "year")]
neiCoal <- neiCoal %>% group_by(year) %>% summarize(coalEmissions = sum(Emissions))

library(ggplot2)
png(file = "plot4.png", width = 512, height = 512)
ggplot(data = neiCoal, mapping = aes(x = year, y = coalEmissions)) +
    geom_line() + geom_point() + 
    labs(x = "year", y = "emissions, tons", 
         title = "Coal Related Emissions in the United States") +
    scale_x_continuous(breaks = c(1999, 2002, 2005, 2008))    
dev.off()
