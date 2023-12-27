install.packages("lubridate")
install.packages("ggplot2")
install.packages("viridis")

# 2. Data Loading and Preprocessing
library(tidyverse)
library(lubridate)
library(ggplot2)
library(viridis)

# Specify the file paths
file_paths <- c(
  "C:/Users/oscar/OneDrive/Desktop/Cyclistics historical trip data/202101-divvy-tripdata.csv",
  "C:/Users/oscar/OneDrive/Desktop/Cyclistics historical trip data/202102-divvy-tripdata.csv",
  "C:/Users/oscar/OneDrive/Desktop/Cyclistics historical trip data/202103-divvy-tripdata.csv",
  "C:/Users/oscar/OneDrive/Desktop/Cyclistics historical trip data/202004-divvy-tripdata.csv",
  "C:/Users/oscar/OneDrive/Desktop/Cyclistics historical trip data/202005-divvy-tripdata.csv",
  "C:/Users/oscar/OneDrive/Desktop/Cyclistics historical trip data/202006-divvy-tripdata.csv",
  "C:/Users/oscar/OneDrive/Desktop/Cyclistics historical trip data/202007-divvy-tripdata.csv",
  "C:/Users/oscar/OneDrive/Desktop/Cyclistics historical trip data/202008-divvy-tripdata.csv",
  "C:/Users/oscar/OneDrive/Desktop/Cyclistics historical trip data/202009-divvy-tripdata.csv",
  "C:/Users/oscar/OneDrive/Desktop/Cyclistics historical trip data/202010-divvy-tripdata.csv",
  "C:/Users/oscar/OneDrive/Desktop/Cyclistics historical trip data/202011-divvy-tripdata.csv",
  "C:/Users/oscar/OneDrive/Desktop/Cyclistics historical trip data/202012-divvy-tripdata.csv"
)

print(paste("Loading", length(file_paths), "CSV files."))

# Load and concatenate the CSV files
list_of_dataframes <- lapply(file_paths, function(fp) {
  message("Reading file: ", fp)
  df <- try(read_csv(fp), silent = TRUE)
  if (inherits(df, "try-error")) {
    message("Error reading file: ", fp)
    return(NULL)
  }
  if (nrow(df) == 0) {
    message("File is empty: ", fp)
    return(NULL)
  }
  return(df)
})

list_of_dataframes <- list_of_dataframes[!sapply(list_of_dataframes, is.null)]
data <- bind_rows(list_of_dataframes)
message("All files have been read and combined.")

# Display basic statistical information about the data
print("Basic statistical info of the data:")
print(summary(data))
print("Structure of the data:")
print(str(data))
print("First few rows of the data:")
print(head(data))

# Basic Preprocessing
# Convert timestamps to datetime objects and handle missing values
data <- data %>%
  mutate(started_at = as_datetime(started_at),
         ended_at = as_datetime(ended_at)) %>%
  drop_na()

# Correct data types if necessary
data$start_station_id <- as.character(data$start_station_id)
data$end_station_id <- as.character(data$end_station_id)

# 3. Exploratory Data Analysis (EDA)
# Calculate ride durations and filter out negative and unreasonably long durations
data <- data %>%
  mutate(duration = as.numeric(difftime(ended_at, started_at, units = "mins"))) %>%
  filter(duration > 0 & duration <= 1440)

# Distribution of ride durations after filtering
hist_plot <- ggplot(data, aes(x = duration)) +
  geom_histogram(bins = 30) +
  labs(title = 'Distribution of Ride Durations', x = 'Duration (minutes)', y = 'Count') +
  theme_minimal()
print(hist_plot)

# Comparing member vs. casual usage
bar_plot <- ggplot(data, aes(x = member_casual)) +
  geom_bar() +
  labs(title = 'Member vs Casual Usage') +
  theme_minimal()
print(bar_plot)

# 4. In-depth Analysis
# Time series analysis of daily ride counts
data <- data %>%
  mutate(start_date = as.Date(started_at))

daily_rides <- data %>%
  group_by(start_date) %>%
  summarise(count = n())

time_series_plot <- ggplot(daily_rides, aes(x = start_date, y = count)) +
  geom_line() +
  labs(title = 'Daily Ride Counts', x = 'Date', y = 'Number of Rides') +
  theme_minimal()
print(time_series_plot)

# 5. Reporting and Visualization
# Heatmap of rides by hour and day of the week
data <- data %>%
  mutate(start_hour = hour(started_at),
         day_of_week = wday(started_at, label = TRUE))

pivot_table <- data %>%
  count(day_of_week, start_hour) %>%
  spread(key = start_hour, value = n, fill = 0)

# Convert pivot_table back to long format for ggplot
long_format <- pivot_table %>%
  gather(key = "start_hour", value = "n", -day_of_week) %>%
  mutate(start_hour = as.numeric(start_hour))  # convert hour to numeric for plotting

# Plot the heatmap
heatmap_plot <- ggplot(long_format, aes(x = start_hour, y = day_of_week, fill = n)) +
  geom_tile() +
  scale_fill_viridis_c() +
  labs(title = 'Heatmap of Rides by Hour and Day of the Week', x = 'Hour of Day', y = 'Day of the Week') +
  theme_minimal()

print(heatmap_plot)

# 6. Automation and Scalability
# For automation, you can create an R script and schedule it to run with taskscheduleR on Windows.
# For handling very large datasets, consider using data.table or dplyr with databases.
