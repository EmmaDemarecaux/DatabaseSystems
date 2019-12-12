# drop DATABASE olympicsdb;
CREATE DATABASE Olympicsdb;
USE Olympicsdb;

# 5) IMPLEMENTATION

create table Country(
	Initials varchar (2) not null,
	Name varchar (48),
	NoGold integer (2),
	NoSilver integer (2),
    NoBronze integer (2),
	primary key (Initials));
    
create table Category(
	ID int not null auto_increment,
	Name varchar (48),
	primary key (ID));
    
create table Sport(
	ID int not null auto_increment,
	Name varchar (48),
    CategoryID int,
	primary key (ID),
	foreign key (CategoryID) REFERENCES Category(ID)
		ON DELETE CASCADE
        ON UPDATE CASCADE);

create table Participant(
	ID int not null auto_increment,
	Name varchar (48),
    Birthday Year,
    CountryInitials varchar (2),
    Sex enum('M','F'),
    Height numeric (3,0),
    Weight  numeric (4,1),
    primary key (ID),
	foreign key (CountryInitials) REFERENCES Country(Initials)
		ON DELETE SET NULL
        ON UPDATE CASCADE);

create table Team(
	ID int not null auto_increment,
    CountryInitials varchar (2),
    NoParticipants numeric (4,0),
    CategoryID int,
    primary key (ID),
	foreign key (CountryInitials) REFERENCES Country(Initials)
		ON DELETE SET NULL
        ON UPDATE CASCADE,
	foreign key (CategoryID) REFERENCES Category(ID)
		ON DELETE SET NULL
        ON UPDATE CASCADE);
        
create table Result(
	TeamID int not null,
	NoGold integer (2),
	NoSilver integer (2),
    NoBronze integer (2),
    primary key (TeamID),
	foreign key (TeamID) REFERENCES Team(ID)
		ON DELETE CASCADE
        ON UPDATE CASCADE);
        
create table PersonParticipation(
	TeamID int not null,
	ParticipantID int not null,
    primary key (TeamID, ParticipantID),
	foreign key (TeamID) REFERENCES Team(ID)
		ON DELETE CASCADE
        ON UPDATE CASCADE,
	foreign key (ParticipantID) REFERENCES Participant(ID)
		ON DELETE CASCADE
        ON UPDATE CASCADE);
	
create table Tournament(
	ID int not null auto_increment,
	SportID  int,
    Sex enum('M','F'),
    GoldTeamID int,
    SilverTeamID int,
    BronzeTeamID int,
    StartDate DateTime,
    EndDate DateTime,
    primary key (ID),
	foreign key (SportID) REFERENCES Sport(ID)
		ON DELETE CASCADE
        ON UPDATE CASCADE,
	foreign key (GoldTeamID) REFERENCES Team(ID)
		ON DELETE SET NULL
        ON UPDATE CASCADE,
	foreign key (SilverTeamID) REFERENCES Team(ID)
		ON DELETE SET NULL
        ON UPDATE CASCADE,        
	foreign key (BronzeTeamID) REFERENCES Team(ID)
		ON DELETE SET NULL
        ON UPDATE CASCADE);

create table `Match`(
	ID int not null auto_increment,
	TournamentID int,
    Sex enum('M','F'),
    Winner1TeamID int,
    Winner2TeamID int,
    Winner3TeamID int,
    StartDate DateTime,
    EndDate DateTime,
    primary key (ID),
	foreign key (TournamentID) REFERENCES Tournament(ID)
		ON DELETE CASCADE
        ON UPDATE CASCADE,
	foreign key (Winner1TeamID) REFERENCES Team(ID)
		ON DELETE SET NULL
        ON UPDATE CASCADE,
	foreign key (Winner2TeamID) REFERENCES Team(ID)
		ON DELETE SET NULL
        ON UPDATE CASCADE,        
	foreign key (Winner3TeamID) REFERENCES Team(ID)
		ON DELETE SET NULL
        ON UPDATE CASCADE);


create table TeamParticipation(
	MatchID int not null,
	TeamID int not null,
    primary key (TeamID, MatchID),
	foreign key (MatchID) REFERENCES `Match`(ID)
		ON DELETE CASCADE
        ON UPDATE CASCADE,
	foreign key (TeamID) REFERENCES Team(ID)
		ON DELETE CASCADE
        ON UPDATE CASCADE);

