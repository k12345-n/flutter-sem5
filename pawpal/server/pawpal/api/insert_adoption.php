<?php
// Set headers for security and JSON formatting
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

/**
 * Standard utility function to send a JSON-encoded response and exit execution
 */
function sendJsonResponse($sentArray)
{
    echo json_encode($sentArray);
    exit();
}

// Ensure the script only accepts POST requests from the app
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Include database connection details
    include 'dbconnect.php'; 
    
    // 1. Capture and sanitize input data
    $pet_id = isset($_POST['pet_id']) ? (int)$_POST['pet_id'] : 0;
    $user_id = isset($_POST['user_id']) ? (int)$_POST['user_id'] : 0;
    // The motivation message is sent as 'message' from the Flutter controller
    $motivation = isset($_POST['message']) ? $conn->real_escape_string($_POST['message']) : "";

    // 2. Server-side validation: reject if IDs are missing or message is empty
    if ($pet_id == 0 || $user_id == 0 || empty($motivation)) {
        sendJsonResponse(array('status' => 'failed', 'message' => 'All fields are required.'));
    }

    // 3. Insert the request into tbl_adoptions with a default status of 'Pending'
    $sqlinsert = "INSERT INTO `tbl_adoptions` (`pet_id`, `user_id`, `motivation`) 
                  VALUES ('$pet_id', '$user_id', '$motivation')";

    // 4. Return success or failure status back to the Flutter widget
    if ($conn->query($sqlinsert) === TRUE) {
        $response = array('status' => 'success', 'message' => 'Request submitted successfully.');
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'message' => 'Database error: ' . $conn->error);
        sendJsonResponse($response);
    }
} else {
    // Block unauthorized request methods (like GET)
    $response = array('status' => 'failed', 'message' => 'Invalid request method.');
    sendJsonResponse($response);
}
?>