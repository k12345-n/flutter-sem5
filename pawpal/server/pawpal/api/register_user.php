<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(array('error' => 'Method Not Allowed'));
    exit();
}

if (!isset($_POST['email']) || !isset($_POST['password']) || !isset($_POST['name']) || !isset($_POST['phone'])) {
    http_response_code(400);
    echo json_encode(array('error' => 'Bad Request'));
    exit();
}

$email = $_POST['email'];
$name = addslashes($_POST['name']);
$phone = $_POST['phone'];
$password = $_POST['password'];
$hashedpassword = sha1($password);

// Check if email already exists
$sqlcheckmail = "SELECT * FROM `tbl_user` WHERE `email` = '$email'";
$result = $conn->query($sqlcheckmail);

if ($result->num_rows > 0) {
    $response = array('status' => 'failed', 'message' => 'Email already registered');
    sendJsonResponse($response);
    exit();
}

// Insert user without image first
$sqlregister = "INSERT INTO `tbl_user`(`email`, `name`, `phone`, `password`) 
                VALUES ('$email','$name','$phone', '$hashedpassword')";

try {
    if ($conn->query($sqlregister) === TRUE) {
	    $last_user_id = $conn->insert_id; 
	    
	    $profileImageName = 'default_user.png'; 
	    
	    if (isset($_POST['image']) && !empty($_POST['image'])) {
	        $encodedimage = base64_decode($_POST['image']);
	        
	        $profileImageName = "user_" . $last_user_id . ".png"; 
	        
	        $path = "../assets/profile/" . $profileImageName; 
	        
	        if (file_put_contents($path, $encodedimage)) {
	            $sqlupdateimage = "UPDATE `tbl_user` SET `profile_image` = '$profileImageName' WHERE `user_id` = '$last_user_id'";
	            $conn->query($sqlupdateimage);
	        } else {
	            error_log("Failed to save profile image for user $last_user_id");
	        }
	    }
	    
	    $response = array(
	        'status' => 'success', 
	        'message' => 'User registered successfully',
	        'user_id' => $last_user_id,
	        'profile_image' => $profileImageName
	    );
	    sendJsonResponse($response);
	} else {
        $response = array('status' => 'failed', 'message' => 'User registration failed: ' . $conn->error);
        sendJsonResponse($response);
    }
} catch(Exception $e) {
    $response = array('status' => 'failed', 'message' => $e->getMessage());
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>