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

sqlite3 "$DB" << EOF
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

CREATE TABLE IF NOT EXISTS weather_actuals (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    date                DATE,
    real_morning_temp_f REAL,
    morning_timestamp   DATETIME,
    real_noon_temp_f    REAL,
    noon_timestamp      DATETIME,
    real_evening_temp_f REAL,
    evening_timestamp   DATETIME,
    real_night_temp_f   REAL,
    night_timestamp     DATETIME
);

INSERT INTO weather_actuals (date)
VALUES (date('$time_stamp'));
EOF

#current temperature
curl -s "wttr.in/$loc_1?format=j1" > weather_new_york.json
curr_temp=$(jq -r '.current_condition[0].temp_F' weather_new_york.json)
local_time1=$(curl -s "wttr.in/new+york?format=%T" | cut -c1-2)
time_stamp1=$(date +"%Y-%m-%d %H:%M:%S")

if [[ $local_time1 == 06 ]]
then
    sqlite3 "$DB" "UPDATE weather_actuals SET real_morning_temp_f = '$curr_temp', morning_timestamp = '$time_stamp1' WHERE date = date('$time_stamp1');"
elif [[ $local_time1 == 12 ]]
then
    sqlite3 "$DB" "UPDATE weather_actuals SET real_noon_temp_f = '$curr_temp', noon_timestamp = '$time_stamp1' WHERE date = date('$time_stamp1');"
elif [[ $local_time1 == 18 ]]
then
    sqlite3 "$DB" "UPDATE weather_actuals SET real_evening_temp_f = '$curr_temp', evening_timestamp = '$time_stamp1' WHERE date = date('$time_stamp1');"
elif [[ $local_time1 == 21 ]]
then
    sqlite3 "$DB" "UPDATE weather_actuals SET real_night_temp_f = '$curr_temp', night_timestamp = '$time_stamp1' WHERE date = date('$time_stamp1');"
fi