# 9) SQL Programming : Triggers
# Adding a new line to the result table with 0 medal when creating a team

DELIMITER //
CREATE TRIGGER Team_Result 
AFTER INSERT ON Team
FOR EACH ROW
BEGIN
	insert Result VALUES (New.ID, 0, 0,0);
END; //
DELIMITER ;

# Updating the result table after the end of a tournament

DELIMITER //
CREATE TRIGGER Tournament_Result 
AFTER update ON Tournament
FOR EACH ROW
BEGIN
	if OLD.GoldTeamID is not null 
    then update result 
		set NoGold = NoGold - 1 where TeamID = OLD.GoldTeamID;
	end if;
	if OLD.SilverTeamID is not null 
    then update result 
		set NoSilver = NoSilver - 1 where TeamID = OLD.SilverTeamID;
	end if;
	if OLD.BronzeTeamID is not null 
    then update result 
		set NoBronze = NoBronze - 1 where TeamID = OLD.BronzeTeamID;
	end if;
    
    if NEW.GoldTeamID is not null 
    then update result 
		set NoGold = NoGold + 1 where TeamID = NEW.GoldTeamID;
	end if;
	if NEW.SilverTeamID is not null 
    then update result 
		set NoSilver = NoSilver + 1 where TeamID = NEW.SilverTeamID;
	end if;
	if NEW.BronzeTeamID is not null 
    then update result 
		set NoBronze = NoBronze+ 1 where TeamID = NEW.BronzeTeamID;
	end if;
END; //
DELIMITER ;

# Updating the country table after updating the result table

DELIMITER //
CREATE TRIGGER Result_Country 
AFTER update ON Result
FOR EACH ROW
BEGIN
	update country set NoGold = NoGold + getDifference(OLD.NoGold, NEW.NoGold) where Initials = getTeamCountry(OLD.TeamID);
	update country set NoSilver = NoSilver + getDifference(OLD.NoSilver, NEW.NoSilver) where Initials = getTeamCountry(OLD.TeamID);
	update country set NoBronze = NoBronze + getDifference(OLD.NoBronze, NEW.NoBronze) where Initials = getTeamCountry(OLD.TeamID);
	
END; //
DELIMITER ;

# 9) SQL Programming : Functions created for the trigger above

DELIMITER //
CREATE FUNCTION getDifference (oldCount int, newCount int) RETURNS int
BEGIN
if oldCount is null then return newCount; end if;
if newCount is not null then return newCount - oldCount; end if;
return - oldCount;
END; //
DELIMITER ;

DELIMITER //
CREATE FUNCTION getTeamCountry (TeamID int) returns varchar(2) BEGIN return (select CountryInitials from Team where ID = TeamID);END; //
DELIMITER ;

# 6) Database Instance

# 5 countries are represented for these Olympics

insert Country VALUES ('DK','Denmark',0,0,0);
insert Country VALUES ('FR','France',0,0,0);
insert Country VALUES ('SE','Sweden',0,0,0);
insert Country VALUES ('DE','Germany',0,0,0);
insert Country VALUES ('GR','Greece',0,0,0);
select * from Country;

# 3 Categories are represented for these Olympics : swimming, gymnastic and volleyball

insert into Category (Name) VALUES ('Swimming');
insert into Category (Name) VALUES ('Gymnastic');
insert into Category (Name) VALUES ('Volleyball');
select * from Category;

# 3 different sports in the swimming category : 50 metres freestyle, 100 metres freestyle and 4 x 100 metres freestyle relay
# 3 different sports in the gymnastic category : artistic, rythmic and trampoline
# 2 different sports in the volleyball category : volleyball (beach) and volleyball (indoor)

insert into Sport (Name, CategoryID) VALUES ('50 metres freestyle', 1);
insert into Sport (Name, CategoryID) VALUES ('100 metres freestyle', 1);
insert into Sport (Name, CategoryID) VALUES ('4 x 100 metres freestyle relay', 1);
insert into Sport (Name, CategoryID) VALUES ('Artistic', 2);
insert into Sport (Name, CategoryID) VALUES ('Rhytmic', 2);
insert into Sport (Name, CategoryID) VALUES ('Trampoline', 2);
insert into Sport (Name, CategoryID) VALUES ('Volleyball (beach)', 3);
insert into Sport (Name, CategoryID) VALUES ('Volleyball (indoor)', 3);
select * from Sport;

