<?php
require_once __DIR__ . '/../../config/init.php';
requireRole(ROLE_CASHIER);
$db = Database::getInstance();

$orderId = $_GET['id'] ?? $_SESSION['last_order_id'] ?? 0;
if (!$orderId) {
  redirect(APP_URL . '/cashier/walkin.php');
}

$stmt = $db->prepare("SELECT o.*,p.payment_method,p.amount_paid,p.change_given,c.full_name AS cashier_name FROM orders o LEFT JOIN payments p ON o.id=p.order_id LEFT JOIN cashiers c ON o.cashier_id=c.id WHERE o.id=?");
$stmt->execute([$orderId]);
$order = $stmt->fetch();
if (!$order) {
  redirect(APP_URL . '/cashier/walkin.php');
}

$stmt = $db->prepare("SELECT od.*,pr.name FROM order_details od JOIN products pr ON od.product_id=pr.id WHERE od.order_id=?");
$stmt->execute([$orderId]);
$items = $stmt->fetchAll();

layoutHeader('Receipt', '<style>
.receipt-wrap{max-width:360px;margin:0 auto;background:var(--surface-color);border:1px solid var(--border-color);border-radius:var(--radius-md);padding:28px;box-shadow:var(--shadow-md)}
.receipt-divider{border:none;border-top:1px dashed var(--border-color);margin:12px 0}
</style>');
?>
<div class="flex justify-between items-center mb-4 no-print">
  <h2 style="font-size:1.2rem">Order Receipt</h2>
  <div style="display:flex;gap:10px">
    <button onclick="window.print()" class="btn btn-ghost"><i class="fa-solid fa-print"></i> Print</button>
    <a href="<?= APP_URL ?>/cashier/walkin.php" class="btn btn-primary"><i class="fa-solid fa-plus"></i> New Order</a>
  </div>
</div>
<div class="receipt-wrap">
  <div style="text-align:center;margin-bottom:14px">
    <div style="font-size:28px;color:var(--primary-color);margin-bottom:6px"><i class="fa-solid fa-mug-hot"></i></div>
    <div style="font-family:'Playfair Display',serif;font-size:1.15rem;font-weight:700;color:var(--primary-color)"><?= APP_NAME ?></div>
    <div style="font-size:.7rem;color:var(--text-secondary);font-style:italic;margin-top:2px"><?= APP_TAGLINE ?></div>
  </div>
  <hr class="receipt-divider">
  <div style="font-size:.78rem;color:var(--text-secondary)">
    <div><strong>Order No.:</strong> <?= e($order['order_number']) ?></div>
    <div><strong>Type:</strong> <?= e($order['order_type']) ?></div>
    <div><strong>Cashier:</strong> <?= e($order['cashier_name']) ?></div>
    <div><strong>Date:</strong> <?= date('M j, Y — g:i A', strtotime($order['created_at'])) ?></div>
  </div>
  <hr class="receipt-divider">
  <table style="width:100%">
    <tbody>
      <?php foreach ($items as $item): ?>
        <tr>
          <td style="font-size:.82rem;padding:3px 0"><?= e($item['name']) ?></td>
          <td style="font-size:.82rem;padding:3px 6px;color:var(--text-muted);text-align:center">×<?= $item['quantity'] ?></td>
          <td style="font-size:.82rem;text-align:right;font-weight:500"><?= peso($item['subtotal']) ?></td>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
  <hr class="receipt-divider">
  <table style="width:100%">
    <tbody>
      <tr>
        <td style="font-size:.95rem;font-weight:700">TOTAL</td>
        <td style="font-size:.95rem;font-weight:700;text-align:right"><?= peso($order['total_amount']) ?></td>
      </tr>
      <tr>
        <td style="font-size:.84rem;color:var(--text-secondary)">Cash Received</td>
        <td style="font-size:.84rem;text-align:right;font-weight:600"><?= peso($order['amount_paid']) ?></td>
      </tr>
      <tr>
        <td style="font-size:.84rem;color:var(--text-secondary)">Change</td>
        <td style="font-size:.84rem;text-align:right;font-weight:600"><?= peso($order['change_given']) ?></td>
      </tr>
      <tr>
        <td style="font-size:.84rem;color:var(--text-secondary)">Payment</td>
        <td style="font-size:.84rem;text-align:right"><?= ucfirst(e($order['payment_method'])) ?></td>
      </tr>
    </tbody>
  </table>
  <hr class="receipt-divider">
  <div style="text-align:center;font-size:.72rem;color:var(--text-muted)">
    <div>Thank you for your purchase!</div>
    <div style="margin-top:4px">EARIST Cavite Campus — GMA, Cavite</div>
  </div>
</div>
<?php layoutFooter(); ?>