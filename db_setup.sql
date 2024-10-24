DROP DATABASE IF EXISTS coursework;

CREATE DATABASE coursework;

USE coursework;

DROP TABLE IF EXISTS Department;

CREATE TABLE Department (
    Dept_ID         INT UNSIGNED NOT NULL,
    Dept_Name       VARCHAR(100) NOT NULL,
    Dept_Location   VARCHAR(100) NOT NULL,
    PRIMARY KEY (Dept_ID)
);

INSERT INTO Department (Dept_ID, Dept_Name, Dept_Location)
VALUES
    (101, 'Computer Science and Information Technology', 'IFH Lab'),
    (102, 'Engineering', 'Building D'),
    (103, 'Chemistry', 'AP Building'),
    (104, 'Biomedical and Biochemical Sciences', 'Biology Building'),
    (105, 'Humanities', 'Humanities Building');

-- This is the Course table

DROP TABLE IF EXISTS Course;

CREATE TABLE Course
(
    Crs_Code       INT UNSIGNED NOT NULL,
    Crs_Title      VARCHAR(255) NOT NULL,
    Crs_Enrollment INT UNSIGNED,
    Dept_ID        INT UNSIGNED NOT NULL,
    PRIMARY KEY (Crs_code),
    FOREIGN KEY (Dept_ID) REFERENCES Department (Dept_ID)
);


INSERT INTO Course VALUES
    (200,'BSc Computer Science', 150, 101),
    (201,'BSc Chemical Engineering', 20, 102),
    (202, 'BSc Chemistry', 100, 103),
    (203, 'MSc Biomedical Sciences', 30, 104),
    (204, 'MSc Languages', 70, 105),
    (205, 'MSc Physics', 100, 102);


-- This is the student table definition


DROP TABLE IF EXISTS Student;

CREATE TABLE Student (
    URN INT UNSIGNED NOT NULL,
    Stu_FName   VARCHAR(255) NOT NULL,
    Stu_LName   VARCHAR(255) NOT NULL,
    Stu_DOB     DATE,
    Stu_Gender ENUM('M', 'F'),
    Stu_Phone   VARCHAR(12),
    Stu_Course  INT UNSIGNED NOT NULL,
    Stu_Type    ENUM('UG', 'PG'),
    PRIMARY KEY (URN),
    FOREIGN KEY (Stu_Course) REFERENCES Course (Crs_Code)
    ON DELETE RESTRICT);


INSERT INTO Student VALUES
    (612345, 'Sara', 'Khan', '2002-06-20','F', '01483112233', 200, 'UG'),
    (612346, 'Pierre', 'Gervais', '2002-03-12','M', '01483223344', 200, 'UG'),
    (612347, 'Patrick', 'O-Hara', '2001-05-03','M', '01483334455', 201, 'UG'),
    (612348, 'Iyabo', 'Ogunsola', '2002-04-21','F', '01483445566', 201, 'UG'),
    (612349, 'Omar', 'Sharif', '2001-12-29','M', '01483778899', 202, 'UG'),
    (612350, 'Yunli', 'Guo', '2002-06-07','F', '01483123456', 203, 'PG'),
    (612351, 'Costas', 'Spiliotis', '2002-07-02','M', '01483234567', 203, 'PG'),
    (612352, 'Tom', 'Jones', '2001-10-24','M',  '01483456789', 204, 'PG'),
    (612353, 'Simon', 'Larson', '2002-08-23','M', '01483998877', 204, 'PG'),
    (612354, 'Sue', 'Smith', '2002-05-16','F', '01483776655', 205, 'PG');


DROP TABLE IF EXISTS Undergraduate;

CREATE TABLE Undergraduate (
    UG_URN  INT UNSIGNED NOT NULL,
    UG_Credits   INT NOT NULL,
    CHECK (60 <= UG_Credits <= 150),
    PRIMARY KEY (UG_URN),
    FOREIGN KEY (UG_URN) REFERENCES Student(URN)
    ON DELETE CASCADE);

