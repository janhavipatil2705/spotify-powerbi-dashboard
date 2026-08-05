select * from spotify_tb;

select count(*) from spotify_tb;

-- BUSINESS PROBLEMS
-- Beginner Level
-- 1. Which artists have the highest total streams?
select artist from spotify_tb where stream = (select max(stream) from spotify_tb)select * from spotify_tb;

select count(*) from spotify_tb;

-- BUSINESS PROBLEMS
-- Beginner Level
-- 1. Which artists have the highest total streams?
select artist from spotify_tb where stream = (select max(stream) from spotify_tb);

-- 2. Which albums are the most popular?
select album from spotify_tb where stream = (select max(stream) from spotify_tb);

-- 3. Which tracks have the highest engagement?
select track, likes+comments_count as engagement from spotify_tb where likes+comments_count = (select max(likes+comments_count) from spotify_tb);

-- 4. Distribution of songs by Album Type
select album_type, count(track) from spotify_tb group by(album_type);

-- 5. Spotify vs YouTube
select most_playedon, count(track) as no_of_tracks from spotify_tb group by(most_playedon);

-- 6. Average audio characteristics
select avg(Danceability) as avg_danceability, avg(Energy) as avg_energy, avg(Acousticness) as avg_acousticness, avg(Valence) as avg_valence, avg(Tempo) as avg_tempo from spotify_tb;

-- 7. Most liked songs
select track from spotify_tb where stream = (select max(stream) from spotify_tb);

-- 8. Top YouTube Channel
select channel, stream from spotify_tb where most_playedon = 'Youtube' order by stream desc limit 1;


-- Intermediate Level
-- 9. Artist Performance
select artist, count(track) as total_songs, sum(stream) as total_streams, sum(views_count) as total_views, sum(likes) as total_likes, sum(comments_count) as total_comment from spotify_tb group by(artist) order by(sum(stream)) desc;

--10. Do songs with more YouTube views also have more Spotify streams?
select corr(views_count,stream) as correlation from spotify_tb;
--Ans. Moderate positive relationship

--11. Are energetic songs streamed more?
select corr(energy,stream) as correlation from spotify_tb;
--Ans. Weak positive relationship

--12. Which songs are "viral"?
with average_vals as(
	select avg(views_count) as avg_views,
	avg(comments_count) as avg_comments,
	avg(stream) as avg_streams
	from spotify_tb
) select artist, track from spotify_tb, average_vals where views_count>avg_views and comments_count>avg_comments and stream>avg_streams;

--13. Compare official videos vs non-official videos.
with video_details as(
	select official_video, likes, views_count, stream, comments_count from spotify_tb
) select official_video, count(*) as total_songs, sum(views_count), sum(stream), sum(comments_count) from video_details group by official_video;

--14. 12. Which songs have high energy but low danceability?
select track, energy, danceability from spotify_tb where energy>(select avg(energy) from spotify_tb) and danceability<(select avg(danceability) from spotify_tb);
-- with CTEs
with average_vals as(
	select avg(energy) as avg_energy,
	avg(danceability) as avg_danceability from spotify_tb
) select track, energy, danceability from spotify_tb, average_vals where energy>avg_energy and danceability<avg_danceability;


-- Advanced level
--15. Top 3 songs of every artist by Spotify streams
select artist, track, stream from (
	select *,
		dense_rank() over(partition by artist order by stream desc) as song_rank
	from spotify_tb
) where song_rank<=3;

--16. Rank songs within each album based on YouTube views
with ranked_songs as(
	select album, track, views_count,
		dense_rank() over(partition by album order by views_count desc) as song_rank
	from spotify_tb where most_playedon = 'Youtube'
) select * from ranked_songs

--17. Compare every song against its artist's average performance
with avg_vals as(
	select track, likes, comments_count, stream, views_count,
	avg(likes) over(partition by artist) as avg_likes,
	avg(comments_count) over(partition by artist) as avg_comment,
	avg(stream) over(partition by artist) as avg_stream,
	avg(views_count) over(partition by artist) as avg_view
	from spotify_tb
) select track,
	case
		when likes>avg_likes or comments_count>avg_comment or stream>avg_stream or views_count>avg_view then 'Above average'
		else 'below average'
	end as "performance"
from avg_vals;

--18. Running total of streams for songs of every artist
select artist, track,
	sum(stream) over(partition by artist order by stream desc)
from spotify_tb;

--19. Previous and next song performance within each artist
select artist, track, stream,
	lag(track) over(partition by artist order by stream desc) as previous_song,
	lead(track) over(partition by artist order by stream desc) as next_song
from spotify_tb;

--20. Identify underrated songs
select artist, track as underrated_songs, likes, stream from spotify_tb where likes<(select avg(likes) from spotify_tb) and stream>(select avg(stream) from spotify_tb);


-- Expert level
--21. One song contributes more than 70% of the artist's total streams.
with cte as(
	select *,
		sum(stream) over(partition by artist) as total_streams
	from spotify_tb
) select artist, track, stream from cte where stream> total_streams*0.70;

--22. Find songs performing above the overall average but below the artist average
with cte as(
	select *,
		avg(stream) over(partition by artist) as artist_avg,
		avg(stream) over() as overall_avg
	from spotify_tb
) select artist, track, stream, artist_avg, overall_avg from cte where stream<artist_avg and stream>overall_avg;







