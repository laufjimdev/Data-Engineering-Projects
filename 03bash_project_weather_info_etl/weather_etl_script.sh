#! /bin/bash

#### EXTRACTION ####

loc_1="New+York"
#local_time=$(curl -s "wttr.in/new+york?format=%T" | cut -c1-2)
#if [[ $local_time == 0 ]]
#
curl -s "wttr.in/$loc_1?format=j1" > weather_new_york.json
#fi

#New York
morning_temp=$(jq -r '.weather[0].hourly[2].tempF' weather_new_york.json)
noon_temp=$(jq -r '.weather[0].hourly[4].tempF' weather_new_york.json)
evening_temp=$(jq -r '.weather[0].hourly[6].tempF' weather_new_york.json)
night_temp=$(jq -r '.weather[0].hourly[7].tempF' weather_new_york.json)

time_stamp=$(date +"%Y-%m-%d %H:%M:%S")

#### LOAD ####
DB='/Users/lauradev/Desktop/Data Engineering Projects/03bash_project_weather_info_etl/weather.db'

sqlite3 $DB << EOF
CREATE TABLE IF NOT EXISTS weather_predictions (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    time_stamp  DATETIME,
    morning_temp_f REAL,
    noon_temp_f   REAL,
    evening_temp_f REAL,
    night_temp_f  REAL
);

INSERT INTO weather_predictions (time_stamp, morning_temp_f, noon_temp_f, evening_temp_f, night_temp_f)
VALUES ('$time_stamp', '$morning_temp', '$noon_temp', '$evening_temp', '$night_temp');
EOF

echo "Inserted: $time_stamp | morning: $morning_temp | noon: $noon_temp | evening: $evening_temp | night: $night_temp"

#Parsing the data
curr_temp=$(jq -r '.current_condition[0].temp_F' weather_new_york.json) 




