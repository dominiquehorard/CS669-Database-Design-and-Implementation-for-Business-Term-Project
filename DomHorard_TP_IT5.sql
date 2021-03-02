--SQL Queries to drop the table
drop table AccountContentLink;
drop table ActorContentLink;
drop table ContentMinutesWatchedChange; ---check that the drops work for this 
drop table DirectorContentLink;
drop table GenreContentLink;
drop table StreamingServiceContentLink;
drop table StudioContentLink;
drop table Actor;
drop table Director;
drop table Genre;
drop table Movie;
drop table Show;
drop table StreamingService;
drop table Studio;
drop table Content;
drop table Account;
drop table Language;

--SQL Queries to drop the sequences
drop sequence account_seq;
drop sequence account_content_seq;
drop sequence actor_seq;
drop sequence actor_content_seq;
drop sequence content_seq;
drop sequence minutes_watched_change_seq; -- sequence for watch date change table
drop sequence director_seq;
drop sequence director_content_seq;
drop sequence genre_seq;
drop sequence genre_content_seq;
drop sequence lang_seq;
drop sequence stream_seq;
drop sequence stream_content_seq;
drop sequence studio_seq;
drop sequence studio_content_seq;

--SQL Queries to create the sequences
create sequence account_seq start with 1;
create sequence account_content_seq start with 1;
create sequence actor_seq start with 1;
create sequence actor_content_seq start with 1;
create sequence content_seq start with 1;
create sequence minutes_watched_change_seq start with 1;
create sequence director_seq start with 1;
create sequence director_content_seq start with 1;
create sequence genre_seq start with 1;
create sequence genre_content_seq start with 1;
create sequence lang_seq start with 1;
create sequence stream_seq start with 1;
create sequence stream_content_seq start with 1;
create sequence studio_seq start with 1;
create sequence studio_content_seq start with 1;

--SQL Queries to create the tables
create table Account (
account_id decimal(12) not null primary key,
first_name varchar(255) not null,
last_name varchar(255) not null,
email varchar(255) not null,
username varchar(255) not null, 
encrypted_password varchar(255)
);

create table Language (
language_id decimal(12) not null primary key,
language_name varchar(50) not null
);

create table Content (
content_id decimal(12) not null primary key,
language_id decimal(12) not null foreign key references Language(language_id),
title varchar(1024) not null,
description varchar(1024) not null
);

create table AccountContentLink (
account_content_id decimal(12) not null primary key,
account_id decimal(12) not null foreign key references Account(account_id),
content_id decimal(12) not null foreign key references Content(content_id),
watch_date date not null,
minutes_watched decimal(3) not null,
was_completed char(1) not null
);

create table Actor (
actor_id decimal(12) not null primary key,
first_name varchar(255) not null,
middle_initial varchar(1) null,
last_name varchar(255) not null
);

create table ActorContentLink(
actor_content_id decimal(12) not null primary key,
actor_id decimal(12) not null foreign key references Actor(actor_id),
content_id decimal(12) not null foreign key references Content(content_id),
role_id char(1) not null
);

create table Director (
director_id decimal(12) not null primary key,
first_name varchar(255) not null,
last_name varchar(255) not null
);

create table DirectorContentLink (
director_content_id decimal(12) not null primary key,
director_id decimal(12) not null foreign key references Director(director_id),
content_id decimal(12) not null foreign key references Content(content_id)
);

create table Genre (
genre_id decimal(12) not null primary key,
genre_name varchar(50) not null
);

create table GenreContentLink (
genre_content_id decimal(12) not null primary key,
content_id decimal(12) not null foreign key references Content(content_id),
genre_id decimal(12) not null foreign key references Genre(genre_id)
);

create table Movie (
content_id decimal(12) not null foreign key references Content(content_id) primary key,
runtime_minutes decimal(3) not null,
date_of_release date not null
);

create table Show (
content_id decimal(12) not null foreign key references Content(content_id) primary key,
episode_title varchar(1024) not null, 
runtime_minutes decimal(2) not null,
date_of_release date not null
);

create table StreamingService (
service_id decimal(12) not null primary key,
service_name varchar(1024) not null
);

create table StreamingServiceContentLink (
service_content_id decimal(12) not null primary key, 
service_id decimal(12) not null foreign key references StreamingService(service_id),
content_id decimal(12) not null foreign key references Content(content_id)
);

create table Studio (
studio_id decimal(12) not null primary key,
studio_name varchar(255)
);

