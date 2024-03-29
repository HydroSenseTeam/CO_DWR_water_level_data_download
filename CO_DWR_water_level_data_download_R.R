
#Author: Abdullah Al Fatta
#Date: 05/11/2023


# Load packages
library(cdssr)
library(dplyr)

# Create an empty data frame to store the results
all_water_levels <- data.frame()

# Loop over all divisions and append the results to the dataframe
for (i in 1:7){
  water_level <- cdssr::get_gw_wl_wells(
    county = , 
    designated_basin = , 
    division = i, 
    management_district= , 
    water_district = ,
    wellid = ,
    api_key = "c9cY6g6B4eQT6NfXVU/1BKs/nKJ9WQFN"
  )
  
  all_water_levels <- rbind(all_water_levels, water_level)
}

# Fetch unique well names and store in well_ids_unique list
well_ids_unique <- unique(all_water_levels$well_id)


# Create an empty dataframe to store the water level data
water_level_data_CWR1 <- data.frame()

while (length(well_ids_unique) > 0) {
  # Get the first well ID from the list
  wellid <- well_ids_unique[1]
  
  # Request well measurements endpoint (api/v2/groundwater/waterlevels/wellmeasurements)
  tryCatch({
    water_level_all <- cdssr::get_gw_wl_wellmeasures(
      wellid = wellid,
      start_date = "1990-01-01", #start date for water level measurement
      end_date = "2023-01-01"    #end date for water level measurement
    )
    
    # Check if the dataframe is empty or not
    if (!is.data.frame(water_level_all) || nrow(water_level_all) == 0) {
      cat(paste("No data found for well ID", wellid, "\n"))
    } else {
      # Append the well_measure data to the dataframe
      water_level_data_CWR1 <- rbind(water_level_data_CWR1, water_level_all)
    }
    
    # Remove the well ID from the list if successful
    well_ids_unique <- well_ids_unique[-1]
    
  }, error = function(e) {
    cat(paste("Error fetching data for well ID", wellid, ":", conditionMessage(e), "\n"))
    # Remove the well ID from the list if it caused an error
    well_ids_unique <- well_ids_unique[-1]
  })
}

# Write the water level data to a CSV file
#write.csv(water_level_data_CWR1, file = "D:/OneDrive - Colostate/Al Fatta Smith/Data/water level data CO/water_level_data_CWR1_usingR.csv", row.names = FALSE)


# Merge the two data frames by well_id column as water_level_all doesn't have lat and lon
# which is needed for plotting in ArcGIS
# merged_water_level_data1 <- merge(water_level_data_CWR1, all_water_levels, by = "well_id", all = TRUE)
# Inner join the two data frames by well_id column and remove non-matching rows from water_level_data_CWR1
merged_data <- inner_join(water_level_data_CWR1, all_water_levels[, c("well_id", "elevation", "latitude", "longitude", "more_information")], by = "well_id")

# Write the water level data to a CSV file
#write.csv(merged_data, file = "D:/OneDrive - Colostate/Al Fatta Smith/Data/water level data CO/merged_data_all.csv", row.names = FALSE)

