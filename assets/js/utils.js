// assets/js/utils.js
// Small reusable JavaScript utilities used across the app.

/**
 * peso(amount)
 * Formats a number as Philippine Peso.
 * Example: peso(1234.5) → "₱1,234.50"
 */
function peso(amount) {
  return '₱' + parseFloat(amount).toLocaleString('en-PH', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });
}

/**
 * showToast(message, type)
 * Shows a small notification that auto-dismisses.
 * type: 'success' | 'error' | 'warning'
 * Creates the toast element if it doesn't exist yet.
 */
function showToast(message, type = 'success') {
  let toast = document.getElementById('app-toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'app-toast';
    toast.style.cssText = `
      position:fixed;bottom:24px;right:24px;padding:12px 20px;
      border-radius:6px;font-size:.84rem;display:flex;align-items:center;
      gap:10px;transform:translateY(80px);transition:transform .3s;
      z-index:9999;font-family:'DM Sans',sans-serif;box-shadow:0 4px 20px rgba(0,0,0,.15);
      max-width:320px;
    `;
    document.body.appendChild(toast);
  }

  const colors = {
    success: { bg: '#1e0d0d', icon: 'fa-circle-check',   iconColor: '#f4c430' },
    error:   { bg: '#991b1b', icon: 'fa-circle-xmark',   iconColor: '#fff' },
    warning: { bg: '#92400e', icon: 'fa-triangle-exclamation', iconColor: '#fbbf24' },
  };
  const style = colors[type] || colors.success;

  toast.style.background = style.bg;
  toast.style.color = '#fff';
  toast.innerHTML = `<i class="fa-solid ${style.icon}" style="color:${style.iconColor};flex-shrink:0"></i> ${message}`;
  toast.style.transform = 'translateY(0)';

  clearTimeout(toast._timeout);
  toast._timeout = setTimeout(() => {
    toast.style.transform = 'translateY(80px)';
  }, 3000);
}

/**
 * confirmDelete(message, formOrCallback)
 * Shows a browser confirm dialog. Returns true if user confirms.
 * Usage: <form onsubmit="return confirmDelete('Delete this item?')">
 */
function confirmDelete(message) {
  return confirm(message || 'Are you sure you want to delete this? This cannot be undone.');
}

/**
 * fetchJSON(url, options)
 * Wrapper around fetch() that automatically:
 * - Sets Content-Type to application/json
 * - Includes the CSRF token in headers
 * - Returns parsed JSON
 */
async function fetchJSON(url, options = {}) {
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';

  const defaults = {
    headers: {
      'Content-Type':   'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-TOKEN':   csrfToken,
    },
  };

  const merged = {
    ...defaults,
    ...options,
    headers: { ...defaults.headers, ...(options.headers || {}) },
  };

  const response = await fetch(url, merged);
  return response.json();
}
