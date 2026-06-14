# Chicago City Data Analysis Project

## 🎯 Objective

Analyze Chicago census, school report card, and crime datasets using SQL, Python, and data visualization techniques. The goal of this project was to strengthen SQL skills learned during my Data Engineering studies while conducting a real-world investigation into the relationships between crime, education, and socioeconomic conditions across Chicago community areas.

---

## 📊 Dataset

This project uses three public Chicago datasets provided during the IBM SQL coursework:

- **CENSUS_DATA** – Community demographics and hardship indexes.
- **SCHOOLS_DATA** – School report cards, safety scores, attendance, and enrollment metrics.
- **CRIME_DATA** – Historical crime incidents, crime types, arrests, and locations.

### Data Preparation Challenges

- Crime dataset exceeded API row limits and required pagination, filtering unnecessary columns, and loading data in chunks.
- School report card data was only available for 2011–2012, requiring date alignment across datasets.
- Large numbers of unused columns were removed to improve loading performance.
- Data quality investigation revealed:
  - 223 records with NULL community areas in the CRIME_DATA table.
  - 6 records assigned to community area `0` with no matching record for a community area name across datasets.
  - ~99.97% of crime records could be successfully mapped to valid Chicago community areas.

---

## 🛠️ Tools Used

- SQL (SQLite)
- Python
- Pandas
- Matplotlib
- Seaborn
- Jupyter Notebooks

Project Structure:

```text
04sql-chicago-city-analysis-project/
│
├── Notebooks/
│   ├── 01_setup.ipynb
│   ├── 02_sql_analysis.ipynb
│   └── 03_visualizations.ipynb
│
└── README.md
```

---

## 🔍 Key Findings

### Crime Analysis

- **Austin** recorded the highest number of crimes with **44,123 incidents**.
- The most common crime types were:
  1. Theft
  2. Battery
  3. Narcotics
  4. Criminal Damage
  5. Burglary

- Approximately **27.16%** of crimes resulted in an arrest.
- Streets, sidewalks, residences, and apartments accounted for the largest concentration of crimes.

### School Analysis

- Average school safety score: **49.5**
- High Schools achieved the strongest average academic performance based on ISAT scores.
- Attendance rates remained relatively high regardless of school safety scores, showing little direct relationship.

### Cross-Dataset Analysis

- High hardship areas generally showed **lower school safety scores**.
- The relationship between hardship and crime was less clear when using raw crime counts; population size appears to be an important factor.
- Communities appearing in both the **Top 10 Crime Areas** and **Bottom 10 School Safety Areas**:
  - West Englewood
  - Auburn Gresham
  - Roseland

- A general negative relationship was observed between hardship index and college enrollment.
- Based on crime volume, hardship index, and school safety metrics, **Austin** emerged as the most at-risk community area.

---

## 📈 Visualizations

The project includes visualizations exploring:

- Top 10 community areas by crime count.
- Hardship index vs Crime count.
- Hardship index vs Avg school safety score.
- Top 10 Crime types distribution.
- Top 10 Community areas by all 3 risk metrics.
- School attendance vs safety score.

---

## 🚀 How to Run

1. Clone the repository.

```bash
git clone <repository-url>
```

2. Install dependencies.

```bash
pip install pandas matplotlib seaborn jupyter
```

3. Launch Jupyter Notebook.

```bash
jupyter notebook
```

4. Run notebooks in order:

```text
01_setup.ipynb
02_sql_analysis.ipynb
03_visualizations.ipynb
```

---

## 📚 What I Learned

- Writing complex SQL queries using CTEs, subqueries, joins, aggregations, and window functions.
- Investigating and validating data quality issues before analysis.
- Using `NULLIF()` and data type conversions to handle inconsistent data.
- Applying aggregate window functions to compare records against dataset-wide metrics.
- Building data visualizations with Matplotlib and Seaborn.
- Combining multiple datasets to generate insights that cannot be observed from a single source alone.
- Understanding the importance of defining proper metrics (e.g., crime rates per capita instead of raw counts) before drawing conclusions.
