# 🌤️ Weather ETL Pipeline — New York City

A beginner-level end-to-end ETL (Extract, Transform, Load) pipeline built in Bash that tracks the margin of error of a weather API's daily predictions against actual observed temperatures.

---

## 📌 Project Overview

This pipeline fetches weather forecast data from [wttr.in](https://wttr.in) at midnight and compares it against actual temperatures recorded throughout the day (morning, noon, evening, and night). At the end of each day, it calculates the prediction error for each time window and stores the results in a local SQLite database.

The goal is to measure how accurate the API's predictions are over time.

---

## 🛠️ Tech Stack

- **Bash** — pipeline orchestration and scripting
- **SQLite3** — local database storage
- **jq** — JSON parsing
- **curl** — API requests
- **cron** — scheduled execution

---

## 🗄️ Database Schema

The pipeline maintains three tables in a local SQLite database:

**`weather_predictions`** — stores the forecast fetched at midnight

- `date` (unique), `created_at`, `morning_temp_f`, `noon_temp_f`, `evening_temp_f`, `night_temp_f`

**`weather_actuals`** — stores the real temperatures recorded throughout the day

- `date` (unique), `real_morning_temp_f`, `morning_timestamp`, `real_noon_temp_f`, `noon_timestamp`, `real_evening_temp_f`, `evening_timestamp`, `real_night_temp_f`, `night_timestamp`

**`predictions_errors`** — stores the calculated error between predictions and actuals

- `date` (unique), `morning_error`, `noon_error`, `evening_error`, `night_error`, `daily_error`

---

## ⚙️ How It Works

The script runs on a cron schedule and behaves differently depending on the time of day:

| Time    | Action                                                                       |
| ------- | ---------------------------------------------------------------------------- |
| `00:00` | Fetches daily forecast, creates DB tables if needed, inserts prediction rows |
| `06:00` | Records actual morning temperature                                           |
| `12:00` | Records actual noon temperature                                              |
| `18:00` | Records actual evening temperature                                           |
| `21:00` | Records actual night temperature + calculates and loads prediction errors    |

---

## 🔁 Error Handling & Retries

Each API request is wrapped in a retry loop with up to 3 attempts and a 5-second wait between each. Every step of the pipeline is logged to a `logs.csv` file with a timestamp, including warnings on failed attempts, success confirmations, and a final failure log with `exit 1` if all retries are exhausted.

---

## 📋 How to Use

1. Clone the repository
2. Navigate to the project folder:
   cd 03bash_project_weather_info_etl
3. Make the script executable:
   chmod +x etl.sh
4. In your crontab, use the full absolute path to wherever you cloned it:
   ```
   0 0 * * * /your/path/to/03bash_project_weather_info_etl/etl.sh
   0 6 * * * /your/path/to/03bash_project_weather_info_etl/etl.sh
   0 12 * * * /your/path/to/03bash_project_weather_info_etl/etl.sh
   0 18 * * * /your/path/to/03bash_project_weather_info_etl/etl.sh
   0 21 * * * /your/path/to/03bash_project_weather_info_etl/etl.sh
   ```
5. The SQLite database and logs file will be created automatically in the project directory on first run

---

## ⚠️ Known Limitations

- **Requires the computer to be on** — cron jobs do not run if the machine is off or asleep. Any missed scheduled execution is lost with no catchup. A cloud VM would be needed for a reliable production setup.
- **Single city** — the pipeline is currently scoped to New York City only.
- **Time-sensitive design** — the pipeline depends on being triggered at exact hours. If a cron job runs late or is skipped, that data window will be missing.
- **No data validation on API response** — if the API returns malformed or unexpected JSON, `jq` will silently write null values into the database.
- **Local storage only** — data lives in a local SQLite file with no backups or replication.

---

## 🤝 Development Notes

This project was written independently as a hands-on exercise to practice Bash scripting in a real-world data engineering context. Throughout development, I consulted Claude (Anthropic) to clarify specific doubts around Bash syntax, SQLite behavior, and scripting conventions — approximately 90% of the code was written by me. The pipeline design, logic, and architecture decisions were my own.

---

## 👩‍💻 Author

Laura Jimenez
