DROP TABLE IF EXISTS countries;
DROP TABLE IF EXISTS WHR_2019;


CREATE TABLE WHR_2019 (
	Country VARCHAR(50) PRIMARY KEY UNIQUE,
	HappinessRank SMALLINT,
	HappinessScore DECIMAL(5,3),
	GDP DECIMAL(6,5),
	Family DECIMAL(6,5),
	LifeExpectancy DECIMAL(6,5),
	Freedom DECIMAL(6,5),
	Generosity DECIMAL(6,5),
	Trust DECIMAL(6,5)
	);

CREATE TABLE countries (
	country_code CHAR(2) PRIMARY KEY UNIQUE,
	lat Decimal(8,6),
	lng Decimal(9,6),
	country VARCHAR(50) UNIQUE
);
	
	
SELECT DISTINCT C.country,W.country FROM countries AS C
FULL OUTER JOIN whr_2019 AS W on C.country = W.country
WHERE C.country is null

-- Match country names

DELETE FROM whr_2019
where country = 'South Sudan'

DELETE FROM whr_2019
where country = 'Northern Cyprus';

UPDATE whr_2019
SET country = (SELECT country FROM countries
			  WHERE country_code = 'CG')
WHERE country = 'Congo (Brazzaville)';

UPDATE whr_2019
SET country = (SELECT country FROM countries
			  WHERE country_code = 'CD')
WHERE country = 'Congo (Kinshasa)';

UPDATE whr_2019
SET country = (SELECT country FROM countries
			  WHERE country_code = 'CI')
WHERE country = 'Ivory Coast';

UPDATE whr_2019
SET country = (SELECT country FROM countries
			  WHERE country_code = 'MM')
WHERE country = 'Myanmar';

UPDATE whr_2019
SET country = (SELECT country FROM countries
			  WHERE country_code = 'MK')
WHERE country = 'North Macedonia';

UPDATE whr_2019
SET country = (SELECT country FROM countries
			  WHERE country_code = 'TT')
WHERE country = 'Trinidad & Tobago';

-- Query History 

ALTER TABLE whr_2019
ADD COLUMN lat Decimal(8,6);

ALTER TABLE whr_2019
ADD COLUMN lng Decimal(9,6);

UPDATE whr_2019 AS whr
SET lat =  (SELECT lat FROM countries AS wc
		   WHERE wc.country = whr.country)
		  
		   
UPDATE whr_2019 AS whr
SET lng =  (SELECT lng FROM countries AS wc
		   WHERE wc.country = whr.country);

 
-- create alcohol_cons Table and clean it

CREATE TABLE alcohol_cons
(
    country varchar(50),
    alcohol_per_year numeric(3,1)
)

SELECT DISTINCT C.country,ac.country FROM countries AS C
FULL OUTER JOIN alcohol_cons AS ac on C.country = ac.country
WHERE C.country is null;

-- Match country names

DELETE FROM alcohol_cons
where country = 'Northern Cyprus';

UPDATE alcohol_cons
SET country = (SELECT country FROM countries
			  WHERE country_code = 'CG')
WHERE country = 'Republic of the Congo';

UPDATE alcohol_cons
SET country = (SELECT country FROM countries
			  WHERE country_code = 'CD')
WHERE country = 'DR Congo';

UPDATE alcohol_cons
SET country = (SELECT country FROM countries
			  WHERE country_code = 'CI')
WHERE country = 'Ivory Coast';

UPDATE alcohol_cons
SET country = (SELECT country FROM countries
			  WHERE country_code = 'MM')
WHERE country = 'Myanmar';

UPDATE alcohol_cons
SET country = (SELECT country FROM countries
			  WHERE country_code = 'SZ')
WHERE country = 'Eswatini';

UPDATE alcohol_cons
SET country = (SELECT country FROM countries
			  WHERE country_code = 'ST')
WHERE country = 'Sao Tome and Principe';

SELECT DISTINCT C.country,ac.country FROM countries AS C
FULL OUTER JOIN alcohol_cons AS ac on C.country = ac.country
WHERE C.country is null;


-- Adding alcohol_LiPerYear column and populating it
ALTER TABLE whr_2019
ADD COLUMN alcohol_LiPerYear numeric(3,1);

UPDATE whr_2019 AS whr
SET alcohol_LiPerYear =  (SELECT alcohol_per_year FROM alcohol_cons AS wc
		   WHERE wc.country = whr.country);

-- Check for null values
SELECT * FROM whr_2019
WHERE alcohol_LiPerYear is null or country is null

-- Clean Clusters table

ALTER TABLE three_clusters
	ADD country_code CHAR(3);

UPDATE three_clusters as tc
SET country_code = (SELECT country_code FROM countries as c
					  WHERE tc.country = c.country)

