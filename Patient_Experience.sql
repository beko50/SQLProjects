CREATE TABLE healthcare_year1(
ID SERIAL PRIMARY KEY,
Facility_ID VARCHAR NOT NULL,
Facility_Name VARCHAR NOT NULL,
City VARCHAR NOT NULL,
State VARCHAR NOT NULL,
Hospital_Type VARCHAR NOT NULL,
Hospital_Ownership	VARCHAR NOT NULL,
Emergency_Services	VARCHAR,
Hospital_overallrating	INTEGER,
Hospital_overallrating_footnote	VARCHAR,
Mortality_national_comparison VARCHAR,
px_national_comparison	VARCHAR,
Timelinesscare_national_comparison VARCHAR
)

CREATE TYPE emergency as enum      -- Data Validation for Emergency Services. Only accepts [YES or NO] data
('Yes','No')

SELECT * FROM healthcare_year1

ALTER TABLE healthcare_year1         -- Changing data type from Integer to Varchar
ALTER COLUMN Hospital_overallrating TYPE VARCHAR;

copy healthcare_year1 FROM 'C:\Users\BEKO\Desktop\Data Projects\Patient Satisfaction\hospital_PS_2020.csv' DELIMITER ',' CSV HEADER;


-- Create SURVEYS Tables (2020-2023)
CREATE TABLE survey1(
id SERIAL,
Facility_ID VARCHAR NOT NULL,
HCAHPS_Measure_ID VARCHAR NOT NULL,
HCAHPS_Question	VARCHAR NOT NULL,
HCAHPS_Answer_Description VARCHAR NOT NULL,
HCAHPS_Answer_Percent VARCHAR NOT NULL,
HCAHPS_Linear_MeanValue	VARCHAR NOT NULL,
Year INTEGER,
Completed_Surveys VARCHAR,
Survey_ResponseRate_Percent VARCHAR,
PRIMARY KEY (ID, HCAHPS_Measure_ID),     -- Composite Primary Keys
FOREIGN KEY (ID) REFERENCES healthcare_year1(ID)    -- FOREIGN KEY referencing hospital_year table
)

SELECT * FROM survey1;


-- Create FOOTNOTE DICTIONARY Table
CREATE TABLE footnote_dictionary(
Footnote VARCHAR,
Footnote_Text VARCHAR
)
SELECT * FROM footnote_dictionary



                               --DATA EXPLORATION AND DATA CLEANING WITH SQL
-- The number of healthcare facilities
SELECT COUNT(DISTINCT facility_id) AS Number_Of_Facilities
FROM healthcare_year1;

-- List of the facilities
SELECT DISTINCT facility_id,facility_name AS Facilities
FROM healthcare_year1
ORDER BY facility_name ASC

-- Number of facilities by type
SELECT hospital_type, COUNT(DISTINCT facility_id) AS Counting_Hospitals
FROM healthcare_year1
GROUP BY hospital_type

-- Highest rated "COMMUNITY" hospitals 
SELECT DISTINCT facility_name, CAST(hospital_overallrating AS INT) 
FROM healthcare_year1
WHERE hospital_overallrating IN ('4','5') AND facility_name ILIKE '%comm%'         -- ILIKE is a Postgres Wildcard for case-insensitive matching
ORDER BY hospital_overallrating DESC
LIMIT 50

-- Number of hospitals within the all the states of USA 
SELECT state, COUNT(DISTINCT facility_id) AS Hospitals_in_state
FROM healthcare_year1
GROUP BY state


-- Deleting the territories labelled as states from ALL tables (5 U.S territories excluding DC)
ALTER TABLE survey1           -- Since all healthcareYears tables are referenced in Survey tables, I drop the foreign keys temporarily before beginning TRANSACTIONS
DROP CONSTRAINT survey1_id_fkey;

-- Initiating Transaction for deletion process in all HEALTHCARE tables
BEGIN TRANSACTION;

DELETE FROM healthcare_year1
WHERE state IN ('AS','GU','MP','PR','VI');

DELETE FROM healthcare_year2
WHERE state IN ('AS','GU','MP','PR','VI');

DELETE FROM healthcare_year3
WHERE state IN ('AS','GU','MP','PR','VI');

DELETE FROM healthcare_year4
WHERE state IN ('AS','GU','MP','PR','VI');

