<?php
header("Access-Control-Allow-Origin: *");

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    include 'dbconnect.php';
    
    // Check if user_id is provided
    if (!isset($_GET['user_id']) || empty($_GET['user_id'])) {
        sendJsonResponse(array('status' => 'failed', 'message' => 'User ID is required.'));
    }
    
    $user_id = (int)$_GET['user_id'];
    
    // Pagination setup
    $results_per_page = 10;
    $curpage = isset($_GET['curpage']) ? (int)$_GET['curpage'] : 1;
    $curpage = max(1, $curpage);
    $page_first_result = ($curpage - 1) * $results_per_page;
    
    // Base query for pets
    $baseQuery = "
        SELECT 
            p.pet_id,
            p.user_id,
            p.pet_name,
            p.pet_type,
            p.category,
            p.description,
            p.image_paths,
            p.lat,
            p.lng,
            p.created_at
        FROM tbl_pets p
        WHERE p.user_id = $user_id
    ";
    
    // Search logic (optional)
    $sqlloadpets = $baseQuery;
    if (isset($_GET['search']) && !empty($_GET['search'])) {
        $search = $conn->real_escape_string($_GET['search']);
        $sqlloadpets .= "
            AND (
                p.pet_name LIKE '%$search%'
                OR p.category LIKE '%$search%'
                OR p.description LIKE '%$search%'
            )
        ";
    }
    
    // Count total results
    $countResult = $conn->query($sqlloadpets);
    $number_of_result = $countResult ? $countResult->num_rows : 0;
    $number_of_page = ceil($number_of_result / $results_per_page);
    
    // Add ordering and pagination
    $sqlloadpets .= " ORDER BY p.pet_id DESC";
    $sqlloadpets .= " LIMIT $page_first_result, $results_per_page";
    
    // Execute final query
    $result = $conn->query($sqlloadpets);
    
    if ($result && $result->num_rows > 0) {
        $petdata = array();
        while ($row = $result->fetch_assoc()) {
            $petdata[] = $row;
        }
        $response = array(
            'status' => 'success', 
            'data' => $petdata,
            'numofpage' => $number_of_page, 
            'numberofresult' => $number_of_result
        );
        sendJsonResponse($response);
    } else {
        $response = array(
            'status' => 'failed', 
            'data' => null,
            'numofpage' => $number_of_page, 
            'numberofresult' => $number_of_result,
            'message' => 'No pets found for this user.'
        );
        sendJsonResponse($response);
    }
} else {
    $response = array('status' => 'failed', 'message' => 'Invalid request method.');
    sendJsonResponse($response);
}
?>