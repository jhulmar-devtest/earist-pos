<?php
// 1. Database Configuration
$host = 'localhost';
$dbname = 'earist_coffeeshop';
$db_username = 'root'; // Change to your database username
$db_password = '';     // Change to your database password

$message = '';

// Establish Database Connection
try {
  $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $db_username, $db_password);
  // Set PDO error mode to exception for easier debugging
  $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
  die("Database connection failed: " . $e->getMessage());
}

// 2. Handle Form Submission
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['create_admin_btn'])) {

  // Sanitize and capture inputs
  $fullName = trim($_POST['full_name']);
  $username = trim($_POST['username']);
  $password = trim($_POST['password']);

  // Basic validation
  if (empty($fullName) || empty($username) || empty($password)) {
    $message = "<p style='color: red;'>All fields are required.</p>";
  } else {
    // Hash the password using bcrypt (as required by your database schema)
    $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

    // Prepare the INSERT statement
    $sql = "INSERT INTO admins (full_name, username, password) VALUES (:full_name, :username, :password)";

    try {
      $stmt = $pdo->prepare($sql);

      // Execute the query with the bound parameters
      $stmt->execute([
        ':full_name' => $fullName,
        ':username' => $username,
        ':password' => $hashedPassword
      ]);

      $message = "<p style='color: green;'>Admin account successfully created!</p>";
    } catch (PDOException $e) {
      // Check if the error is a duplicate entry for the unique username column
      if ($e->getCode() == 23000) {
        $message = "<p style='color: red;'>Error: That username is already taken.</p>";
      } else {
        $message = "<p style='color: red;'>Error: " . $e->getMessage() . "</p>";
      }
    }
  }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Create Admin Account</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 50px;
    }

    .form-container {
      max-width: 400px;
      padding: 20px;
      border: 1px solid #ccc;
      border-radius: 5px;
    }

    .form-group {
      margin-bottom: 15px;
    }

    .form-group label {
      display: block;
      margin-bottom: 5px;
    }

    .form-group input {
      width: 100%;
      padding: 8px;
      box-sizing: border-box;
    }

    button {
      padding: 10px 15px;
      background-color: #28a745;
      color: white;
      border: none;
      cursor: pointer;
      border-radius: 3px;
    }

    button:hover {
      background-color: #218838;
    }
  </style>
</head>

<body>

  <div class="form-container">
    <h2>Add New Admin</h2>

    <?= $message; ?>

    <form method="POST" action="">
      <div class="form-group">
        <label for="full_name">Full Name:</label>
        <input type="text" id="full_name" name="full_name" required>
      </div>

      <div class="form-group">
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" required>
      </div>

      <div class="form-group">
        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required>
      </div>

      <button type="submit" name="create_admin_btn">Create Admin Account</button>
    </form>
  </div>

</body>

</html>