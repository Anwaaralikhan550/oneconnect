/**
 * Partners management page logic — uses event delegation (no inline onclick)
 */
let currentPage = 1;
let currentFilter = '';
let currentSearch = '';

document.addEventListener('DOMContentLoaded', async function () {
  if (!requireAuth()) return;
  initSidebar();

  // Tab click handlers
  document.querySelectorAll('.tab[data-status]').forEach(function (tab) {
    tab.addEventListener('click', function () {
      document.querySelectorAll('.tab[data-status]').forEach(function (t) { t.classList.remove('active'); });
      tab.classList.add('active');
      currentFilter = tab.dataset.status;
      currentPage = 1;
      loadPartners();
    });
  });

  // Search
  var searchInput = document.getElementById('search-partners');
  var searchTimeout;
  searchInput.addEventListener('input', function () {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(function () {
      currentSearch = searchInput.value.trim();
      currentPage = 1;
      loadPartners();
    }, 400);
  });

  // Event delegation for all button actions
  document.addEventListener('click', function (e) {
    var btn = e.target.closest('[data-action]');
    if (!btn) return;

    var action = btn.getAttribute('data-action');
    var id = btn.getAttribute('data-id');
    var status = btn.getAttribute('data-status');

    if (action === 'view-partner') {
      viewPartner(id);
    } else if (action === 'set-partner-status') {
      setPartnerStatus(id, status);
    } else if (action === 'add-favourite') {
      toggleFavourite(id, true, btn);
    } else if (action === 'remove-favourite') {
      toggleFavourite(id, false, btn);
    } else if (action === 'close-modal') {
      closeModal();
    } else if (action === 'go-to-page') {
      var page = parseInt(btn.getAttribute('data-page'), 10);
      currentPage = page;
      loadPartners();
    }
  });

  await loadPartners();
});

async function loadPartners() {
  var tbody = document.getElementById('partners-tbody');
  var paginationEl = document.getElementById('partners-pagination');
  tbody.innerHTML = '<tr><td colspan="7" class="loading"><div class="spinner"></div></td></tr>';

  try {
    var url = '/admin-panel/partners?page=' + currentPage + '&limit=15';
    if (currentFilter) url += '&status=' + currentFilter;
    if (currentSearch) url += '&search=' + encodeURIComponent(currentSearch);

    var res = await api.get(url);
    var data = res.data;
    var pagination = res.pagination;

    if (data.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7" class="empty-state"><p>No partners found</p></td></tr>';
      paginationEl.innerHTML = '';
      return;
    }

    var html = '';
    for (var i = 0; i < data.length; i++) {
      var p = data[i];
      var statusBadge = '<span class="badge badge-' + p.status + '">' + formatStatus(p.status) + '</span>';
      var favAction = p.isFavourited ? 'remove-favourite' : 'add-favourite';
      var favClass = p.isFavourited ? 'btn-favourite active' : 'btn-favourite';
      var favIcon = p.isFavourited ? '&#9733;' : '&#9734;';
      var actions = '<button class="' + favClass + '" data-action="' + favAction + '" data-id="' + p.id + '" title="' + (p.isFavourited ? 'Remove from favourites' : 'Add to favourites') + '">' + favIcon + '</button>';
      actions += ' <button class="btn btn-sm btn-outline" data-action="view-partner" data-id="' + p.id + '">View</button>';

      if (p.status === 'PENDING_REVIEW') {
        actions += ' <button class="btn btn-sm btn-success" data-action="set-partner-status" data-id="' + p.id + '" data-status="APPROVED">Approve</button>';
        actions += ' <button class="btn btn-sm btn-danger" data-action="set-partner-status" data-id="' + p.id + '" data-status="REJECTED">Reject</button>';
      }
      if (p.status === 'APPROVED') {
        actions += ' <button class="btn btn-sm btn-warning" data-action="set-partner-status" data-id="' + p.id + '" data-status="SUSPENDED">Suspend</button>';
      }
      if (p.status === 'SUSPENDED') {
        actions += ' <button class="btn btn-sm btn-success" data-action="set-partner-status" data-id="' + p.id + '" data-status="APPROVED">Reactivate</button>';
      }

      html += '<tr>'
        + '<td><strong>' + p.businessId + '</strong></td>'
        + '<td>' + p.businessName + '</td>'
        + '<td>' + p.ownerFullName + '</td>'
        + '<td>' + p.businessType + '</td>'
        + '<td>' + (p.city || '-') + '</td>'
        + '<td>' + statusBadge + '</td>'
        + '<td><div class="actions">' + actions + '</div></td>'
        + '</tr>';
    }
    tbody.innerHTML = html;
    renderPagination(paginationEl, pagination);
  } catch (err) {
    console.error('loadPartners error:', err);
    tbody.innerHTML = '<tr><td colspan="7" class="empty-state"><p>Error: ' + err.message + '</p></td></tr>';
  }
}

