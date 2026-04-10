<?php
require_once __DIR__ . '/../../config/init.php';
requireRole(ROLE_ADMIN);
$db = Database::getInstance();

// ── KPI cards ────────────────────────────────────────────────
$stmt = $db->prepare("SELECT COALESCE(SUM(total_amount),0) FROM orders WHERE DATE(created_at)=CURDATE() AND status!='cancelled'");
$stmt->execute();
$todaySales = (float)$stmt->fetchColumn();

$stmt = $db->prepare("SELECT COUNT(*) FROM orders WHERE DATE(created_at)=CURDATE() AND status!='cancelled'");
$stmt->execute();
$todayCount = (int)$stmt->fetchColumn();

$stmt = $db->prepare("SELECT COUNT(*) FROM orders WHERE order_type='pre-order' AND status IN ('pending','preparing','ready')");
$stmt->execute();
$activePreorders = (int)$stmt->fetchColumn();

$stmt = $db->query("SELECT COUNT(*) FROM refund_requests WHERE status='pending'");
$pendingRefunds = (int)$stmt->fetchColumn();

// ── Revenue chart (last 7 days) ───────────────────────────────
$stmt = $db->prepare("SELECT DATE(created_at) AS d, COALESCE(SUM(total_amount),0) AS t
  FROM orders WHERE created_at>=DATE_SUB(CURDATE(),INTERVAL 6 DAY) AND status!='cancelled'
  GROUP BY DATE(created_at) ORDER BY d");
$stmt->execute();
$salesRaw = $stmt->fetchAll();
$salesByDate = [];
for ($i = 6; $i >= 0; $i--) {
  $d = date('Y-m-d', strtotime("-{$i} days"));
  $salesByDate[$d] = 0;
}
foreach ($salesRaw as $r) {
  $salesByDate[$r['d']] = (float)$r['t'];
}
$chartLabels = array_map(fn($d) => date('D', strtotime($d)), array_keys($salesByDate));
$chartData   = array_values($salesByDate);

// ── Recent orders ─────────────────────────────────────────────
$stmt = $db->prepare("SELECT o.order_number,o.order_type,o.status,o.total_amount,
    p.payment_method,o.created_at,COALESCE(s.full_name,'Walk-in') AS customer
  FROM orders o
  LEFT JOIN payments p ON o.id=p.order_id
  LEFT JOIN students s ON o.student_id=s.id
  ORDER BY o.created_at DESC LIMIT 8");
$stmt->execute();
$recentOrders = $stmt->fetchAll();

// ── Top cashier leaderboard ───────────────────────────────────
$lbPeriods = [
  'today' => "DATE(o.created_at) = CURDATE()",
  'week'  => "YEARWEEK(o.created_at,1) = YEARWEEK(CURDATE(),1)",
  'month' => "YEAR(o.created_at)=YEAR(CURDATE()) AND MONTH(o.created_at)=MONTH(CURDATE())",
  'year'  => "YEAR(o.created_at)=YEAR(CURDATE())",
];
$leaderboards = [];
foreach ($lbPeriods as $key => $where) {
  $stmt = $db->prepare("
    SELECT c.id, c.full_name,
           COUNT(DISTINCT o.id) AS txn_count,
           COALESCE(SUM(p.amount_paid - p.change_given), 0) AS revenue,
           ROUND(AVG(f.rating),1) AS avg_rating,
           COUNT(f.id) AS review_count
    FROM cashiers c
    JOIN orders o ON o.cashier_id = c.id
    JOIN payments p ON p.order_id = o.id AND p.payment_status = 'paid'
    LEFT JOIN order_feedback f ON f.order_id = o.id
    WHERE o.status != 'cancelled' AND $where
    GROUP BY c.id, c.full_name
    HAVING revenue > 0
    ORDER BY revenue DESC 
    LIMIT 5
  ");
  $stmt->execute();
  $leaderboards[$key] = $stmt->fetchAll();
}

// ── Best sellers per leaf category ───────────────────────────
$bsRows = $db->query(
  "SELECT c.id AS cat_id, c.name AS cat_name,
          p.id AS prod_id, p.name AS prod_name, p.price,
          COALESCE(SUM(od.quantity),0) AS total_qty,
          COALESCE(SUM(od.quantity * od.price_at_time),0) AS total_rev
   FROM categories c
   JOIN products p ON p.category_id = c.id
   LEFT JOIN order_details od ON od.product_id = p.id
   LEFT JOIN orders o ON od.order_id = o.id AND o.status != 'cancelled'
   WHERE c.parent_id IS NOT NULL AND c.name != 'Add-ons'
   GROUP BY c.id, c.name, p.id, p.name, p.price
   ORDER BY c.sort_order, c.name, total_qty DESC"
)->fetchAll();

$bestSellers = [];
foreach ($bsRows as $row) {
  if (!isset($bestSellers[$row['cat_id']])) {
    $bestSellers[$row['cat_id']] = $row;
  }
}

// ── Cashier session log ───────────────────────────────────────
$sessionLog = [];
try {
  $sessionLog = $db->query(
    "SELECT cs.id, c.full_name, cs.login_at, cs.logout_at,
            TIMESTAMPDIFF(MINUTE, cs.login_at, COALESCE(cs.logout_at, NOW())) AS duration_min
     FROM cashier_sessions cs
     JOIN cashiers c ON cs.cashier_id = c.id
     ORDER BY cs.login_at DESC LIMIT 50"
  )->fetchAll();
} catch (\Throwable $e) {
  // Table may not exist yet — run cashier_sessions_migration.sql
}

layoutHeader('Dashboard', '<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>');
?>
<style>
  /* ── Leaderboard ─────────────────────────────────────────── */
  .leaderboard-tab {
    flex: 1;
    padding: 8px 0;
    font-size: 0.74rem;
    font-weight: 700;
    background: transparent;
    border: none;
    border-bottom: 2px solid transparent;
    color: var(--text-muted);
    cursor: pointer;
    font-family: inherit;
    transition: all var(--transition-fast);
  }

  .leaderboard-tab:hover {
    color: var(--text-color);
  }

  .leaderboard-tab.active {
    color: var(--primary-color);
    border-bottom-color: var(--primary-color);
  }

  .lb-row {
    display: flex;
    align-items: center;
    gap: var(--space-3);
    padding: 10px var(--space-4);
    border-bottom: 1px solid var(--border-color);
  }

  .lb-row:last-child {
    border-bottom: none;
  }

  .lb-rank {
    width: 26px;
    text-align: center;
    font-size: 1.05rem;
    flex-shrink: 0;
    line-height: 1;
  }

  .lb-info {
    flex: 1;
    min-width: 0;
  }

  .lb-name {
    font-size: 0.82rem;
    font-weight: 700;
    color: var(--text-color);
    margin-bottom: 5px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .lb-bar-wrap {
    height: 4px;
    background: var(--surface-sunken);
    border-radius: 2px;
    overflow: hidden;
  }

  .lb-bar {
    height: 100%;
    background: var(--primary-color);
    border-radius: 2px;
  }

  .lb-stats {
    text-align: right;
    flex-shrink: 0;
  }

  .lb-rev {
    font-size: 0.82rem;
    font-weight: 800;
    color: var(--text-color);
  }

  .lb-txn {
    font-size: 0.68rem;
    color: var(--text-muted);
    margin-top: 1px;
  }

  /* ── Best sellers ────────────────────────────────────────── */
  .bestseller-row {
    display: flex;
    align-items: center;
    gap: var(--space-3);
    padding: 10px var(--space-4);
    border-bottom: 1px solid var(--border-color);
  }

  .bestseller-row:last-child {
    border-bottom: none;
  }

  .bestseller-cat {
    font-size: 0.60rem;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--text-muted);
    width: 76px;
    flex-shrink: 0;
    line-height: 1.3;
  }

  .bestseller-body {
    flex: 1;
    min-width: 0;
  }

  .bestseller-name {
    font-size: 0.82rem;
    font-weight: 700;
    color: var(--text-color);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .bestseller-meta {
    display: flex;
    align-items: center;
    gap: 5px;
    margin-top: 2px;
    flex-wrap: wrap;
  }

  .bestseller-badge {
    font-size: 0.66rem;
    font-weight: 700;
    background: var(--primary-subtle);
    color: var(--primary-color);
    border: 1px solid rgba(192, 57, 43, 0.15);
    padding: 1px 6px;
    border-radius: var(--radius-full);
  }

  .bestseller-price {
    font-size: 0.80rem;
    font-weight: 800;
    color: var(--primary-color);
    flex-shrink: 0;
  }

  /* ── Session dot pulse ───────────────────────────────────── */
  .session-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    flex-shrink: 0;
  }

  .session-dot.active {
    background: var(--status-ready);
    box-shadow: 0 0 0 3px rgba(5, 150, 105, 0.15);
    animation: pulse 2s infinite;
  }

  .session-dot.offline {
    background: var(--border-strong);
  }

  @keyframes pulse {

    0%,
    100% {
      box-shadow: 0 0 0 3px rgba(5, 150, 105, 0.15);
    }

    50% {
      box-shadow: 0 0 0 5px rgba(5, 150, 105, 0.05);
    }
  }
</style>

<div class="page-header">
  <div>
    <div class="page-header-title">Dashboard</div>
    <div class="page-header-sub"><?= date('l, F j, Y') ?> — Overview of today's activity</div>
  </div>
  <div class="page-header-actions">
    <a href="<?= APP_URL ?>/admin/reports.php" class="btn btn-ghost">
      <i class="fa-solid fa-chart-bar"></i> Reports
    </a>
  </div>
</div>

<!-- KPI cards -->
<div class="stats-grid">
  <div class="stat-card stat-red">
    <div class="stat-icon red"><i class="fa-solid fa-peso-sign"></i></div>
    <div class="stat-content">
      <div class="stat-label">Today's Revenue</div>
      <div class="stat-value"><?= peso($todaySales) ?></div>
      <div class="stat-sub">All non-cancelled orders</div>
    </div>
  </div>
  <div class="stat-card stat-brown">
    <div class="stat-icon brown"><i class="fa-solid fa-receipt"></i></div>
    <div class="stat-content">
      <div class="stat-label">Transactions Today</div>
      <div class="stat-value"><?= $todayCount ?></div>
      <div class="stat-sub">Walk-in &amp; pre-orders</div>
    </div>
  </div>
  <div class="stat-card stat-gold">
    <div class="stat-icon gold"><i class="fa-solid fa-clock"></i></div>
    <div class="stat-content">
      <div class="stat-label">Active Pre-orders</div>
      <div class="stat-value"><?= $activePreorders ?></div>
      <div class="stat-sub">Pending · Preparing · Ready</div>
    </div>
  </div>
  <div class="stat-card <?= $pendingRefunds > 0 ? 'stat-red' : '' ?>">
    <div class="stat-icon <?= $pendingRefunds > 0 ? 'red' : 'green' ?>">
      <i class="fa-solid fa-rotate-left"></i>
    </div>
    <div class="stat-content">
      <div class="stat-label">Pending Refunds</div>
      <div class="stat-value"><?= $pendingRefunds ?></div>
      <div class="stat-sub"><?= $pendingRefunds > 0
                              ? '<a href="' . APP_URL . '/admin/refunds.php" style="color:var(--primary-color);font-weight:600">Review requests →</a>'
                              : 'All clear' ?></div>
    </div>
  </div>
</div>

<!-- Row 2: Revenue chart | Top Cashier Leaderboard -->
<div class="dash-grid-chart">

  <div class="card">
    <div class="card-header">
      <div class="card-title"><i class="fa-solid fa-chart-line"></i> Revenue — Last 7 Days</div>
    </div>
    <div class="card-body"><canvas id="salesChart" height="100"></canvas></div>
  </div>

  <!-- Top Cashier Leaderboard -->
  <div class="card">
    <div class="card-header" style="padding-bottom:0">
      <div class="card-title"><i class="fa-solid fa-ranking-star"></i> Top Cashiers</div>
    </div>
    <div style="display:flex;border-bottom:1px solid var(--border-color)">
      <?php foreach (['today' => 'Today', 'week' => 'This Week', 'month' => 'This Month', 'year' => 'This Year'] as $k => $lbl): ?>
        <button class="leaderboard-tab <?= $k === 'today' ? 'active' : '' ?>"
          data-period="<?= $k ?>" onclick="switchLB('<?= $k ?>')"><?= $lbl ?></button>
      <?php endforeach; ?>
    </div>
    <?php foreach ($leaderboards as $period => $rows): ?>
      <div id="lb-<?= $period ?>" style="<?= $period !== 'today' ? 'display:none' : '' ?>">
        <?php if (empty($rows)): ?>
          <div style="padding:var(--space-6);text-align:center;color:var(--text-muted);font-size:0.84rem">
            <i class="fa-solid fa-mug-hot" style="display:block;font-size:24px;opacity:0.13;margin-bottom:8px"></i>
            No transactions in this period
          </div>
          <?php else:
          $maxRev = (float)max(array_column($rows, 'revenue'));
          $medals = ['🥇', '🥈', '🥉'];
          foreach ($rows as $i => $r):
            $pct = $maxRev > 0 ? round((float)$r['revenue'] / $maxRev * 100) : 0;
          ?>
            <div class="lb-row">
              <div class="lb-rank"><?= $medals[$i] ?? ($i + 1) ?></div>
              <div class="lb-info">
                <div class="lb-name"><?= e($r['full_name']) ?></div>
                <div class="lb-bar-wrap">
                  <div class="lb-bar" style="width:<?= $pct ?>%"></div>
                </div>
              </div>
              <div class="lb-stats">
                <div class="lb-rev"><?= peso($r['revenue']) ?></div>
                <div class="lb-txn"><?= $r['txn_count'] ?> txn<?= $r['txn_count'] != 1 ? 's' : '' ?>
                  <?php if ($r['avg_rating']): ?>
                    · <span style="color:var(--accent-color)">★</span><?= $r['avg_rating'] ?>
                  <?php endif; ?>
                </div>
              </div>
            </div>
        <?php endforeach;
        endif; ?>
      </div>
    <?php endforeach; ?>
  </div>

</div>

<!-- Row 3: Best sellers | Recent orders -->
<div class="dash-grid-sellers">

  <!-- Best sellers per category -->
  <div class="card">
    <div class="card-header">
      <div class="card-title"><i class="fa-solid fa-fire"></i> Best Sellers</div>
    </div>
    <div>
      <?php if (empty($bestSellers)): ?>
        <div style="padding:var(--space-6);text-align:center;color:var(--text-muted);font-size:0.84rem">
          <i class="fa-solid fa-box-open" style="display:block;font-size:24px;opacity:0.13;margin-bottom:8px"></i>
          No products yet
        </div>
      <?php else: ?>
        <?php foreach ($bestSellers as $row): ?>
          <div class="bestseller-row">
            <div class="bestseller-cat"><?= e($row['cat_name']) ?></div>
            <div class="bestseller-body">
              <div class="bestseller-name"><?= e($row['prod_name']) ?></div>
              <div class="bestseller-meta">
                <?php if ($row['total_qty'] > 0): ?>
                  <span class="bestseller-badge"><?= $row['total_qty'] ?> sold</span>
                  <span style="color:var(--status-ready);font-weight:600;font-size:0.70rem"><?= peso($row['total_rev']) ?></span>
                <?php else: ?>
                  <span style="color:var(--text-muted);font-size:0.70rem">No orders yet</span>
                <?php endif; ?>
              </div>
            </div>
            <div class="bestseller-price"><?= peso($row['price']) ?></div>
          </div>
        <?php endforeach; ?>
      <?php endif; ?>
    </div>
  </div>

  <!-- Recent orders -->
  <div class="card">
    <div class="card-header">
      <div class="card-title"><i class="fa-solid fa-list-check"></i> Recent Orders</div>
      <a href="<?= APP_URL ?>/admin/orders.php" class="btn btn-ghost btn-sm">View All</a>
    </div>
    <div style="overflow-x:auto">
      <table class="data-table">
        <thead>
          <tr>
            <th>Order No.</th>
            <th>Customer</th>
            <th>Type</th>
            <th>Amount</th>
            <th>Payment</th>
            <th>Status</th>
            <th>Time</th>
          </tr>
        </thead>
        <tbody>
          <?php if (empty($recentOrders)): ?>
            <tr>
              <td colspan="7">
                <div class="empty-state"><i class="fa-solid fa-receipt"></i>
                  <p>No orders yet</p>
                </div>
              </td>
            </tr>
            <?php else: foreach ($recentOrders as $o): ?>
              <tr>
                <td><strong><?= e($o['order_number']) ?></strong></td>
                <td><?= e($o['customer']) ?></td>
                <td><span class="badge badge-<?= $o['order_type'] === 'walk-in' ? 'walkin' : 'preorder' ?>"><?= e($o['order_type']) ?></span></td>
                <td class="num"><?= peso($o['total_amount']) ?></td>
                <td><?= e($o['payment_method'] ?? '—') ?></td>
                <td><span class="badge badge-<?= e($o['status']) ?>"><?= e($o['status']) ?></span></td>
                <td class="text-muted"><?= date('g:i A', strtotime($o['created_at'])) ?></td>
              </tr>
          <?php endforeach;
          endif; ?>
        </tbody>
      </table>
    </div>
  </div>

</div>

<!-- Row 4: Cashier Session Log -->
<div class="card" style="margin-bottom:var(--space-5)">
  <div class="card-header">
    <div class="card-title"><i class="fa-solid fa-clock-rotate-left"></i> Cashier Session Log</div>
    <span style="font-size:0.74rem;color:var(--text-muted)">Last 50 sessions, most recent first</span>
  </div>
  <?php if (empty($sessionLog)): ?>
    <div style="padding:var(--space-6);text-align:center;color:var(--text-muted);font-size:0.84rem">
      <i class="fa-solid fa-database" style="display:block;font-size:24px;opacity:0.13;margin-bottom:8px"></i>
      No session data — run <code style="background:var(--surface-sunken);padding:1px 5px;border-radius:3px">cashier_sessions_migration.sql</code> first
    </div>
  <?php else: ?>
    <div style="overflow-x:auto">
      <table class="data-table">
        <thead>
          <tr>
            <th>Cashier</th>
            <th>Login</th>
            <th>Logout</th>
            <th>Duration</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($sessionLog as $s):
            $active  = $s['logout_at'] === null;
            $durMin  = (int)$s['duration_min'];
            $durStr  = $durMin < 60
              ? $durMin . 'm'
              : floor($durMin / 60) . 'h ' . ($durMin % 60) . 'm';
          ?>
            <tr>
              <td>
                <div style="display:flex;align-items:center;gap:8px">
                  <span class="session-dot <?= $active ? 'active' : 'offline' ?>"></span>
                  <strong><?= e($s['full_name']) ?></strong>
                </div>
              </td>
              <td class="text-muted"><?= date('M j, g:i A', strtotime($s['login_at'])) ?></td>
              <td class="text-muted"><?= $active ? '—' : date('M j, g:i A', strtotime($s['logout_at'])) ?></td>
              <td><?= $durStr ?></td>
              <td>
                <?php if ($active): ?>
                  <span class="badge" style="background:var(--status-ready-bg);color:var(--status-ready);border:1px solid var(--status-ready-border)">
                    ● Active
                  </span>
                <?php else: ?>
                  <span class="badge badge-claimed">Logged out</span>
                <?php endif; ?>
              </td>
            </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  <?php endif; ?>
</div>

<script>
  function switchLB(period) {
    document.querySelectorAll('[id^="lb-"]').forEach(el => el.style.display = 'none');
    document.querySelectorAll('.leaderboard-tab').forEach(t => t.classList.remove('active'));
    document.getElementById('lb-' + period).style.display = '';
    document.querySelector('[data-period="' + period + '"]').classList.add('active');
  }

  const cc = getComputedStyle(document.documentElement);
  const clr = k => cc.getPropertyValue(k).trim();

  new Chart(document.getElementById('salesChart'), {
    type: 'line',
    data: {
      labels: <?= json_encode($chartLabels) ?>,
      datasets: [{
        label: 'Revenue',
        data: <?= json_encode($chartData) ?>,
        borderColor: clr('--primary-color'),
        backgroundColor: 'rgba(192,57,43,0.07)',
        fill: true,
        tension: 0.4,
        pointBackgroundColor: clr('--primary-color'),
        pointRadius: 4,
        pointHoverRadius: 6,
        borderWidth: 2,
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: {
          display: false
        }
      },
      scales: {
        y: {
          ticks: {
            callback: v => '₱' + v.toLocaleString()
          },
          grid: {
            color: 'rgba(0,0,0,0.04)'
          }
        },
        x: {
          grid: {
            display: false
          }
        }
      }
    }
  });
</script>

<?php layoutFooter(); ?>