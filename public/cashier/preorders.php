<?php
require_once __DIR__ . '/../../config/init.php';
requireRole(ROLE_CASHIER);
$db = Database::getInstance();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_status'])) {
  verifyCsrf();
  $oid    = (int)$_POST['order_id'];
  $status = $_POST['new_status'] ?? '';
  $allowed = [STATUS_PREPARING, STATUS_READY, STATUS_CLAIMED, STATUS_CANCELLED];
  if (in_array($status, $allowed, true)) {
    $db->prepare("UPDATE orders SET status=?,cashier_id=? WHERE id=?")
      ->execute([$status, currentUserId(), $oid]);
    auditLog(ROLE_CASHIER, currentUserId(), "status_{$status}", 'orders', $oid);
    flash('global', "Order updated to: {$status}.", 'success');
  }
  redirect(APP_URL . '/cashier/preorders.php');
}

$orders = $db->query(
  "SELECT o.id, o.order_number, o.status, o.total_amount, o.created_at, o.notes,
            s.full_name AS student_name, s.student_id_no,
            p.payment_method, p.reference_number,
            GROUP_CONCAT(CONCAT(od.quantity,'× ',pr.name, IF(od.customization_note IS NOT NULL AND od.customization_note != '', CONCAT(' (',od.customization_note,')'), '')) ORDER BY pr.name SEPARATOR '\n') AS items
     FROM orders o
     JOIN students s ON o.student_id = s.id
     JOIN order_details od ON o.id = od.order_id
     JOIN products pr ON od.product_id = pr.id
     LEFT JOIN payments p ON o.id = p.order_id
     WHERE o.order_type = 'pre-order'
       AND o.status IN ('pending','preparing','ready')
     GROUP BY o.id, o.order_number, o.status, o.total_amount, o.created_at, o.notes,
              s.full_name, s.student_id_no, p.payment_method, p.reference_number
     ORDER BY FIELD(o.status,'ready','preparing','pending'), o.created_at ASC"
)->fetchAll();

$counts = ['pending' => 0, 'preparing' => 0, 'ready' => 0];
foreach ($orders as $o) $counts[$o['status']] = ($counts[$o['status']] ?? 0) + 1;

// Payment method icon + color map
$payIcons = [
  'GCash'          => ['icon' => 'fa-mobile-screen-button', 'label' => 'GCash'],
  'PayMaya'        => ['icon' => 'fa-wallet',               'label' => 'PayMaya'],
  'Online Banking' => ['icon' => 'fa-building-columns',     'label' => 'Bank Transfer'],
  'online'         => ['icon' => 'fa-credit-card',          'label' => 'Online'],
  'cash'           => ['icon' => 'fa-money-bill-wave',       'label' => 'Cash'],
];