SELECT * FROM three_clusters

	--Droping columns
	ALTER TABLE three_clusters 
	DROP COLUMN gdp,
	DROP COLUMN family,
	DROP COLUMN lifeexpectancy,
	DROP COLUMN country,
	DROP COLUMN lat,
	DROP COLUMN lng
	

CREATE view Clusters as 
SELECT c.country,tc.class, hr.happinessscore 
FROM three_clusters as tc
JOIN countries as c on tc.country_code = c.country_code
JOIN happines_rank as hr on hr.country_code = c.country_code

SELECT * FROM Clusters

--Create Coordinates Table

CREATE TABLE Coordinates (
	index int GENERATED BY DEFAULT AS IDENTITY,
	country_code CHAR(3),
	lat numeric(8,6),
	lng numeric(9,6),
	primary key(index),
	CONSTRAINT fk_CC
		FOREIGN KEY(country_code)
			REFERENCES countries(country_code)
	
)

INSERT INTO Coordinates (country_code,lat,lng)
SELECT C.country_code,whr.lat,whr.lng
FROM countries as C
JOIN whr_2019 as whr on whr.country = C.country

SELECT * FROM Coordinates

--Creating Trust Table

CREATE TABLE trust (
	index int GENERATED BY DEFAULT AS IDENTITY,
	country_code CHAR(3),
	trust numeric(6,5),
	primary key(index),
	CONSTRAINT fk_CC
		FOREIGN KEY(country_code)
			REFERENCES countries(country_code)
	
);

INSERT INTO trust (country_code,trust)
SELECT C.country_code,whr.trust
FROM countries as C
JOIN whr_2019 as whr on whr.country = C.country;

SELECT * FROM trust


--Creating whr_2019 as a view





CREATE view whr_2019 as 
SELECT c.country,hr.happinessrank,hr.happinessscore,gdp.gdp,f.family,le.lifeexpectancy,fr.freedom,
g.generosity, tr.trust,Co.lat,Co.lng,al.alcohol_liperyear
FROM countries AS c
JOIN happines_rank as hr on hr.country_code = c.country_code
JOIN family as f on f.country_code = c.country_code
JOIN generosity as g on g.country_code = c.country_code
JOIN alcohol as al on al.country_code = c.country_code
JOIN gdp on gdp.country_code = c.country_code
JOIN life_expectancy as le on le.country_code = c.country_code
JOIN freedom as fr on fr.country_code = c.country_code
JOIN trust as tr on tr.country_code = c.country_code
JOIN Coordinates as Co on Co.country_code = c.country_code






SELECT count(*) FROM whr_2019

CREATE view whr_2019 as 
SELECT * FROM stage_whr_2019

--Create Predicted Values
CREATE VIEW Predicted_values AS
(
    pred_happinessscore numeric(20,14),
    happinesscore smallint,
    gdp numeric(5,3),
    family numeric(6,5),
    lifeexpectancy numeric(6,5),
    freedom numeric(6,5),
    generosity numeric(6,5),
    trust numeric(6,5),
    lat numeric(8,6),
    lng numeric(9,6),
    alcohol_liperyear numeric(3,1),
    CONSTRAINT whr_2019_pkey PRIMARY KEY (country)
)

SELECT * FROM three_clusters

-- Creating Constraints 

ALTER TABLE alcohol
ADD PRIMARY KEY (index),
ADD CONSTRAINT FK_alcohol_liperyear
FOREIGN KEY (country_code) REFERENCES countries(country_code)

ALTER TABLE family
ADD PRIMARY KEY (index),
ADD CONSTRAINT FK_family
FOREIGN KEY (country_code) REFERENCES countries(country_code)

ALTER TABLE freedom
ADD PRIMARY KEY (index),
ADD CONSTRAINT FK_freedom
FOREIGN KEY (country_code) REFERENCES countries(country_code)

ALTER TABLE gdp
ADD PRIMARY KEY (index),
ADD CONSTRAINT FK_gdp
FOREIGN KEY (country_code) REFERENCES countries(country_code)

ALTER TABLE generosity
ADD PRIMARY KEY (index),
ADD CONSTRAINT FK_generosity
FOREIGN KEY (country_code) REFERENCES countries(country_code)

ALTER TABLE happines_rank
ADD PRIMARY KEY (index),
ADD CONSTRAINT FK_happines_rank
FOREIGN KEY (country_code) REFERENCES countries(country_code)

ALTER TABLE life_expectancy
ADD PRIMARY KEY (index),
ADD CONSTRAINT FK_LE
FOREIGN KEY (country_code) REFERENCES countries(country_code)

ALTER TABLE three_clusters
ADD PRIMARY KEY (index),
ADD CONSTRAINT FK_TC
FOREIGN KEY (country_code) REFERENCES countries(country_code)



