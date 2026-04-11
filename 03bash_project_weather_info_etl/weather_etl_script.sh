#! /bin/bash

#### EXTRACTION ####
#Downloading the data to a json file
curl -s "wttr.in/?format=j1" > weather.json
#Parsing the data
temp=$(jq -r '.current_condition[0].temp_F' weather.json) 
uv=$(jq -r '.current_condition[0].uvIndex' weather.json)
precip=$(jq -r '.current_condition[0].precipMM' weather.json)
humidity=$(jq -r '.current_condition[0].humidity' weather.json)
sky=$(jq -r '.current_condition[0].weatherDesc[0].value' weather.json)

echo $sky