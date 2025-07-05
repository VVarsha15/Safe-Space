<?php
include 'db.php';

$phone = $_POST['phone'];
$password = $_POST['password'];

$result = mysqli_query($conn, "SELECT * FROM users WHERE phone='$phone'");

if (mysqli_num_rows($result) > 0) {
    $row = mysqli_fetch_assoc($result);
    if ($row['password'] === $password) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "invalid_password"]);
    }
} else {
    echo json_encode(["status" => "user_not_found"]);
}
?>
