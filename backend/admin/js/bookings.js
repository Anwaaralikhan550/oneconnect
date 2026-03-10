const state = {
  scope: 'today',
  page: 1,
  limit: 20,
};

document.addEventListener('DOMContentLoaded', async () => {
  if (!requireAuth()) return;
  initSidebar();

  const scopeFilter = document.getElementById('scope-filter');
  scopeFilter.addEventListener('change', async () => {
    state.scope = scopeFilter.value;
    state.page = 1;
    await loadBookings();
  });

  await loadBookings();
});

async function loadBookings() {
  const statsEl = document.getElementById('booking-stats');
  const listEl = document.getElementById('booking-list');
  const paginationEl = document.getElementById('booking-pagination');

  statsEl.innerHTML = '<div class="loading"><div class="spinner"></div></div>';
  listEl.innerHTML = '<div class="loading"><div class="spinner"></div></div>';
  paginationEl.style.display = 'none';

  try {
    const res = await api.get(`/admin/bookings/stats?scope=${state.scope}&page=${state.page}&limit=${state.limit}`);
    const payload = res.data;

    renderStats(statsEl, payload);
    renderTable(listEl, payload.bookings);
    renderPagination(paginationEl, payload.pagination);
  } catch (err) {
    statsEl.innerHTML = `<div class="empty-state"><p>Failed to load stats: ${err.message}</p></div>`;
    listEl.innerHTML = `<div class="empty-state"><p>Failed to load bookings.</p></div>`;
  }
}

function renderStats(container, payload) {
  const counts = payload.statusCounts || {};
  container.innerHTML = `
    <div class="stat-card">
      <div class="stat-label">Total (Filtered)</div>
      <div class="stat-value">${payload.totalBookings || 0}</div>
    </div>
    <div class="stat-card info">
      <div class="stat-label">Total Today</div>
      <div class="stat-value">${payload.totalBookingsToday || 0}</div>
    </div>
    <div class="stat-card pending">
      <div class="stat-label">Pending</div>
      <div class="stat-value">${counts.PENDING || 0}</div>
    </div>
    <div class="stat-card success">
      <div class="stat-label">Completed</div>
      <div class="stat-value">${counts.COMPLETED || 0}</div>
    </div>
    <div class="stat-card danger">
      <div class="stat-label">Cancelled</div>
      <div class="stat-value">${counts.CANCELLED || 0}</div>
    </div>
  `;
}

function renderTable(container, bookings) {
  if (!bookings || bookings.length === 0) {
    container.innerHTML = `
      <div class="empty-state">
        <p>No bookings found for selected filter.</p>
      </div>`;
    return;
  }

  let html = `
    <table>
      <thead>
        <tr>
          <th>Customer</th>
          <th>Provider</th>
          <th>Service Type</th>
          <th>Status</th>
          <th>Location</th>
          <th>Created</th>
        </tr>
      </thead>
      <tbody>
  `;

  for (const booking of bookings) {
    const customerName = booking.customer?.name || '-';
    const providerName = booking.provider?.name || '-';
    const mapLink = getMapLink(booking.userLatitude, booking.userLongitude);
    const createdAt = new Date(booking.createdAt).toLocaleString();

    html += `
      <tr>
        <td>${escapeHtml(customerName)}</td>
        <td>${escapeHtml(providerName)}</td>
        <td>${escapeHtml(formatEnum(booking.serviceType))}</td>
        <td><span class="badge badge-${booking.status}">${escapeHtml(booking.status)}</span></td>
        <td>${mapLink}</td>
        <td>${escapeHtml(createdAt)}</td>
      </tr>
    `;
  }

  html += '</tbody></table>';
  container.innerHTML = html;
}

function getMapLink(lat, lng) {
  if (lat == null || lng == null) return '-';
  const url = `https://maps.google.com/?q=${lat},${lng}`;
  return `<a href="${url}" target="_blank" rel="noopener noreferrer">View Location</a>`;
}

function renderPagination(container, pagination) {
  if (!pagination || pagination.totalPages <= 1) {
    container.style.display = 'none';
    return;
  }

  const { page, totalPages, total } = pagination;

  container.innerHTML = `
    <div>Showing page ${page} of ${totalPages} (${total} total)</div>
    <div class="pagination-buttons">
      <button id="btn-prev" ${page <= 1 ? 'disabled' : ''}>Previous</button>
      <button id="btn-next" ${page >= totalPages ? 'disabled' : ''}>Next</button>
    </div>
  `;

  container.style.display = 'flex';

  const prevBtn = document.getElementById('btn-prev');
  const nextBtn = document.getElementById('btn-next');

  prevBtn?.addEventListener('click', async () => {
    if (state.page <= 1) return;
    state.page -= 1;
    await loadBookings();
  });

  nextBtn?.addEventListener('click', async () => {
    if (state.page >= totalPages) return;
    state.page += 1;
    await loadBookings();
  });
}

function formatEnum(value) {
  if (!value) return '-';
  return value
    .toLowerCase()
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}
