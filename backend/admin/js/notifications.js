/**
 * Broadcast Notifications page logic
 */
document.addEventListener('DOMContentLoaded', () => {
  if (!requireAuth()) return;
  initSidebar();

  let currentPage = 1;

  const titleInput = document.getElementById('notif-title');
  const bodyInput = document.getElementById('notif-body');
  const btnSend = document.getElementById('btn-send');
  const tbody = document.getElementById('history-tbody');
  const paginationEl = document.getElementById('history-pagination');

  // Send broadcast
  btnSend.addEventListener('click', async () => {
    const title = titleInput.value.trim();
    const body = bodyInput.value.trim();

    if (!title || !body) {
      showToast('Title and body are required', 'error');
      return;
    }

    if (!confirm(`Send this notification to ALL users?\n\nTitle: ${title}\nBody: ${body}`)) return;

    btnSend.disabled = true;
    try {
      const res = await api.post('/admin-panel/notifications/broadcast', { title, body });
      showToast(`Broadcast sent to ${res.data.count} users`);
      titleInput.value = '';
      bodyInput.value = '';
      loadHistory();
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    } finally {
      btnSend.disabled = false;
    }
  });

  async function loadHistory() {
    tbody.innerHTML = '<tr><td colspan="4" class="loading"><div class="spinner"></div></td></tr>';

    try {
      const res = await api.get(`/admin-panel/notifications/history?page=${currentPage}&limit=20`);
      const { data, pagination } = res;

      if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="empty-state"><p>No broadcasts sent yet</p></td></tr>';
        paginationEl.innerHTML = '';
        return;
      }

      tbody.innerHTML = data.map((n) => {
        const shortBody = n.body.length > 80 ? n.body.slice(0, 80) + '...' : n.body;
        return `
          <tr>
            <td>${escapeHtml(n.title)}</td>
            <td>${escapeHtml(shortBody)}</td>
            <td>${n.recipientCount}</td>
            <td>${new Date(n.createdAt).toLocaleString()}</td>
          </tr>
        `;
      }).join('');

      renderPagination(paginationEl, pagination, (page) => {
        currentPage = page;
        loadHistory();
      });
    } catch (err) {
      tbody.innerHTML = `<tr><td colspan="4" class="empty-state"><p>Error: ${err.message}</p></td></tr>`;
    }
  }

  loadHistory();
});

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
