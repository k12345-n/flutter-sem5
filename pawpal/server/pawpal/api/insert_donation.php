<?php
// Set header to allow cross-origin requests from the Flutter application
header("Access-Control-Allow-Origin: *");
// Include the database connection configuration
include 'dbconnect.php';

// Check if the incoming request is a POST method
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // 1. Capture basic donation data sent from the Flutter app
    $user_id = $_POST['user_id'];
    $pet_id = $_POST['pet_id'];
    $type = $_POST['type']; // Can be 'Money', 'Food', or 'Medical'
    
    // 2. Validate and sanitize optional inputs
    // Default amount to 0 if not provided (common for physical donations)
    $amount = isset($_POST['amount']) ? $_POST['amount'] : 0;
    // Escape the description string to prevent SQL injection
    $desc = isset($_POST['description']) ? $conn->real_escape_string($_POST['description']) : "";

    // 3. Capture additional columns merged into your SQL table
    // Physical donations do not have a Billplz ID, so they default to "NULL"
    $bill_id = isset($_POST['bill_id']) ? $_POST['bill_id'] : "NULL";
    // Default status to 'completed' for non-monetary items
    $payment_status = isset($_POST['payment_status']) ? $_POST['payment_status'] : "completed";

    // 4. Construct the SQL query to insert into tbl_donations
    $sqlinsert = "INSERT INTO tbl_donations (user_id, pet_id, donation_type, amount, description, bill_id, payment_status) 
                  VALUES ('$user_id', '$pet_id', '$type', '$amount', '$desc', '$bill_id', '$payment_status')";

    // 5. Execute query and return a JSON status to the app
    if ($conn->query($sqlinsert) === TRUE) {
        echo json_encode(array('status' => 'success'));
    } else {
        // Provide error details for easier debugging during development
        echo json_encode(array('status' => 'failed', 'error' => $conn->error));
    }
}
?>