# 4 participants in Denmark
# 4 participants in France
# 2 participants in Sweeden
# 2 participants in Germany
# 1 participant in Greece

insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Morten', 1995, 'DK', 'M', 175, 80.0);
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Elisa', 1994, 'DK', 'F', 174, 59.0);
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Sofie', 1996, 'DK', 'F', 173, 65.0);
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Anna', 1996, 'DK', 'F', 173, 65.0);
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Capucine', 1996, 'FR', 'F', 168, 60.0);
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Emma', 1996, 'FR', 'F', 175, 65.0);
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Charles', 1996, 'FR', 'M', 175, 65.0);
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Sandra', 1996, 'FR', 'F', 175, 65.0);
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Karl', 1995, 'SE', 'M', 175, 70.0);
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Olivia', 1995, 'SE', 'F', 175, 60.0);
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Malte', 1995, 'DE', 'M', 175, 70.0);
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Tobias', 1995, 'DE', 'M', 175, 70.0);
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Maria', 1995, 'GR', 'F', 175, 60.0);
select * from participant;

# Creation of different teams by the country, the number of participants and the category
# Affection participants - teams

#SWIMMING - 50 metres freestyle - M
#SWIMMING - 100 metres freestyle - M

insert into Team (CountryInitials, NoParticipants, CategoryID) VALUES ('DK', 1, 1);
insert into PersonParticipation VALUES (1,1);
insert into Team (CountryInitials, NoParticipants, CategoryID) VALUES ('SE', 1, 1);
insert into PersonParticipation VALUES (2,9);
insert into Team (CountryInitials, NoParticipants, CategoryID) VALUES ('DE', 1, 1);
insert into PersonParticipation VALUES (3,11);

# Creation of tournaments for each sport and each sex

insert into Tournament (SportID, Sex, GoldTeamID, SilverTeamID, BronzeTeamID, StartDate, EndDate) 
VALUES (1,'M',NULL,NULL,NULL,'2018-07-14 10:00:00','2018-07-14 12:00:00'),
(2,'M',NULL,NULL,NULL,'2018-07-15 10:00:00','2018-07-15 12:00:00');

# Creation of matches inside each tournament

insert into `Match` (TournamentID, Sex, Winner1TeamID, Winner2TeamID, Winner3TeamID, StartDate, EndDate) 
VALUES (1,'M',NULL,NULL,NULL,'2018-04-14 10:00:00','2018-04-14 18:13:00'),
(2,'M',NULL,NULL,NULL,'2018-07-15 10:00:00','2018-07-15 12:00:00');

# Affectation matches - teams

#Match 1 for team 1, 2, 3
insert TeamParticipation VALUES (1,1);
insert into TeamParticipation VALUES (1,2);
insert into TeamParticipation VALUES (1,3);
#Match 2 for team 1, 2, 3
insert into TeamParticipation VALUES (2,1);
insert into TeamParticipation VALUES (2,2);
insert into TeamParticipation VALUES (2,3);

#VOLLEYBALL (beach) - F

insert into Team (CountryInitials, NoParticipants, CategoryID) VALUES ('DK', 3, 3);
insert into PersonParticipation VALUES (4,2);
insert into PersonParticipation VALUES (4,3);
insert into PersonParticipation VALUES (4,4);
insert into Team (CountryInitials, NoParticipants, CategoryID) VALUES ('FR', 3, 3);
insert into PersonParticipation VALUES (5,6);
insert into PersonParticipation VALUES (5,5);
insert into PersonParticipation VALUES (5,8);
insert into Tournament (SportID, Sex, GoldTeamID, SilverTeamID, BronzeTeamID, StartDate, EndDate) 
VALUES (7,'F',NULL,NULL,NULL,'2018-07-14 08:00:00','2018-07-14 16:00:00');

insert into `Match` (TournamentID, Sex, Winner1TeamID, Winner2TeamID, Winner3TeamID, StartDate, EndDate) 
VALUES (3,'F',NULL,NULL,NULL,'2018-07-14 08:00:00','2018-07-14 10:00:00'),
(3,'F',NULL,NULL,NULL,'2018-07-14 14:00:00','2018-07-14 16:00:00');

