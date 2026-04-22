#! /bin/bash

#### EXTRACTION ####

loc_1="New+York"
loc1_time=$(TZ="America/New_York" date +"%H")
time_stamp=$(date +"%Y-%m-%d %H:%M:%S")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB="$SCRIPT_DIR/weather.db"

if [[ $loc1_time == 0 ]];
then
    echo "$time_stamp, ETL Process Started" >> logs.csv

    ### API fetch failure handler
    MAX_ATTEMPTS=3
    for attempt in $(seq 1 $MAX_ATTEMPTS); do
        curl -s "wttr.in/$loc_1?format=j1" > weather_new_york.json && break
        echo "$time_stamp, EXTRACTION warning (attempt $attempt of $MAX_ATTEMPTS failed)" >> logs.csv
        sleep 5
    done
    
    if [[ $attempt == $MAX_ATTEMPTS ]]; then
        echo "$time_stamp, EXTRACTION failed (all retries exhausted)" >> logs.csv
        exit 1
    fi

    ### Data malformation handler
    if ! jq empty weather_new_york.json 2>/dev/null; then
    echo "$time_stamp, EXTRACTION failed (invalid JSON response)" >> logs.csv
    exit 1
    fi

    echo "$time_stamp,EXTRACTION success (fetched weather data)" >> logs.csv
    #New York
    morning_temp=$(jq -r '.weather[0].hourly[2].tempF' weather_new_york.json)
    noon_temp=$(jq -r '.weather[0].hourly[4].tempF' weather_new_york.json)
    evening_temp=$(jq -r '.weather[0].hourly[6].tempF' weather_new_york.json)
    night_temp=$(jq -r '.weather[0].hourly[7].tempF' weather_new_york.json)

    #### LOAD ####
    sqlite3 "$DB" << EOF
    CREATE TABLE IF NOT EXISTS weather_predictions (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        date        DATE UNIQUE,
        created_at  DATETIME,
        morning_temp_f REAL,
        noon_temp_f   REAL,
        evening_temp_f REAL,
        night_temp_f  REAL
    );

    CREATE TABLE IF NOT EXISTS weather_actuals (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        date                DATE UNIQUE,
        real_morning_temp_f REAL,
        morning_timestamp   DATETIME,
        real_noon_temp_f    REAL,
        noon_timestamp      DATETIME,
        real_evening_temp_f REAL,
        evening_timestamp   DATETIME,
        real_night_temp_f   REAL,
        night_timestamp     DATETIME
    );

    CREATE TABLE IF NOT EXISTS predictions_errors (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        date                DATE UNIQUE,
        morning_error       REAL,
        noon_error          REAL,
        evening_error       REAL,
        night_error         REAL,
        daily_error         REAL
    );


    INSERT OR IGNORE INTO weather_predictions 
    (date, created_at, morning_temp_f, noon_temp_f, evening_temp_f, night_temp_f)
    VALUES 
    (date('$time_stamp'),'$time_stamp', '$morning_temp', '$noon_temp', '$evening_temp', '$night_temp');


    INSERT OR IGNORE INTO weather_actuals (date)
    VALUES (date('$time_stamp'));

    INSERT OR IGNORE INTO predictions_errors (date)
    VALUES (date('$time_stamp'));
EOF
    echo "$time_stamp, LOADING success (loaded predictions data)" >> logs.csv
fi

#### EXTRACTION ####
#Actual temperatures
if [[ $loc1_time != 0 ]];
then

    ### API fetch failure handler
    MAX_RETRIES=3
    for attempt in $(seq 1 $MAX_RETRIES); do
        curl -s "wttr.in/$loc_1?format=j1" > weather_new_york.json && break
        echo "$time_stamp, EXTRACTION warning (attempt $attempt of $MAX_RETRIES failed)" >> logs.csv
        sleep 5
    done

    if [[ $attempt == $MAX_RETRIES ]]; then
        echo "$time_stamp, EXTRACTION failed (all retries exhausted)" >> logs.csv
        exit 1
    fi

    ### Data malformation handler
    if ! jq empty weather_new_york.json 2>/dev/null; then
    echo "$time_stamp, EXTRACTION failed (invalid JSON response)" >> logs.csv
    exit 1
    fi

    echo "$time_stamp, EXTRACTION success (fetched weather data)" >> logs.csv
    curr_temp=$(jq -r '.current_condition[0].temp_F' weather_new_york.json)

    if [[ $loc1_time == 06 ]];
    then
        sqlite3 "$DB" "UPDATE weather_actuals SET real_morning_temp_f = '$curr_temp', morning_timestamp = '$time_stamp' WHERE date = date('$time_stamp');"
        echo "$time_stamp, LOADING success (loaded current morning temperature)" >> logs.csv
    elif [[ $loc1_time == 12 ]];
    then
        sqlite3 "$DB" "UPDATE weather_actuals SET real_noon_temp_f = '$curr_temp', noon_timestamp = '$time_stamp' WHERE date = date('$time_stamp');"
        echo "$time_stamp, LOADING success (loaded current noon temperature)" >> logs.csv
    elif [[ $loc1_time == 18 ]];
    then
        sqlite3 "$DB" "UPDATE weather_actuals SET real_evening_temp_f = '$curr_temp', evening_timestamp = '$time_stamp' WHERE date = date('$time_stamp');"
        echo "$time_stamp, LOADING success (loaded current evening temperature)" >> logs.csv
    elif [[ $loc1_time == 21 ]];
    then
        sqlite3 "$DB" "UPDATE weather_actuals SET real_night_temp_f = '$curr_temp', night_timestamp = '$time_stamp' WHERE date = date('$time_stamp');"
        echo "$time_stamp, LOADING success (loaded current night temperature)" >> logs.csv

        #### TRANSFORM ####
        #### LOAD ####
        ###Loading predictions errors
        sqlite3 "$DB" "UPDATE predictions_errors
        SET
            morning_error = sub.morning_error,
            noon_error    = sub.noon_error,
            evening_error = sub.evening_error,
            night_error   = sub.night_error,
            daily_error   = sub.daily_error
        FROM (
            SELECT 
                a.date,

                a.real_morning_temp_f - p.morning_temp_f AS morning_error,
                a.real_noon_temp_f    - p.noon_temp_f    AS noon_error,
                a.real_evening_temp_f - p.evening_temp_f AS evening_error,
                a.real_night_temp_f   - p.night_temp_f   AS night_error,

                (
                    ABS(a.real_morning_temp_f - p.morning_temp_f) +
                    ABS(a.real_noon_temp_f    - p.noon_temp_f) +
                    ABS(a.real_evening_temp_f - p.evening_temp_f) +
                    ABS(a.real_night_temp_f   - p.night_temp_f)
                ) / 4.0 AS daily_error

            FROM weather_actuals a

            JOIN weather_predictions p ON a.date = p.date
            -- 🚨 guard: only compute if all actuals exist
            WHERE 
                a.real_morning_temp_f IS NOT NULL AND
                a.real_noon_temp_f IS NOT NULL AND
                a.real_evening_temp_f IS NOT NULL AND
                a.real_night_temp_f IS NOT NULL

        ) AS sub
        WHERE predictions_errors.date = sub.date
        AND predictions_errors.date = date('$time_stamp');"
        echo "$time_stamp, LOADING success (transformed and loaded prediction errors data)" >> logs.csv
    fi
    echo "$time_stamp, ETL Process Ended" >> logs.csv
fi
