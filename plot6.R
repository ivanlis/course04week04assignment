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
#  (either related to Baltimore City or Los Angeles County)
neiVehiclesTwoPlaces <- nei[nei$SCC %in% sccVehicles & nei$fips %in% c("24510", "06037"), 
                   c("fips", "Emissions", "year")]
neiVehiclesTwoPlaces <- neiVehiclesTwoPlaces %>% group_by(fips, year) %>%
    summarize(vehicleEmissions = sum(Emissions))
neiVehiclesTwoPlaces$fips <- factor(x = neiVehiclesTwoPlaces$fips, 
                                    levels = c("24510", "06037"), 
                                    labels = c("Baltimore", "Los Angeles"))
names(neiVehiclesTwoPlaces)[1] <- "Area"

# Plot the computed summary.
library(ggplot2)
png(file = "plot6.png", width = 512, height = 1024)
absPlot <- ggplot(data = neiVehiclesTwoPlaces, 
       mapping = aes(x = year, y = vehicleEmissions, col = Area)) +
    geom_line() + geom_point() + 
    labs(x = "year", y = "emissions, tons", 
         title = "Emissions from motor vehicles in Baltimore and Los Angeles") +
    scale_x_continuous(breaks = c(1999, 2002, 2005, 2008))


# As we are asked to COMPARE the cases of Baltimore and Los Angeles,
# let's draw a "proportional" graph. The emissions of 1999 are taken as 1.
splitNeiVehiclesTwoPlaces <- split(neiVehiclesTwoPlaces, neiVehiclesTwoPlaces$Area)

splitNeiVehiclesTwoPlaces[["Baltimore"]]$vehicleEmissionsRel <- 
    splitNeiVehiclesTwoPlaces[["Baltimore"]]$vehicleEmissions / 
    splitNeiVehiclesTwoPlaces[["Baltimore"]]$vehicleEmissions[1]

splitNeiVehiclesTwoPlaces[["Los Angeles"]]$vehicleEmissionsRel <- 
    splitNeiVehiclesTwoPlaces[["Los Angeles"]]$vehicleEmissions / 
    splitNeiVehiclesTwoPlaces[["Los Angeles"]]$vehicleEmissions[1]

neiVehiclesTwoPlacesRel <- rbind(splitNeiVehiclesTwoPlaces[["Baltimore"]], 
                        splitNeiVehiclesTwoPlaces[["Los Angeles"]])

relPlot <- ggplot(data = neiVehiclesTwoPlacesRel, 
                  mapping = aes(x = year, y = vehicleEmissionsRel, col = Area)) +
    geom_line() + geom_point() + 
    labs(x = "year", y = "emissions", 
         title = "Emissions from motor vehicles in Baltimore and Los Angeles (proportional)") +
    scale_x_continuous(breaks = c(1999, 2002, 2005, 2008))

# An extra library just to lay out a grid of ggplot2 graphs.
library(gridExtra)
grid.arrange(absPlot, relPlot, ncol = 1)

dev.off()
