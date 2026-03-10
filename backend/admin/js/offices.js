/**
 * Admin Offices CRUD page logic
 */
document.addEventListener('DOMContentLoaded', () => {
  if (!requireAuth()) return;
  initSidebar();

  let currentPage = 1;
  let searchTerm = '';
  let filterType = '';
  let debounceTimer = null;
  let editingId = null;

  const tbody = document.getElementById('offices-tbody');
  const paginationEl = document.getElementById('offices-pagination');
  const searchInput = document.getElementById('search-offices');
  const filterTypeSelect = document.getElementById('filter-type');
  const modal = document.getElementById('office-modal');
  const modalTitle = document.getElementById('office-modal-title');
  const form = document.getElementById('office-form');
  const btnCreate = document.getElementById('btn-create');
  const btnSave = document.getElementById('btn-save-office');

  // Search with debounce
  searchInput.addEventListener('input', () => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      searchTerm = searchInput.value.trim();
      currentPage = 1;
      loadOffices();
    }, 400);
  });

  // Filter by type
  filterTypeSelect.addEventListener('change', () => {
    filterType = filterTypeSelect.value;
    currentPage = 1;
    loadOffices();
  });

  // Modal close
  modal.addEventListener('click', (e) => {
    if (e.target === modal || e.target.dataset.action === 'close-modal') {
      modal.classList.remove('show');
    }
  });

  // Create button
  btnCreate.addEventListener('click', () => {
    editingId = null;
    modalTitle.textContent = 'Create Office';
    form.reset();
    form.querySelector('[name="id"]').value = '';
    modal.classList.add('show');
  });

  // Save button
  btnSave.addEventListener('click', async () => {
    const data = Object.fromEntries(new FormData(form));
    data.isOpen = data.isOpen === 'true';
    data.rating = parseFloat(data.rating) || 0;
    const id = data.id;
    delete data.id;

    // Remove empty optional fields
    if (!data.phone) delete data.phone;
    if (!data.address) delete data.address;

    try {
      if (id) {
        await api.put(`/admin-panel/admin-offices/${id}`, data);
        showToast('Office updated');
      } else {
        await api.post('/admin-panel/admin-offices', data);
        showToast('Office created');
      }
      modal.classList.remove('show');
      loadOffices();
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  });

  // Delegate table actions
  tbody.addEventListener('click', async (e) => {
    const btn = e.target.closest('button');
    if (!btn) return;

    const id = btn.dataset.id;
    if (btn.dataset.action === 'edit') {
      openEditModal(btn.dataset.office);
    } else if (btn.dataset.action === 'delete') {
      await deleteOffice(id);
    }
  });

  function openEditModal(jsonStr) {
    try {
      const o = JSON.parse(jsonStr);
      editingId = o.id;
      modalTitle.textContent = 'Edit Office';
      form.querySelector('[name="id"]').value = o.id;
      form.querySelector('[name="name"]').value = o.name;
      form.querySelector('[name="officeType"]').value = o.officeType;
      form.querySelector('[name="phone"]').value = o.phone || '';
      form.querySelector('[name="address"]').value = o.address || '';
      form.querySelector('[name="rating"]').value = o.rating || 0;
      form.querySelector('[name="isOpen"]').value = o.isOpen ? 'true' : 'false';
      modal.classList.add('show');
    } catch {
      showToast('Error parsing office data', 'error');
    }
  }

  async function deleteOffice(id) {
    if (!confirm('Are you sure you want to delete this office?')) return;

    try {
      await api.delete(`/admin-panel/admin-offices/${id}`);
      showToast('Office deleted');
      loadOffices();
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  async function loadOffices() {
    tbody.innerHTML = '<tr><td colspan="7" class="loading"><div class="spinner"></div></td></tr>';

    try {
      let url = `/admin-panel/admin-offices?page=${currentPage}&limit=20`;
      if (filterType) url += `&officeType=${filterType}`;
      if (searchTerm) url += `&search=${encodeURIComponent(searchTerm)}`;

      const res = await api.get(url);
      const { data, pagination } = res;

      if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="empty-state"><p>No offices found</p></td></tr>';
        paginationEl.innerHTML = '';
        return;
      }

      tbody.innerHTML = data.map((o) => `
        <tr>
          <td>${escapeHtml(o.name)}</td>
          <td>${escapeHtml(o.officeType)}</td>
          <td>${o.phone || '—'}</td>
          <td>${escapeHtml(o.address || '—')}</td>
          <td><span class="badge ${o.isOpen ? 'badge-active' : 'badge-banned'}">${o.isOpen ? 'Open' : 'Closed'}</span></td>
          <td>${o.rating}</td>
          <td class="actions">
            <button class="btn btn-sm btn-outline" data-action="edit" data-office='${JSON.stringify(o).replace(/'/g, '&#39;')}'>Edit</button>
            <button class="btn btn-sm btn-danger" data-action="delete" data-id="${o.id}">Delete</button>
          </td>
        </tr>
      `).join('');

      renderPagination(paginationEl, pagination, (page) => {
        currentPage = page;
        loadOffices();
      });
    } catch (err) {
      tbody.innerHTML = `<tr><td colspan="7" class="empty-state"><p>Error: ${err.message}</p></td></tr>`;
    }
  }

  loadOffices();
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