create table StudioContentLink (
studio_content_id decimal(12) not null primary key,
studio_id decimal(12) not null foreign key references Studio(studio_id),
content_id decimal(12) not null foreign key references Content(content_id)
);

--SQL Query to create the historical table for ContentWatchChange
create table ContentMinutesWatchedChange (
minutes_watched_change_id decimal(12) not null primary key,
account_id decimal(12) not null foreign key references Account(account_id),
content_id decimal(12) not null foreign key references Content(content_id),
minutes_watched_old decimal(3) not null,
minutes_watched_new decimal(3) not null,
watch_date_old date not null,
watch_date_new date not null,
date_changed date not null
);
go

--Trigger for tracking the change of a watch date for content
create trigger minutes_watched_change_trg
on AccountContentLink
after update
as
begin
	declare @old_minutes_completed decimal = (select minutes_watched from deleted);
	declare @new_minutes_completed decimal = (select minutes_watched from inserted);
	declare @old_watch_date date = (select watch_date from deleted);
	declare @new_watch_date date = (select watch_date from inserted);

	if (@old_watch_date < @new_watch_date)
	insert into ContentMinutesWatchedChange(minutes_watched_change_id, content_id, account_id, minutes_watched_old, minutes_watched_new,watch_date_old,watch_date_new,date_changed)
	values(next value for minutes_watched_change_seq,(select content_id from inserted),(select account_id from inserted),@old_minutes_completed,@new_minutes_completed,@old_watch_date,@new_watch_date,getdate());
end;
go

-- Indexes
create index ContentIndex
on Content (language_id,title);

create index AccountConIndex
on AccountContentLink(account_id,content_id);

create index ActorConIndex
on ActorContentLink(actor_id,content_id);

create index DirectorConIndex
on DirectorContentLink(director_id,content_id);

create index GenreConIndex
on GenreContentLink(content_id,genre_id);

create index StreamingServiceConIndex
on StreamingServiceContentLink(service_id,content_id);

create index StudioConIndex
on StudioContentLink(studio_id,content_id);

create index ActorName
on Actor(first_name,last_name);

create index DirectName
on Director(first_name,last_name);

---------------------------------------INSERT STATEMENTS

--declaring the starting point for the variables
declare @current_account_seq int = next value for account_seq;
declare @current_account_content_seq int = next value for account_content_seq;
declare @current_actor_seq int = next value for actor_seq;
declare @current_actor_content_seq int = next value for actor_content_seq;
declare @current_content_seq int = next value for content_seq;
declare @current_minutes_watched_change_seq int = next value for minutes_watched_change_seq;
declare @current_director_seq int = next value for director_seq;
declare @current_director_content_seq int = next value for director_content_seq;
declare @current_genre_seq int = next value for genre_seq;
declare @current_genre_content_seq int = next value for genre_content_seq;
declare @current_lang_seq int = next value for lang_seq;
declare @current_stream_seq int = next value for stream_seq;
declare @current_stream_content_seq int = next value for stream_content_seq;
declare @current_studio_seq int = next value for studio_seq;
declare @current_studio_content_seq int = next value for studio_content_seq;

insert into StreamingService
values(@current_stream_seq, 'Stream4Free');
set @current_stream_seq = next value for stream_seq
insert into StreamingService
values(@current_stream_seq, '5uper5tream');
set @current_stream_seq = next value for stream_seq
insert into StreamingService
values(@current_stream_seq, '6lock6usters');
set @current_stream_seq = next value for stream_seq
insert into StreamingService
values(@current_stream_seq, 'S7reamIt');
set @current_stream_seq = next value for stream_seq
insert into StreamingService
values(@current_stream_seq, 'Gr8 Streams');
set @current_stream_seq = next value for stream_seq
insert into StreamingService
values(@current_stream_seq, 'GoodFilms');
set @current_stream_seq = next value for stream_seq
insert into StreamingService
values(@current_stream_seq, 'MadMotions');

insert into Genre
values(@current_genre_seq,'Action');
set @current_genre_seq = next value for genre_seq
insert into Genre
values(@current_genre_seq,'Horror');
set @current_genre_seq = next value for genre_seq
insert into Genre
values(@current_genre_seq,'Thriller');
set @current_genre_seq = next value for genre_seq
insert into Genre
values(@current_genre_seq,'Comedy');
set @current_genre_seq = next value for genre_seq
insert into Genre
values(@current_genre_seq,'Family');
set @current_genre_seq = next value for genre_seq
insert into Genre
values(@current_genre_seq,'Crime');
set @current_genre_seq = next value for genre_seq
insert into Genre
values(@current_genre_seq,'Independent');
set @current_genre_seq = next value for genre_seq
insert into Genre
values(@current_genre_seq,'Drama');
set @current_genre_seq = next value for genre_seq
insert into Genre
values(@current_genre_seq,'Romance');
set @current_genre_seq = next value for genre_seq
insert into Genre
values(@current_genre_seq,'Animated');

