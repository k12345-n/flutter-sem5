<?php
error_reporting(0);
// Capture data from Flutter URL parameters
$email = $_GET['email'];
$phone = $_GET['phone'];
$name = $_GET['name'];
$amount = $_GET['amount']; 
$userid = $_GET['userid'];
$petid = $_GET['petid'];

// Billplz Credentials (using your provided keys)
$api_key = '20b9a95c-22b4-4d2b-8476-01ab7a643c19';
$collection_id = '8gqswnfj';
$host = 'https://www.billplz-sandbox.com/api/v3/bills';

$data = array(
    'collection_id' => $collection_id,
    'email' => $email,
    'mobile' => $phone,
    'name' => $name,
    'amount' => $amount * 100, // logic for cents
    'description' => 'Donation for Pet ID: '.$petid,
    'callback_url' => "https://canorcannot.com/Ken/pawpal/api/return_url", 
    // Redirect passes all info to the update script
    'redirect_url' => "https://canorcannot.com/Ken/pawpal/api/billplz_payment_update.php?userid=$userid&petid=$petid&email=$email&name=$name&phone=$phone&amount=$amount" 
);

$process = curl_init($host);
curl_setopt($process, CURLOPT_HEADER, 0);
curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
curl_setopt($process, CURLOPT_TIMEOUT, 30);
curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data)); 

$return = curl_exec($process);
curl_close($process);

$bill = json_decode($return, true);

// Redirect the WebView to the generated Billplz URL
header("Location: {$bill['url']}");
?>