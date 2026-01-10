<?php
include_once("dbconnect.php");

// Get data from the redirect URL
$userid = $_GET['userid'];
$petid = $_GET['petid'];
$amount = $_GET['amount'];
$email = $_GET['email'];
$phone = $_GET['phone'];
$name = $_GET['name'];

// Collect Billplz response for verification
$data = array(
    'id' =>  $_GET['billplz']['id'],
    'paid_at' => $_GET['billplz']['paid_at'],
    'paid' => $_GET['billplz']['paid'],
    'x_signature' => $_GET['billplz']['x_signature']
);

$paidstatus = $_GET['billplz']['paid'];
$receiptid = $_GET['billplz']['id'];

if ($paidstatus == "true") {
    $paidstatus = "Success";
} else {
    $paidstatus = "Failed";
}

// X Signature verification 
$signing = '';
foreach ($data as $key => $value) {
    $signing .= 'billplz' . $key . $value;
    if ($key === 'paid') { break; } else { $signing .= '|'; }
}

// Your X-Signature Key
$xkey = '0621be89f5c0420593654ccd3b72314bc748856398df94cdfcba9089af0485cca52f2c710eab5359259a992ace4c28893e05c4d1510f62224cc35e3d6cb5bc40';
$signed = hash_hmac('sha256', $signing, $xkey);

if ($signed === $data['x_signature']) {
    if ($paidstatus == "Success") {
        // Insert into your PawPal donation table
        $sqlinsert = "INSERT INTO `tbl_donations`(`user_id`, `pet_id`, `donation_type`, `amount`, `description`, `bill_id`, `payment_status`) 
                      VALUES ('$userid', '$petid', 'Money', '$amount', 'Donation via Billplz', '$receiptid', 'completed')";
        $conn->query($sqlinsert);
    }

    // Display the Receipt UI style
    echo "
    <html><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
    <link rel=\"stylesheet\" href=\"https://www.w3schools.com/w3css/4/w3.css\">
    <body>
    <center><h4>Donation Receipt</h4></center>
    <table class='w3-table w3-striped'>
    <th>Item</th><th>Description</th>
    <tr><td>Receipt ID</td><td>$receiptid</td></tr>
    <tr><td>Name</td><td>$name</td></tr>
    <tr><td>Email</td><td>$email</td></tr>
    <tr><td>Amount</td><td>RM $amount</td></tr>
    <tr><td>Status</td><td style='color:".($paidstatus=="Success"?"green":"red")."'>$paidstatus</td></tr>
    </table><br>
    <center><button class='w3-button w3-orange' onclick=\"window.location.href='https://canorcannot.com/Ken';\">Return to PawPal</button></center>
    </body>
    </html>";
}
?>