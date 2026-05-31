# Data Engineering Projects

## Overview

This repository is a collection of data engineering projects I have built while transitioning from Industrial Engineering into Data Engineering.

It serves as a hands-on learning environment where I apply concepts from coursework, self-study, and independent experimentation. Each project is contained in its own directory and focuses on a specific data engineering problem, workflow, or system design pattern.

The goal of this repository is to demonstrate practical understanding of data pipelines, data modeling, ETL processes, database design, and automation through real implementations rather than isolated exercises.

---

## Repository Structure

Each project is organized in its own folder:

```
/Data-Engineering-Projects
│
├── 01python_etl_gas_prices/
├── 02bash_project/
├── 03bash_project_weather_info_etl/
├── ...
```

Each directory typically includes:

* Source code
* Data extraction / transformation logic
* Database schema or storage logic
* Project-specific documentation (README)
* Notes on design decisions and improvements

---

## Project Focus Areas

Across this repository, I explore topics such as:

* ETL / ELT pipeline design
* API data extraction and ingestion
* Data cleaning and transformation workflows
* SQL-based data modeling
* Error handling and data validation strategies
* Logging and observability in data pipelines
* Incremental data loading and deduplication strategies
* Automation of scheduled data processes

---

## Example Project: Weather ETL System

One of the main projects in this repository is a weather data pipeline that:

* Extracts weather forecast and observation data from an external API
* Stores structured data in a relational database
* Implements data validation and deduplication logic
* Maintains historical records of measurements over time
* Computes and compares forecasted vs actual values

This project evolved iteratively, with improvements including:

* Retry and error handling mechanisms
* Logging system implementation
* Data consistency and schema corrections
* Transition to portable database paths
* Enforcement of uniqueness constraints to avoid duplicate entries
* Refactoring for maintainability and clarity

---

## Commit Strategy

This repository uses a structured commit tagging convention to maintain clarity across multiple projects within a single codebase.

Each commit is prefixed with the project identifier it belongs to (e.g. `03weather - ...`).

This approach helps:

* Track changes per project over time
* Preserve context in a multi-project repository
* Support iterative development and experimentation

Example:

```
03weather - added retry logic for API failures
03weather - improved logging and error handling
```

---

## Goals of This Repository

* Build a strong foundation in data engineering fundamentals
* Develop production-style thinking (logging, reliability, structure)
* Gain experience with real data pipelines and system design
* Document learning progression over time
* Build a portfolio of applied, technical work

---

## Notes

This repository is actively evolving. Projects may be refactored, reorganized, or expanded as new concepts are learned and applied.

The structure reflects a learning process rather than a final production system.

---

## Author

Laura Jimenez
Industrial Engineer transitioning into Data Engineering with a focus on data systems, automation, and scalable workflows.
