const express = require('express');
const mysql = require('mysql');
const util = require('util');
const ejs = require('ejs');
const bodyParser = require('body-parser');
const {request, application} = require("express");

const PORT = 8000;
const DB_HOST = 'localhost';
const DB_USER = 'root';
const DB_PASSWORD = '';
const DB_NAME = 'coursework';
const DB_PORT = 3306;

var connection = mysql.createConnection({
    host: DB_HOST,
    user: DB_USER,
    password: DB_PASSWORD,
    database: DB_NAME,
    port: DB_PORT
});

connection.query = util.promisify(connection.query).bind(connection);

connection.connect((err) => {
    if (err) {
        console.error(`could not connect to database 
        ${err}
        `);
        return;
    }
    console.log('boom, you are connected');
})

const app = express();

app.set('view engine', 'ejs');
app.use(express.static('public'));
app.use(bodyParser.urlencoded({extended: false}));
app.get('/', async(req, res) => {
    const studentCount = await connection.query('SELECT COUNT(*) AS count FROM Student');
    const academicCount = await connection.query('SELECT COUNT(*) AS count FROM Lecturer');
    const courseCount = await connection.query('SELECT COUNT(*) AS count FROM Course');
    const departmentCount = await connection.query('SELECT COUNT(*) AS count FROM Department');
    const hobbyCount = await connection.query('SELECT COUNT(*) AS count FROM Hobby');


    console.log(studentCount[0].count);
    res.render('index', {
        studentCount: studentCount[0].count,
        academicCount: academicCount[0].count,
        departmentCount: departmentCount[0].count,
        courseCount: courseCount[0].count,
        hobbyCount: hobbyCount[0].count
    });
});

app.get('/students', async (req, res) => {

    const students = await connection.query('SELECT * from Student INNER JOIN Course on student.Stu_Course = course.Crs_Code')
    console.log(students);
    res.render('students', {students: students});
});

app.get('/students/edit/:id', async (req, res) => {
   const courses = await connection.query('SELECT Crs_Code, Crs_Title FROM Course');
    const student = await connection.query('SELECT * from Student INNER JOIN Course on student.Stu_Course = course.Crs_Code WHERE URN = ?',
        [req.params.id]);
    res.render('student_edit', {student: student[0], courses: courses, message: ''});
});

app.post('/students/edit/:id', async (req,res) =>{

    const updatedStudent = req.body;
    if (isNaN(updatedStudent.Stu_Phone || updatedStudent.Stu_Phone.length != 11)){
        const courses = await connection.query('SELECT Crs_Code, Crs_Title FROM Course');
        const student = await connection.query('SELECT * from Student INNER JOIN Course on student.Stu_Course = course.Crs_Code WHERE URN = ?',
            [req.params.id]);
        res.render('student_edit', {student: student[0], courses: courses, message: 'student not updated, invalid number' });
        return;
    }

    await connection.query('UPDATE STUDENT SET ? WHERE URN = ?', [updatedStudent, req.params.id]);
    const courses = await connection.query('SELECT Crs_Code, Crs_Title FROM Course');
    const student = await connection.query('SELECT * from Student INNER JOIN Course on student.Stu_Course = course.Crs_Code WHERE URN = ?',
        [req.params.id]);
    res.render('student_edit', {student: student[0], courses: courses, message: 'student updated' });
})

app.get('/students/view/:id', async (req, res) =>{

    const student = await connection.query('SELECT * from Student INNER JOIN Course on student.Stu_Course = course.Crs_Code WHERE URN = ?',
        [req.params.id]);
    res.render('student_view', {student: student[0]});
})
app.get('/academics', async (req, res) => {

    const academics = await connection.query('SELECT * from Lecturer INNER JOIN Course on lecturer.Crs_Code = course.Crs_Code')
    console.log(academics);
    res.render('academics', {academics: academics});
});
app.get('/academics/view/:id', async (req, res) =>{

    const lecturer = await connection.query('SELECT * from Lecturer INNER JOIN Course on lecturer.Crs_Code = course.Crs_Code WHERE Lec_ID = ?',
        [req.params.id]);
    res.render('academic_view', {lecturer: lecturer[0]});
})
app.get('/academics/edit/:id', async (req, res) => {
    const courses = await connection.query('SELECT Crs_Code, Crs_Title FROM Course');
     const lecturer = await connection.query('SELECT * from Lecturer INNER JOIN Course on lecturer.Crs_Code = course.Crs_Code WHERE Lec_ID = ?',
         [req.params.id]);
     res.render('academic_edit', {lecturer: lecturer[0], courses: courses, message: ''});
 });
