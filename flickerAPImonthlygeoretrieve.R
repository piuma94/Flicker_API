


## FINAL API query search - glasgow buffer geography ######################
## i have developed a pipeline to access the flicker api and retrieve georeferenced data for a series of specific keywords. 
## first define the are and the keywords, the script will create a list for you and then aggregate everything in a dataframe with converted dates.
## the errors handled are if i stop getting images (quite rare) - if i start getting only duplicated images and the nr of new images do not change after 10 pages - if the final dataset is empty 
## moreover, we are handling the situation in which different elements of the same list are differently formatted.

## Put your own directory
setwd("/Users/luigi.caopinna/Library/CloudStorage/OneDrive-UniversityofGlasgow/Desktop/Pipelines - DEF script/flicker/data") ## fisso casa

#setwd("C:/Users/luigi/OneDrive - University of Glasgow/Desktop/Pipelines - DEF script/flicker/data") ## fisso casa
library(FlickrAPI)
library(dplyr)
library(lubridate)
#install.packages("openxlsx")
library(openxlsx)
### i need to understand what the accuracy thing stand for. 
## MOST OF THE TIME I HAVE AN ACCURACY OF 16: THAT MEANS A CITY STREET LEVEL ACCURACY, 15 WAS CITY LEVEL

#setFlickrAPIKey(api_key, overwrite = FALSE, install = FALSE)
key <- "*************************"
secret <- "*******************"
# Coordinates of Glasgow
glasgow_lon <- -4.25763
glasgow_lat <- 55.86515

# Buffer radius in kilometers
buffer_radius <- 100
# Calculate the bounding box coordinates
bbox_lon_min <- glasgow_lon - (buffer_radius / (111.32 * cos(glasgow_lat * pi / 180)))
bbox_lon_max <- glasgow_lon + (buffer_radius / (111.32 * cos(glasgow_lat * pi / 180)))
bbox_lat_min <- glasgow_lat - (buffer_radius / 110.574)
bbox_lat_max <- glasgow_lat + (buffer_radius / 110.574)
load("names.Rda") ### uploading the file with parks numbers
names_no_parks<-gsub("Park","",names)
names_no_parks<-gsub("   ","",names_no_parks)
names_no_parks<-gsub( " ","",names_no_parks)
API_words<-c( 
              "SDG","tree","trees","biodiversity_loss","nature","environment","protect_nature","Naturephotography","flowers","wildflowers","bee","bees","bird","birds","restore_biodiversity","citizenscience","connectivity","BirdSpecies","mammalspecies","Birding","birdphotography","Habitat","wildlifephotography","wildlife","animals","garden","gardening","LocalNatureReserve","urban_corridors","HabitatMapping", ## WP2
              
              names_no_parks,names, "park","parks", ## GCC ideas - parks and parks names 
              "flood_risk","riverscapes","riverscape","river_landscape","river_landscapes","flood_adaptation","flood","flooding", "tidal","riverclyde","tidal_change",  "sea_level_rise", "sea_level" , "extreme_weather", "flood_warning",
              "UrbanCorridorParks", "FloodWaterStorage", "searise", "riverclyde", "riverkelvin",  #) ## WP1,#) ## WP1
              "derelict", "vacant","land","polluted_lands","derelictland", "greenhouse_gas","trappollutants","greenhousegases","abandoned_land","polluted","airquality","vacant_land","contamination" ,"pollutant","environmentalcontamination", ###) ### WP3 
              "Promoting_active_travel","active_travel","inclusive_mobility","cycling", "cyclist", "cyclists", "bike", "bike_sharing","wheeling" , "walking", "bus" , "tram" ,"bus_stops" , "subway","subway_station", "train","trains", "train_station", "tram_stops", "the_limit", "20mileshour","20_minute_neighbourhood","public_transport","mcgill","firstbus" ,"lowemission_zone", "lez", "nextbike", "mobility", "10_minutes_from_home" , "pedestrian", "transportation","sustainable_travel", "bicycles", "bicycle", "cycle", "pedestrianised", "e-bike", "e-bicycle", "commuters", "commuting", "adaptive_cycle", "walkability", "rail", "JMB_travel", "PVT", "stagecoach", "liveable_neighbhourood", "LN", "city_network", "road_safety", ### WP 4
              "Sustainable_energy","solar_panels","solar_panel","wind_turbines","wind_turbine", "eolic_turbine","eolic_turbines", "net_zero", "net_zero_carbon", "low_carbon","low_carbon_energy","clean_energy" ,"CleanEnergyDemand", "renewables", "renewable_energy", "sustainable_energy","low_emissions" ,"lower_emissions", "emissions" ,"carbon_emissions","carbon_neutral","energy_solutions","Climate_Crisis", "cutting_emissions" ,"energy" , "energy_transition", "heating","sustainable_heating","sustainable_transport", "sustainable" ,"CarbonDioxideEmissions", ## WP5
              "Sustainable_development_goal", "SDG", "SIMD","Scottish_Index_of_Multiple_Deprivation", "system_thinking", ### WS1 words
              "Glasgow" , "streetphotography" , "streetphotographers","glasgowstreetphotography","photooftheday", "PeopleMakeGlasgow","glasgow_people", "photo_mapping", "glasgow_westend","westend_glasgow" , "glasgow_photography" , "glasgow_photographer" ,"Glasgow_central" , "glasgow_street_photography", "photo", "community_spaces" , "Community","southside_glasgow", "glasgow_southside", "glasgow_style" ,"community_justice", "collaborative_community", "Community_collaboration", ### WS 2 words
              "data" , "data_analytics","data_hub", ## WS3
              "Urban_environmental", "ecological_ceiling", "climate_resilience","climate_adaptation" ,"glasgow_living_lab", "living_lab", "thriving_cities", "thrivingcityinitiative","c40cities", "green_transition","GALLANT","glasgowGALLANT", "GALLANTglasgow","sustainability" , "climate_change" ,"air_quality", "environmentaljustice", ######) ## GALLANT wide
              "Scotland", "Glasgow_city_region", "western_Lowlands","Glasgow_West","Anderston", "west_end","Govan","Govanhill" , "Strathbungo", ## the geographic API query
              "decay","vandalised", "vandal", "mural", "leftbehind", "disused","abandoned", "vandalism", "graffiti", "murals", "antisocial", "publicdisorder", "urbandecay", "crime", "criminality", "publicnuisance", "propertydamage","garbage","trash" ## vandalism related queries
             ) ## GCC ideas - parks and parks names 
              #emoji(keyword = "palm_tree"),emoji(keyword = "deciduous_tree"),emoji(keyword = "vertical_traffic_light"),emoji(keyword = "bus"),emoji(keyword = "oncoming_bus"), emoji(keyword = "bicycle"),emoji(keyword = "seedling"),emoji(keyword = "deciduous_tree"),emoji(keyword = "herb"),emoji(keyword = "potted_plant")) ## adding emojis
