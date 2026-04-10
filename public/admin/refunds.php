<?php
require_once __DIR__ . '/../../config/init.php';
requireRole(ROLE_ADMIN);
$db = Database::getInstance();

// Approve / Reject
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
  verifyCsrf();
  $rid    = (int)$_POST['refund_id'];
  $action = $_POST['action'] === 'approve' ? 'approved' : 'rejected';
  $note   = sanitizeString($_POST['admin_note'] ?? '', 500);
  $db->prepare("UPDATE refund_requests SET status=?,admin_note=?,reviewed_by=?,reviewed_at=NOW() WHERE id=?")
    ->execute([$action, $note, currentUserId(), $rid]);
  if ($action === 'approved') {
    // Also update the payment status to refunded
    $db->prepare("UPDATE payments p JOIN refund_requests r ON p.order_id=r.order_id SET p.payment_status='refunded' WHERE r.id=?")->execute([$rid]);
  }
  auditLog(ROLE_ADMIN, currentUserId(), "refund_{$action}", 'refund_requests', $rid);
  flash('global', "Refund request {$action}.", "success");
  redirect(APP_URL . '/admin/refunds.php');
}

$refunds = $db->query("SELECT r.*,s.full_name AS student_name,s.student_id_no,o.order_number,o.total_amount FROM refund_requests r JOIN students s ON r.student_id=s.id JOIN orders o ON r.order_id=o.id ORDER BY r.created_at DESC")->fetchAll();
layoutHeader('Refund Requests');
?>
<h2 class="mb-4" style="font-size:1.2rem">Refund Requests</h2>
<?php showFlash('global'); ?>
<div class="card">
  <div style="overflow-x:auto">
    <table class="data-table">
      <thead>
        <tr>
          <th>Order</th>
          <th>Student</th>
          <th>Amount</th>
          <th>Reason</th>
          <th>Requested</th>
          <th>Status</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        <?php if (empty($refunds)): ?>
          <tr>
            <td colspan="7" style="text-align:center;padding:30px;color:var(--text-muted)">No refund requests.</td>
          </tr>
          <?php else: foreach ($refunds as $r): ?>
            <tr>
              <td><strong><?= e($r['order_number']) ?></strong></td>
              <td><?= e($r['student_name']) ?><div class="text-muted"><?= e($r['student_id_no']) ?></div>
              </td>
              <td><?= peso($r['total_amount']) ?></td>
              <td><?= e($r['reason']) ?></td>
              <td><?= date('M j, Y', strtotime($r['created_at'])) ?></td>
              <td><span class="badge badge-<?= $r['status'] === 'pending' ? 'pending' : ($r['status'] === 'approved' ? 'paid' : 'cancelled') ?>"><?= e($r['status']) ?></span></td>
              <td>
                <?php if ($r['status'] === 'pending'): ?>
                  <form method="POST" style="display:flex;gap:6px">
                    <?= csrfField() ?>
                    <input type="hidden" name="refund_id" value="<?= $r['id'] ?>">
                    <button name="action" value="approve" class="btn btn-accent btn-sm"><i class="fa-solid fa-check"></i> Approve</button>
                    <button name="action" value="reject" class="btn btn-danger btn-sm"><i class="fa-solid fa-times"></i> Reject</button>
                  </form>
                <?php else: ?>
                  <span class="text-muted">—</span>
                <?php endif; ?>
              </td>
            </tr>
        <?php endforeach;
        endif; ?>
      </tbody>
    </table>
  </div>
</div>
<?php layoutFooter(); ?>