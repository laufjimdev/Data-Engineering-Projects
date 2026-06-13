This is a SQL + Python + Jupyter Notebooks Project that will help me solidify the skills I've been learning throught my Data Engineering studying path.

This project is born as the continuation of my IBM SQL BASICS course, were they provided 3 data sets from Chicago state, census, schools scorecards and crimes data. With this project I intend to show my Python, SQL and visualization skills along with a data analysis of the data to answer curious questions.
I will be documenting the challenges encountered during this journey and how I overcame them.

Challenges:

-Crimes dataset was very large, the API had a 1,000 rows limit, had to find a way around it, so added a Limit clause to fetch all the data needed, also deleted from the dataset source columns that were irrelevant before loading, and added the chunk option to read_csv method to break it into smaller batches.
-Datasets for report cards only include years 2011 and 2012, had to filter data from other 2 tables to match the dates.
-Report card data had a lot of columns info that will not be needed for this project, so I excluded them from the data to be imported, reducing loading time.
-I ran into data quality issues during aggregation by community area, the grouped totals initially appeared inconsistent with the raw dataset. Further investigation identified the exact causes of the discrepancy. The CRIME_DATA table had 223 null values in the community_area column, it also had 6 records under community_area 0 which doesnt have any record in the SCHOOLS_DATA table. This means: 688,212 records could be successfully mapped to valid Chicago community areas, Approximately 99.97% of the dataset was geographically assignable.
-Learned about NULLIF fuction due to the need of filtering and casting the SCHOOLS_DATA.college_enrollment_rate column, certain schools had a NDA values.
-Learned about aggregate window functions due to the need of using an AVG value to qualify a result set without collapsing it.
-Learned about Matplotlib and Seaborn as part of the visualizations section of this project.