app.post('/academics/edit/:id', async (req,res) =>{

    const updatedLecturer = req.body;
    const emailPattern = /^[a-zA-Z0-9]+@[a-zA-Z]+\.com$/;
    if (!emailPattern.test(updatedLecturer.Lec_Email)){
        const courses = await connection.query('SELECT Crs_Code, Crs_Title FROM Course');
        const lecturer = await connection.query('SELECT * from Lecturer INNER JOIN Course on lecturer.Crs_Code = course.Crs_Code WHERE Lec_ID = ?',
            [req.params.id]);
        res.render('academic_edit', {lecturer: lecturer[0], courses: courses, message: 'lecturer not updated, invalid email format' });
        return;
    }

    await connection.query('UPDATE LECTURER SET ? WHERE LEC_ID = ?', [updatedLecturer, req.params.id]);
    const courses = await connection.query('SELECT Crs_Code, Crs_Title FROM Course');
    const lecturer = await connection.query('SELECT * from Lecturer INNER JOIN Course on lecturer.Crs_Code = course.Crs_Code WHERE Lec_ID = ?',
        [req.params.id]);
    res.render('academic_edit', {lecturer: lecturer[0], courses: courses, message: 'lecturer updated' });
})

app.get('/clubs', async (req, res) => {
    try {
        const clubs = await connection.query('SELECT * FROM Club_Hobby');
        const students = await connection.query('SELECT * FROM Student');
        const hobbies = await connection.query(`
SELECT 
    student.URN,
    student.Stu_FName,
    student.Stu_LName,
    hobby.Hobby_Code,
    hobby.Hobby_Name,
    club.Club_ID,
    club.Club_Name
FROM 
    Student_Hobby
INNER JOIN 
    Hobby ON Student_Hobby.Hobby_Code = Hobby.Hobby_Code
INNER JOIN 
    Club_Hobby ON Student_Hobby.Hobby_Code = Club_Hobby.Hobby_Code
INNER JOIN 
    Club ON Club_Hobby.Club_ID = Club.Club_ID
INNER JOIN 
    Student ON Student_Hobby.URN = Student.URN;
`);

        res.render('hobbies', { hobbies });
    } catch (error) {
        console.error(error);
        res.status(500).send(error);
    }
});
async function fetchHobbyDetailsFromDB(studentURN) {
    try {
        const hobbyDetails = await connection.query(`
            SELECT 
                student.URN,
                student.Stu_FName,
                student.Stu_LName,
                hobby.Hobby_Code,
                hobby.Hobby_Name,
                club.Club_ID,
                club.Club_Name
            FROM 
                Student_Hobby
            INNER JOIN 
                Hobby ON Student_Hobby.Hobby_Code = Hobby.Hobby_Code
            INNER JOIN 
                Club_Hobby ON Student_Hobby.Hobby_Code = Club_Hobby.Hobby_Code
            INNER JOIN 
                Club ON Club_Hobby.Club_ID = Club.Club_ID
            INNER JOIN 
                Student ON Student_Hobby.URN = Student.URN
            WHERE 
                student.URN = ?;
        `, [studentURN]);

        return hobbyDetails[0];
    } catch (error) {
        throw error;
    }
}

app.get('/clubs/view/:id', async (req, res) => {
    try {
        const studentURN = req.params.id;
        const hobbyDetails = await fetchHobbyDetailsFromDB(studentURN);
        res.render('hobbies_view', { hobbyDetails });
    } catch (error) {
        console.error(error);
        res.status(500).send('Internal Server Error');
    }
});
app.get('/clubs/edit/:id', async (req, res) => {
    try {

        const hobby = await connection.query('SELECT * FROM Hobby');
        const clubs = await connection.query('SELECT * FROM Club_Hobby');
        const student = await connection.query('SELECT * FROM Student INNER JOIN Student_Hobby ON Student.URN= Student_Hobby.URN WHERE Student.URN = ?',
            [req.params.id]);
        res.render('hobbies_edit', { student: student[0],clubs: clubs[0], hobbies: hobby, message: '' });
    } catch (err) {
        console.error('Error fetching data:', err.message);
        res.status(500).send(`Error fetching data: ${err.message}`);
    }
});




app.post('/clubs/edit/:id', async (req, res) => {
    try {
        const { Hobby_Code, Club_ID } = req.body;
        const studentURN = req.params.id;
        const hobby = await connection.query('SELECT * FROM Hobby');
        const clubs = await connection.query('SELECT * FROM Club_Hobby');
        const student = await connection.query('SELECT * FROM Student INNER JOIN Student_Hobby ON Student.URN= Student_Hobby.URN WHERE Student.URN = ?',
            [req.params.id]);
        await connection.query('UPDATE Student_Hobby SET Hobby_Code = ? WHERE URN = ?', [Hobby_Code, studentURN]);

        await connection.query('UPDATE Club_Hobby SET Hobby_Code = ? WHERE Club_ID = ?', [Hobby_Code, Club_ID]);

        const hobbyDetails = await fetchHobbyDetailsFromDB(studentURN);

        res.render('hobbies_edit', { student: student[0], hobbies: hobby, clubs: clubs[0],  hobbyDetails, message: 'Student\'s hobby and club have been updated' });
    } catch (error) {
        console.error(error);
        res.status(500).send('Internal Server Error');
    }
});

