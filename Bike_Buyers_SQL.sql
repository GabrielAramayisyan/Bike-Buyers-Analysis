-- THE CSV FILE IS IMPORTED WITH GUI TOOL OF pgAdmin4

CREATE TABLE bike_buyers (
	"ID" INT PRIMARY KEY,
	"Martiel Status" VARCHAR(255),
	"Gender" VARCHAR(255),
	"Income" NUMERIC,
	"Children" INT,
	"Education" VARCHAR(255),
	"Occupation" VARCHAR(255),
	"Home Owner" VARCHAR(255),
	"Cars" INT,
	"Commute Distance" VARCHAR(255),
	"Region" VARCHAR(255),
	"Age" INT,
	"Purchased Bike" VARCHAR(255)
);



-- FIXING A TYPO IN A COLUMN NAME

ALTER TABLE bike_buyers
RENAME "Martiel Status" TO "Marital Status"



-- SPOTTING AND DELETING DUBLICATE VALUES

BEGIN;
DELETE FROM bike_buyers
WHERE "ID" IN (
	SELECT "ID" FROM (
		SELECT
			*,
			ROW_NUMBER() OVER(
				PARTITION BY
					"Marital Status",
					"Gender",
					"Income",
					"Children",
					"Education",
					"Occupation",
					"Home Owner",
					"Cars",
					"Commute Distance",
					"Region",
					"Age",
					"Purchased Bike",
					"Age Brackets"
				ORDER BY "ID"
			) AS "Row Number" 
		FROM bike_buyers
	)
	WHERE "Row Number"  > 1
)
COMMIT;



-- CREATING AGE BRACKETS FOR EASIER ANALYZE

ALTER TABLE bike_buyers
ADD COLUMN "Age Brackets" VARCHAR(255);


BEGIN;
UPDATE bike_buyers
SET "Age Brackets" = (
	SELECT
		CASE
			WHEN "Age" < 31 THEN 'Adolescent (25-31)'
			WHEN "Age" BETWEEN 31 AND 54 THEN 'Middle Age (31-54)'
			WHEN "Age" > 54 THEN 'Old (55+)'
			ELSE 'Invalid'
		END AS Age_Groups
)
ROLLBACK;
COMMIT;



-- CLIENT COUNT BY GENDER AND PURCHASE STATUS

SELECT
	"Gender",
	"Purchased Bike",
	COUNT("ID") AS "Customer Count"
FROM bike_buyers
GROUP BY "Gender", "Purchased Bike"
ORDER BY "Gender" DESC, "Customer Count"



-- AVERAGE INCOME BY GENDER AND BIKE PURCHASE STATUS
-- FINDINGS - CUSTOMER MENTALITY:
-- MALES THAT HAVE PURCHASED BIKES EARN ~ 6.97% MORE IN AVERAGE THAN MALES THAT HAVEN'T PURCHASED BIKES
-- FEMALES THAT HAVE PURCHASED BIKES EARN ~ 4.26% MORE IN AVERAGE THAN FEMALES THAT HAVEN'T PURCHASED BIKES

SELECT
	"Gender",
	"Purchased Bike",
	COUNT("ID") AS "Customer Count",
	ROUND(AVG("Income"), 2) AS "Average Income"
FROM bike_buyers
GROUP BY "Gender", "Purchased Bike"
ORDER BY "Gender" DESC, "Average Income" DESC



-- BIKE PURCHASES PERCENTAGE BY COMMUTE DISTANCE
-- FINDINGS:
-- 41.6% OF CUSTOMERS THAT PURCHASED BIKES LIVE 0-1 MILES AWAY FROM THEIR WORKPLACE
-- ADJUST MARKETING (ADD CHANGE)

WITH counted_purchases AS (
	SELECT
		"Commute Distance",
		"Purchased Bike",
		COUNT("Purchased Bike") AS "Purchased Count"
	FROM bike_buyers
	WHERE "Purchased Bike" = 'Yes'
	GROUP BY "Commute Distance", "Purchased Bike"
),
total_purchase AS (
	SELECT SUM("Purchased Count") AS "Total" FROM counted_purchases
)
SELECT
	c."Commute Distance",
	c."Purchased Bike",
	C."Purchased Count",
	ROUND((c."Purchased Count" * 100.0) / t."Total", 1) AS "Percentage"
FROM counted_purchases c
CROSS JOIN total_purchase t
ORDER BY c."Commute Distance"



-- CUSTOMER AGE BRACKETS AND PURCHASES PERCENTAGE
-- FINDINGS:
-- 38.1% OF THE CUSTOMERS THAT HAVE PURCHASED BIKES ARE 31-54 YEARS OLD
-- TAILOR BIKES' DESIGNS AND COLORING TO THEI PREFERENCES

WITH counted_clieants AS (
	SELECT
		"Age Brackets",
		"Purchased Bike",
		COUNT("Purchased Bike") AS "Clients Count"
	FROM bike_buyers
	GROUP BY "Age Brackets", "Purchased Bike"
),
total_percentage AS (
	SELECT SUM("Clients Count") AS total_clients
	FROM counted_clieants
)
SELECT
	c."Age Brackets",
	c."Purchased Bike",
	c."Clients Count",
	ROUND((c."Clients Count" * 100.0) /  t.total_clients, 1) || ' %' as "Percentage"
FROM counted_clieants c
CROSS JOIN total_percentage t
ORDER BY "Age Brackets"




	























