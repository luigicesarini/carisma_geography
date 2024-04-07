library(sf)
library(tmap)
library(dplyr)
library(data.table)

setwd(paste0(rstudioapi::getSourceEditorContext()$path,"/.."))

setwd("/Users/lcesarini/repo/carisma_geography/")

df <- fread("geografia_carisma.csv",header = FALSE)
list_coords <- list()
for (i in 1:length(df$V1)) {
  list_coords[[i]] <- tmaptools::geocode_OSM(df$V4[i])$coords
}

install.packages("base64enc")
library(base64enc)

tmap_mode("view")

cbind(df,do.call("rbind",list_coords)) %>% 
  select(V1,V4,x,y) -> df_geo


doppioni <- df_geo$V4[duplicated(df_geo$V4)] %>% unique()




df_geo$x[df_geo$V4==doppioni] <- df_geo$x[df_geo$V4==doppioni] + sample(seq(-0.05,+0.05,0.01),size=sum(df_geo$V4==doppioni))
df_geo$y[df_geo$V4==doppioni] <- df_geo$y[df_geo$V4==doppioni] + sample(seq(-0.05,+0.05,0.01),size=sum(df_geo$V4==doppioni))

df_geo %>% 
st_as_sf(coords=c("x","y"),crs=4326,remove=FALSE) %>% 
  rename("Name"="V1",
         "Luogo"="V4") -> sf_obj 
  
library(leaflet)


leaflet(data=sf_obj) %>% 
  setView(lng = 12, lat = 42.3601, zoom = 6) %>% 
  addProviderTiles(providers$Esri.NatGeoWorldMap) %>% 
  addMarkers(~x, ~y, popup = ~as.character(Name), label = ~as.character(Name)) -> m

# Define the coordinates for the line
line_coords <- c(7.093889, 12.50111, 44.701111, 44.9625)  # For example, two points

# Add the line to the map
m <- addPolylines(map = m, lng = line_coords[1:2], lat = line_coords[3:4],popup = "Po",color='red')
m

library(htmlwidgets)
saveWidget(m, file="index.html")

