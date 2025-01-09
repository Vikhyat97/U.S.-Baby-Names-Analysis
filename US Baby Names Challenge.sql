use baby_names_db;

-- Task 1: Find the most popular girl and boy name and check their year wise performance

-- Male Calculation:

SELECT
Year,
Name,
SUM(Births) AS total_males
FROM Names
WHERE Gender = 'M'
GROUP BY 2,1
ORDER BY 3 DESC
LIMIT 1;

SELECT
Year,
Name,
SUM(Births) AS total_males
FROM Names
WHERE Name = 'Michael'
GROUP BY 2,1;

-- Female Calculation:

SELECT
Year,
Name,
SUM(Births) AS total_females
FROM Names
WHERE Gender = 'F'
GROUP BY 2,1
ORDER BY 3 DESC
LIMIT 1;

SELECT
Year,
Name,
SUM(Births) AS total_females
FROM Names
WHERE Name = 'Jennifer'
GROUP BY 2,1;

-- Task 2: Find the names with the biggest jumps and drops in popularity from the first year of the data set to the last year

-- CALCULATION OF BIGGEST JUMPS FROM 1980-1999

WITH cte_1980 AS
(SELECT
Year,
Name,
SUM(Births) AS total_count
FROM Names
WHERE Year = 1980
GROUP BY 1,2
ORDER BY 3 DESC),

cte_1999 AS
(SELECT
Year,
Name,
SUM(Births) AS total_count
FROM Names
WHERE Year = 1999
GROUP BY 1,2
ORDER BY 3 DESC)

SELECT 
*,
t2.total_count - t1.total_count as jump_value
FROM cte_1980 t1
INNER JOIN cte_1999 t2
ON t1.Name = t2.Name
ORDER BY 7 DESC
LIMIT 10;

-- CALCULATION OF BIGGEST DROPS FROM 1980-1999

WITH cte_1980 AS
(SELECT
Year,
Name,
SUM(Births) AS total_count
FROM Names
WHERE Year = 1980
GROUP BY 1,2
ORDER BY 3 DESC),

cte_1999 AS
(SELECT
Year,
Name,
SUM(Births) AS total_count
FROM Names
WHERE Year = 1999
GROUP BY 1,2
ORDER BY 3 DESC)

SELECT 
*,
t1.total_count - t2.total_count as jump_value
FROM cte_1980 t1
INNER JOIN cte_1999 t2
ON t1.Name = t2.Name
ORDER BY 7 DESC
LIMIT 10;

-- Task 3: Find the top 3 girl names and top 3 boy names for each year.

-- Top 3 girl names for each year

SELECT
*
FROM
(
	SELECT
	Year,
	Name,
	SUM(Births) AS total_females,
	ROW_NUMBER() OVER(PARTITION BY Year ORDER BY SUM(Births) DESC) AS row_num
	FROM Names
	WHERE Gender = 'F'
	GROUP BY 1,2) AS ranked_females
    WHERE row_num <=3;

-- Top 3 boy names for each year

SELECT
*
FROM
(
	SELECT
	Year,
	Name,
	SUM(Births) AS total_males,
	ROW_NUMBER() OVER(PARTITION BY Year ORDER BY SUM(Births) DESC) AS row_num
	FROM Names
	WHERE Gender = 'M'
	GROUP BY 1,2) AS ranked_males
    WHERE row_num <=3;

-- Task 4: Return the number of babies born in each of the six regions.

SELECT
t2.region,
SUM(t1.Births) AS total_babies
FROM Names t1
LEFT JOIN regions t2
ON t1.State = t2.State
GROUP BY 1;

-- Task 5: Return the 3 most popular girl names and 3 most popular boy names within each region.

-- CALCULATION FOR MALES

SELECT
*
FROM
(
	SELECT
	t1.Name,
	t2.region,
	SUM(t1.Births) AS male_babies,
	ROW_NUMBER() OVER(PARTITION BY region ORDER BY SUM(Births) DESC) AS row_num
	FROM Names t1
	LEFT JOIN regions t2
	ON t1.State = t2.State
	WHERE t1.Gender = 'M'
	GROUP BY 1,2) AS ranked_males_regions
WHERE row_num <= 3;

-- CALCULATION FOR FEMALES

SELECT
*
FROM
(
	SELECT
	t1.Name,
	t2.region,
	SUM(t1.Births) AS female_babies,
	ROW_NUMBER() OVER(PARTITION BY region ORDER BY SUM(Births) DESC) AS row_num
	FROM Names t1
	LEFT JOIN regions t2
	ON t1.State = t2.State
	WHERE t1.Gender = 'F'
	GROUP BY 1,2) AS ranked_females_regions
WHERE row_num <= 3;

-- Task 6: Top 10 Androgynous names.

SELECT
COUNT(DISTINCT Gender) AS num_genders,
SUM(num_babies),
Name
FROM
(
    SELECT
	Gender,
	Name,
    SUM(Births) AS num_babies
	FROM Names
	GROUP BY 1,2
    ORDER BY 3 DESC) AS abc
GROUP BY 3
HAVING COUNT(DISTINCT Gender) = 2
ORDER BY 2 DESC
LIMIT 10;

-- Task 7: States with the Highest % of people called 'Chris'

-- OPTION 1

with cte as 
(select 
state,
sum(births) as total_chris_births
from names
where name = 'Chris'
group by 1),

cte_1 as
(select
*, (select
sum(births) as total_chris_births
from names
where name = 'Chris') as chris_across_states
from cte)

select
*,
total_chris_births/chris_across_states *100 as pct_of_chris
from cte_1
order by 4 desc;

-- OPTION 2

with chris_name as
(select 
state,
sum(births) as total_chris_births
from names
where name = 'Chris'
group by 1),

total_babies as
(select
state,
sum(births) as total_babies_count
from names
group by 1),

chris_with_total_babies as
(select 
t1.state,
t1.total_chris_births,
t2.total_babies_count
from chris_name t1
inner join total_babies t2
on t1.state = t2.state)

select 
state,
total_chris_births/total_babies_count * 100 as pct_with_chris
from chris_with_total_babies
order by 2 desc;