function formatStatus(status) {
  var map = {
    'PENDING_REVIEW': 'Pending',
    'APPROVED': 'Approved',
    'REJECTED': 'Rejected',
    'SUSPENDED': 'Suspended'
  };
  return map[status] || status;
}

async function setPartnerStatus(id, status) {
  try {
    await api.put('/admin-panel/partners/' + id + '/status', { status: status });
    showToast('Partner ' + formatStatus(status).toLowerCase());
    await loadPartners();
  } catch (err) {
    console.error('setPartnerStatus error:', err);
    showToast(err.message, 'error');
  }
}

async function viewPartner(id) {
  try {
    var res = await api.get('/admin-panel/partners/' + id);
    var p = res.data;

    var modal = document.getElementById('partner-modal');
    document.getElementById('modal-title').textContent = p.businessName;

    var phones = p.phones.map(function (ph) { return ph.countryCode + ' ' + ph.phoneNumber; }).join(', ') || '-';
    var days = p.operatingDays.map(function (d) { return d.dayCode; }).join(', ') || '-';
    var categories = p.partnerCategories.map(function (pc) { return pc.category.name; }).join(', ') || '-';
    var location = [p.address, p.area, p.city, p.country].filter(Boolean).join(', ') || '-';

    var pendingSP = p.serviceProviders.filter(function (s) { return s.contentStatus === 'PENDING'; }).length;
    var pendingBiz = p.businesses.filter(function (b) { return b.contentStatus === 'PENDING'; }).length;
    var pendingAmen = p.amenities.filter(function (a) { return a.contentStatus === 'PENDING'; }).length;
    var pendingPromo = p.promotions.filter(function (pr) { return pr.contentStatus === 'PENDING'; }).length;

    document.getElementById('modal-body').innerHTML = ''
      + '<div class="detail-row"><div class="detail-label">Business ID</div><div class="detail-value">' + p.businessId + '</div></div>'
      + '<div class="detail-row"><div class="detail-label">Owner</div><div class="detail-value">' + p.ownerFullName + '</div></div>'
      + '<div class="detail-row"><div class="detail-label">Email</div><div class="detail-value">' + p.businessEmail + '</div></div>'
      + '<div class="detail-row"><div class="detail-label">Phone(s)</div><div class="detail-value">' + phones + '</div></div>'
      + '<div class="detail-row"><div class="detail-label">Type</div><div class="detail-value">' + p.businessType + '</div></div>'
      + '<div class="detail-row"><div class="detail-label">Status</div><div class="detail-value"><span class="badge badge-' + p.status + '">' + formatStatus(p.status) + '</span></div></div>'
      + '<div class="detail-row"><div class="detail-label">Location</div><div class="detail-value">' + location + '</div></div>'
      + '<div class="detail-row"><div class="detail-label">Hours</div><div class="detail-value">' + (p.openingTime || '-') + ' - ' + (p.closingTime || '-') + '</div></div>'
      + '<div class="detail-row"><div class="detail-label">Operating Days</div><div class="detail-value">' + days + '</div></div>'
      + '<div class="detail-row"><div class="detail-label">Categories</div><div class="detail-value">' + categories + '</div></div>'
      + '<div class="detail-row"><div class="detail-label">Rating</div><div class="detail-value">' + p.rating + '</div></div>'
      + '<div class="detail-row"><div class="detail-label">Description</div><div class="detail-value">' + (p.description || '-') + '</div></div>'
      + '<div class="detail-row"><div class="detail-label">Joined</div><div class="detail-value">' + new Date(p.createdAt).toLocaleString() + '</div></div>'
      + '<hr style="margin: 16px 0; border: none; border-top: 1px solid #eee;">'
      + '<div class="detail-row"><div class="detail-label">Services</div><div class="detail-value">' + p.serviceProviders.length + ' (' + pendingSP + ' pending)</div></div>'
      + '<div class="detail-row"><div class="detail-label">Businesses</div><div class="detail-value">' + p.businesses.length + ' (' + pendingBiz + ' pending)</div></div>'
      + '<div class="detail-row"><div class="detail-label">Amenities</div><div class="detail-value">' + p.amenities.length + ' (' + pendingAmen + ' pending)</div></div>'
      + '<div class="detail-row"><div class="detail-label">Promotions</div><div class="detail-value">' + p.promotions.length + ' (' + pendingPromo + ' pending)</div></div>'
      + '<div class="detail-row"><div class="detail-label">Media</div><div class="detail-value">' + p.media.length + ' files</div></div>';

    modal.classList.add('show');
  } catch (err) {
    console.error('viewPartner error:', err);
    showToast(err.message, 'error');
  }
}