#Match 3 for team 4,5
insert into TeamParticipation VALUES (3,4);
insert into TeamParticipation VALUES (3,5);
#Match 4 for team 4,5
insert into TeamParticipation VALUES (4,4);
insert into TeamParticipation VALUES (4,5);

#GYMNASTICS - ARTISTIC - F

insert into Team (CountryInitials, NoParticipants, CategoryID) VALUES ('GR', 1, 2);
insert into PersonParticipation VALUES (6,13);
insert into Team (CountryInitials, NoParticipants, CategoryID) VALUES ('SE', 1, 2);
insert into PersonParticipation VALUES (7,10);
insert into Tournament (SportID, Sex, GoldTeamID, SilverTeamID, BronzeTeamID, StartDate, EndDate) 
VALUES (4,'F',NULL,NULL,NULL,'2018-07-16 14:00:00','2018-07-16 18:00:00');

insert into `Match` (TournamentID, Sex, Winner1TeamID, Winner2TeamID, Winner3TeamID, StartDate, EndDate) 
VALUES (4,'F',NULL,NULL,NULL,'2018-07-16 14:00:00','2018-07-16 18:00:00');

#Match 5 for team 6,7
insert into TeamParticipation VALUES (5,6);
insert into TeamParticipation VALUES (5,7);

#GYMNASTICS - TRAMPOLINE - M

insert into Team (CountryInitials, NoParticipants, CategoryID) VALUES ('FR', 1, 2);
insert into PersonParticipation VALUES (8,7);
insert into Team (CountryInitials, NoParticipants, CategoryID) VALUES ('DE', 1, 2);
insert into PersonParticipation VALUES (9,12);
insert into Tournament (SportID, Sex, GoldTeamID, SilverTeamID, BronzeTeamID, StartDate, EndDate) 
VALUES (6,'M',NULL,NULL,NULL,'2018-07-16 08:00:00','2018-07-16 12:00:00');

insert into `Match` (TournamentID, Sex, Winner1TeamID, Winner2TeamID, Winner3TeamID, StartDate, EndDate) 
VALUES (5,'M',NULL,NULL,NULL,'2018-07-16 08:00:00','2018-07-16 12:00:00');

#Match 6 for team 8,9
insert into TeamParticipation VALUES (6,8);
insert into TeamParticipation VALUES (6,9);

select * from Team;
select * from PersonParticipation;
select * from Tournament;
select * from TeamParticipation;
select * from `Match`;
select * from Result;

#Creation of the views male and female participants without their height and weight

CREATE VIEW Female AS SELECT Name, CountryInitials from Participant WHERE Sex = 'F';

CREATE VIEW Male AS SELECT Name, CountryInitials from Participant WHERE Sex = 'M';

select * from Female;
select * from Male;

# 9) SQL Programming : Events

#Creation of an event that tells us the number of day before the beginning of the OLYMPICS

create table Time_before_Olympics(
	TS Timestamp,
    Days_before_Olympics int,
    Message Varchar(100));
    
CREATE EVENT Time_insert
ON SCHEDULE every 1 day starts current_timestamp
Do insert Days_before_Olympics values (current_timestamp, timestampdiff(day,current_timestamp,'2018-07-14'),"Time before first match");

select * from Time_before_Olympics;

#####In real life:

# Creation of an event to update the results of the matches

create event anEvent
on schedule every 1 day starts '2018-04-14 19:10:00'
do call updat();

DELIMITER //
CREATE procedure updatmatch ()
BEGIN
declare currentTime varchar(10) default substr(current_timestamp(),1, 10);
update `match` set Winner1TeamID = (select TeamID from teamparticipation where  `match`.ID = teamparticipation.MatchID limit 1) where currentTime = substr(Date, 1, 10);
update `match` set Winner2TeamID = (select TeamID from teamparticipation where  `match`.ID = teamparticipation.MatchID and teamparticipation.TeamID <> winner1TeamID limit 1) where currentTime = substr(Date, 1, 10);
update `match` set Winner3TeamID = (select TeamID from teamparticipation where  `match`.ID = teamparticipation.MatchID and teamparticipation.TeamID <> winner1TeamID and teamparticipation.TeamID <> winner2TeamID limit 1) where currentTime = substr(Date, 1, 10);
END; //
DELIMITER ;

# Creation of an event to update the results of the tournaments