COMMIT;
-- Deleting corresponding IDs in HealthCare and Survey Tables which violate FK constraint rule
DELETE FROM survey4
WHERE id IN(
	SELECT s4.id
	FROM survey4 s4
	WHERE NOT EXISTS (
		SELECT 1
		FROM healthcare_year4 h4
		WHERE h4.id = s4.id
	)
);
-- Adding back FK constraints in SURVEY TABLES after dropping them for initial deletion process. 
ALTER TABLE survey4
ADD CONSTRAINT survey4_id_fkey
FOREIGN KEY(id)
REFERENCES healthcare_year4(ID);


-- Number of states after deleting all redundant territories
SELECT COUNT(DISTINCT state) AS US_states
FROM healthcare_year1

-- Facilities in all states
SELECT state, COUNT(DISTINCT facility_id) As State_facilities
FROM healthcare_year1
GROUP BY state
ORDER BY State_facilities DESC

-- MAPPING abbreviation of states to their fullnames (USING INNER JOIN)
CREATE TABLE state_mapping(
	Abbreviation VARCHAR(2) PRIMARY KEY,
	state_name VARCHAR(50) NOT NULL
)
INSERT INTO state_mapping (Abbreviation, state_name) VALUES
('AL', 'Alabama'),('AK', 'Alaska'),('AZ', 'Arizona'),('AR', 'Arkansas'),('CA', 'California'),('CO', 'Colorado'),('CT', 'Connecticut'),('DE', 'Delaware'),
('DC', 'District of Columbia'),('FL', 'Florida'),('GA', 'Georgia'),('HI', 'Hawaii'),('ID', 'Idaho'),('IL', 'Illinois'),('IN', 'Indiana'),('IA', 'Iowa'),('KS', 'Kansas'),
('KY', 'Kentucky'),('LA', 'Louisiana'),('ME', 'Maine'),('MD', 'Maryland'),('MA', 'Massachusetts'),('MI', 'Michigan'),('MN', 'Minnesota'),('MS', 'Mississippi'),('MO', 'Missouri'),
('MT', 'Montana'),('NE', 'Nebraska'),('NV', 'Nevada'),('NH', 'New Hampshire'),('NJ', 'New Jersey'),('NM', 'New Mexico'),('NY', 'New York'),('NC', 'North Carolina'),
('ND', 'North Dakota'),('OH', 'Ohio'),('OK', 'Oklahoma'),('OR', 'Oregon'),('PA', 'Pennsylvania'),('RI', 'Rhode Island'),('SC', 'South Carolina'),('SD', 'South Dakota'),
('TN', 'Tennessee'),('TX', 'Texas'),('UT', 'Utah'),('VT', 'Vermont'),('VA', 'Virginia'),('WA', 'Washington'),('WV', 'West Virginia'),('WI', 'Wisconsin'),('WY', 'Wyoming');

-- JOINING TABLES; state_mapping and healthcare_year1
SELECT h.*, m.state_name
FROM healthcare_year1 h
JOIN state_mapping m 
ON h.state = m.abbreviation

-- Average hcahps answer % across all facilities
SELECT DISTINCT hcahps_answer_description,
	   ROUND(AVG(CAST(hcahps_answer_percent AS INT)),2) AS Average_Answer_Percentage
FROM survey1
GROUP BY hcahps_answer_description
ORDER BY average_answer_percentage DESC

--Surveys completed uniquely by each facility
SELECT DISTINCT h.facility_id, h.facility_name,h.state, CAST(s.completed_surveys AS INT)
FROM healthcare_year1 h
JOIN survey1 s ON h.facility_id = s.facility_id
ORDER BY completed_surveys DESC

-- JOINING 3 tables (HEALTHCARE, SURVEY and STATE_MAPPING)to find the hospitals AND their locations with higher survey response rate
SELECT DISTINCT h.facility_id,h.facility_name, m.state_name, CAST(s.survey_responserate_percent AS INT)
FROM healthcare_year1 h
JOIN survey1 s ON h.facility_id = s.facility_id
JOIN state_mapping m ON h.state = m.abbreviation
-- WHERE facility_name LIKE '%GUNDER%'      -- LIKE since %Gunder% is case-sensitive here
ORDER BY survey_responserate_percent DESC
LIMIT 10


-- JOINING ALL HEALTHCARE tables to SURVEY tables
SELECT h.*,s.*
FROM healthcare_year1 h
JOIN survey1 s ON h.facility_id = s.facility_id
ORDER BY h.facility_id ASC
LIMIT 10000







