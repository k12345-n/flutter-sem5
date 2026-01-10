<?php
// Set headers to allow cross-origin requests from Flutter
header("Access-Control-Allow-Origin: *"); 

// Only process POST requests coming from the app
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // 1. Validation: Ensure both email and password are provided
    if (!isset($_POST['email']) || !isset($_POST['password'])) {
        $response = array('status' => 'failed', 'message' => 'Bad Request');
        sendJsonResponse($response);
        exit();
    }
    
    // 2. Capture and hash the password to match database storage
    $email = $_POST['email'];
    $password = $_POST['password'];
    $hashedpassword = sha1($password);

    // 3. Connect to the database
    include 'dbconnect.php';
    
    // 4. Execute the login query
    $sqllogin = "SELECT * FROM `tbl_user` WHERE `email` = '$email' AND `password` = '$hashedpassword'";
    $result = $conn->query($sqllogin);
    
    // 5. Check if a user matches the credentials
    if ($result->num_rows > 0) {
        $userdata = array();
        while ($row = $result->fetch_assoc()) {
            $row['phone'] = $row['phone'] ?? "";
            $row['profile_image'] = $row['profile_image'] ?? "default_user.png";
            $userdata[] = $row;
        }
        // Successful login response
        $response = array('status' => 'success', 'message' => 'Login successful', 'data' => $userdata);
        sendJsonResponse($response);
    } else {
        // Handle incorrect credentials
        $response = array('status' => 'failed', 'message' => 'Invalid email or password');
        sendJsonResponse($response);
    }

} else {
    // Block direct browser access (GET requests)
    $response = array('status' => 'failed', 'message' => 'Method Not Allowed');
    sendJsonResponse($response);
    exit();
}

/**
 * Standard function to convert a PHP array into a JSON response for Flutter
 */
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>