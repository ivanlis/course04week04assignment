# Unpack files and read data
if (!file.exists("./data"))
    dir.create("./data")

if (!file.exists("./data/summarySCC_PM25.rds") || 
    !file.exists("./data/Source_Classification_Code.rds"))
    unzip("exdata_data_NEI_data.zip", exdir = "./data")

nei <- readRDS("./data/summarySCC_PM25.rds")
#scc <- readRDS("./data/Source_Classification_Code.rds")

library(dplyr)

# First, group the data by the (type, year) pair.
# Then, find emission totals for each group.
neiByTypeYearBaltimore <- nei %>% filter(fips == "24510") %>%
    group_by(type, year) %>% summarize(emissionsTypeYear = sum(Emissions))

# Plot the emission values as functions of time.
# As we have few types, plot all the graphs on the same plot,
#  but with different colors.
library(ggplot2)

png(file = "plot3.png", width = 512, height = 512)
ggplot(data = neiByTypeYearBaltimore, 
       mapping = aes(x = year, y = emissionsTypeYear, color = type)) + 
    geom_line() + geom_point() +
    labs(x = "year", y = "emissions, tons", 
         title = "Emissions in Baltimore", subtitle = "By source type") +
    scale_x_continuous(breaks = c(1999, 2002, 2005, 2008))
dev.off()