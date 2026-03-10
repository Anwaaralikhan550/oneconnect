/**
 * API Client — wraps fetch() with JWT auth headers and 401 handling.
 */
const API_BASE = '/api/v1';

function getToken() {
  return localStorage.getItem('admin_token');
}

function setToken(token) {
  localStorage.setItem('admin_token', token);
}

function getRefreshToken() {
  return localStorage.getItem('admin_refresh_token');
}

function setRefreshToken(token) {
  localStorage.setItem('admin_refresh_token', token);
}

function clearAuth() {
  localStorage.removeItem('admin_token');
  localStorage.removeItem('admin_refresh_token');
  localStorage.removeItem('admin_name');
  localStorage.removeItem('admin_email');
}

async function refreshAccessToken() {
  const refreshToken = getRefreshToken();
  if (!refreshToken) return false;

  try {
    const res = await fetch(`${API_BASE}/admin-auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });

    if (!res.ok) return false;

    const json = await res.json();
    if (json.success && json.data) {
      setToken(json.data.accessToken);
      setRefreshToken(json.data.refreshToken);
      return true;
    }
    return false;
  } catch {
    return false;
  }
}

async function request(method, url, data) {
  const headers = {};
  const token = getToken();
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const opts = { method, headers };
  if (method !== 'GET' && method !== 'DELETE') {
    headers['Content-Type'] = 'application/json';
    opts.body = JSON.stringify(data || {});
  }

  let res = await fetch(`${API_BASE}${url}`, opts);

  // If 401, try to refresh and retry once
  if (res.status === 401) {
    const refreshed = await refreshAccessToken();
    if (refreshed) {
      headers['Authorization'] = `Bearer ${getToken()}`;
      opts.headers = headers;
      res = await fetch(`${API_BASE}${url}`, opts);
    }
  }

  // Still 401 after refresh? Redirect to login
  if (res.status === 401) {
    clearAuth();
    window.location.href = '/admin/';
    return null;
  }

  const json = await res.json();
  if (!res.ok) {
    throw new Error(json.error || `Request failed (${res.status})`);
  }
  return json;
}

const api = {
  get: (url) => request('GET', url),
  post: (url, data) => request('POST', url, data),
  put: (url, data) => request('PUT', url, data),
  delete: (url) => request('DELETE', url),
};

// Toast notification helper
function showToast(message, type = 'success') {
  let container = document.querySelector('.toast-container');
  if (!container) {
    container = document.createElement('div');
    container.className = 'toast-container';
    document.body.appendChild(container);
  }

  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.textContent = message;
  container.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    setTimeout(() => toast.remove(), 300);
  }, 3000);
}

// Check if user is authenticated (for protected pages)
function requireAuth() {
  if (!getToken()) {
    window.location.href = '/admin/';
    return false;
  }
  return true;
}

// Set admin info in sidebar
function initSidebar() {
  const nameEl = document.getElementById('admin-name');
  const emailEl = document.getElementById('admin-email');
  if (nameEl) nameEl.textContent = localStorage.getItem('admin_name') || 'Admin';
  if (emailEl) emailEl.textContent = localStorage.getItem('admin_email') || '';

  const logoutBtn = document.getElementById('btn-logout');
  if (logoutBtn) {
    logoutBtn.addEventListener('click', async (e) => {
      e.preventDefault();
      try {
        await api.post('/admin-auth/logout', { refreshToken: getRefreshToken() });
      } catch { /* ignore */ }
      clearAuth();
      window.location.href = '/admin/';
    });
  }
}
