<?php
require_once __DIR__ . '/../../config/init.php';
requireRole(ROLE_ADMIN);
$db = Database::getInstance();

// Monthly summary for current year
$monthly = $db->query("SELECT MONTH(created_at) AS m, MONTHNAME(created_at) AS month_name, COALESCE(SUM(total_amount),0) AS total, COUNT(*) AS cnt FROM orders WHERE YEAR(created_at)=YEAR(NOW()) AND status!='cancelled' GROUP BY MONTH(created_at), MONTHNAME(created_at) ORDER BY m")->fetchAll();

layoutHeader('Reports', '<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>');
?>
<h2 class="mb-4" style="font-size:1.2rem">Sales Reports — <?= date('Y') ?></h2>
<div class="card" style="margin-bottom:24px">
  <div class="card-header">
    <div class="card-title"><i class="fa-solid fa-chart-bar"></i> Monthly Sales</div>
  </div>
  <div class="card-body"><canvas id="monthChart" height="100"></canvas></div>
</div>
<div class="card">
  <div style="overflow-x:auto">
    <table class="data-table">
      <thead>
        <tr>
          <th>Month</th>
          <th>Transactions</th>
          <th>Total Sales</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($monthly as $m): ?>
          <tr>
            <td><?= e($m['month_name']) ?></td>
            <td><?= $m['cnt'] ?></td>
            <td><?= peso($m['total']) ?></td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
</div>
<script>
  new Chart(document.getElementById('monthChart'), {
    type: 'bar',
    data: {
      labels: <?= json_encode(array_column($monthly, 'month_name')) ?>,
      datasets: [{
        label: 'Monthly Sales (₱)',
        data: <?= json_encode(array_column($monthly, 'total')) ?>,
        backgroundColor: 'rgba(178,34,34,.75)',
        borderRadius: 6
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