DELIMITER //
CREATE procedure updattournament ()
BEGIN
update Tournament set GoldTeamID = (select Winner1TeamID from `match` where `match`.TournamentID = Tournament.ID limit 1) where currentTime = substr(Date, 1, 10);
update Tournament set SilverTeamID = (select Winner2TeamID from `match` where `match`.TournamentID = Tournament.ID limit 1) where currentTime = substr(Date, 1, 10);
update Tournament set BronzeTeamID = (select Winner3TeamID from `match` where `match`.TournamentID = Tournament.ID limit 1) where currentTime = substr(Date, 1, 10);
END; //
DELIMITER ;

##### But in order to populate the match and tournament tables we had to create the following events:

# Creation of an event to update the results of the matches

DELIMITER //
CREATE procedure updmatch ()
BEGIN
update `match` set Winner1TeamID = (select TeamID from teamparticipation where  `match`.ID = teamparticipation.MatchID limit 1);
update `match` set Winner2TeamID = (select TeamID from teamparticipation where  `match`.ID = teamparticipation.MatchID and teamparticipation.TeamID <> winner1TeamID limit 1);
update `match` set Winner3TeamID = (select TeamID from teamparticipation where  `match`.ID = teamparticipation.MatchID and teamparticipation.TeamID <> winner1TeamID and teamparticipation.TeamID <> winner2TeamID limit 1) ;
END; //
DELIMITER ;

call updmatch ();

# Creation of an event to update the results of the tournaments

DELIMITER //
CREATE procedure updtournament ()
BEGIN
update Tournament set GoldTeamID = (select Winner1TeamID from `match` where `match`.TournamentID = Tournament.ID limit 1);
update Tournament set SilverTeamID = (select Winner2TeamID from `match` where `match`.TournamentID = Tournament.ID limit 1);
update Tournament set BronzeTeamID = (select Winner3TeamID from `match` where `match`.TournamentID = Tournament.ID limit 1);
END; //
DELIMITER ;

call updtournament ();

select * from `match`;
select * from tournament;

# 7) SQL Data Queries

#How many gold medals did Charles get ?
SELECT P.Name, SUM(NoGold) AS Number_Gold_Medals
FROM Participant AS P JOIN Result AS R JOIN PersonParticipation AS PP 
WHERE R.TeamID = PP.TeamID AND P.ID = PP.ParticipantID AND P.Name = 'Charles';

#What is the number of participants for the scandinavian countries(Denmark and Sweden) ?
Select count(p.ID) as Number_Participants, c.Name  
from Participant p join Country c where c.Initials = p.CountryInitials 
group by c.Initials 
having c.Initials in ('DK', 'SE');

#What is the ranking of countries order by decreasing total numberof medals ?
Select Name, NoGold + NoSilver + NoBronze as Number_Medals 
from Country 
group by Name 
order by Number_Medals DESC;

# 8) SQL Table Modifications

# Morten broke his leg and is therefore repladced by Nicolai from the same country
DELETE FROM Participant WHERE Name='Morten';

insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES ('Nicolai', 1995, 'DK', 'M', 180, 70.0);

# As a team is defined by its participants and the category they are involved in, 
# we should chagne the team ID for Denmark in the swimming category to indicate thatthe team has been changed
update Team set ID = 10 where ID = 1;

# Then we make Nicolai involved in that new team for Denmark in the swimming category
insert into PersonParticipation values (10, 14);

# The table TeamParticipation is automatically updated as TeamID is a foreign key REFERENCES Team(ID) ON UPDATE CASCADE
update Male set Name = 'Nicolai' where Name = 'Morten';

# 9) SQL Programming : Transaction

DELIMITER //
CREATE PROCEDURE replacePerson (in oldPerson varchar(48), newPerson varchar(48))
BEGIN
DECLARE oldAmount int default 0;
START TRANSACTION;
insert into Participant (Name, Birthday, CountryInitials, Sex, Height, Weight) VALUES (newPerson, 1996, 'DK', 'F', 185, 73.0);
SET oldAmount = (select count(*) FROM Participant WHERE `Name`=oldPerson);
DELETE FROM Participant WHERE `Name`=oldPerson;
IF (oldAmount - (select count(*) FROM Participant WHERE `Name`=oldPerson) = 0 )
THEN ROLLBACK;
ELSE COMMIT;
END IF;
END; //
DELIMITER ;
call replacePerson ('Elisa', 'Elisabeth');
select * from Participant;