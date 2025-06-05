SELECT * 
FROM nyc_airbnb.city;

-- creating duplicate table

create table nyc_airbnb.duplicate1
like nyc_airbnb.city;

-- inserting data from original to duplicate table
insert nyc_airbnb.duplicate1
select *
 from nyc_airbnb.city;
 
 # manipulation will be carried out in duplicate table now
 
 SELECT * 
FROM nyc_airbnb.duplicate1;

-- checking the duplicates 
 
  SELECT *
   FROM (
    SELECT*,
    ROW_NUMBER() OVER(Partition By id, name, host_id, host_name, neighbourhood_group, neighbourhood, latitude, longitude, room_type,price,minimum_nights, number_of_reviews, last_review, reviews_per_month, calculated_host_listings_count, availability_365) as final_count
     from nyc_airbnb.duplicate1
     ) AS SUB
     WHERE final_count > 1;
     
  # No duplication has been located
  
  -- STANDARIZING DATA

   # trimming to remove white spaces
UPDATE nyc_airbnb.duplicate1
SET
    name = TRIM(name),
    host_name = TRIM(host_name),
    neighbourhood_group = TRIM(neighbourhood_group),
    neighbourhood = TRIM(neighbourhood),
    room_type = TRIM(room_type),
    last_review = TRIM(last_review);   

 # to check if there's null or blank
SELECT *
FROM nyc_airbnb.duplicate1
WHERE
    name IS NULL OR name = '' OR
    host_name IS NULL OR host_name = '' OR
    neighbourhood_group IS NULL OR neighbourhood_group = '' OR
    neighbourhood IS NULL OR neighbourhood = '' OR
    room_type IS NULL OR room_type = '' OR
    last_review IS NULL OR last_review = '';
    
    -- checking if which hosts has the most repeated bookings
    SELECT 
    host_name, 
    COUNT(*) AS host_name_count
FROM nyc_airbnb.duplicate1
GROUP BY host_name
order by host_name_count desc;

-- finding booking in each neighbourhood

SELECT 
    neighbourhood,
    COUNT(*) AS bookings_count
FROM nyc_airbnb.duplicate1
GROUP BY neighbourhood
ORDER BY bookings_count DESC;


-- neighborhood with the highest average price
SELECT 
    neighbourhood_group AS "Neighborhood Group",
    ROUND(AVG(price), 2) AS "Average Price"
FROM nyc_airbnb.duplicate1
GROUP BY neighbourhood_group
ORDER BY AVG(price) DESC;


-- most consistent bookings (high availability + high reviews)
SELECT 
    neighbourhood_group, 
    AVG(availability_365), 
    AVG(number_of_reviews)
FROM nyc_airbnb.duplicate1
GROUP BY neighbourhood_group
ORDER BY AVG(availability_365) + AVG(number_of_reviews) DESC
LIMIT 10;

-- high minimum night requirements have lower availability
SELECT 
    min_night_category,
    ROUND(AVG(availability_365), 2) AS Average_Availability
FROM (
    SELECT 
        availability_365,
        CASE WHEN minimum_nights >= 7 THEN 'High Minimum Nights' ELSE 'Low Minimum Nights' END AS min_night_category
    FROM nyc_airbnb.duplicate1
) AS sub
GROUP BY min_night_category;
 
