# 1. Environment Setup
# Ensure that you have the necessary Python libraries installed:
# pip install pandas matplotlib seaborn

# 2. Data Loading and Preprocessing
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

# Load the CSV files
directory = r'C:\Users\oscar\OneDrive\Desktop\Cyclistics historical trip data'  # Correct path
file_paths = [os.path.join(directory, f) for f in os.listdir(directory) if f.endswith('.csv')]
list_of_dataframes = []
for file in file_paths:
    try:
        df = pd.read_csv(file)
        if not df.empty:
            list_of_dataframes.append(df)
        else:
            print(f"File {file} is empty and will be skipped.")
    except pd.errors.EmptyDataError:
        print(f"Error reading file {file}. It may be empty or improperly formatted.")

if list_of_dataframes:
    data = pd.concat(list_of_dataframes, ignore_index=True)
    print("Data loaded successfully.")
else:
    print("No data to analyze.")

# Display basic information about the data
print("Basic information about the data:")
print(data.info())
print("\nFirst few rows of the data:")
print(data.head())

# Basic Preprocessing
# Convert timestamps to datetime objects
data['started_at'] = pd.to_datetime(data['started_at'])
data['ended_at'] = pd.to_datetime(data['ended_at'])

# Handle missing values (e.g., drop or impute)
data.dropna(inplace=True)  # Dropping missing values
print("\nData after handling missing values:")
print(data.info())

# Correct data types if necessary
data['start_station_id'] = data['start_station_id'].astype(str)
data['end_station_id'] = data['end_station_id'].astype(str)

# 3. Exploratory Data Analysis (EDA)
# Calculate ride durations and filter out negative and unreasonably long durations
data['duration'] = (data['ended_at'] - data['started_at']).dt.total_seconds() / 60
data = data[(data['duration'] > 0) & (data['duration'] <= 1440)]  # Only keep durations between 0 and 1440 minutes

# Print basic statistics about ride durations
print("\nBasic statistics of ride durations (in minutes):")
print(data['duration'].describe())

# Distribution of ride durations after filtering
sns.histplot(data['duration'], bins=30)
plt.title('Distribution of Ride Durations')
plt.xlabel('Duration (minutes)')
plt.ylabel('Count')
plt.show()

# Comparing member vs. casual usage
sns.countplot(x='member_casual', data=data)
plt.title('Member vs Casual Usage')
plt.show()

# Print the count of member vs casual users
print("\nCount of member vs casual users:")
print(data['member_casual'].value_counts())

# 4. In-depth Analysis
# Time series analysis of daily ride counts
data['start_date'] = data['started_at'].dt.date
daily_rides = data.groupby('start_date').size()
print("\nDaily ride counts:")
print(daily_rides.head())

daily_rides.plot(kind='line')
plt.title('Daily Ride Counts')
plt.xlabel('Date')
plt.ylabel('Number of Rides')
plt.show()

# 5. Reporting and Visualization
# Heatmap of rides by hour and day of the week
data['start_hour'] = data['started_at'].dt.hour
data['day_of_week'] = data['started_at'].dt.day_name()
pivot_table = pd.pivot_table(data, values='ride_id', index='day_of_week', columns='start_hour', aggfunc='count')
sns.heatmap(pivot_table, cmap='YlGnBu')
plt.title('Heatmap of Rides by Hour and Day of the Week')
plt.ylabel('Day of the Week')
plt.xlabel('Hour of Day')
plt.show()

# 6. Automation and Scalability
# For automation, you can encapsulate these steps in functions or a Python script that can be executed regularly.
# For scalability, consider using libraries like Dask for handling very large datasets.
