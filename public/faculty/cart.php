<?php
require_once __DIR__ . '/../../config/init.php';
requireRole(ROLE_FACULTY);
$db = Database::getInstance();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['place_order'])) {
  verifyCsrf();
  $items     = json_decode($_POST['cart_json'] ?? '[]', true);
  $methodRaw = sanitizeString($_POST['payment_method'] ?? '');
  $ref       = sanitizeString($_POST['reference_no'] ?? '', 100);
  $onlineMethods = ['GCash', 'PayMaya', 'Online Banking'];
  $method    = in_array($methodRaw, $onlineMethods, true) ? $methodRaw : PAY_ONLINE;
  $notes     = sanitizeString($_POST['notes'] ?? '', 500);

  if (empty($items)) {
    flash('global', 'Your cart is empty.', 'error');
    redirect(APP_URL . '/faculty/cart.php');
  }
  if (empty($ref)) {
    flash('global', 'Reference number is required.', 'error');
    redirect(APP_URL . '/faculty/cart.php');
  }

  $total = 0; $details = []; $ok = true;
  foreach ($items as $item) {
    $pid  = (int)($item['id'] ?? 0);
    $stmt = $db->prepare("SELECT id,name,price FROM products WHERE id=? AND is_available=1");
    $stmt->execute([$pid]);
    $prod = $stmt->fetch();
    if (!$prod) {
      flash('global', 'A product in your cart is no longer available.', 'error');
      $ok = false; break;
    }
    $qty   = (int)$item['qty'];
    $price = isset($item['price']) && $item['price'] > 0 ? round((float)$item['price'], 2) : (float)$prod['price'];
    $sub   = $price * $qty;
    $total += $sub;
    $note  = sanitizeString($item['note'] ?? '', 300);
    $details[] = ['product_id' => $prod['id'], 'qty' => $qty, 'price' => $price, 'sub' => $sub, 'note' => $note];
  }

  if ($ok) {
    $db->beginTransaction();
    try {
      $orderNo = generateOrderNumber();
      $db->prepare(
        "INSERT INTO orders (order_number,order_type,status,faculty_id,total_amount,notes) VALUES (?,?,?,?,?,?)"
      )->execute([$orderNo, ORDER_PREORDER, STATUS_PENDING, currentUserId(), $total, $notes]);
      $orderId = (int)$db->lastInsertId();

      $stmt = $db->prepare(
        "INSERT INTO order_details (order_id,product_id,quantity,price_at_time,subtotal,customization_note) VALUES (?,?,?,?,?,?)"
      );
      foreach ($details as $d) {
        $stmt->execute([$orderId, $d['product_id'], $d['qty'], $d['price'], $d['sub'], $d['note']]);
      }
      $db->prepare(
        "INSERT INTO payments (order_id,payment_method,amount_paid,payment_status,reference_number,paid_at) VALUES (?,?,?,?,?,NOW())"
      )->execute([$orderId, $method, $total, PAY_STATUS_PAID, $ref]);
      $db->commit();
      auditLog(ROLE_FACULTY, currentUserId(), 'place_preorder', 'orders', $orderId);
      flash('global', "Order {$orderNo} placed! Show your faculty ID when claiming.", 'success');
      redirect(APP_URL . '/faculty/dashboard.php');
    } catch (\Throwable $e) {
      $db->rollBack();
      error_log($e->getMessage());
      flash('global', 'Order failed. Please try again.', 'error');
      redirect(APP_URL . '/faculty/cart.php');
    }
  } else {
    redirect(APP_URL . '/faculty/cart.php');
  }
}

$imgBase  = APP_URL . '/../uploads/products/';
$products = $db->query("SELECT id, image_path FROM products WHERE is_available = 1")->fetchAll();

