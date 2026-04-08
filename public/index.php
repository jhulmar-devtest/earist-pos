<?php
// ============================================================
// public/index.php  —  Entry point
// Logged-in users go to their dashboard.
// Everyone else sees the landing page.
// ============================================================
require_once __DIR__ . '/../config/init.php';

if (isLoggedIn()) {
  redirectByRole();
} else {
  redirect(APP_URL . '/landing.php');
}
