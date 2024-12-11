### Cohort Analysis for Customer Lifetime Value (CLV) Estimation
Googleheet link : https://docs.google.com/spreadsheets/d/1M1UVaigvNnHa5xlzLwQVVg2kQ1SKNlM2OGe8RyibvZ0/edit?usp=sharing

### Project Summary: 
- In this project, I performed a detailed cohort analysis to estimate Customer Lifetime Value (CLV) by analyzing weekly revenue and registration cohorts, as per the instructions. The goal was to address the limitations of Shopify’s simplistic CLV formula by considering all user registrations (not just purchasers) and analyzing customer retention over a 12-week period.

#### Steps Taken:
Data Extraction and Preparation:

- I queried the turing_data_analytics.raw_events table to extract the necessary data for calculating weekly revenue and registrations.
The registration cohort was determined by the user's first visit to the site, tracked using user_pseudo_id.
Weekly Revenue by Cohorts:

For each weekly cohort, I calculated the weekly revenue per registration (i.e., dividing total revenue by the number of users who visited during a particular week).
- I adjusted the dataset to include all users, not just those who made a purchase, ensuring that the full scope of user activity was considered.
Cumulative Revenue Calculation:

- Using the weekly average revenue per cohort, I calculated cumulative revenue over time (up to week 12) to understand the revenue growth by cohort.
I calculated averages for each week since registration and derived percentage growth based on those averages.
#### Predictive Analysis:

- To estimate future revenue, I applied the cumulative growth percentages to predict the expected revenue for cohorts acquired after the final available week (2021-01-24).
- This allowed me to forecast revenue for up to 12 weeks for newly acquired cohorts, providing an actionable view of CLV growth.
Visualization:

#### The results were visualized in three charts:
Weekly Average Revenue by Cohorts (USD)
Cumulative Revenue by Cohorts (USD)
Revenue Prediction by Cohorts (USD)
Conditional formatting was applied to highlight trends and make the data easier to interpret.