insert into Language
values (@current_lang_seq,'English');
set @current_stream_seq = next value for stream_seq
insert into StreamingService
values(@current_stream_seq, 'Netflix');
insert into Account
values(@current_account_seq, 'Dominique','Horard','email1@email.com','dhorard','Password1');
insert into Director
values(@current_director_seq, 'Tony', 'Scott');
insert into Studio
values (@current_studio_seq,'Regency Cinema');
insert into Actor
values (@current_actor_seq,'Denzel',null,'Washington');
insert into Content
values(@current_content_seq, @current_lang_seq,'Man On Fire', 
'In a Mexico City wracked by a recent wave of kidnappings, ex-CIA operative John Creasy (Denzel Washington) reluctantly accepts a job as a bodyguard for 9-year-old Lupita (Dakota Fanning), the daughter of wealthy businessman Samuel Ramos (Marc Anthony). Just as Creasy begins to develop a fondness for the young girl, a bloodthirsty gunman (Jesús Ochoa) kidnaps her. Now, Creasy must pick off a succession of corrupt cops and criminals to reach his ultimate object of vengeance.');
insert into Movie
values(@current_content_seq, 180, cast('02/23/2004' as date))
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),32,1);
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Action'));

set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Ryan', 'Coogler');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'New Line Cinema');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Michael','B','Jordan');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Creed','Adonis Johnson (Michael B. Jordan) never knew his famous father, boxing champion Apollo Creed, who died before Adonis was born. However, boxing is in his blood, so he seeks out Rocky Balboa (Sylvester Stallone) and asks the retired champ to be his trainer. Rocky sees much of Apollo in Adonis, and agrees to mentor him, even as he battles an opponent deadlier than any in the ring. With Rocky''s help, Adonis soon gets a title shot, but whether he has the true heart of a fighter remains to be seen.');
insert into Movie
values(@current_content_seq, 165, cast('03/19/2018' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),67,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Drama'));

set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Ari', 'Aster');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'A24')
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Florence',null,'Pugh');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Midsommar','A couple travel to Sweden to visit their friend''s rural hometown for its fabled midsummer festival, but what begins as an idyllic retreat quickly devolves into an increasingly violent and bizarre competition at the hands of a pagan cult.')
insert into Movie
values(@current_content_seq, 90, cast('07/19/2019' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),83,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Horror'));

set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Toni',null,'Collet');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Hereditary','Scary Cult Movie')
insert into Movie
values(@current_content_seq, 132, cast('02/19/2017' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),131,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Horror'));

set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Billy',null,'Mayo');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'The Strange Thing About the Johnsons','Scary Cultish Movie')
insert into Movie
values(@current_content_seq, 132, cast('02/19/2017' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),131,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Drama'));

set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Batheson',null,'Suriqui');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'The Other Movie','Light hearted cult movie')
insert into Movie
values(@current_content_seq, 64, cast('02/12/2009' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),40,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Horror'));

set @current_account_seq = next value for account_seq
insert into Account
values(@current_account_seq, 'Nicole','Kirby','email2@email.com','nkirby','Password2');
set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Barry', 'Jenkins');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Trevante',null,'Rhodes');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Moonlight','A look at three defining chapters in the life of Chiron, a young black man growing up in Miami. His epic journey to manhood is guided by the kindness, support and love of the community that helps raise him.');
insert into Movie
values(@current_content_seq, 129, cast('09/28/2016' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),112,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Independent'));

set @current_account_seq = next value for account_seq
insert into Account
values(@current_account_seq, 'Jumel','Pluviose','email3@email.com','jpluviose','Password3');
set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Jordan', 'Peele');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'Bulumhouse Productions');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Allison',null,'Williams');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Get Out','Now that Chris (Daniel Kaluuya) and his girlfriend, Rose (Allison Williams), have reached the meet-the-parents milestone of dating, she invites him for a weekend getaway upstate with Missy and Dean. At first, Chris reads the family''s overly accommodating behavior as nervous attempts to deal with their daughter''s interracial relationship, but as the weekend progresses, a series of increasingly disturbing discoveries lead him to a truth that he never could have imagined.');
insert into Movie
values(@current_content_seq, 95, cast('08/13/2016' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),54,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,0);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Thriller'));

set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'TriStar Pictures');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Ansel',null,'Egort');
set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Edgar', 'Wright');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Baby Driver','Baby, a music-loving orphan also happens to be the prodigiously talented go-to getaway driver for heist mastermind Doc. With the perfect soundtrack picked out for each and every job, Baby ensures Doc''s violent, bank-robbing cronies - including Buddy, Bats and Darling - get in and out of Dodge before it''s too late. He''s not in it for the long haul though, hoping to nail one last job before riding off into the sunset with beautiful diner waitress Debora. Easier said than done.');
insert into Movie
values(@current_content_seq, 130, cast('05/09/2017' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),123,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Action'));

set @current_account_seq = next value for account_seq
insert into Account
values(@current_account_seq, 'Lucienne','Lamothe','email6@email.com','llamothe','Password4');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'StudioCanal');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Simon',null,'Pegg');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Shaun of the Dead','Shaun (Simon Pegg) is a 30-something loser with a dull, easy existence. When he''s not working at the electronics store, he lives with his slovenly best friend, Ed (Nick Frost), in a small flat on the outskirts of London. The only unpredictable element in his life is his girlfriend, Liz (Kate Ashfield), who wishes desperately for Shaun to grow up and be a man. When the town is inexplicably overrun with zombies, Shaun must rise to the occasion and protect both Liz and his mother (Penelope Wilton).');
insert into Movie
values(@current_content_seq, 86, cast('10/19/2018' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),43,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Comedy'));

set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'Big Talk');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Michael',null,'Cera');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Scott pilgrim vs. the World','In Toronto, 22-year-old Scott Pilgrim is a bassist for his unsuccessful indie garage band Sex Bob-Omb. He is dating Knives Chau, a 17-year-old high-school student, to the disapproval of his friends in the band, his roommate Wallace Wells, and his younger sister Stacey Pilgrim. Scott meets an American Amazon.ca delivery girl, Ramona Flowers, after having first seen her in a dream. He loses interest in Knives, but does not break up with her before pursuing Ramona.');
insert into Movie
values(@current_content_seq, 86, cast('07/27/2010' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),76,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Comedy'));

set @current_stream_seq = next value for stream_seq
insert into StreamingService
values(@current_stream_seq, 'Hulu');
set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Gariele', 'Muccino');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'Columbia Pictures');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Will',null,'Smith');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Pursuit of Happyness','Life is a struggle for single father Chris Gardner (Will Smith). Evicted from their apartment, he and his young son (Jaden Christopher Syre Smith) find themselves alone with no place to go. Even though Chris eventually lands a job as an intern at a prestigious brokerage firm, the position pays no money. The pair must live in shelters and endure many hardships, but Chris refuses to give in to despair as he struggles to create a better life for himself and his son.');
insert into Movie
values(@current_content_seq, 134, cast('11/16/2004' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),134,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Drama'));

set @current_account_seq = next value for account_seq
insert into Account
values(@current_account_seq, 'Mehreen','Baakza','email4@email.com','mbaakza','Password5');
set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Guillermo', 'del Toro');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'TSG Entertainment');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Sally',null,'Hawkins');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Shape of Water','Elisa is a mute, isolated woman who works as a cleaning lady in a hidden, high-security government laboratory in 1962 Baltimore. Her life changes forever when she discovers the lab''s classified secret -- a mysterious, scaled creature from South America that lives in a water tank. As Elisa develops a unique bond with her new friend, she soon learns that its fate and very survival lies in the hands of a hostile government agent and a marine biologist.');
insert into Movie
values(@current_content_seq, 112,cast('12/10/2018' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),111,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Romance'));

set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Pete', 'Doctor');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'Pixar');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Jamie',null,'Fox');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Soul','Joe is a middle-school band teacher whose life hasn''t quite gone the way he expected. His true passion is jazz -- and he''s good. But when he travels to another realm to help someone find their passion, he soon discovers what it means to have soul.');
insert into Movie
values(@current_content_seq, 110, cast('11/01/2020' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),78,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Family'));

set @current_account_seq = next value for account_seq
insert into Account
values(@current_account_seq, 'Sianne','Valverde','email5@email.com','sunnyv','Password6');
set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Larry', 'David');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'Giggling Goose');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Jerry',null,'Seinfeld');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Seinfeld','Four single friends -- comic Jerry Seinfeld, bungling George Costanza, frustrated working gal Elaine Benes and eccentric neighbor Cosmo Kramer -- deal with the absurdities of everyday life in New York City.');
insert into Show
values(@current_content_seq,'Soup Nazi',23, cast('02/19/1989' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),21,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Comedy'));

set @current_stream_seq = next value for stream_seq
insert into StreamingService
values(@current_stream_seq, 'Amazon Prime Video');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'Alan Yang Pictures');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Aziz',null,'Ansari');
set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Aziz', 'Ansari');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Master of None','Ansari plays the role of Dev, a New York-based actor who is struggling to identify what he really wants, both personally and professionally. The series reveals glimpses of Dev''s younger years, and explores current aspects of his life, including modern etiquette (regarding texting and social media), and being young and single in the city.');
insert into Show
values(@current_content_seq,'First Date',23, cast('09/11/2015' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),23,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Comedy'));

set @current_account_seq = next value for account_seq
insert into Account
values(@current_account_seq, 'Victoria','Horard','email7@email.com','vhorard','Password7');
set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Louie', 'CK');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'FX Productions');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Louis',null,'CK');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Louie','Life can be hectic for a newly single father and successful stand-up comedian -- just ask Louie, a fictionalized version of comic Louis C.K., who portrays the character.');
insert into Show
values(@current_content_seq,'Sleepover',23, cast('03/27/2015' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),22,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Comedy'));

set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Loren', 'Bouchard');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq,@current_lang_seq,'Archer','Archer is an American adult animated sitcom created by Adam Reed for FX. The series follows the exploits of a dysfunctional intelligence agency, led by Sterling Archer and seven of his colleagues—his mother Malory Archer, Lana Kane, Cyril Figgis, Cheryl Tunt, Pam Poovey, Ray Gillette and Dr. Algernop Krieger.');
insert into Show
values(@current_content_seq,'Cold Fusion',23, cast('07/19/2020' as date))
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Judy',null,'Greer');
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),23,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,0);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Comedy'));