layoutHeader('Pre-orders', '');
?>
<style>
  /* ── Pre-order queue ───────────────────────────────────────── */
  .queue-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(310px, 1fr));
    gap: var(--space-4);
  }

  /* Status accent left-border */
  .order-card {
    background: var(--surface-color);
    border: 1.5px solid var(--border-color);
    border-radius: var(--radius-md);
    box-shadow: var(--shadow-sm);
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }

  .order-card.status-ready {
    border-color: var(--status-ready-border);
  }

  .order-card.status-preparing {
    border-color: var(--status-preparing-border);
  }

  .order-card.status-pending {
    border-color: var(--status-pending-border);
  }

  /* Card header */
  .order-card-head {
    padding: var(--space-3) var(--space-4);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--space-3);
    border-bottom: 1px solid var(--border-color);
  }

  .order-card-head.status-ready {
    background: var(--status-ready-bg);
  }

  .order-card-head.status-preparing {
    background: var(--status-preparing-bg);
  }

  .order-card-head.status-pending {
    background: var(--status-pending-bg);
  }

  .order-number {
    font-size: 0.86rem;
    font-weight: 800;
    letter-spacing: -0.01em;
  }

  .order-time {
    font-size: 0.72rem;
    color: var(--text-muted);
  }

  /* Card body */
  .order-card-body {
    padding: var(--space-4);
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
  }

  /* Student row */
  .student-row {
    display: flex;
    align-items: center;
    gap: var(--space-3);
  }

  .student-avatar {
    width: 34px;
    height: 34px;
    border-radius: var(--radius-full);
    background: var(--surface-sunken);
    border: 1.5px solid var(--border-color);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--text-muted);
    font-size: 13px;
    flex-shrink: 0;
  }

  .student-name {
    font-size: 0.88rem;
    font-weight: 700;
    color: var(--text-color);
  }

  .student-id {
    font-size: 0.72rem;
    color: var(--text-muted);
    margin-top: 1px;
    font-family: monospace;
    letter-spacing: 0.04em;
  }

  /* Items summary */
  .items-box {
    background: var(--surface-raised);
    border: 1px solid var(--border-color);
    border-radius: var(--radius-xs);
    padding: var(--space-2) var(--space-3);
    font-size: 0.78rem;
    color: var(--text-secondary);
    line-height: 1.6;
  }

  /* Payment verification box — the KEY section */
  .payment-verify {
    border: 1.5px solid var(--border-color);
    border-radius: var(--radius-sm);
    overflow: hidden;
  }

  .payment-verify-header {
    background: var(--surface-raised);
    border-bottom: 1px solid var(--border-color);
    padding: 6px 12px;
    display: flex;
    align-items: center;
    gap: var(--space-2);
    font-size: 0.68rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.09em;
    color: var(--text-muted);
  }

  .payment-verify-header i {
    font-size: 11px;
    color: var(--primary-color);
  }

  .payment-verify-body {
    padding: var(--space-3) var(--space-3);
    display: flex;
    align-items: center;
    gap: var(--space-3);
  }

  .payment-method-badge {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    background: var(--surface-sunken);
    border: 1px solid var(--border-color);
    border-radius: var(--radius-xs);
    padding: 4px 10px;
    font-size: 0.76rem;
    font-weight: 700;
    color: var(--text-secondary);
    white-space: nowrap;
    flex-shrink: 0;
  }

  .payment-method-badge i {
    font-size: 12px;
    color: var(--primary-color);
  }

  .ref-number-wrap {
    flex: 1;
    min-width: 0;
  }

  .ref-label {
    font-size: 0.62rem;
    font-weight: 600;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.08em;
    margin-bottom: 2px;
  }

  .ref-number {
    font-family: 'Courier New', monospace;
    font-size: 0.92rem;
    font-weight: 700;
    color: var(--text-color);
    letter-spacing: 0.04em;
    word-break: break-all;
  }

  .ref-missing {
    font-size: 0.80rem;
    color: var(--status-cancelled);
    font-style: italic;
    font-weight: 500;
  }

  /* Total row */
  .order-total-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .order-total-amount {
    font-size: 1.15rem;
    font-weight: 800;
    color: var(--primary-color);
    letter-spacing: -0.01em;
  }

  /* Notes */
  .order-notes {
    font-size: 0.76rem;
    color: var(--text-secondary);
    font-style: italic;
    padding: var(--space-2) var(--space-3);
    background: var(--accent-subtle);
    border: 1px solid rgba(240, 180, 41, 0.20);
    border-radius: var(--radius-xs);
  }

  .order-notes i {
    color: var(--accent-dark);
    margin-right: 4px;
  }

  /* Action footer */
  .order-card-foot {
    padding: var(--space-3) var(--space-4);
    border-top: 1px solid var(--border-color);
    background: var(--surface-raised);
    display: flex;
    gap: var(--space-2);
    align-items: center;
    flex-wrap: wrap;
  }

  /* Verify warning on pending */
  .verify-notice {
    display: flex;
    align-items: flex-start;
    gap: var(--space-2);
    font-size: 0.74rem;
    color: var(--status-pending);
    padding: var(--space-2) var(--space-3);
    background: var(--status-pending-bg);
    border: 1px solid var(--status-pending-border);
    border-radius: var(--radius-xs);
    margin-bottom: var(--space-3);
    line-height: 1.5;
  }

  .verify-notice i {
    font-size: 12px;
    flex-shrink: 0;
    margin-top: 1px;
  }

  .verify-notice strong {
    font-weight: 700;
  }
</style>

<div class="page-header">
  <div>
    <div class="page-header-title">Pre-order Queue</div>
    <div class="page-header-sub"><?= count($orders) ?> active · <?= $counts['ready'] ?> ready to claim</div>
  </div>
  <div class="page-header-actions">
    <?php if ($counts['ready'] > 0): ?>
      <span class="badge badge-ready"><?= $counts['ready'] ?> ready</span>
    <?php endif; ?>
    <?php if ($counts['preparing'] > 0): ?>
      <span class="badge badge-preparing"><?= $counts['preparing'] ?> preparing</span>
    <?php endif; ?>
    <?php if ($counts['pending'] > 0): ?>
      <span class="badge badge-pending"><?= $counts['pending'] ?> pending</span>
    <?php endif; ?>
  </div>
</div>
<?php showFlash('global'); ?>

<div class="alert alert-info mb-5" style="margin-bottom:var(--space-5)">
  <i class="fa-solid fa-circle-info"></i>
  <div>
    <strong>How to verify payment:</strong> Before pressing <em>Start Preparing</em>, check the reference number below against your <strong>GCash / PayMaya inbox</strong> or ask to see the student's payment screenshot.
    Always verify the student's <strong>physical school ID</strong> before marking as <em>Claimed</em>.
  </div>
</div>

