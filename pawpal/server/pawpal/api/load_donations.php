<?php
// Set headers to allow Flutter app access and define response format as JSON
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// Connect to the database using your shared config
include 'dbconnect.php';

// Check if the app actually sent a User ID via the URL (GET request)
if (isset($_GET['user_id'])) {
    $user_id = $_GET['user_id'];
    
    // SQL Query: Fetch all donations for this specific user
    // ORDER BY ensures the most recent donations appear at the top of the list
    $sqlload = "SELECT * FROM tbl_donations WHERE user_id = '$user_id' ORDER BY date_donated DESC";
    $result = $conn->query($sqlload);

    // If the database returns one or more records
    if ($result->num_rows > 0) {
        $donations = array();
        // Loop through each row and pack it into an array for the app to read
        while ($row = $result->fetch_assoc()) {
            $donations[] = $row;
        }
        // Success: Send the full list of donations back to Flutter
        echo json_encode(array('status' => 'success', 'data' => $donations));
    } else {
        // No records found: Tell the app the history is currently empty
        echo json_encode(array('status' => 'failed', 'message' => 'No donation history found'));
    }
} else {
    // Security check: If someone tries to access this script without a User ID
    echo json_encode(array('status' => 'failed', 'message' => 'Bad Request: User ID missing'));
}
?>