## for flicker, emojis are not helpfull and do not retrieve any image. GOOD TO KNOW
              
              ## do not waste money, check for duplicated
sum(!duplicated(API_words))
#APIwords_added<-c( emoji(keyword = "palm_tree"),emoji(keyword = "deciduous_tree"),emoji(keyword = "vertical_traffic_light"),emoji(keyword = "bus"),emoji(keyword = "oncoming_bus"), emoji(keyword = "bicycle"),emoji(keyword = "seedling"),emoji(keyword = "deciduous_tree"),emoji(keyword = "herb"),emoji(keyword = "potted_plant"))
API_words_sorted<-sort(API_words[!duplicated(API_words)])
length(API_words_sorted)  ### 520 so i need to see 520*2 data total
# flickrOAuth(api_key =key, secret = secret)
for (word in API_words_sorted[]) { ## ALL WORKED BUT THERE WAS A PROBLEM WITH GARDENING and 32 and 33
  #word="nature"
  # Search for photos within the buffer area
  all_photos <- list()
  all_photosasc <- list()
  
  all_photos[[1]] <- getPhotoSearch(
    tags =word,
    api_key = key,
    sort = "date-posted-desc",
    api_secret = secret,
    bbox = c(bbox_lon_min, bbox_lat_min, bbox_lon_max, bbox_lat_max),
    extras =c("description", "license", "date_upload", "date_taken", "owner_name", "icon_server", "original_format", "last_update", "geo", "tags", "machine_tags", "o_dims", "views", "media", "path_alias", "url_sq", "url_t", "url_s", "url_q", "url_m", "url_n", "url_z", "url_c", "url_l", "url_o"),
    page = 1,
    per_page = 200
  )
  
  all_photosasc[[1]] <- getPhotoSearch(
    tags =word,
    api_key = key,
    sort = "date-posted-asc",
    api_secret = secret,
    bbox = c(bbox_lon_min, bbox_lat_min, bbox_lon_max, bbox_lat_max),
    extras =c("description", "license", "date_upload", "date_taken", "owner_name", "icon_server", "original_format", "last_update", "geo", "tags", "machine_tags", "o_dims", "views", "media", "path_alias", "url_sq", "url_t", "url_s", "url_q", "url_m", "url_n", "url_z", "url_c", "url_l", "url_o"),
    page = 1,
    per_page = 200
  )
  
  # Retrieve photos from each page
  num_pages <- 100000000000000
  un_nr <- list() ## create a list of unique numbers 
  un_nr_asc <- list() ## create a list of unique numbers 
  
  for (page in 2:num_pages) {
    # page=2
    photos <- getPhotoSearch(
      tags =word, #c("nature", "biodiversity_loss","protect_nature","Naturephotography","flowers","wildflowers","bee","bees"),#c("bird","birds","biodiversity_loss","restore_biodiversity","citizenscience","biodiversity","connectivity","BirdSpecies","mammalspecies","Birding","birdphotography","HabitatMapping"), ## c("flood","flooding", "tidal","riverclyde")
      sort = "date-posted-desc",
      api_key = key,
      api_secret = secret,
      bbox = c(bbox_lon_min, bbox_lat_min, bbox_lon_max, bbox_lat_max),
      extras = c("description", "license", "date_upload", "date_taken", "owner_name", "icon_server", "original_format", "last_update", "geo", "tags", "machine_tags", "o_dims", "views", "media", "path_alias", "url_sq", "url_t", "url_s", "url_q", "url_m", "url_n", "url_z", "url_c", "url_l", "url_o"),
      page = page,
      per_page = 200
    )
    photos_asc <- getPhotoSearch(
      tags =word, #c("nature", "biodiversity_loss","protect_nature","Naturephotography","flowers","wildflowers","bee","bees"),#c("bird","birds","biodiversity_loss","restore_biodiversity","citizenscience","biodiversity","connectivity","BirdSpecies","mammalspecies","Birding","birdphotography","HabitatMapping"), ## c("flood","flooding", "tidal","riverclyde")
      sort = "date-posted-asc",
      api_key = key,
      api_secret = secret,
      bbox = c(bbox_lon_min, bbox_lat_min, bbox_lon_max, bbox_lat_max),
      extras = c("description", "license", "date_upload", "date_taken", "owner_name", "icon_server", "original_format", "last_update", "geo", "tags", "machine_tags", "o_dims", "views", "media", "path_alias", "url_sq", "url_t", "url_s", "url_q", "url_m", "url_n", "url_z", "url_c", "url_l", "url_o"),
      page = page,
      per_page = 200
    )
    ### going to sleep for 20 sec 
    Sys.sleep(1* 20) ## as this do not have a limit rate. i need to put this here to apparently being able to retrieve more images 
    
    # Check if the photos data frame is empty and break the loop if it is
    if (nrow(photos) == 0 & nrow(photos_asc) == 0) { ### stopping if i am not retrieving more images
      print(paste("No results on page desc", page, "- stopping."))
      print(paste("No results on page asc", page, "- stopping."))
      
      break
    } else {
      #row.names(photos) <- paste0(page, "_", row.names(photos))
      #row.names(photos_asc) <- paste0(page, "_", row.names(photos_asc))
      
      all_photos[[page]] <- photos
      all_photosasc[[page]] <- photos_asc
      
      print(page)
      ## transforming all to characters to avoid conflict 
      all_photos <- lapply(all_photos, function(df) {
        df$context <- as.character(df$context)
        df$latitude <- as.character(df$latitude)
        df$longitude <- as.character(df$longitude)
        df$accuracy <- as.character(df$accuracy)
        
        df$datetakenunknown <- as.character(df$datetakenunknown)
        
        return(df)
      })
      all_photosasc <- lapply(all_photosasc, function(df) {
        df$context <- as.character(df$context)
        df$latitude <- as.character(df$latitude)
        df$longitude <- as.character(df$longitude)
        df$accuracy <- as.character(df$accuracy)
        
        df$datetakenunknown <- as.character(df$datetakenunknown)
        
        return(df)
      })
      ## checking images duplicated in all photos
      all_photos_df <- (bind_rows(all_photos))
      #all_photos_df$description<-as.character(all_photos_df$description)
      #all_photos_df <- do.call(rbind, all_photos)
      
      print(paste("duplicated desc=",sum(duplicated(all_photos_df$id))))
      print(paste("unique desc=",length(unique(all_photos_df$id))))
      un_nr[[page]]<-length(unique(all_photos_df$id))
      ### checking duplicated for ascending search
      all_photos_df_asc <- (bind_rows(all_photosasc))
      #all_photos_df$description<-as.character(all_photos_df$description)
      #all_photos_df <- do.call(rbind, all_photos)
      
      print(paste("duplicated asc=",sum(duplicated(all_photos_df_asc$id))))
      print(paste("unique asc=",length(unique(all_photos_df_asc$id))))
      un_nr_asc[[page]]<-length(unique(all_photos_df_asc$id))
      print(paste("unique total=",length(unique(c(all_photos_df_asc$id,all_photos_df$id)))))
      print(paste("overlap total=",length(intersect(all_photos_df_asc$id,all_photos_df$id))))
      
      
      
    }
    ### basic and simple check, if the nr of unique is equal to the previous, then let's stop 
    ## with the end it means it will continue if at least one is stil getting something.
    ifelse(page>11,if ( un_nr[[(page-10)]]==  un_nr[[page]] & un_nr_asc[[(page-10)]]==  un_nr_asc[[page]]  ) { ## stopping if i am starting to always get the same number of images
      print(paste("no getting new images at page = ", page, " - stopping."))
      break
    } else {
      print("new page")
      ### basic and simple check, if the nr of unique is equal to the previous, then let's stop 
      
    }, print(""))
    
    
    
  }
  # Combine all photos into a single data frame
  formatted_date <- format(Sys.time(), "%Y-%m-%d")
  #print(formatted_date)
  
   
  # load("biodiversity_loss_list_flickr.Rda") #all_photos
  all_photos <- lapply(all_photos, function(df) {
    df$context <- as.character(df$context)
    df$latitude <- as.character(df$latitude)
    df$longitude <- as.character(df$longitude)
    df$accuracy <- as.character(df$accuracy)
    
    df$datetakenunknown <- as.character(df$datetakenunknown)
    
    return(df)
  })
  all_photosasc <- lapply(all_photosasc, function(df) {
    df$context <- as.character(df$context)
    df$latitude <- as.character(df$latitude)
    df$longitude <- as.character(df$longitude)
    df$accuracy <- as.character(df$accuracy)
    
    df$datetakenunknown <- as.character(df$datetakenunknown)
    
    return(df)
  })
  
  ## making it a dataframe
  all_photos_df <- bind_rows(all_photos)
  all_photos_df_asc <- (bind_rows(all_photosasc))
  
  #all_photos_df <- do.call(rbind, all_photos)
  try(all_photos_df<-rbind(all_photos_df,all_photos_df_asc)) ## if this try do not work, then i will still only save the ascending one
  # i need to put that because it somethimes stopped
  
  ## checking before removing duplicates 
  all_photos_df<-all_photos_df[!duplicated(all_photos_df$id),]
  
  ### explaining dates 
  # Load the lubridate package
  
  # Get a correct format on the dates, end up being a dangerous waste of time. Just avoid it for now. 
  
  # Extract components from the datetime column and create new columns
  if (nrow(all_photos_df) > 0) { ### stopping if i am not retrieving more images
    #all_photos_df$datetaken <- as.Date(all_photos_df$datetaken, format = "%d/%m/%Y")
    
    all_photos_df$year <- year(all_photos_df$datetaken)
    all_photos_df$month <- month(all_photos_df$datetaken)
    all_photos_df$day <- day(all_photos_df$datetaken)
    all_photos_df$hour <- hour(all_photos_df$datetaken)
    all_photos_df$minute <- minute(all_photos_df$datetaken)
    all_photos_df$second <- second(all_photos_df$datetaken)
    
    #all_photos_df<-all_photos_df[,-11]
    all_photos_df[,11]<-bind_rows(all_photos_df$description)
    
    try(save(all_photos_df,file=paste(word,formatted_date,"df_flickr.Rda", sep="_")))
    #write.csv(all_photos_df,file=paste(word,"df_flickr.csv", sep="_"))
    try(write.xlsx(as.data.frame(all_photos_df), paste(word,formatted_date,"df_flickr.xlsx", sep="_")))
    
  } else {
    print("no retrieved data - no saving")
  }
  
}
















































