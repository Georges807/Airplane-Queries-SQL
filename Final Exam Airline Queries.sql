-- 1) Display the name and the capacity of the AIRBUS planes.
--    (Plane’s description that starts with A->AIRBUS,  B->BOEING,C->CONCORDE). 

SELECT PLA_DESC, MAX_PASSENGER
FROM PLANE
WHERE PLA_DESC LIKE 'A%'

--2) Display the identifications of the pilots who have more than two flights (>=) departures from Montreal.

SELECT PILOT_ID, COUNT(*) as FLIGHTS
FROM Flight
WHERE CITY_DEP = 102
GROUP BY PILOT_ID  
HAVING COUNT(*) >= 2

--3) Display the planes (plane id, its description, localization(city) and the numberof passenger) 
--   that are located in OTTAWA and their max passenger is greater than 200(>=)
--   (display the result in the descending order of their max of passenger)

SELECT PLANE.PLA_ID, PLANE.PLA_DESC, PLANE.MAX_PASSENGER, CITY.CITY_NAME
FROM PLANE
JOIN CITY ON PLANE.CITY_ID = CITY.CITY_ID
WHERE PLANE.CITY_ID = 100 AND PLANE.MAX_PASSENGER >= 200
ORDER BY PLANE.MAX_PASSENGER DESC

-- 4) Display the pilots (pilot id and name) who perform at least one departure from MONTREAL. 
SELECT DISTINCT PILOT.PILOT_ID, PILOT.LAST_NAME
FROM PILOT
JOIN FLIGHT ON PILOT.PILOT_ID = FLIGHT.PILOT_ID
WHERE FLIGHT.CITY_DEP = 102

-- 5) Display the pilots (pilot id, name and plane description) who pilot a BOEING

SELECT DISTINCT PILOT.PILOT_ID, PILOT.LAST_NAME, PILOT.FIRST_NAME, PLANE.PLA_DESC
FROM PILOT
JOIN FLIGHT ON PILOT.PILOT_ID = FLIGHT.PILOT_ID 
JOIN PLANE ON FLIGHT.PLA_ID = PLANE.PLA_ID
WHERE PLANE.PLA_DESC LIKE 'B%'

-- 6) Display the pilots (id and name) who earn the same salary as PETERS’s or LAHRIRE’s salary.

SELECT PILOT_ID, LAST_NAME, FIRST_NAME, SALARY
FROM PILOT
WHERE SALARY IN (
    SELECT SALARY 
    FROM PILOT 
    WHERE LAST_NAME IN ('PETERS', 'LAHRIRE')
) AND LAST_NAME NOT IN ('PETERS', 'LAHRIRE');


-- 7) Display the pilots (id, name and city name) who live in the same city as the localization
--    city of the AIRBUS.

SELECT PILOT.PILOT_ID, PILOT.LAST_NAME, PILOT.FIRST_NAME, CITY.CITY_NAME
FROM PILOT
JOIN CITY ON PILOT.CITY_ID = CITY.CITY_ID
WHERE CITY.CITY_ID IN (
    SELECT CITY_ID 
    FROM PLANE
    WHERE PLA_DESC LIKE 'A%'
);


-- 8) Display the planes (description and maximum of passenger) that their 
--    max passenger is greater (>) than the max passenger of all planes located in Montreal.

SELECT PLA_DESC, MAX_PASSENGER
FROM PLANE
WHERE MAX_PASSENGER > (
    SELECT MAX(MAX_PASSENGER)
    FROM PLANE
    WHERE CITY_ID = 102
);

-- 9) Display the planes (description and maximum of passenger) where their max passenger is
--    greater (>) than at least a max passenger of one plane located in Toronto.

SELECT PLA_DESC, MAX_PASSENGER
FROM PLANE
WHERE MAX_PASSENGER > (
    SELECT MIN(MAX_PASSENGER)
    FROM PLANE
    WHERE CITY_ID = 103
);

