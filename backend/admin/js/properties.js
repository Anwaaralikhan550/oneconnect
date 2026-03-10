/**
 * Properties management page logic
 */
document.addEventListener('DOMContentLoaded', () => {
  if (!requireAuth()) return;
  initSidebar();

  let currentPage = 1;
  let currentStatus = '';
  let searchTerm = '';
  let debounceTimer = null;

  const tbody = document.getElementById('properties-tbody');
  const paginationEl = document.getElementById('properties-pagination');
  const searchInput = document.getElementById('search-properties');
  const modal = document.getElementById('property-modal');
  const modalBody = document.getElementById('property-modal-body');

  // Tab switching
  document.querySelectorAll('.tab').forEach((tab) => {
    tab.addEventListener('click', () => {
      document.querySelector('.tab.active').classList.remove('active');
      tab.classList.add('active');
      currentStatus = tab.dataset.status;
      currentPage = 1;
      loadProperties();
    });
  });

  // Search with debounce
  searchInput.addEventListener('input', () => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      searchTerm = searchInput.value.trim();
      currentPage = 1;
      loadProperties();
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
      showPropertyDetail(btn.dataset.property);
    } else if (btn.dataset.action === 'approve') {
      await changeStatus(id, 'approve');
    } else if (btn.dataset.action === 'reject') {
      await changeStatus(id, 'reject');
    } else if (btn.dataset.action === 'delete') {
      await deleteProperty(id);
    }
  });

  async function loadProperties() {
    tbody.innerHTML = '<tr><td colspan="7" class="loading"><div class="spinner"></div></td></tr>';

    try {
      let url = `/admin-panel/properties?page=${currentPage}&limit=20`;
      if (currentStatus) url += `&contentStatus=${currentStatus}`;
      if (searchTerm) url += `&search=${encodeURIComponent(searchTerm)}`;

      const res = await api.get(url);
      const { data, pagination } = res;

      if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="empty-state"><p>No properties found</p></td></tr>';
        paginationEl.innerHTML = '';
        return;
      }

      tbody.innerHTML = data.map((p) => {
        const price = p.price ? 'PKR ' + Number(p.price).toLocaleString() : '—';
        const beds = p.beds != null ? p.beds : '—';
        const baths = p.baths != null ? p.baths : '—';

        return `
          <tr>
            <td>${escapeHtml(p.title)}</td>
            <td>${escapeHtml(p.location || '—')}</td>
            <td>${escapeHtml(p.propertyType || '—')}</td>
            <td>${price}</td>
            <td>${beds} / ${baths}</td>
            <td><span class="badge badge-${p.contentStatus}">${p.contentStatus}</span></td>
            <td class="actions">
              <button class="btn btn-sm btn-outline" data-action="view" data-property='${JSON.stringify(p).replace(/'/g, '&#39;')}'>View</button>
              ${p.contentStatus !== 'APPROVED' ? `<button class="btn btn-sm btn-success" data-action="approve" data-id="${p.id}">Approve</button>` : ''}
              ${p.contentStatus !== 'REJECTED' ? `<button class="btn btn-sm btn-warning" data-action="reject" data-id="${p.id}">Reject</button>` : ''}
              <button class="btn btn-sm btn-danger" data-action="delete" data-id="${p.id}">Delete</button>
            </td>
          </tr>
        `;
      }).join('');

      renderPagination(paginationEl, pagination, (page) => {
        currentPage = page;
        loadProperties();
      });
    } catch (err) {
      tbody.innerHTML = `<tr><td colspan="7" class="empty-state"><p>Error: ${err.message}</p></td></tr>`;
    }
  }

  function showPropertyDetail(jsonStr) {
    try {
      const p = JSON.parse(jsonStr);
      const price = p.price ? 'PKR ' + Number(p.price).toLocaleString() : '—';

      let imagesHtml = '';
      if (p.mainImageUrl) {
        imagesHtml += `<div class="image-gallery"><img src="${p.mainImageUrl}" alt="Main"></div>`;
      }
      if (p.images && p.images.length > 0) {
        imagesHtml = '<div class="image-gallery">' +
          (p.mainImageUrl ? `<img src="${p.mainImageUrl}" alt="Main">` : '') +
          p.images.map((img) => `<img src="${img.imageUrl}" alt="Property">`).join('') +
          '</div>';
      }

      modalBody.innerHTML = `
        <div class="detail-row"><div class="detail-label">Title</div><div class="detail-value">${escapeHtml(p.title)}</div></div>
        <div class="detail-row"><div class="detail-label">Location</div><div class="detail-value">${escapeHtml(p.location || '—')}</div></div>
        <div class="detail-row"><div class="detail-label">Type</div><div class="detail-value">${escapeHtml(p.propertyType || '—')}</div></div>
        <div class="detail-row"><div class="detail-label">Price</div><div class="detail-value">${price}</div></div>
        <div class="detail-row"><div class="detail-label">Beds</div><div class="detail-value">${p.beds != null ? p.beds : '—'}</div></div>
        <div class="detail-row"><div class="detail-label">Baths</div><div class="detail-value">${p.baths != null ? p.baths : '—'}</div></div>
        <div class="detail-row"><div class="detail-label">Kitchen</div><div class="detail-value">${p.kitchen != null ? p.kitchen : '—'}</div></div>
        <div class="detail-row"><div class="detail-label">Area (sqft)</div><div class="detail-value">${p.sqft || '—'}</div></div>
        <div class="detail-row"><div class="detail-label">Status</div><div class="detail-value"><span class="badge badge-${p.contentStatus}">${p.contentStatus}</span></div></div>
        <div class="detail-row"><div class="detail-label">Description</div><div class="detail-value">${escapeHtml(p.description || 'No description')}</div></div>
        ${imagesHtml ? `<div class="detail-row"><div class="detail-label">Images</div><div class="detail-value">${imagesHtml}</div></div>` : ''}
      `;
      modal.classList.add('show');
    } catch {
      modalBody.innerHTML = '<p>Error parsing property data</p>';
      modal.classList.add('show');
    }
  }

  async function changeStatus(id, action) {
    try {
      await api.put(`/admin-panel/properties/${id}/${action}`);
      showToast(`Property ${action}d`);
      loadProperties();
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  async function deleteProperty(id) {
    if (!confirm('Are you sure you want to delete this property? This cannot be undone.')) return;

    try {
      await api.delete(`/admin-panel/properties/${id}`);
      showToast('Property deleted');
      loadProperties();
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  loadProperties();
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
