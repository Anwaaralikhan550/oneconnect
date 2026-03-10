/**
 * Dashboard page logic — stats, charts, pending items
 */
document.addEventListener('DOMContentLoaded', async () => {
  if (!requireAuth()) return;
  initSidebar();

  const statsContainer = document.getElementById('stats-grid');
  const pendingList = document.getElementById('pending-list');

  try {
    const res = await api.get('/admin-panel/dashboard/stats');
    const stats = res.data;

    statsContainer.innerHTML = `
      <div class="stat-card">
        <div class="stat-label">Total Partners</div>
        <div class="stat-value">${stats.partners.total}</div>
      </div>
      <div class="stat-card pending">
        <div class="stat-label">Pending Approvals</div>
        <div class="stat-value">${stats.totalPending}</div>
      </div>
      <div class="stat-card success">
        <div class="stat-label">Service Providers</div>
        <div class="stat-value">${stats.serviceProviders.total}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Businesses</div>
        <div class="stat-value">${stats.businesses.total}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Amenities</div>
        <div class="stat-value">${stats.amenities.total}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Promotions</div>
        <div class="stat-value">${stats.promotions.total}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Registered Users</div>
        <div class="stat-value">${stats.users.total}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Total Reviews</div>
        <div class="stat-value">${stats.reviews.total}</div>
      </div>
      <div class="stat-card pending">
        <div class="stat-label">Pending Properties</div>
        <div class="stat-value">${stats.properties.pending}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Admin Offices</div>
        <div class="stat-value">${stats.adminOffices.total}</div>
      </div>
    `;

    // Load charts and pending items in parallel
    await Promise.all([
      loadCharts(),
      loadPendingItems(pendingList, stats),
    ]);
  } catch (err) {
    statsContainer.innerHTML = `<div class="empty-state"><p>Failed to load dashboard: ${err.message}</p></div>`;
  }
});

async function loadCharts() {
  // Only render if Chart.js loaded
  if (typeof Chart === 'undefined') return;

  try {
    const [signupsRes, searchesRes] = await Promise.all([
      api.get('/admin-panel/analytics/signups'),
      api.get('/admin-panel/analytics/top-searches'),
    ]);

    renderSignupsChart(signupsRes.data);
    renderSearchesChart(searchesRes.data);
  } catch {
    // Charts are non-critical — silently skip
  }
}

function renderSignupsChart(data) {
  const ctx = document.getElementById('signups-chart');
  if (!ctx) return;

  // Build labels from last 12 months
  const months = [];
  const now = new Date();
  for (let i = 11; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    months.push(d.toISOString().slice(0, 7)); // "YYYY-MM"
  }

  const monthLabels = months.map((m) => {
    const [y, mo] = m.split('-');
    return new Date(y, mo - 1).toLocaleDateString('en', { month: 'short', year: '2-digit' });
  });

  // Map data to month buckets
  const userMap = {};
  for (const row of data.users || []) {
    const key = new Date(row.month).toISOString().slice(0, 7);
    userMap[key] = row.count;
  }
  const partnerMap = {};
  for (const row of data.partners || []) {
    const key = new Date(row.month).toISOString().slice(0, 7);
    partnerMap[key] = row.count;
  }

  new Chart(ctx, {
    type: 'line',
    data: {
      labels: monthLabels,
      datasets: [
        {
          label: 'Users',
          data: months.map((m) => userMap[m] || 0),
          borderColor: '#3499AF',
          backgroundColor: 'rgba(52,153,175,0.1)',
          fill: true,
          tension: 0.3,
        },
        {
          label: 'Partners',
          data: months.map((m) => partnerMap[m] || 0),
          borderColor: '#28a745',
          backgroundColor: 'rgba(40,167,69,0.1)',
          fill: true,
          tension: 0.3,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { position: 'top' } },
      scales: {
        y: { beginAtZero: true, ticks: { stepSize: 1 } },
      },
    },
  });
}

function renderSearchesChart(data) {
  const ctx = document.getElementById('searches-chart');
  if (!ctx) return;

  const top10 = (data || []).slice(0, 10);

  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: top10.map((r) => r.query),
      datasets: [{
        label: 'Search Count',
        data: top10.map((r) => r.count),
        backgroundColor: '#3499AF',
        borderRadius: 4,
      }],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      indexAxis: 'y',
      plugins: { legend: { display: false } },
      scales: {
        x: { beginAtZero: true, ticks: { stepSize: 1 } },
      },
    },
  });
}

async function loadPendingItems(container, stats) {
  const items = [];

  if (stats.partners.pending > 0) {
    try {
      const res = await api.get('/admin-panel/partners?status=PENDING_REVIEW&limit=5');
      for (const p of res.data) {
        items.push({ type: 'Partner', name: p.businessName, id: p.id, date: p.createdAt });
      }
    } catch { /* ignore */ }
  }

  const types = [
    { key: 'serviceProviders', urlType: 'service-providers', label: 'Service Provider' },
    { key: 'businesses', urlType: 'businesses', label: 'Business' },
    { key: 'amenities', urlType: 'amenities', label: 'Amenity' },
    { key: 'promotions', urlType: 'promotions', label: 'Promotion' },
  ];

  for (const t of types) {
    if (stats[t.key].pending > 0) {
      try {
        const res = await api.get(`/admin-panel/content/${t.urlType}?contentStatus=PENDING&limit=3`);
        for (const item of res.data) {
          items.push({
            type: t.label,
            name: item.name || item.title,
            id: item.id,
            date: item.createdAt,
          });
        }
      } catch { /* ignore */ }
    }
  }

  if (items.length === 0) {
    container.innerHTML = `
      <div class="empty-state">
        <div class="empty-icon">&#10003;</div>
        <p>No pending items. Everything is up to date!</p>
      </div>`;
    return;
  }

  let html = '<table><thead><tr><th>Type</th><th>Name</th><th>Date</th></tr></thead><tbody>';
  for (const item of items.slice(0, 10)) {
    const date = new Date(item.date).toLocaleDateString();
    html += `<tr>
      <td><span class="badge badge-pending">${item.type}</span></td>
      <td>${item.name}</td>
      <td>${date}</td>
    </tr>`;
  }
  html += '</tbody></table>';
  container.innerHTML = html;
}
