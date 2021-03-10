library(mapview)
library(leaflet)
# devtools::install_github("r-spatial/leafgl")
library(leafgl)
library(sf)
library(colourvalues)
library(magrittr)
library(data.table)

if(!"my_gadm.RData"%in%list.files()){
  gadm=readRDS("gadm36_FRA_5_sf.rds")#data from https://gadm.org/download_country_v3.html
  load("poly_com_simplif.RData")#lazy way to get APL for a given year from poly_com
  gadm_nom=gadm$NAME_5
  nom2=poly_com[["2015"]]@data$NOM_COM.y
  sum(is.na(nom2))
  sum(!gadm_nom%in%nom2)
  data=poly_com[["2015"]]@data
  data=data.table(data)
  data$nb_NA=rowSums(is.na(data))
  setorder(data,nb_NA)
  data=data[,.SD[1],by="NOM_COM.y"]
  gadm=merge(gadm,data,by.x="NAME_5",by.y="NOM_COM.y")
  gadm=sf::st_cast(gadm,"POLYGON")
  gadm=gadm[!is.na(gadm$Z_MOYEN),]
  gadm$NAME_5=iconv(gadm$NAME_5,"UTF-8","latin1")
  gadm$NAME_5=iconv(gadm$NAME_5,"latin1","UTF-8")
  gadm$popup= paste(gadm$NAME_5,"APL:",round(gadm$mg60_publie,1))
  
  
  save(gadm,file = "my_gadm.RData")
} 

load("my_gadm.RData")


# gadm$NAME_5=iconv(gadm$NAME_5,"latin1","UTF-8")
# table(Encoding(gadm$NAME_5))
# gadm$NAME_5[11:15]
# 
# ch_lu = st_read("gis_osm_landuse_a_free_1.shp")
# ch_lu = ch_lu[, c(1, 3, 4)] # don't handle NAs so far
# ch_lu=sf::st_cast(ch_lu,"POLYGON")
options(viewer = NULL)

# A cause de valeurs extrêmes, il vaut mieux considérer les quantiles.
cols = colour_values_rgb(Hmisc::cut2(gadm$mg60_publie,g = 5)%>%as.numeric,palette = "blue2red",#colour_palettes()
                         include_alpha = FALSE) / 255

table(validUTF8(gadm$popup))


system.time({
  m = leaflet() %>%
    addTiles()%>%
    # addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
    addGlPolygons(data = gadm,
                  color = cols,
                  popup = "popup",
                  group = "APL mg60 2015") %>%
    # addPolygons(data=gadm,fillColor =~cols)%>% 17 sec vs 1,6 sec avec Gl
    # leafem::addMouseCoordinates() %>%
    setView(lng = 2, lat = 47, zoom = 6) 
    # addLayersControl(overlayGroups = "NAME_5")
})


m


