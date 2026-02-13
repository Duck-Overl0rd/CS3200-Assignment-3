-- =====================================================================
-- Query 1: Create a new Table Music Video,
-- that is a class of type Track (generalization)
-- but adds the attribute Video director. A music video is a track.
-- There cannot be a video without a track, and each track can have either
-- no video or just one. 
-- =====================================================================

CREATE TABLE IF NOT EXISTS MusicVideo (
    TrackId INTEGER PRIMARY KEY, -- enforces 1-to-0/1 relationship
    VideoDirector TEXT NOT NULL,
    CONSTRAINT fk_track
        FOREIGN KEY (TrackId) REFERENCES tracks(TrackId) ON DELETE CASCADE
);

-- =====================================================================
-- Query 2: Write the queries that insert at least 10 videos,
-- respecting the problem rules.
-- =====================================================================

INSERT OR IGNORE INTO MusicVideo(TrackId, VideoDirector)
SELECT t.TrackId, 'Director A'
FROM tracks t
WHERE t.TrackId = 1
    AND NOT EXISTS (SELECT 1 FROM MusicVideo mv WHERE mv.TrackId = t.TrackId);

INSERT OR IGNORE INTO MusicVideo(TrackId, VideoDirector)
SELECT t.TrackId, 'Director B'
FROM tracks t
WHERE t.TrackId = 2
    AND NOT EXISTS (SELECT 1 FROM MusicVideo mv WHERE mv.TrackId = t.TrackId);

INSERT OR IGNORE INTO MusicVideo(TrackId, VideoDirector)
SELECT t.TrackId, 'Director C'
FROM tracks t
WHERE t.TrackId = 3
    AND NOT EXISTS (SELECT 1 FROM MusicVideo mv WHERE mv.TrackId = t.TrackId);

INSERT OR IGNORE INTO MusicVideo(TrackId, VideoDirector)
SELECT t.TrackId, 'Director D'
FROM tracks t
WHERE t.TrackId = 4
    AND NOT EXISTS (SELECT 1 FROM MusicVideo mv WHERE mv.TrackId = t.TrackId);

INSERT OR IGNORE INTO MusicVideo(TrackId, VideoDirector)
SELECT t.TrackId, 'Director E'
FROM tracks t
WHERE t.TrackId = 5
    AND NOT EXISTS (SELECT 1 FROM MusicVideo mv WHERE mv.TrackId = t.TrackId);

INSERT OR IGNORE INTO MusicVideo(TrackId, VideoDirector)
SELECT t.TrackId, 'Director F'
FROM tracks t
WHERE t.TrackId = 6
    AND NOT EXISTS (SELECT 1 FROM MusicVideo mv WHERE mv.TrackId = t.TrackId);

INSERT OR IGNORE INTO MusicVideo(TrackId, VideoDirector)
SELECT t.TrackId, 'Director G'
FROM tracks t
WHERE t.TrackId = 7
    AND NOT EXISTS (SELECT 1 FROM MusicVideo mv WHERE mv.TrackId = t.TrackId);

INSERT OR IGNORE INTO MusicVideo(TrackId, VideoDirector)
SELECT t.TrackId, 'Director H'
FROM tracks t
WHERE t.TrackId = 8
    AND NOT EXISTS (SELECT 1 FROM MusicVideo mv WHERE mv.TrackId = t.TrackId);

INSERT OR IGNORE INTO MusicVideo(TrackId, VideoDirector)
SELECT t.TrackId, 'Director I'
FROM tracks t
WHERE t.TrackId = 9
    AND NOT EXISTS (SELECT 1 FROM MusicVideo mv WHERE mv.TrackId = t.TrackId);

INSERT OR IGNORE INTO MusicVideo(TrackId, VideoDirector)
SELECT t.TrackId, 'Director J'
FROM tracks t
WHERE t.TrackId = 10
    AND NOT EXISTS (SELECT 1 FROM MusicVideo mv WHERE mv.TrackId = t.TrackId);

-- Alternative: insert videos for the first 10 tracks dynamically
-- INSERT INTO MusicVideo(TrackId, VideoDirector)
-- SELECT TrackId, 'AutoDirector_' || TrackId FROM Track WHERE TrackId BETWEEN 1 AND 10;

-- =====================================================================
-- Query 3: Insert another video for the track "Voodoo",
-- assuming that you don't know the TrackId, so your insert query
-- should specify the TrackId directly.
-- =====================================================================