INSERT INTO Undergraduate VALUES
    (612345, 120),
    (612346, 90),
    (612347, 150),
    (612348, 120),
    (612349, 120);

DROP TABLE IF EXISTS Postgraduate;

CREATE TABLE Postgraduate (
    PG_URN  INT UNSIGNED NOT NULL,
    Thesis  VARCHAR(512) NOT NULL,
    PRIMARY KEY (PG_URN),
    FOREIGN KEY (PG_URN) REFERENCES Student(URN)
    ON DELETE CASCADE);

INSERT INTO Postgraduate VALUES
    (612350, 'An evaluation of reinforcement learning algorithms used in the production of video games'),
    (612351, 'A critical analysis of network security and privacy concerns associated with Industry 4.0 investment in healthcare.'),
    (612352, 'An exploration of how artificial intelligence is changing human-computer interaction patterns in children'),
    (612353, 'A study of the impact of artificial intelligence and machine learning on software engineering practices in the education sector'),
    (612354, 'The impact of NoSQL databases on data management and analysis in smart cities');

DROP TABLE IF EXISTS Hobby;

CREATE TABLE Hobby(
    Hobby_Code      VARCHAR(3) NOT NULL,
    Hobby_Name      VARCHAR(100) NOT NULL,
    PRIMARY KEY (Hobby_Code)
);

INSERT INTO Hobby (Hobby_Code, Hobby_Name)
VALUES
    ('H01', 'Reading'),
    ('H02', 'Hiking'),
    ('H03', 'Chess'),
    ('H04', 'Taichi'),
    ('H05', 'Ballroom Dancing'),
    ('H06', 'Football'),
    ('H07', 'Tennis'),
    ('H08', 'Rugby'),
    ('H09', 'Climbing'),
    ('H10', 'Rowing');

DROP TABLE IF EXISTS Student_Hobby;

CREATE TABLE Student_Hobby(
    URN         INT UNSIGNED NOT NULL,
    Hobby_Code  VARCHAR(3) NOT NULL,
    PRIMARY KEY (URN, Hobby_Code),
    FOREIGN KEY (URN) REFERENCES Student(URN),
    FOREIGN KEY (Hobby_Code) REFERENCES Hobby(Hobby_Code)
);

INSERT INTO Student_Hobby (URN, Hobby_Code)
VALUES
    (612345, 'H01'),
    (612350, 'H02'),
    (612346, 'H03'),
    (612351, 'H04'),
    (612347, 'H05'),
    (612353, 'H06'),
    (612348, 'H07'),
    (612352, 'H08'),
    (612354, 'H09'),
    (612349, 'H10');

DROP TABLE IF EXISTS Lecturer;

CREATE TABLE Lecturer(
    Lec_ID              VARCHAR(2) NOT NULL,
    Lec_FName           VARCHAR(300) NOT NULL,
    Lec_LName           VARCHAR(300) NOT NULL,
    Lec_Email           VARCHAR(300) NOT NULL,
    Office_Location     VARCHAR (300) NOT NULL,
    Crs_Code            INT UNSIGNED NOT NULL,
    PRIMARY KEY(Lec_ID),
    FOREIGN KEY (Crs_Code) REFERENCES Course(Crs_Code)
);

INSERT INTO Lecturer (Lec_ID,Lec_FName, Lec_LName, Lec_Email, Office_Location, Crs_Code)
VALUES
    ('L1', 'John', 'Doe', 'johndoe@gmail.com', 'IFH Lab', 200),
    ('L2', 'Jane', 'Doe', 'janedoe@gmail.com', 'Building D', 201),
    ('L3', 'Isabelle', 'Conklin', 'isabelleconklin@gmail.com', 'AP Building', 202),
    ('L4', 'Conrad', 'Fisher', 'conradfisher@gmail.com', 'Biology Building', 203),
    ('L5', 'Jeremiah', 'Fisher', 'jeremiahfisher@gmail.com', 'Humanities Building', 204);

