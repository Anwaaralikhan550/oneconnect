/**
 * Users management page logic
 */
document.addEventListener('DOMContentLoaded', () => {
  if (!requireAuth()) return;
  initSidebar();

  let currentPage = 1;
  let currentBanned = '';
  let searchTerm = '';
  let debounceTimer = null;

  const tbody = document.getElementById('users-tbody');
  const paginationEl = document.getElementById('users-pagination');
  const searchInput = document.getElementById('search-users');
  const modal = document.getElementById('user-modal');
  const modalBody = document.getElementById('user-modal-body');

  // Tab switching
  document.querySelectorAll('.tab').forEach((tab) => {
    tab.addEventListener('click', () => {
      document.querySelector('.tab.active').classList.remove('active');
      tab.classList.add('active');
      currentBanned = tab.dataset.banned;
      currentPage = 1;
      loadUsers();
    });
  });

  // Search with debounce
  searchInput.addEventListener('input', () => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      searchTerm = searchInput.value.trim();
      currentPage = 1;
      loadUsers();
    }, 400);
  });

  // Modal close
  modal.addEventListener('click', (e) => {
    if (e.target === modal || e.target.dataset.action === 'close-modal') {
      modal.classList.remove('show');
    }
  });

  // Delegate actions
  tbody.addEventListener('click', async (e) => {
    const btn = e.target.closest('button');
    if (!btn) return;

    const id = btn.dataset.id;
    if (btn.dataset.action === 'view') {
      await showUserDetail(id);
    } else if (btn.dataset.action === 'ban') {
      await toggleBan(id);
    }
  });

  async function loadUsers() {
    tbody.innerHTML = '<tr><td colspan="6" class="loading"><div class="spinner"></div></td></tr>';

    try {
      let url = `/admin-panel/users?page=${currentPage}&limit=20`;
      if (currentBanned) url += `&isBanned=${currentBanned}`;
      if (searchTerm) url += `&search=${encodeURIComponent(searchTerm)}`;

      const res = await api.get(url);
      const { data, pagination } = res;

      if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="empty-state"><p>No users found</p></td></tr>';
        paginationEl.innerHTML = '';
        return;
      }

      tbody.innerHTML = data.map((u) => `
        <tr>
          <td>${escapeHtml(u.name)}</td>
          <td>${escapeHtml(u.email)}</td>
          <td>${u.phone || '—'}</td>
          <td><span class="badge ${u.isBanned ? 'badge-banned' : 'badge-active'}">${u.isBanned ? 'Banned' : 'Active'}</span></td>
          <td>${new Date(u.createdAt).toLocaleDateString()}</td>
          <td class="actions">
            <button class="btn btn-sm btn-outline" data-action="view" data-id="${u.id}">View</button>
            <button class="btn btn-sm ${u.isBanned ? 'btn-success' : 'btn-danger'}" data-action="ban" data-id="${u.id}">
              ${u.isBanned ? 'Unban' : 'Ban'}
            </button>
          </td>
        </tr>
      `).join('');

      renderPagination(paginationEl, pagination, (page) => {
        currentPage = page;
        loadUsers();
      });
    } catch (err) {
      tbody.innerHTML = `<tr><td colspan="6" class="empty-state"><p>Error: ${err.message}</p></td></tr>`;
    }
  }

  async function showUserDetail(id) {
    modal.classList.add('show');
    modalBody.innerHTML = '<div class="loading"><div class="spinner"></div></div>';

    try {
      const res = await api.get(`/admin-panel/users/${id}`);
      const u = res.data;

      modalBody.innerHTML = `
        <div class="detail-row"><div class="detail-label">Name</div><div class="detail-value">${escapeHtml(u.name)}</div></div>
        <div class="detail-row"><div class="detail-label">Email</div><div class="detail-value">${escapeHtml(u.email)}</div></div>
        <div class="detail-row"><div class="detail-label">Phone</div><div class="detail-value">${u.phone || '—'}</div></div>
        <div class="detail-row"><div class="detail-label">Status</div><div class="detail-value"><span class="badge ${u.isBanned ? 'badge-banned' : 'badge-active'}">${u.isBanned ? 'Banned' : 'Active'}</span></div></div>
        <div class="detail-row"><div class="detail-label">Joined</div><div class="detail-value">${new Date(u.createdAt).toLocaleDateString()}</div></div>
        <div class="detail-row"><div class="detail-label">Reviews</div><div class="detail-value">${u._count.reviews}</div></div>
        <div class="detail-row"><div class="detail-label">Favorites</div><div class="detail-value">${u._count.favorites}</div></div>
      `;
    } catch (err) {
      modalBody.innerHTML = `<p>Error loading user: ${err.message}</p>`;
    }
  }

  async function toggleBan(id) {
    try {
      const res = await api.put(`/admin-panel/users/${id}/ban`);
      showToast(res.data.isBanned ? 'User banned' : 'User unbanned');
      loadUsers();
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  loadUsers();
});

// ─── SHARED HELPERS ─────────────────────────────────

function escapeHtml(str) {
  const div = document.createElement('div');
  div.textContent = str || '';
  return div.innerHTML;
}

function renderPagination(container, pagination, onPageChange) {
  const { page, totalPages, total } = pagination;
  if (totalPages <= 1) {
    container.innerHTML = `<span>Showing all ${total} results</span><div></div>`;
    return;
  }

  const start = (page - 1) * pagination.limit + 1;
  const end = Math.min(page * pagination.limit, total);

  let buttonsHtml = '';
  buttonsHtml += `<button ${page <= 1 ? 'disabled' : ''} data-page="${page - 1}">&laquo; Prev</button>`;
  for (let i = Math.max(1, page - 2); i <= Math.min(totalPages, page + 2); i++) {
    buttonsHtml += `<button class="${i === page ? 'active' : ''}" data-page="${i}">${i}</button>`;
  }
  buttonsHtml += `<button ${page >= totalPages ? 'disabled' : ''} data-page="${page + 1}">Next &raquo;</button>`;

  container.innerHTML = `
    <span>Showing ${start}–${end} of ${total}</span>
    <div class="pagination-buttons">${buttonsHtml}</div>
  `;

  container.querySelectorAll('.pagination-buttons button').forEach((btn) => {
    btn.addEventListener('click', () => {
      const p = parseInt(btn.dataset.page, 10);
      if (p >= 1 && p <= totalPages) onPageChange(p);
    });
  });
}