INSERT OR IGNORE INTO MusicVideo(TrackId, VideoDirector)
SELECT t.TrackId, 'Voodoo Director'
FROM tracks t
WHERE t.Name = 'Voodoo'
    AND NOT EXISTS (SELECT 1 FROM MusicVideo mv WHERE mv.TrackId = t.TrackId);

-- If you DO know the TrackId (say it's 42), you could also do:
-- INSERT INTO MusicVideo(TrackId, VideoDirector) VALUES(42, 'Voodoo Director');

-- =====================================================================
-- Query 4: Write a query that lists all the tracks
-- that have a ' in the name (e.g. Jorge Da Capadócia, o Samba De Uma Nota Só (One Note Samba))
-- (this is á,é,í,ó,ú)
-- =====================================================================

SELECT TrackId, Name
FROM tracks
WHERE Name LIKE '%á%'
   OR Name LIKE '%Á%'
   OR Name LIKE '%é%'
   OR Name LIKE '%É%'
   OR Name LIKE '%í%'
   OR Name LIKE '%Í%'
   OR Name LIKE '%ó%'
   OR Name LIKE '%Ó%'
   OR Name LIKE '%ú%'
   OR Name LIKE '%Ú%'
ORDER BY Name;

-- =====================================================================
-- Query 5: Creative addition. Make an interesting query that uses a JOIN of at least two tables.
-- Example: Show track name, album title, and artist name (JOINs across three tables)
-- =====================================================================

SELECT t.TrackId,
       t.Name AS Track,
       al.Title AS Album,
       ar.Name AS Artist,
       g.Name AS Genre
FROM tracks t
LEFT JOIN albums al ON t.AlbumId = al.AlbumId
LEFT JOIN artists ar ON al.ArtistId = ar.ArtistId
LEFT JOIN genres g ON t.GenreId = g.GenreId
ORDER BY ar.Name, al.Title, t.TrackId
LIMIT 200;

-- =====================================================================
-- Query 6: Creative addition. Make an interesting query that uses a GROUP statement and at least two tables.
-- Example: For each genre, count tracks and compute average duration (minutes)
-- =====================================================================

SELECT g.GenreId,
       g.Name AS Genre,
       COUNT(t.TrackId) AS TrackCount,
       ROUND(AVG(t.Milliseconds) / 60000.0, 2) AS AvgDurationMinutes
FROM genres g
JOIN tracks t ON t.GenreId = g.GenreId
GROUP BY g.GenreId, g.Name
ORDER BY AvgDurationMinutes DESC;

-- =====================================================================
-- Query 7: Write a query that lists all the customers that listen to
-- longer-than-average tracks, excluding the tracks that are longer than 15 minutes.
-- Interpretation used here:
--  - Compute the average duration across tracks that are <= 15 minutes.
--  - Find customers who have at least one purchased/listened track with
--  duration > that average AND <= 15 minutes.
-- =====================================================================

WITH AvgShortTrack AS (
    SELECT AVG(Milliseconds) AS AvgMs
    FROM tracks
    WHERE Milliseconds <= 15 * 60 * 1000 -- 15 minutes in ms
),
CustomerTracks AS (
    SELECT c.CustomerId, c.FirstName || ' ' || c.LastName AS CustomerName,
           t.TrackId, t.Name AS TrackName, t.Milliseconds
    FROM customers c
    JOIN invoices i ON i.CustomerId = c.CustomerId
    JOIN invoice_items il ON il.InvoiceId = i.InvoiceId
    JOIN tracks t ON t.TrackId = il.TrackId
    WHERE t.Milliseconds <= 15 * 60 * 1000
)
SELECT DISTINCT ct.CustomerId, ct.CustomerName
FROM CustomerTracks ct
CROSS JOIN AvgShortTrack a
WHERE ct.Milliseconds > a.AvgMs
ORDER BY ct.CustomerName;

-- =====================================================================
-- Query 8: Write a query that lists all the tracks that are
-- not in one of the top 5 genres with longer duration in the database. 
-- =====================================================================

WITH GenreTotals AS (
    SELECT g.GenreId, g.Name, SUM(t.Milliseconds) AS TotalMs
    FROM genres g
    JOIN tracks t ON t.GenreId = g.GenreId
    GROUP BY g.GenreId, g.Name
),
Top5Genres AS (
    SELECT GenreId FROM GenreTotals ORDER BY TotalMs DESC LIMIT 5
)
SELECT t.TrackId, t.Name, g.Name AS Genre, t.Milliseconds
FROM tracks t
LEFT JOIN genres g ON t.GenreId = g.GenreId
WHERE t.GenreId NOT IN (SELECT GenreId FROM Top5Genres)
ORDER BY g.Name, t.Name;