DROP TABLE IF EXISTS Certifications;

CREATE TABLE Certifications (
    Cert_ID         VARCHAR(2) NOT NULL,
    Cert_Name       VARCHAR(255) NOT NULL,
    PRIMARY KEY (Cert_ID)
);

INSERT INTO Certifications (Cert_ID, Cert_Name)
VALUES
    ('C1', 'BSc'),
    ('C2', 'MSc'),
    ('C3', 'PHD'),
    ('C4', 'BA'),
    ('C5', 'MA'),
    ('C6', 'MBA');

DROP TABLE IF EXISTS Lecturer_Certifications;

CREATE TABLE Lecturer_Certifications (
    Lec_ID      VARCHAR(2) NOT NULL,
    Cert_ID     VARCHAR(2) NOT NULL,
    PRIMARY KEY (Lec_ID, Cert_ID),
    FOREIGN KEY (Lec_ID) REFERENCES Lecturer(Lec_ID),
    FOREIGN KEY (Cert_ID) REFERENCES Certifications(Cert_ID)
);

INSERT INTO Lecturer_Certifications (Lec_ID, Cert_ID)
VALUES
    ('L1', 'C1'),
    ('L1', 'C2'),
    ('L1', 'C3'),
    ('L2', 'C1'),
    ('L2', 'C2'),
    ('L3', 'C1'),
    ('L4', 'C4'),
    ('L4', 'C5');

DROP TABLE IF EXISTS Club;
CREATE TABLE Club(
    Club_ID             INT UNSIGNED NOT NULL,
    Club_Name           VARCHAR(300) NOT NULL,
    Club_Description    TEXT NOT NULL,
    Club_Website        VARCHAR(300) NOT NULL,
    Club_Leader         INT UNSIGNED NOT NULL,
    FOREIGN KEY (Club_Leader) REFERENCES Student(URN) ON DELETE RESTRICT,
    PRIMARY KEY (Club_ID),
    Club_Type ENUM('UG_Club', 'PG_Club', 'Both')
);

INSERT INTO Club (Club_ID, Club_Name, Club_Description, Club_Website, Club_Leader, Club_Type)
VALUES
    (301, 'Book Club', 'Reading club for bookworms! Every Monday and Wednesday at 12pm in the Library.', 'https://bookclub.example.com', 612345, 'Both'),
    (302, 'Walking Club', 'Walk to town but we take the Cathedral Route! Join us everyday to destress at 8am. Postgraduate Students only.', 'https://walkingclub.example.com', 612350, 'PG_Club'),
    (303, 'Chess Club', 'Learn to play chess with friends every Thursday at 6pm in the AP Building. Undergraduate Students only.', 'https://chessclub.example.com', 612346, 'UG_Club'),
    (304, 'Martial Arts Club', 'A community dedicated to practicing various types of Martial Arts. Every Thursday(5pm-8pm) at Surrey Sports Park.', 'https://maclub.example.com', 612351, 'Both'),
    (305, 'Dance Club', 'Explore various dance styles at the Dance Studio in Surrey Sports Park every Saturday from 10am to 12pm.', 'https://danceclub.example.com', 612347, 'Both'),
    (306, 'Football Club', 'Join us to enjoy and compete in the sport of Football at 8am on Friday, Surrey Sports Park. Postgraduate Students Only.', 'https://footballclub.example.com',612354, 'PG_Club'),
    (307, 'Tennis Club', 'Join us to play and learn the sport of tennis, Surrey Sports Park at 8am on Friday (beginner friendly). Undergraduate Students Only.', 'https://tennisclub.example.com', 612348, 'UG_Club'),
    (308, 'Rugby Club', 'Join us to play,learn and compete at the sport of rugby, Surrey Sports Park at 8am on Friday.', 'https://rugbyclub.example.com', 612352, 'Both'),
    (309, 'Rock Climbing Club', 'Passionate about scaling heights and exploring the  thrill of rock climbing? Join us at Surrey Sports Park every Wednesday at 4pm. Postgraduate Students Only.', 'https://rockclimbclub.example.com', 612354, 'PG_Club'),
    (310, 'Rowing Club', 'A dedicated group passionate about rowing, promoting teamwork and water fitness. Guildford City Centre Rowing Centre, 10am-1pm every Saturday', 'https://rowingclub.example.com', 612349, 'Both');