-- 10) Display the number of pilots in service (pilot in service are pilots who make at least one flight.

SELECT COUNT(DISTINCT PILOT_ID) AS "THE PILOTS IN SERVCE"
FROM FLIGHT;

-- 11) For each AIRBUS in service during the afternoon, display its description, its id and the departures 
--    and arrivals cities.
SELECT 
	PLANE.PLA_ID AS "PLANE ID",
    PLANE.PLA_DESC AS "PLANE DESCRIPTION",
    DEP_CITY.CITY_NAME AS "DEPART CITY",
    ARR_CITY.CITY_NAME AS "ARRIVAL CITY"
FROM 
    PLANE
JOIN 
    FLIGHT ON PLANE.PLA_ID = FLIGHT.PLA_ID
JOIN 
    CITY AS DEP_CITY ON FLIGHT.CITY_DEP = DEP_CITY.CITY_ID
JOIN 
    CITY AS ARR_CITY ON FLIGHT.CITY_ARR = ARR_CITY.CITY_ID
WHERE 
    PLANE.PLA_DESC LIKE 'A%' AND
    FLIGHT.DEP_TIME > 1200
ORDER BY PLANE.PLA_ID;


-- 12) Create a view containing the pilots (names) who do not make any flight.

CREATE VIEW PILOTS_WITH_NO_FLIGHTS AS
SELECT LAST_NAME, FIRST_NAME
FROM PILOT
WHERE PILOT_ID NOT IN (
    SELECT DISTINCT PILOT_ID
    FROM FLIGHT
);

SELECT * FROM PILOTS_WITH_NO_FLIGHTS

-- 13) Create a view which returns the pilot’s id, his name, his salary as well as the plane’s description
--     that he pilots

CREATE VIEW PILOT_PLANE_INFO AS
SELECT DISTINCT PILOT.PILOT_ID, PILOT.LAST_NAME, PILOT.FIRST_NAME, PILOT.SALARY, PLANE.PLA_DESC
FROM PILOT
JOIN FLIGHT ON PILOT.PILOT_ID = FLIGHT.PILOT_ID
JOIN PLANE ON FLIGHT.PLA_ID = PLANE.PLA_ID

-- 14) Display the pilot’s id and name, his piloting frequency. piloting frequency is the number of flight.

SELECT P.PILOT_ID, P.LAST_NAME, P.FIRST_NAME, COUNT(F.FLIGHT_ID) AS count
FROM PILOT P
LEFT JOIN FLIGHT F ON P.PILOT_ID = F.PILOT_ID
GROUP BY P.PILOT_ID, P.FIRST_NAME, P.LAST_NAME;


-- 15) Pilot Paul Ross (#3) called in sick. We need to find a replacement pilot to fly his flight.
--     The replacement pilot has to be in the city of departure of #3's flight (either based in that
--     city and doesn't work elsewhere or flew to that city earlier that day).
--     This extra work should not affect the pilot's original schedule. The new schedule should allow 
--     at least 1 hour buffer time to account for delays.

SELECT DISTINCT P.PILOT_ID, P.FIRST_NAME, P.LAST_NAME
FROM PILOT P
INNER JOIN FLIGHT F ON P.PILOT_ID = F.PILOT_ID
WHERE 
    P.PILOT_ID <> 3 AND 
    P.CITY_ID IN ( 
        SELECT F2.CITY_DEP 
        FROM FLIGHT F2 
        WHERE F2.PILOT_ID = 3
    ) AND 
    P.PILOT_ID NOT IN ( 
        SELECT F3.PILOT_ID 
        FROM FLIGHT F3
        WHERE (F3.DEP_TIME - (
            SELECT F4.DEP_TIME 
            FROM FLIGHT F4 
            WHERE F4.PILOT_ID = 3
        )) < 100
    )
ORDER BY P.PILOT_ID;
