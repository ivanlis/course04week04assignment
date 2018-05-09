# Unpack files and read data
if (!file.exists("./data"))
    dir.create("./data")

if (!file.exists("./data/summarySCC_PM25.rds") || 
    !file.exists("./data/Source_Classification_Code.rds"))
    unzip("exdata_data_NEI_data.zip", exdir = "./data")

nei <- readRDS("./data/summarySCC_PM25.rds")
scc <- readRDS("./data/Source_Classification_Code.rds")

library(dplyr)

# Extract all the SCC values related to motor vehicles
sccVehicles <- scc$SCC[grep(pattern = "vehicle", x = scc$EI.Sector, 
                            ignore.case = TRUE, value = FALSE)]
# Extract data on the pollutants whose ids are among what we've just found
#  (only related to Baltimore City)
neiVehicles <- nei[nei$SCC %in% sccVehicles & nei$fips == "24510", c("Emissions", "year")]
# Compute totals by year.
neiVehicles <- neiVehicles %>% group_by(year) %>% summarize(vehicleEmissions = sum(Emissions))

# Plot the computed summary.
library(ggplot2)
png(file = "plot5.png", width = 512, height = 512)
ggplot(data = neiVehicles, mapping = aes(x = year, y = vehicleEmissions)) +
    geom_line() + geom_point() + 
    labs(x = "year", y = "emissions, tons", 
         title = "Emissions from motor vehicles in Baltimore") +
    scale_x_continuous(breaks = c(1999, 2002, 2005, 2008))    
dev.off()

