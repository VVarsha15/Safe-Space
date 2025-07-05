<?php
include 'db.php';

$name = $_POST['name'];
$phone = $_POST['phone'];
$password = $_POST['password'];
$age = $_POST['age'];
$em_name = $_POST['em_name'];
$em_phone = $_POST['em_phone'];
$em_relation = $_POST['em_relation'];

// Check if phone already exists
$check = mysqli_query($conn, "SELECT * FROM users WHERE phone='$phone'");
if (mysqli_num_rows($check) > 0) {
    echo json_encode(["status" => "user_exists"]);
} else {
    $query = "INSERT INTO users (name, phone, password, age, emergency_name, emergency_phone, emergency_relation) 
              VALUES ('$name', '$phone', '$password', '$age', '$em_name', '$em_phone', '$em_relation')";

    if (mysqli_query($conn, $query)) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => mysqli_error($conn)]);
    }
}
?>
