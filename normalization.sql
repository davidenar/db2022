use iths;

DROP TABLE IF EXISTS UNF;

CREATE TABLE `UNF` (
    `Id` DECIMAL(38, 0) NOT NULL,
    `Name` VARCHAR(26) NOT NULL,
    `Grade` VARCHAR(11) NOT NULL,
    `Hobbies` VARCHAR(25),
    `City` VARCHAR(10) NOT NULL,
    `School` VARCHAR(30) NOT NULL,
    `HomePhone` VARCHAR(15),
    `JobPhone` VARCHAR(15),
    `MobilePhone1` VARCHAR(15),
    `MobilePhone2` VARCHAR(15)
)  ENGINE=INNODB;

LOAD DATA INFILE '/var/lib/mysql-files/denormalized-data.csv'
INTO TABLE UNF
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DROP TABLE IF EXISTS Student;

CREATE TABLE Student (
	StudentId int not null,
	FirstName VARCHAR(255) NOT NULL,
        LastName VARCHAR(255) NOT NULL,
        CONSTRAINT PRIMARY KEY (StudentId)
        ) engine=INNODB;

INSERT INTO Student (StudentID, FirstName, LastName)
SELECT DISTINCT Id, SUBSTRING_INDEX(Name, ' ', 1), SUBSTRING_INDEX(Name, ' ', -1)
FROM UNF;

DROP TABLE IF EXISTS School;
CREATE TABLE School AS SELECT DISTINCT 0 As SchoolId, School As Name, City FROM UNF;

SET @id = 0;
UPDATE School SET SchoolId =  (SELECT @id := @id + 1);

ALTER TABLE School ADD PRIMARY KEY(SchoolId);

DROP TABLE IF EXISTS StudentSchool;
CREATE TABLE StudentSchool AS SELECT DISTINCT UNF.Id AS StudentId, School.SchoolId
FROM UNF INNER JOIN School ON UNF.School = School.Name;
ALTER TABLE StudentSchool MODIFY COLUMN StudentId INT;
ALTER TABLE StudentSchool MODIFY COLUMN SchoolId INT;
ALTER TABLE StudentSchool ADD PRIMARY KEY(StudentId, SchoolId);

DROP TABLE IF EXISTS Phone;
CREATE TABLE Phone (
    PhoneId INT NOT NULL AUTO_INCREMENT,
    StudentId INT NOT NULL,
    Type VARCHAR(32),
    Number VARCHAR(32) NOT NULL,
    CONSTRAINT PRIMARY KEY(PhoneId)
);

INSERT INTO Phone(StudentId, Type, Number)
SELECT ID As StudentId, "Home" AS Type, HomePhone as Number FROM UNF
WHERE HomePhone IS NOT NULL AND HomePhone != ''
UNION SELECT ID As StudentId, "Job" AS Type, JobPhone as Number FROM UNF
WHERE JobPhone IS NOT NULL AND JobPhone != ''
UNION SELECT ID As StudentId, "Mobile" AS Type, MobilePhone1 as Number FROM UNF
WHERE MobilePhone1 IS NOT NULL AND MobilePhone1 != ''
UNION SELECT ID As StudentId, "Mobile" AS Type, MobilePhone2 as Number FROM UNF
WHERE MobilePhone2 IS NOT NULL AND MobilePhone2 != '';

DROP VIEW IF EXISTS HobbyTemp;

CREATE VIEW HobbyTemp AS SELECT Id AS StudentId, SUBSTRING_INDEX(Hobbies,', ',1) AS Hobby FROM UNF
UNION SELECT Id AS StudentId, SUBSTRING_INDEX(SUBSTRING_INDEX(Hobbies,', ',-2),', ',1) AS Hobby FROM UNF
UNION SELECT Id AS StudentId, SUBSTRING_INDEX(Hobbies,', ',-1) AS Hobby FROM UNF;

DROP TABLE IF EXISTS Hobby;

CREATE TABLE Hobby(
	HobbyId INT NOT NULL auto_increment,
	HobbyType VARCHAR(40),
	CONSTRAINT PRIMARY KEY(HobbyId))
ENGINE=INNODB;

INSERT INTO Hobby (HobbyType) SELECT DISTINCT Hobby FROM HobbyTemp;

DROP TABLE IF EXISTS StudentHobby;

CREATE TABLE StudentHobby AS SELECT StudentId, HobbyId FROM HobbyTemp JOIN Hobby ON HobbyTemp.Hobby = Hobby.HobbyType;

ALTER TABLE StudentHobby MODIFY COLUMN StudentId INT;
ALTER TABLE StudentHobby MODIFY COLUMN HobbyId INT;
ALTER TABLE StudentHobby ADD PRIMARY KEY (StudentId, HobbyId);

DROP TABLE IF EXISTS Grade;

CREATE TABLE Grade(
	GradeId INT NOT NULL auto_increment,
	GradeDescription VARCHAR(50) NOT NULL,
	CONSTRAINT PRIMARY KEY (GradeId))
ENGINE=INNODB;

INSERT INTO Grade (GradeDescription) SELECT DISTINCT Grade from UNF;

DROP TABLE IF EXISTS StudentGrade;

CREATE TABLE StudentGrade AS SELECT DISTINCT Id AS StudentId, GradeId FROM UNF JOIN Grade ON UNF.Grade = Grade.GradeDescription;

ALTER TABLE StudentGrade MODIFY COLUMN StudentId INT;
ALTER TABLE StudentGrade MODIFY COLUMN GradeId INT;
ALTER TABLE StudentGrade ADD PRIMARY KEY (StudentId, GradeId);