<?php if (empty($orders)): ?>
  <div class="card">
    <div class="empty-state">
      <i class="fa-solid fa-circle-check"></i>
      <h3>Queue is clear!</h3>
      <p>No active pre-orders right now.</p>
    </div>
  </div>
<?php else: ?>
  <div class="queue-grid">
    <?php foreach ($orders as $o):
      $pay = $payIcons[$o['payment_method']] ?? $payIcons['online'];
    ?>
      <div class="order-card status-<?= e($o['status']) ?>">

        <!-- Header -->
        <div class="order-card-head status-<?= e($o['status']) ?>">
          <div>
            <div class="order-number"><?= e($o['order_number']) ?></div>
            <div class="order-time"><?= date('g:i A · M j', strtotime($o['created_at'])) ?></div>
          </div>
          <span class="badge badge-<?= e($o['status']) ?>"><?= ucfirst(e($o['status'])) ?></span>
        </div>

        <!-- Body -->
        <div class="order-card-body">

          <!-- Student -->
          <div class="student-row">
            <div class="student-avatar"><i class="fa-solid fa-graduation-cap"></i></div>
            <div>
              <div class="student-name"><?= e($o['student_name']) ?></div>
              <div class="student-id"><?= e($o['student_id_no']) ?></div>
            </div>
          </div>

          <!-- Items -->
          <div class="items-box">
            <?php foreach (explode("\n", $o['items']) as $line): ?>
              <div><?= e($line) ?></div>
            <?php endforeach; ?>
          </div>

          <!-- ★ Payment Verification Block ★ -->
          <div class="payment-verify">
            <div class="payment-verify-header">
              <i class="fa-solid fa-shield-check"></i> Payment Verification
            </div>
            <div class="payment-verify-body">
              <div class="payment-method-badge">
                <i class="fa-solid <?= $pay['icon'] ?>"></i>
                <?= $pay['label'] ?>
              </div>
              <div class="ref-number-wrap">
                <div class="ref-label">Reference No.</div>
                <?php if (!empty($o['reference_number'])): ?>
                  <div class="ref-number"><?= e($o['reference_number']) ?></div>
                <?php else: ?>
                  <div class="ref-missing">No reference number</div>
                <?php endif; ?>
              </div>
            </div>
          </div>

          <!-- Verify notice (only on pending) -->
          <?php if ($o['status'] === STATUS_PENDING): ?>
            <div class="verify-notice">
              <i class="fa-solid fa-triangle-exclamation"></i>
              <div><strong>Verify before preparing:</strong> Check this reference number in your <?= $pay['label'] ?> inbox before pressing Start Preparing.</div>
            </div>
          <?php endif; ?>

          <!-- Notes -->
          <?php if (!empty($o['notes'])): ?>
            <div class="order-notes">
              <i class="fa-solid fa-note-sticky"></i><?= e($o['notes']) ?>
            </div>
          <?php endif; ?>

          <!-- Total -->
          <div class="order-total-row">
            <span style="font-size:0.74rem;font-weight:600;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.06em">Order Total</span>
            <span class="order-total-amount"><?= peso($o['total_amount']) ?></span>
          </div>

        </div><!-- /body -->

        <!-- Actions footer -->
        <div class="order-card-foot">
          <form method="POST" style="display:flex;gap:var(--space-2);flex:1;flex-wrap:wrap">
            <?= csrfField() ?>
            <input type="hidden" name="update_status" value="1">
            <input type="hidden" name="order_id" value="<?= $o['id'] ?>">

            <?php if ($o['status'] === STATUS_PENDING): ?>
              <button name="new_status" value="preparing" class="btn btn-primary btn-sm flex-1"
                onclick="return confirm('Have you verified the <?= $pay['label'] ?> reference number for order <?= e($o['order_number']) ?>?')">
                <i class="fa-solid fa-fire"></i> Start Preparing
              </button>

            <?php elseif ($o['status'] === STATUS_PREPARING): ?>
              <button name="new_status" value="ready" class="btn btn-accent btn-sm flex-1">
                <i class="fa-solid fa-bell"></i> Mark Ready
              </button>

            <?php elseif ($o['status'] === STATUS_READY): ?>
              <button name="new_status" value="claimed" class="btn btn-success btn-sm flex-1"
                onclick="return confirm('Confirm school ID verified for <?= e($o['student_name']) ?>?')">
                <i class="fa-solid fa-id-card"></i> Claim Order
              </button>
            <?php endif; ?>

            <button name="new_status" value="cancelled" class="btn btn-danger btn-sm"
              onclick="return confirmDelete('Cancel order <?= e($o['order_number']) ?>? This cannot be undone.')"
              title="Cancel order">
              <i class="fa-solid fa-xmark"></i>
            </button>

          </form>
        </div>

      </div><!-- /order-card -->
    <?php endforeach; ?>
  </div>
<?php endif; ?>
<?php layoutFooter(); ?>