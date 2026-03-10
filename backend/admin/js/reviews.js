/**
 * Reviews moderation page logic
 */
document.addEventListener('DOMContentLoaded', () => {
  if (!requireAuth()) return;
  initSidebar();

  let currentPage = 1;
  let searchTerm = '';
  let debounceTimer = null;

  const tbody = document.getElementById('reviews-tbody');
  const paginationEl = document.getElementById('reviews-pagination');
  const searchInput = document.getElementById('search-reviews');
  const modal = document.getElementById('review-modal');
  const modalBody = document.getElementById('review-modal-body');

  // Search with debounce
  searchInput.addEventListener('input', () => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      searchTerm = searchInput.value.trim();
      currentPage = 1;
      loadReviews();
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
      showReviewDetail(btn.dataset.review);
    } else if (btn.dataset.action === 'delete') {
      await deleteReview(id);
    }
  });

  async function loadReviews() {
    tbody.innerHTML = '<tr><td colspan="6" class="loading"><div class="spinner"></div></td></tr>';

    try {
      let url = `/admin-panel/reviews?page=${currentPage}&limit=20`;
      if (searchTerm) url += `&search=${encodeURIComponent(searchTerm)}`;

      const res = await api.get(url);
      const { data, pagination } = res;

      if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="empty-state"><p>No reviews found</p></td></tr>';
        paginationEl.innerHTML = '';
        return;
      }

      tbody.innerHTML = data.map((r) => {
        const target = getTargetName(r);
        const stars = renderStars(r.rating);
        const shortText = r.reviewText ? (r.reviewText.length > 60 ? r.reviewText.slice(0, 60) + '...' : r.reviewText) : '—';

        return `
          <tr>
            <td>${escapeHtml(r.user.name)}</td>
            <td>${escapeHtml(target)}</td>
            <td><span class="stars">${stars}</span> ${r.rating}</td>
            <td>${escapeHtml(shortText)}</td>
            <td>${new Date(r.createdAt).toLocaleDateString()}</td>
            <td class="actions">
              <button class="btn btn-sm btn-outline" data-action="view" data-review='${JSON.stringify(r).replace(/'/g, '&#39;')}'>View</button>
              <button class="btn btn-sm btn-danger" data-action="delete" data-id="${r.id}">Delete</button>
            </td>
          </tr>
        `;
      }).join('');

      renderPagination(paginationEl, pagination, (page) => {
        currentPage = page;
        loadReviews();
      });
    } catch (err) {
      tbody.innerHTML = `<tr><td colspan="6" class="empty-state"><p>Error: ${err.message}</p></td></tr>`;
    }
  }

  function showReviewDetail(jsonStr) {
    try {
      const r = JSON.parse(jsonStr);
      const target = getTargetName(r);
      const stars = renderStars(r.rating);

      modalBody.innerHTML = `
        <div class="detail-row"><div class="detail-label">User</div><div class="detail-value">${escapeHtml(r.user.name)} (${escapeHtml(r.user.email)})</div></div>
        <div class="detail-row"><div class="detail-label">Target</div><div class="detail-value">${escapeHtml(target)}</div></div>
        <div class="detail-row"><div class="detail-label">Rating</div><div class="detail-value"><span class="stars">${stars}</span> ${r.rating} ${r.ratingText ? '— ' + escapeHtml(r.ratingText) : ''}</div></div>
        <div class="detail-row"><div class="detail-label">Review</div><div class="detail-value">${escapeHtml(r.reviewText || 'No text')}</div></div>
        <div class="detail-row"><div class="detail-label">Date</div><div class="detail-value">${new Date(r.createdAt).toLocaleString()}</div></div>
      `;
      modal.classList.add('show');
    } catch {
      modalBody.innerHTML = '<p>Error parsing review data</p>';
      modal.classList.add('show');
    }
  }

  async function deleteReview(id) {
    if (!confirm('Are you sure you want to delete this review? This cannot be undone.')) return;

    try {
      await api.delete(`/admin-panel/reviews/${id}`);
      showToast('Review deleted');
      loadReviews();
    } catch (err) {
      showToast('Error: ' + err.message, 'error');
    }
  }

  loadReviews();
});

function getTargetName(review) {
  if (review.serviceProvider) return review.serviceProvider.name + ' (Service)';
  if (review.business) return review.business.name + ' (Business)';
  if (review.amenity) return review.amenity.name + ' (Amenity)';
  return 'Unknown';
}

function renderStars(rating) {
  const full = Math.floor(rating);
  let s = '';
  for (let i = 0; i < 5; i++) s += i < full ? '\u2605' : '\u2606';
  return s;
}

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