set @current_account_seq = next value for account_seq
insert into Account
values(@current_account_seq, 'Hung','Troung','email8@email.com','htroung','Password8');
set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Larry', 'Leichliter')
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'Cartoon Network Studios');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Jeremy',null,'Shada');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq,@current_lang_seq,'Adventure Time','Twelve- year-old Finn battles evil in the Land of Ooo. Assisted by his magical dog, Jake, Finn roams the Land of Ooo righting wrongs and battling evil. Usually that evil comes in the form of the Ice King, who is in search of a wife. He''s decided he should wed Princess Bubblegum, though she doesn''t want to marry him. Still, he persists in trying to steal her away, and Finn and Jake, along with Lady Raincorn (a cross between a unicorn and a rainbow) do their best to keep her from harm.');
insert into Show
values(@current_content_seq,'Come Along With Me',23, cast('06/29/2018' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),8,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Animated'));

set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Adam', 'Reed');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Philip',null,'Solomon');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq,@current_lang_seq,'Craig of the Creek','Craig and his two friends Kelsey and J.P. explore the wilderness of the creek, which is dominated by other children.');
insert into Show
values(@current_content_seq,'Cousin of the Creek',23, cast('04/09/2018' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),13,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Animated'));

set @current_account_seq = next value for account_seq
insert into Account
values(@current_account_seq, 'Matt','Day','email9@email.com','mday','Password9');
set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Loren', 'Bouchard');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'Bento Box Entertainment');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'H','J','Benjamin');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Bob''s Burgers','Bob Belcher is a third-generation restaurateur who runs Bob''s Burgers with his loving wife and their three children.');
insert into Show
values(@current_content_seq,'Bobby Driver',23, cast('9/19/2018' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),23,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Animated'));

set @current_lang_seq = next value for lang_seq
insert into Language
values (@current_lang_seq,'Spanish');

set @current_lang_seq = next value for lang_seq
insert into Language
values (@current_lang_seq,'Russian');

set @current_account_seq = next value for account_seq
insert into Account
values(@current_account_seq, 'Travis','Scott','email10@email.com','tscott','Password10');
set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Catherine', 'Reitman');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'Wolf & Rabbit Entertainment');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Catherine',null,'Reitman');
set @current_lang_seq = next value for lang_seq
insert into Language
values (@current_lang_seq,'French');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Workin'' Moms','Warm, loyal PR executive Kate and her longtime friend, no-nonsense psychiatrist Anne, attend a judgmental mommies'' group, where they meet timid IT tech Jenny and blindly optimistic real estate agent Frankie. The four quickly form an unlikely friendship, sharing struggles of urban motherhood filled with the chaos of toddlers, tantrums, careers, and identity crises, all while trying to achieve the holy grail: a sense of self.');
insert into Show
values(@current_content_seq,'Bad Help',23, cast('06/17/2017' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),16,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Comedy'));

set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Sho', 'Miyake');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'W Field');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Yoshiyoshi',null,'Arakawa');
set @current_lang_seq = next value for lang_seq
insert into Language
values (@current_lang_seq,'Japanese');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq, @current_lang_seq,'Ju-On: Origins','JU-ON: Origins is a Japanese horror streaming television series based on the Ju-On franchise.');
insert into Show
values(@current_content_seq,'Episode 1',23, cast('07/12/2020' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),23,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Horror'));

set @current_lang_seq = next value for lang_seq
insert into Language
values (@current_lang_seq,'Chinese');

set @current_lang_seq = next value for lang_seq
insert into Language
values (@current_lang_seq,'Arabic');

set @current_director_seq = next value for director_seq
insert into Director
values(@current_director_seq, 'Baran', 'bo Odar');
set @current_studio_seq = next value for studio_seq
insert into Studio
values (@current_studio_seq,'Wiedemann & Berg Television');
set @current_actor_seq = next value for actor_seq
insert into Actor
values (@current_actor_seq,'Louis',null,'Hofmann');
set @current_lang_seq = next value for lang_seq
insert into Language
values (@current_lang_seq,'German');
set @current_content_seq = next value for content_seq
insert into Content
values(@current_content_seq,@current_lang_seq,'Dark','When two children go missing in a small German town, its sinful past is exposed along with the double lives and fractured relationships that exist among four families as they search for the kids.');
insert into Show
values(@current_content_seq,'Sic Mundus Creatus Est',40, cast('04/24/2017' as date))
set @current_studio_content_seq = next value for studio_content_seq
insert into StudioContentLink
values(@current_studio_content_seq,@current_studio_seq,@current_content_seq);
set @current_account_content_seq = next value for account_content_seq
insert into AccountContentLink
values(@current_account_content_seq,@current_account_seq,@current_content_seq, getdate(),18,1);
set @current_actor_content_seq = next value for actor_content_seq
insert into ActorContentLink
values (@current_actor_content_seq,@current_actor_seq,@current_content_seq,1);
set @current_stream_content_seq = next value for stream_content_seq
insert into StreamingServiceContentLink
values (@current_stream_content_seq,@current_stream_seq,@current_content_seq);
set @current_director_content_seq = next value for director_content_seq
insert into DirectorContentLink
values (@current_director_content_seq,@current_director_seq,@current_content_seq);
set @current_genre_content_seq = next value for genre_content_seq
insert into GenreContentLink
values (@current_genre_content_seq,@current_content_seq,(select genre_id from Genre where genre_name='Drama'));

set @current_lang_seq = next value for lang_seq
insert into Language
values (@current_lang_seq,'Korean');

set @current_lang_seq = next value for lang_seq
insert into Language
values (@current_lang_seq,'Portugese');

-------------------------------------HISTORY TABLE TRIGGER

update AccountContentLink
set minutes_watched = 12,
watch_date = cast('02/23/2021' as date)
where account_content_id = 1
go
update AccountContentLink
set minutes_watched = 14,
watch_date = cast('04/23/2021' as date)
where account_content_id = 2

update AccountContentLink
set minutes_watched = 54,
watch_date = cast('02/28/2021' as date)
where account_content_id = 3

update AccountContentLink
set minutes_watched = 67,
watch_date = cast('06/23/2021' as date)
where account_content_id = 4

update AccountContentLink
set minutes_watched = 90,
watch_date = cast('06/16/2021' as date)
where account_content_id = 5

update AccountContentLink
set minutes_watched = 80,
watch_date = cast('12/23/2021' as date)
where account_content_id = 6

update AccountContentLink
set minutes_watched = 115,
watch_date = cast('06/03/2021' as date)
where account_content_id = 7

update AccountContentLink
set minutes_watched = 65,
watch_date = cast('10/23/2021' as date)
where account_content_id = 8

update AccountContentLink
set minutes_watched = 50,
watch_date = cast('08/23/2021' as date)
where account_content_id = 9

update AccountContentLink
set minutes_watched = 130,
watch_date = cast('11/23/2021' as date)
where account_content_id = 10