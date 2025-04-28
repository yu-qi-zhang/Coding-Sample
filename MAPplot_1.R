# This is an R script for 3 aims:
#1 Loading any geographic shape file into R
#2 Generating sample dataset
#3 Drawing map plot of this dataset with some settings

#install.packages("sf")   
#install.packages("ggplot2") 
#install.packages("tmap")   
library(sf)
library(ggplot2)
library(tmap)

#A.Load the map data
korea_lvl2 <- st_read("~/gadm41_KOR_2.shp") 

# Check the boundaries
ggplot(data = korea_lvl2) +
  geom_sf() +
  theme_minimal() +
  ggtitle("Boundaries")


# a sample with variable x to see the plots (The unique code for each unit in map dataset is GID_2 or NAME_2)
set.seed(123) 
datause <- data.frame(
  NAME_2 = korea_lvl2$NAME_2, 
  x = sample(100:1000, 229, replace = TRUE)  
)

#B. combine the map data with dataset used and plot
merged_data <- merge(korea_lvl2, datause, by = "NAME_2", all.x = TRUE)

#C. get the graph
# Plot, continuous (without grid and axis)
ggplot(data = merged_data) +
  geom_sf(aes(fill = x)) +  
  scale_fill_gradient(name = "value",low = "gray90", high = "gray20") + 
  theme_minimal() +
  ggtitle("Level of x in Korea") +
theme(
  legend.position = "right",
  axis.text = element_blank(),       # axis text
  axis.ticks = element_blank(),      # axis ticks
  axis.title = element_blank(),       # axis titles
  panel.grid.major = element_blank(), # major grid lines
  panel.grid.minor = element_blank()  # minor grid lines
)

# Plot, discrete (without grid and axis)
merged_data$group <- cut(merged_data$x,
                            breaks = c(0, 200, 400, 600, 800, 1000), 
                            labels = c("0-200", "200-400", "400-600", "600-800", "800-1000"),
                            include.lowest = TRUE)

ggplot(data = merged_data) +
  geom_sf(aes(fill = group)) +  
  scale_fill_manual(name = "x Categories", 
                    values = c("0-200" = "gray90", 
                               "200-400" = "gray70", 
                               "400-600" = "gray50", 
                               "600-800" = "gray30", 
                               "800-1000" = "gray20")) + 
  theme_minimal() +
  ggtitle("Level of x in Korea") +
  theme(
    legend.position = "right",
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