app.get('/departments', async (req, res) => {

    const departments = await connection.query('SELECT * FROM Department');
    console.log(departments);
    res.render('departments', {departments: departments});
});

app.get('/departments/view/:id', async (req, res) => {
    const department = await connection.query(
        'SELECT * FROM DEPARTMENT WHERE Dept_ID = ?',
        [req.params.id]
    );

    const courseInfo = await connection.query(
        'SELECT Crs_Code, Crs_Title FROM Course WHERE Dept_ID = ?',
        [req.params.id]
    );

    res.render('department_view', {
        department: department[0],
        courseInfo: courseInfo
    });
});
app.get('/departments/edit/:id', async (req, res) => {
    try {
        const department = await connection.query('SELECT * FROM Department WHERE Dept_ID = ?', [req.params.id]);

        const departments = await connection.query('SELECT DISTINCT Dept_Location FROM Department');

        res.render('department_edit', { department: department[0], departments: departments, message: '' });
    } catch (error) {
        console.error(error);
        res.status(500).send('Internal Server Error');
    }
});


app.post('/departments/edit/:id', async (req, res) => {
    const departmentId = req.params.id;
    const updatedLocation = req.body.Dept_Location;

    try {
        await connection.query('UPDATE Department SET Dept_Location = ? WHERE Dept_ID = ?', [updatedLocation, departmentId]);

        const departments = await connection.query('SELECT DISTINCT Dept_Location FROM Department');

        const department = await connection.query('SELECT * FROM Department WHERE Dept_ID = ?', [departmentId]);

        res.render('department_edit', {
            department: department[0],
            departments: departments,
            message: 'Department location updated successfully!'
        });
    } catch (error) {
        console.error('Error updating department location:', error);

        const departments = await connection.query('SELECT DISTINCT Dept_Location FROM Department');

        const department = await connection.query('SELECT * FROM Department WHERE Dept_ID = ?', [departmentId]);

        res.render('department_edit', {
            department: department[0],
            departments: departments,
            message: 'Error updating department location!'
        });
    }
});

app.get('/courses', async (req, res) => {

    const courses = await connection.query('SELECT * from Course INNER JOIN Department on course.Dept_ID = department.Dept_ID')
    console.log(courses);
    res.render('courses', {courses: courses});
});

app.get('/courses/view/:id', async (req, res) =>{

    const course = await connection.query('SELECT * from Course INNER JOIN Department on course.Dept_ID = department.Dept_ID WHERE Crs_Code = ?',
        [req.params.id]);
    res.render('course_view', {course: course[0]});
})

app.get('/courses/edit/:id', async (req, res) => {
    const course = await connection.query('SELECT * from Course INNER JOIN Department on course.Dept_ID = department.Dept_ID WHERE Crs_Code = ?',
        [req.params.id]);
    const departments = await connection.query('SELECT Dept_ID, Dept_Name FROM Department');
    res.render('course_edit', {course: course[0], departments: departments, message: ''});
});


app.post('/courses/edit/:id', async (req, res) => {
    const updatedCourse = req.body;

    try {
        const department = await connection.query('SELECT Dept_ID FROM Department WHERE Dept_Name = ?', [updatedCourse.Dept_Name]);

        if (department.length === 0) {
            return res.status(404).send('Department not found');
        }

        const departmentID = department[0].Dept_ID;

        await connection.query('UPDATE COURSE SET Dept_ID = ? WHERE Crs_Code = ?', [departmentID, req.params.id]);

        const course = await connection.query('SELECT * FROM Course WHERE Crs_Code = ?', [req.params.id]);
        const departments = await connection.query('SELECT Dept_ID, Dept_Name FROM Department');

        res.render('course_edit', {
            course: course[0],
            departments: departments,
            message: 'Course updated successfully!'
        });
    } catch (error) {
        console.error('Error updating course:', error);

        const departments = await connection.query('SELECT Dept_ID, Dept_Name FROM Department');

        res.render('course_edit', {
            course: {},
            departments: departments,
            message: 'Error updating course!'
        });
    }
});



app.listen(PORT, () => {
    console.log(`application listening on http://localhost:${PORT}`);
});

