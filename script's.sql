--EDA
SELECT COUNT(*) FROM spotify;
SELECT COUNT(DISTINCT artist) FROM spotify;
SELECT DISTINCT album_type FROM spotify;
SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;
DELETE FROM spotify
WHERE duration_min = 0;
SELECT DISTINCT channel FROM spotify;
SELECT DISTINCT most_played_on FROM spotify;

--easy_category_problem
/* 1- Retrieve the names of all tracks that have more than 1 billion streams.
   2- List all albums along with their respective artists.
   3- Get the total number of comments for tracks where licensed = TRUE.
   4- Find all tracks that belong to the album type single.
   5- Count the total number of tracks by each artist.
*/

--Q.1 Retrieve the names of all tracks that have more than 1 billion streams.
SELECT track FROM spotify
WHERE stream > 1000000000;

-- Q.2 List all albums along with their respective artists.
SELECT Distinct album, artist
FROM spotify
Order by 2;

-- Q.3 Get the total number of comments for tracks where licensed = TRUE
SELECT Sum(comments)
FROM spotify
WHERE licensed = 'true';

-- Q.4 Find all tracks that belong to the album type single.
SELECT * FROM spotify
where album_type ilike 'single';

-- Q.5 Count the total number of tracks by each artist.
SELECT artist, count(title) as No_of_Songs
From spotify
GROUP BY artist
Order by 2 ASC;

/*Medium Level
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

--Q.6 Calculate the average danceability of tracks in each album.
Select album, avg(danceability) as avg_danceability
From spotify
Group BY album
Order BY 2 asc;

--Q.7 Find the top 5 tracks with the highest energy values.
SELECT Distinct track, avg(energy)
FROM spotify
GROUP By 1 
Order by 2 DESC
Limit 5;

--Q.8 List all tracks along with their views and likes where official_video = TRUE.
Select track, sum(views), sum(likes)
FROM spotify
where official_video = 'true'
GROUP by 1 
Order by 2 DESC;

--Q.9 For each album, calculate the total views of all associated tracks.
SELECT album, track,  SUM(Views) Total_Views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;

--Retrieve the track names that have been streamed on Spotify more than YouTube.
Select *
From
(Select 
	track,
	--most_played_on
	Coalesce(SUM(Case WHEN most_played_on ='Youtube' then stream end),0) as Streamed_on_Youtube,
	Coalesce(SUM(Case WHEN most_played_on ='Spotify' then stream end),0) as Streamed_on_Spotify
FROM spotify
Group by 1 
)
Where Streamed_on_Spotify > Streamed_on_Youtube AND
Streamed_on_youtube <> 0;



/*
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each ;
Find tracks where the energy-to-liveness ratio is greater than 1.2.
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

--Q.1 Find the top 3 most-viewed tracks for each artist using window function
WITH artist_rank
AS(
SELECT 
	artist,
	track,
	SUM(views),
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rankings
FROM spotify
GROUP BY 1,2
ORDER BY 1,3 DESC
)
SELECT *
FROM artist_rank
WHERE rankings <=3;

--Q.2 Write a query to find tracks where the liveness score is above the average

SELECT track
FROM spotify 
WHERE liveness > 
(SELECT 
	avg(liveness)
FROM spotify
);

--Q.3 Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each ;
WITH CTE
as
(SELECT 
	album,
	MAX(energy) AS max_ener,
	MIN(energy) AS min_ener
FROM spotify
GROUP BY album
)

SELECT 
	album,
	max_ener - min_ener as ener_diff
FROM cte
Order by 2 DESC;



--Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT 
	track,
	energy/liveness AS EL_ratio
FROM spotify
WHERE energy/liveness > 1.2;



