<?php
require_once __DIR__ . '/../../config/init.php';
requireRole(ROLE_ADMIN);
$db = Database::getInstance();
$orders = $db->query("SELECT o.*,COALESCE(s.full_name,'Walk-in') AS customer,p.payment_method,p.payment_status FROM orders o LEFT JOIN students s ON o.student_id=s.id LEFT JOIN payments p ON o.id=p.order_id ORDER BY o.created_at DESC LIMIT 100")->fetchAll();
layoutHeader('All Orders');
?>
<h2 class="mb-4" style="font-size:1.2rem">All Orders</h2>
<div class="card">
  <div style="overflow-x:auto">
    <table class="data-table">
      <thead>
        <tr>
          <th>Order No.</th>
          <th>Customer</th>
          <th>Type</th>
          <th>Total</th>
          <th>Payment</th>
          <th>Status</th>
          <th>Date</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($orders as $o): ?>
          <tr>
            <td><strong><?= e($o['order_number']) ?></strong></td>
            <td><?= e($o['customer']) ?></td>
            <td><span class="badge badge-<?= $o['order_type'] === 'walk-in' ? 'walkin' : 'preorder' ?>"><?= e($o['order_type']) ?></span></td>
            <td><?= peso($o['total_amount']) ?></td>
            <td><?= e($o['payment_method'] ?? '—') ?></td>
            <td><span class="badge badge-<?= e($o['status']) ?>"><?= e($o['status']) ?></span></td>
            <td><?= date('M j, Y g:i A', strtotime($o['created_at'])) ?></td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
</div>
<?php layoutFooter(); ?>