function closeModal() {
  document.getElementById('partner-modal').classList.remove('show');
}

async function toggleFavourite(id, add, btn) {
  try {
    if (add) {
      await api.post('/admin-panel/partners/' + id + '/favourite');
      btn.className = 'btn-favourite active';
      btn.setAttribute('data-action', 'remove-favourite');
      btn.setAttribute('title', 'Remove from favourites');
      btn.innerHTML = '&#9733;';
      showToast('Partner added to favourites');
    } else {
      await api.delete('/admin-panel/partners/' + id + '/favourite');
      btn.className = 'btn-favourite';
      btn.setAttribute('data-action', 'add-favourite');
      btn.setAttribute('title', 'Add to favourites');
      btn.innerHTML = '&#9734;';
      showToast('Partner removed from favourites');
    }
  } catch (err) {
    console.error('toggleFavourite error:', err);
    showToast(err.message, 'error');
  }
}

function renderPagination(el, pagination) {
  var page = pagination.page;
  var totalPages = pagination.totalPages;
  var total = pagination.total;
  var limit = pagination.limit;

  if (totalPages <= 1) {
    el.innerHTML = '<span>Showing all ' + total + ' results</span><div></div>';
    return;
  }

  var start = (page - 1) * limit + 1;
  var end = Math.min(page * limit, total);
  var buttons = '';

  buttons += '<button ' + (page <= 1 ? 'disabled' : 'data-action="go-to-page" data-page="' + (page - 1) + '"') + '>Prev</button>';
  for (var i = 1; i <= Math.min(totalPages, 5); i++) {
    buttons += '<button class="' + (i === page ? 'active' : '') + '" data-action="go-to-page" data-page="' + i + '">' + i + '</button>';
  }
  if (totalPages > 5) {
    buttons += '<button disabled>...</button><button data-action="go-to-page" data-page="' + totalPages + '">' + totalPages + '</button>';
  }
  buttons += '<button ' + (page >= totalPages ? 'disabled' : 'data-action="go-to-page" data-page="' + (page + 1) + '"') + '>Next</button>';

  el.innerHTML = '<span>Showing ' + start + '-' + end + ' of ' + total + '</span><div class="pagination-buttons">' + buttons + '</div>';
}
