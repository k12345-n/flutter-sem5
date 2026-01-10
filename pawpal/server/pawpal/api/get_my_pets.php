<?php
// Set headers to allow cross-origin requests from Flutter and define JSON response format
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// Establish connection to the MySQL database
include 'dbconnect.php';

// Capture search and filter parameters from the Flutter GET request
$search = isset($_GET['search']) ? $conn->real_escape_string($_GET['search']) : "";
$type = isset($_GET['type']) ? $conn->real_escape_string($_GET['type']) : "All";

// Pagination settings: define how many pets to show per page
$results_per_page = 10;
$curpage = isset($_GET['curpage']) ? (int)$_GET['curpage'] : 1;
$curpage = max(1, $curpage); // Ensure page number is at least 1
$page_first_result = ($curpage - 1) * $results_per_page;

// Base SQL query: Joins tbl_pets with tbl_user to get the name of the person who posted the pet
$sqlloadpets = "SELECT tbl_pets.*, tbl_user.name AS user_name 
                FROM tbl_pets 
                LEFT JOIN tbl_user ON tbl_pets.user_id = tbl_user.user_id 
                WHERE 1=1";

// Task 1: Add filter logic if a specific pet type (Dogs, Cat, Rabbit) is selected
if ($type != "All") {
    $sqlloadpets .= " AND LOWER(pet_type) = LOWER('$type')";
}

// Task 1: Add search logic to look for keywords in pet name, category, or description
if (!empty($search)) {
    $sqlloadpets .= " AND (pet_name LIKE '%$search%'
                       OR category LIKE '%$search%'
                       OR description LIKE '%$search%')";
}

// Calculate total results and total pages for pagination logic
$countResult = $conn->query($sqlloadpets);
$number_of_result = $countResult ? $countResult->num_rows : 0;
$number_of_page = ceil($number_of_result / $results_per_page);

// Final SQL: Sort by newest pets first and apply the LIMIT for pagination
$sqlloadpets .= " ORDER BY pet_id DESC LIMIT $page_first_result, $results_per_page";
$result = $conn->query($sqlloadpets);

// Process the result set
if ($result && $result->num_rows > 0) {
    $petdata = array();
    while ($row = $result->fetch_assoc()) {
        $row['description'] = $row['description'] ?? "No description";
        $row['image_paths'] = $row['image_paths'] ?? "default.png";
        $petdata[] = $row;
    }
    // Return success response with pet list and pagination data
    echo json_encode(array('status' => 'success', 'data' => $petdata, 'numofpage' => $number_of_page));
} else {
    // Return failure response if no pets are found matching the criteria
    echo json_encode(array('status' => 'failed', 'data' => null, 'message' => 'No pets found.'));
}

/**
 * Standard utility function to exit and send a JSON response
 */
function sendJsonResponse($sentArray) {
    echo json_encode($sentArray);
    exit();
}
?>