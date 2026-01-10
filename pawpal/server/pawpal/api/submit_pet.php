<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(array('error' => 'Method Not Allowed'));
    exit();
}

$userid = $_POST['user_id'];
$petname = addslashes($_POST['pet_name']);
$petType = $_POST['pet_type'];

$petAge = isset($_POST['pet_age']) ? (int)$_POST['pet_age'] : 0; 
$gender = isset($_POST['gender']) ? $_POST['gender'] : "Unknown";
$health = isset($_POST['health_status']) ? addslashes($_POST['health_status']) : "Healthy";

$category = $_POST['category']; 
$description = addslashes($_POST['description']);
$lat = floatval($_POST['lat']);
$lng = floatval($_POST['lng']);
$imageCount = isset($_POST['image_count']) ? (int)$_POST['image_count'] : 1;

$encodedImages = explode('|||', $_POST['image_paths']);

$sqlinsertpet = "INSERT INTO `tbl_pets`(`user_id`, `pet_name`, `pet_type`, `pet_age`, `gender`, `health_status`, `category`, `description`, `lat`, `lng`) 
VALUES ('$userid', '$petname', '$petType', '$petAge', '$gender', '$health', '$category', '$description', '$lat', '$lng')";

try{
    if ($conn->query($sqlinsertpet) === TRUE){
        $last_id = $conn->insert_id;
        
        $filenames = array();
        
        for ($i = 0; $i < count($encodedImages) && $i < 3; $i++) {
            $encodedimage = base64_decode($encodedImages[$i]);
            
            $filename = "pet_".$last_id."_".($i + 1).".png";
            $path = "../assets/pets/".$filename;
            
            $bytes_written = file_put_contents($path, $encodedimage);
            
            if ($bytes_written !== false) {
                $filenames[] = $filename;
                error_log("Saved image $filename ($bytes_written bytes)");
            } else {
                error_log("Failed to save image $filename");
            }
        }

        $imagePathsString = implode(',', $filenames);
        
        $sqlupdate = "UPDATE `tbl_pets` SET `image_paths` = '$imagePathsString' WHERE `pet_id` = $last_id";
        
        if ($conn->query($sqlupdate) === TRUE) {
            $response = array(
                'status' => 'success', 
                'message' => 'Pet added successfully with ' . count($filenames) . ' image(s)',
                'pet_id' => $last_id,
                'image_paths' => $imagePathsString
            );
            sendJsonResponse($response);
        } else {
            $response = array(
                'status' => 'failed', 
                'message' => 'Pet added but image path update failed: ' . $conn->error
            );
            sendJsonResponse($response);
        }
    } else {
        $response = array(
            'status' => 'failed', 
            'message' => 'Pet not added: ' . $conn->error
        );
        sendJsonResponse($response);
    }
} catch(Exception $e) {
    $response = array(
        'status' => 'failed', 
        'message' => $e->getMessage()
    );
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>