--To properly run procedures, run queries from the main SQL file from the drop table statements to the index creation statements. 
--The insert statement for language is needed for the procedure to add content to complete successfully
--AddAccount procedure will add the new account with arguments that are input @account_id decimal(12),
--procedure  accepts  @account_id decimal(12),@first_name varchar(255),@last_name varchar(255),@email varchar(255),@username varchar(255), @encrypted_password varchar(255)
create or alter procedure AddAccount @first_name varchar(255),@last_name varchar(255),
@email varchar(255),@username varchar(255), @encrypted_password varchar(255)
as
begin

	declare @current_account_seq int = next value for account_seq;
	declare @v_account_id decimal(12)

--inserts into the Account table the arguments that were defined in the create procedure statement
	insert into Account(account_id,first_name,last_name,email,username,encrypted_password)
	values(@current_account_seq,@first_name,@last_name,@email,@username,@encrypted_password);
end;
go
execute AddAccount 'Procedure','Test3','test@email.com','domhorard','password1';
go

--AddEnglishContent procedure 
--AddEnglishContent procedure will add the new content into the database with arguments that are input 
--procedure  accepts  @content_id decimal(12),@title varchar(1024),@description varchar(1024) as arguments
create or alter procedure AddEnglishContent @title varchar(1024),@description varchar(1024)
as
begin
	declare @current_content_seq int = next value for content_seq;
	--variable that stores the language ID from the language table 
	declare @v_language_id decimal(12)

	--elect statement says to take the value stored in the variable as the language ID from the language table where the value is next one for the designated sequence
	select @v_language_id = language_id
	from Language
	where language_name = 'English'

	--values for the arguments and the variable are inserted into the Content table 
	insert into Content(content_id,language_id,title,description)
	values(@current_content_seq,@v_language_id,@title,@description)
end;
go
execute AddEnglishContent 'Test tese', 'Test Description' ---removed 2 from the insert
select* from Content
go

--AddLanguage Procedure
--AddLanguage procedure will add the new content into the database with arguments that are input 
--procedure  accepts @language_name varchar(50) as arguments
create or alter procedure AddLanguage  @language_name varchar(50)
as
begin

	declare @current_lang_seq int = next value for lang_seq;
	
	insert into Language(language_id,language_name)
	values(@current_lang_seq,@language_name)
end;
go

execute AddLanguage 'Fake language'
select * from Language