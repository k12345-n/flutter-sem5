<?php
// Headers to ensure the Flutter app can talk to this PHP script securely
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

// This script only accepts POST requests (used for submitting form data)
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Collect the data sent from the Flutter controllers
    $user_id = $_POST['user_id'];
    $name = addslashes($_POST['name']); // Escape special characters to prevent SQL injection or crashes
    $phone = $_POST['phone'];
    $image = isset($_POST['image']) ? $_POST['image'] : ""; 

    // Step 1: Update the user's basic info (Name and Phone) in the database
    $sqlupdate = "UPDATE `tbl_user` SET `name` = '$name', `phone` = '$phone' WHERE `user_id` = '$user_id'";

    if ($conn->query($sqlupdate) === TRUE) {
        $filename = "";
        
        // Step 2: Check if the user also uploaded a new profile picture
        if (!empty($image)) {
            // Convert the Base64 string from Flutter back into actual image bytes
            $decoded_image = base64_decode($image);
            
            // Create a unique filename using the UserID and a Timestamp to avoid caching issues
            $filename = "user_" . $user_id . "_" . time() . ".png";
            $path = "../assets/profile/" . $filename;
            
            // Step 3: Physically save the image file to the server's storage folder
            if (file_put_contents($path, $decoded_image)) {
                // Step 4: Link the new filename to the user's row in the database
                $conn->query("UPDATE `tbl_user` SET `profile_image` = '$filename' WHERE `user_id` = '$user_id'");
            }
        }

        // Final Response: Tell Flutter everything worked and provide the new data
        echo json_encode(array(
            'status' => 'success', 
            'message' => 'Profile updated',
            'new_name' => $name,
            'new_phone' => $phone,
            'new_image' => $filename
        ));
    } else {
        // SQL Error: Something went wrong with the query
        echo json_encode(array('status' => 'failed', 'message' => $conn->error));
    }
} else {
    // If someone tries to "GET" this page instead of "POSTing" data
    echo json_encode(array('status' => 'failed', 'message' => 'Invalid Request'));
}
?>