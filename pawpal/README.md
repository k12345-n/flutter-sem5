Title: Pawpal

Setup:

1st step:
go back to the file before pawpal which is flutter-sem5. Then, press the green button with label code download zip file.

2nd step: 
Open zip file. Then ignore book_estimator_time, use pawpal file.
Or copy whole pawpal file to your prefer location. 

3rd step: setup XAMPP
Inside pawpal file, navigate to server/pawpal/api
then find the file SQL table 
copy whole SQL code and paste to phpmyadmin SQL to create the pawpal_db

4th step: 
Inside pawpal file, navigate to server/pawpal/api
Copy all php file
at XAMPP navigate to htdocs, create file pawpal 
inside papwal create file api
paste all php file to the XAMPP/htdocs/pawpal/api

5th step: 
Inside XAMPP/htdocs/pawpal
crete a file assets then inside create another file pets
The whole path is like XAMPP/htdocs/pawpal/assets/pets

API explanation:
dbconnect.php: Connects to the database named pawpal_db.

get_my_pets.php: retrieve a list of pets based on the user id.

login.php: verify user credentials against the database.

register.php: Insert a new user record into the database

submit_pet: Inserts a new pet listing and saves its image to the database.

Sample JSON response:
<img width="833" height="66" alt="Screenshot 2025-12-06 at 1 57 11 PM" src="https://github.com/user-attachments/assets/24df19c8-9e85-49e8-bb42-8d3990e95f33" />