DROP TABLE IF EXISTS Postgraduate_Club;

CREATE TABLE Postgraduate_Club(
    Club_ID         INT UNSIGNED NOT NULL,
    FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID),
    PRIMARY KEY(Club_ID)
);

INSERT INTO Postgraduate_Club(Club_ID)
VALUES
    (301),
    (302),
    (304),
    (305),
    (306),
    (308),
    (309),
    (310);

DROP TABLE IF EXISTS Undergraduate_Club;

CREATE TABLE Undergraduate_Club(
    Club_ID         INT Unsigned NOT NULL,
    FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID),
    PRIMARY KEY (Club_ID)
);

INSERT INTO Undergraduate_Club(Club_ID)
VALUES
    (301),
    (303),
    (304),
    (305),
    (307),
    (308),
    (310);

DROP TABLE IF EXISTS Student_Club;

CREATE TABLE Student_Club(
    URN         INT UNSIGNED NOT NULL,
    Club_ID     INT UNSIGNED NOT NULL,
    PRIMARY KEY (URN, Club_ID),
    FOREIGN KEY (URN) REFERENCES Student(URN),
    FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID)
);

INSERT INTO Student_Club(URN, Club_ID)
VALUES
    (612345, 301),
    (612350, 302),
    (612346, 303),
    (612351, 304),
    (612347, 305),
    (612353, 306),
    (612348, 307),
    (612352, 308),
    (612354, 309),
    (612349, 310);

DROP TABLE IF EXISTS Club_Hobby;

CREATE TABLE Club_Hobby(
    Club_ID         INT UNSIGNED NOT NULL,
    Hobby_Code      VARCHAR(3) NOT NULL,
    PRIMARY KEY (Club_ID, Hobby_Code),
    FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID),
    FOREIGN KEY (Hobby_Code) REFERENCES Hobby(Hobby_Code)
);

INSERT INTO Club_Hobby(Club_ID, Hobby_Code)
VALUES
    (301, 'H01'),
    (302, 'H02'),
    (303, 'H03'),
    (304, 'H04'),
    (305, 'H05'),
    (306, 'H06'),
    (307, 'H07'),
    (308, 'H08'),
    (309, 'H09'),
    (310, 'H10');

DROP TABLE IF EXISTS Student_Club_Hobby;

CREATE TABLE Student_Club_Hobby(
    URN               INT UNSIGNED NOT NULL,
    Club_ID           INT UNSIGNED NOT NULL,
    Hobby_Code        VARCHAR(3)   NOT NULL,
    Level_of_Interest VARCHAR(7)   NOT NULL,
PRIMARY KEY (URN, Club_ID, Hobby_Code),
FOREIGN KEY (URN) REFERENCES Student(URN),
FOREIGN KEY (Club_ID) REFERENCES Club(Club_ID),
FOREIGN KEY (Hobby_Code) REFERENCES Hobby(Hobby_Code)
);

INSERT INTO Student_Club_Hobby(URN, Club_ID, Hobby_Code, Level_of_Interest)
VALUES
    (612345, 301, 'H01', 'High'),
    (612350, 302, 'H02', 'Medium'),
    (612346, 303, 'H03', 'Low'),
    (612351, 304, 'H04', 'Low'),
    (612347, 305, 'H05', 'Medium'),
    (612353, 306, 'H06', 'High'),
    (612348, 307, 'H07', 'Medium'),
    (612352, 308, 'H08', 'High'),
    (612354, 309, 'H09', 'Low'),
    (612349, 310, 'H10', 'Medium');


