<<<<<<< Updated upstream
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
=======
🛠️ Project Setup
Prerequisites:

Flutter SDK: 3.10.0+
PHP: 7.4+ (Hosted on cPanel)
Database: MySQL

Installation
1. Clone the Repo:
git clone https://github.com/k12345-n/flutter-sem5.git

or download the zip file

2. Ensure the baseUrl points to your cPanel directory:
Open lib/my_config.dart.

class MyConfig {
  static const String baseUrl = "http://canorcannot.com/Ken";
}

3. Install Dependencies:
run this at vscode terminal:
flutter pub get

🚀 Features
1. User Authentication & Profile
Secure Access: Registration and login with password hashing (SHA1) on the server.
Remember Me: Local session persistence using SharedPreferences.
Dynamic Profile: Users can update their name, phone number, and profile picture.

2. Pet Management
Multi-Image Submission: Upload up to 3 images per pet with built-in cropping functionality.
Smart Discovery: Search for pets by name or filter by type (Dogs, Cats, Rabbits).
Location Tagging: Integrates Google Maps/Geolocator to tag the pet's current location.

3. Community Interaction
Adoption Requests: Users can submit a request to adopt with a personalized motivation message.
Flexible Donations: Supports "Money", "Food", and "Medical" donation types to support pet rescuers.
History Tracking: A dedicated dashboard for users to view their past donation contributions.

🐾 PawPal Backend API
This repository contains the PHP backend for the PawPal mobile application, providing a secure bridge between the Flutter frontend and the MySQL database. It handles user lifecycles, pet adoption workflows, and payment processing.

📡 API Usage 
User & Profile Management:
1. User Registration (register_user.php | POST): Creates a new account using name, email, password, and phone. It automatically hashes passwords using SHA1 and handles Base64 profile image uploads.
2. User Login (login_user.php | POST): Validates email and password. On success, it returns a JSON object containing the user's full profile data for local app storage.
3. Profile Update (update_profile.php | POST): Updates name and phone for an existing user_id. If a new image is provided, the script generates a timestamped filename to prevent image caching issues in the app.

Pet Inventory:
1. Submit Pet (submit_pet.php | POST): Registers a pet for adoption. It accepts location coordinates (lat/lng) and up to 3 images passed as a single string separated by |||. Images are stored in the /assets/pets/ folder.
2. Fetch Pets (get_my_pets.php | GET): Retrieves a paginated list (10 results per page). Supports filtering by pet type (e.g., Cat, Dog) and keyword searching through names and descriptions.

Adoptions & Donations:
1. Adoption Request (insert_adoption.php | POST): Submits a user's motivation message for a specific pet_id. Requests default to a Pending status.
2. Physical Donations (insert_donation.php | POST): Records non-monetary gifts like food or medicine. These are logged immediately as completed since they do not require third-party verification.
3. Donation History (load_donations.php | GET): Provides a full list of all contributions (money and items) for a specific user_id, sorted by the most recent date.

Billplz Payment Integration:
1. Initiate Payment (billplz_payment.php | GET): The primary entry point for monetary donations. It sends data to the Billplz Sandbox API and redirects the Flutter WebView to the bank selection portal.
2. Payment Verification (billplz_payment_update.php | GET): The callback script. It verifies the X-Signature to prevent fraud, logs the successful payment into tbl_donations, and renders a clean HTML receipt for the user.

📥 Response Format
The API follows a consistent JSON structure to simplify error handling in Flutter:
1. Success: Returns {"status": "success", "data": ...}.
2. Failure: Returns {"status": "failed", "message": "Reason for error"}.
3. Note: All image uploads expect Base64 encoded strings. Ensure your Flutter app strips the data:image/png;base64, prefix before sending if necessary.
>>>>>>> Stashed changes