layoutHeader('My Cart', '');
?>
<style>
  :root { --pay-gcash:#007AFF; --pay-paymaya:#4caf50; }

  .cart-layout { display:grid; grid-template-columns:1fr 360px; gap:var(--space-6); align-items:start; }
  @media(max-width:860px){ .cart-layout{grid-template-columns:1fr} .cart-sidebar{order:-1} }

  .cart-item-row {
    display:grid; grid-template-columns:52px 44px 1fr 72px 28px;
    align-items:center; gap:var(--space-3); padding:var(--space-3) 0;
    border-bottom:1px solid var(--border-color); animation:rowIn 0.2s ease both;
  }
  .cart-item-row:last-child{border-bottom:none}
  @keyframes rowIn{from{opacity:0;transform:translateX(-8px)}to{opacity:1;transform:translateX(0)}}

  .cart-item-thumb{width:52px;height:52px;flex-shrink:0;border-radius:var(--radius-sm);background:var(--surface-raised);border:1px solid var(--border-color);overflow:hidden;display:flex;align-items:center;justify-content:center}
  .cart-item-thumb img{width:100%;height:100%;object-fit:cover}
  .cart-item-thumb-icon{font-size:18px;color:var(--border-strong)}
  .cart-item-info{min-width:0}
  .cart-item-name{font-size:0.86rem;font-weight:700;color:var(--text-color);line-height:1.3;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
  .cart-item-unit{font-size:0.70rem;color:var(--text-muted);margin-top:1px}
  .cart-item-note{font-size:0.68rem;color:var(--text-muted);margin-top:1px;line-height:1.35}

  .qty-control{display:flex;flex-direction:column;align-items:center;gap:2px}
  .qty-btn{width:28px;height:20px;border-radius:var(--radius-xs);background:var(--surface-raised);border:1px solid var(--border-color);font-size:13px;font-weight:700;color:var(--text-secondary);cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all var(--transition-fast);font-family:inherit;line-height:1}
  .qty-btn:hover{background:var(--primary-color);color:var(--text-on-primary);border-color:var(--primary-color)}
  .qty-btn.minus:hover{background:var(--status-cancelled-bg);color:var(--status-cancelled);border-color:var(--status-cancelled-border)}
  .qty-input{width:34px;height:24px;text-align:center;border:1px solid var(--border-color);border-radius:var(--radius-xs);background:var(--surface-color);font-size:0.84rem;font-weight:700;font-family:inherit;color:var(--text-color);outline:none}
  .qty-input:focus{border-color:var(--primary-color)}
  .cart-item-sub{text-align:right;font-size:0.88rem;font-weight:800;color:var(--text-color)}
  .cart-remove{width:30px;height:30px;flex-shrink:0;border-radius:var(--radius-sm);background:transparent;border:1px solid transparent;color:var(--text-muted);font-size:12px;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all var(--transition-fast)}
  .cart-remove:hover{background:var(--status-cancelled-bg);border-color:var(--status-cancelled-border);color:var(--status-cancelled)}

  .cart-empty-state{text-align:center;padding:var(--space-10) var(--space-6)}
  .cart-empty-state i{font-size:40px;color:var(--border-strong);display:block;margin-bottom:var(--space-4)}
  .cart-empty-state h3{font-size:1rem;font-weight:700;margin-bottom:var(--space-2)}
  .cart-empty-state p{font-size:0.84rem;color:var(--text-muted)}

  .summary-line{display:flex;justify-content:space-between;align-items:center;padding:var(--space-2) 0;font-size:0.84rem;color:var(--text-secondary)}
  .summary-total{display:flex;justify-content:space-between;align-items:center;padding:var(--space-4) 0 var(--space-3);border-top:2px solid var(--border-color);margin-top:var(--space-2)}
  .summary-total-label{font-size:0.80rem;font-weight:700;text-transform:uppercase;letter-spacing:0.05em;color:var(--text-secondary)}
  .summary-total-value{font-size:1.50rem;font-weight:800;color:var(--primary-color);letter-spacing:-0.02em;transition:all 0.2s cubic-bezier(0.34,1.2,0.64,1)}

  .pay-tabs{display:grid;grid-template-columns:repeat(3,1fr);gap:var(--space-2);margin-bottom:var(--space-4)}
  .pay-tab{border:1.5px solid var(--border-color);border-radius:var(--radius-sm);padding:var(--space-3) var(--space-2);text-align:center;cursor:pointer;transition:all var(--transition-fast);background:var(--surface-color)}
  .pay-tab:hover{border-color:var(--primary-color);background:var(--primary-subtle)}
  .pay-tab.active{border-color:var(--primary-color);background:var(--primary-subtle);box-shadow:0 0 0 2px var(--primary-subtle)}
  .pay-tab input{display:none}
  .pay-tab-icon{font-size:18px;margin-bottom:4px}
  .pay-tab-label{font-size:0.72rem;font-weight:700;color:var(--text-secondary);display:block}
  .pay-tab.active .pay-tab-label{color:var(--primary-color)}

  .place-btn{width:100%;height:48px;background:var(--primary-color);color:var(--text-on-primary);border:none;border-radius:var(--radius-md);font-size:0.92rem;font-weight:700;font-family:inherit;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:var(--space-2);box-shadow:var(--shadow-primary);transition:all var(--transition-fast)}
  .place-btn:hover{background:var(--primary-dark);transform:translateY(-1px);box-shadow:0 6px 20px rgba(192,57,43,0.38)}
  .place-btn:active{transform:translateY(0)}
  .place-btn:disabled{opacity:0.45;cursor:not-allowed;pointer-events:none;transform:none}

  .id-reminder{display:flex;align-items:flex-start;gap:var(--space-3);background:var(--accent-subtle);border:1px solid rgba(240,180,41,0.25);border-radius:var(--radius-sm);padding:var(--space-3) var(--space-4);margin-top:var(--space-4);font-size:0.78rem;line-height:1.5;color:var(--text-secondary)}
  .id-reminder i{color:var(--accent-dark);font-size:14px;flex-shrink:0;margin-top:1px}

  input[type=number]::-webkit-inner-spin-button,
  input[type=number]::-webkit-outer-spin-button{-webkit-appearance:none;margin:0}
  input[type=number]{-moz-appearance:textfield}
</style>

<div class="page-header">
  <div>
    <div class="page-header-title">My Cart</div>
    <div class="page-header-sub">Review your items and complete payment to place your order</div>
  </div>
  <div class="page-header-actions">
    <a href="<?= APP_URL ?>/faculty/menu.php" class="btn btn-ghost btn-sm">
      <i class="fa-solid fa-arrow-left"></i> Back to Menu
    </a>
  </div>
</div>
<?php showFlash('global'); ?>

<div class="cart-layout">
  <div class="card">
    <div class="card-header">
      <div class="card-title"><i class="fa-solid fa-cart-shopping"></i> Cart Items</div>
      <span class="text-muted" id="item-count" style="font-size:0.78rem"></span>
    </div>
    <div id="cart-display" style="padding:0 var(--space-5)">
      <div class="cart-empty-state">
        <i class="fa-solid fa-cart-shopping"></i>
        <h3>Loading cart…</h3>
      </div>
    </div>
  </div>

  <div class="cart-sidebar">
    <div class="card mb-4">
      <div class="card-header">
        <div class="card-title"><i class="fa-solid fa-receipt"></i> Order Summary</div>
      </div>
      <div class="card-body" style="padding-bottom:var(--space-3)">
        <div class="summary-line"><span>Subtotal</span><span id="sub-total">₱0.00</span></div>
        <div class="summary-line"><span>Service fee</span><span style="color:var(--status-ready);font-weight:600">Free</span></div>
        <div class="summary-total">
          <div class="summary-total-label">Total</div>
          <div class="summary-total-value" id="order-total">₱0.00</div>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <div class="card-title"><i class="fa-solid fa-money-bill-transfer"></i> Payment</div>
      </div>
      <div class="card-body">
        <form id="checkout-form" method="POST">
          <?= csrfField() ?>
          <input type="hidden" name="place_order" value="1">
          <input type="hidden" name="cart_json" id="cart-json">

          <div style="font-size:0.76rem;font-weight:600;color:var(--text-secondary);margin-bottom:var(--space-3)">Payment Method</div>
          <div class="pay-tabs" id="pay-tabs">
            <label class="pay-tab active">
              <input type="radio" name="payment_method" value="GCash" checked>
              <div class="pay-tab-icon" style="color:var(--pay-gcash)"><i class="fa-solid fa-mobile-screen-button"></i></div>
              <span class="pay-tab-label">GCash</span>
            </label>
            <label class="pay-tab">
              <input type="radio" name="payment_method" value="PayMaya">
              <div class="pay-tab-icon" style="color:var(--pay-paymaya)"><i class="fa-solid fa-wallet"></i></div>
              <span class="pay-tab-label">PayMaya</span>
            </label>
            <label class="pay-tab">
              <input type="radio" name="payment_method" value="Online Banking">
              <div class="pay-tab-icon" style="color:var(--secondary-color)"><i class="fa-solid fa-building-columns"></i></div>
              <span class="pay-tab-label">Bank</span>
            </label>
          </div>

          <div class="form-group">
            <label class="form-label">Reference Number <span class="req">*</span></label>
            <input type="text" name="reference_no" id="ref-input" class="form-control"
              required placeholder="e.g. 09123456789" autocomplete="off"
              style="font-family:monospace;letter-spacing:0.04em;font-size:0.88rem">
            <div class="form-hint" id="ref-hint">Enter your GCash reference number</div>
          </div>

          <div class="form-group">
            <label class="form-label">Notes <span style="font-weight:400;color:var(--text-muted)">(optional)</span></label>
            <textarea name="notes" class="form-control" rows="2" placeholder="Special instructions, sugar level, etc."></textarea>
          </div>

          <button type="submit" class="place-btn" id="place-btn" disabled>
            <i class="fa-solid fa-lock"></i>
            Place Order · <span id="btn-total">₱0.00</span>
          </button>

          <div class="id-reminder">
            <i class="fa-solid fa-id-card"></i>
            <div>Bring your <strong>faculty ID</strong> when claiming your order at the counter.</div>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<script>
  <?php
  $imageMap = [];
  foreach ($products as $p) {
    if (!empty($p['image_path']) && file_exists(UPLOAD_DIR . $p['image_path'])) {
      $imageMap[$p['id']] = $imgBase . $p['image_path'];
    }
  }
  ?>
  const productImages = <?= json_encode($imageMap, JSON_UNESCAPED_SLASHES|JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT) ?>;
</script>

<script>
  function getCart()   { return JSON.parse(sessionStorage.getItem('faculty_cart') || '{}'); }
  function saveCart(c) { sessionStorage.setItem('faculty_cart', JSON.stringify(c)); }

  function changeQty(key, delta) {
    const cart = getCart();
    if (!cart[key]) return;
    cart[key].qty = Math.max(0, cart[key].qty + delta);
    if (cart[key].qty === 0) delete cart[key];
    saveCart(cart); renderCart();
  }
  function setQty(key, val) {
    const cart = getCart();
    const qty  = parseInt(val, 10);
    if (isNaN(qty) || qty <= 0) delete cart[key];
    else if (cart[key]) cart[key].qty = qty;
    saveCart(cart); renderCart();
  }
  function removeItem(key) { const cart = getCart(); delete cart[key]; saveCart(cart); renderCart(); }

  function renderCart() {
    const cart = getCart();
    const keys = Object.keys(cart);
    const el   = document.getElementById('cart-display');
    document.getElementById('item-count').textContent =
      keys.length > 0 ? keys.length + (keys.length === 1 ? ' item' : ' items') : '';

    if (keys.length === 0) {
      el.innerHTML = '<div class="cart-empty-state"><i class="fa-solid fa-cart-shopping"></i><h3>Your cart is empty</h3><p><a href="faculty/menu.php" style="color:var(--primary-color);font-weight:600">Browse the menu →</a></p></div>';
      setTotals(0);
      document.getElementById('place-btn').disabled = true;
      document.getElementById('cart-json').value = '[]';
      return;
    }

    let total = 0, html = '', cartArr = [];
    keys.forEach(key => {
      const item = cart[key];
      const id   = item.productId;
      const sub  = item.price * item.qty;
      total += sub;
      cartArr.push({ id, qty: item.qty, price: item.price, note: item.note || '' });
      const imgSrc   = productImages[id];
      const thumb    = imgSrc ? '<img src="' + imgSrc + '" alt="' + item.name + '">' : '<span class="cart-item-thumb-icon"><i class="fa-solid fa-mug-hot"></i></span>';
      const noteHtml = item.note ? '<div class="cart-item-note">' + item.note + '</div>' : '';
      html +=
        '<div class="cart-item-row" id="row-' + key + '">' +
        '<div class="cart-item-thumb">' + thumb + '</div>' +
        '<div class="qty-control">' +
        '<button class="qty-btn" onclick="changeQty(\'' + key + '\',1)">+</button>' +
        '<input class="qty-input" type="number" min="1" max="99" value="' + item.qty + '" onchange="setQty(\'' + key + '\',this.value)" onblur="setQty(\'' + key + '\',this.value)" onclick="this.select()">' +
        '<button class="qty-btn minus" onclick="changeQty(\'' + key + '\',-1)">−</button>' +
        '</div>' +
        '<div class="cart-item-info"><div class="cart-item-name">' + item.name + '</div>' + noteHtml + '<div class="cart-item-unit">₱' + parseFloat(item.price).toFixed(2) + ' each</div></div>' +
        '<div class="cart-item-sub">₱' + sub.toFixed(2) + '</div>' +
        '<button class="cart-remove" onclick="removeItem(\'' + key + '\')"><i class="fa-solid fa-xmark"></i></button>' +
        '</div>';
    });

    el.innerHTML = '<div style="padding:0">' + html + '</div>';
    setTotals(total);
    document.getElementById('cart-json').value = JSON.stringify(cartArr);
    document.getElementById('place-btn').disabled = false;
    document.getElementById('btn-total').textContent = '₱' + total.toFixed(2);
  }

  function setTotals(total) {
    document.getElementById('sub-total').textContent   = '₱' + total.toFixed(2);
    document.getElementById('order-total').textContent = '₱' + total.toFixed(2);
    document.getElementById('btn-total').textContent   = '₱' + total.toFixed(2);
  }

  const hints = { GCash:'Enter your GCash reference number', PayMaya:'Enter your PayMaya reference number', 'Online Banking':'Enter your bank transaction reference' };
  document.getElementById('pay-tabs').addEventListener('change', e => {
    document.querySelectorAll('.pay-tab').forEach(t => t.classList.remove('active'));
    e.target.closest('.pay-tab').classList.add('active');
    document.getElementById('ref-hint').textContent = hints[e.target.value] || 'Enter your reference number';
  });

  document.getElementById('checkout-form').addEventListener('submit', function() {
    const cart = getCart();
    const cartArr = Object.entries(cart).map(([key, i]) => ({ id: i.productId, qty: i.qty, price: i.price, note: i.note || '' }));
    document.getElementById('cart-json').value = JSON.stringify(cartArr);
    sessionStorage.removeItem('faculty_cart');
  });

  renderCart();
</script>
<?php layoutFooter(); ?>
