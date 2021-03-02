---------------------QUESTION 1

select Account.account_id,Account.username,Content.content_id,Content.title,sum(minutes_watched_new) as total_rewatched_minutes,month(ContentMinutesWatchedChange.watch_date_new) as month_of_year
from ContentMinutesWatchedChange
join Account on Account.account_id = ContentMinutesWatchedChange.account_id
join Content on Content.content_id = ContentMinutesWatchedChange.content_id
where month(watch_date_new) = 6
group by Account.account_id,username,Content.content_id,Content.title,watch_date_new

select * from ContentMinutesWatchedChange

---------------------QUESTION 2

select case 
	when year(Movie.date_of_release) < 2010 then 'Movies Released Before 2010'
	when year(Movie.date_of_release) > 2010 then 'Movies Released After 2010'
	end as content_before_2010,
	count(*) as number_released_before_2010
from Content
join Movie on Movie.content_id = Content.content_id
group by case 
	when year(Movie.date_of_release) < 2010 then 'Movies Released Before 2010'
	when year(Movie.date_of_release) > 2010 then 'Movies Released After 2010'
	end
union
select case 
	when year(Show.date_of_release) < 2010 then 'Shows Released Before 2010'
	when year(Show.date_of_release) > 2010 then 'Shows Released After 2010'
	end as content_before_2010,
	count(*) as number_released_before_2010
from Content
join Show on Show.content_id = Content.content_id
group by case 
	when year(Show.date_of_release) < 2010 then 'Shows Released Before 2010'
	when year(Show.date_of_release) > 2010 then 'Shows Released After 2010'
	end
select * from Content join Movie on Movie.content_id = Content.content_id
select * from Content join Show on Show.content_id = Content.content_id

-----------------------QUESTION 3


select count(DirectorContentLink.director_id) as content_directed,
	Director.director_id,
	Director.last_name,
	count(AccountContentLink.account_id) as users_who_watched
from Director
left join DirectorContentLink on DirectorContentLink.director_id = Director.director_id
full join Content on Content.content_id = DirectorContentLink.content_id
join AccountContentLink on AccountContentLink.content_id = Content.content_id
group by DirectorContentLink.director_id,Director.director_id,Director.last_name
having count(DirectorContentLink.director_id) >= 3


-------------------QUESTION 4

select StreamingService.service_name, 
count(StreamingServiceContentLink.service_id) as service_with_most_content_data_in_db
from StreamingService
join StreamingServiceContentLink on StreamingServiceContentLink.service_id = StreamingService.service_id
group by StreamingService.service_name
order by service_with_most_content_data_in_db desc