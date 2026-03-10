/**
 * Content approval page logic — uses event delegation (no inline onclick)
 */
var contentType = 'service-providers';
var contentPage = 1;
var contentFilter = '';
var contentSearch = '';

var TYPE_LABELS = {
  'service-providers': 'Service Providers',
  'businesses': 'Businesses',
  'amenities': 'Amenities',
  'promotions': 'Promotions',
};

var TYPE_NAME_FIELD = {
  'service-providers': 'name',
  'businesses': 'name',
  'amenities': 'name',
  'promotions': 'title',
};

var TYPE_CATEGORY_FIELD = {
  'service-providers': 'serviceType',
  'businesses': 'category',
  'amenities': 'amenityType',
  'promotions': null,
};

document.addEventListener('DOMContentLoaded', async function () {
  if (!requireAuth()) return;
  initSidebar();

  // Content type tabs
  document.querySelectorAll('.tab[data-type]').forEach(function (tab) {
    tab.addEventListener('click', function () {
      document.querySelectorAll('.tab[data-type]').forEach(function (t) { t.classList.remove('active'); });
      tab.classList.add('active');
      contentType = tab.dataset.type;
      contentPage = 1;
      contentFilter = '';
      document.getElementById('filter-status').value = '';
      loadContent();
    });
  });

  // Status filter
  document.getElementById('filter-status').addEventListener('change', function (e) {
    contentFilter = e.target.value;
    contentPage = 1;
    loadContent();
  });

  // Search
  var searchInput = document.getElementById('search-content');
  var searchTimeout;
  searchInput.addEventListener('input', function () {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(function () {
      contentSearch = searchInput.value.trim();
      contentPage = 1;
      loadContent();
    }, 400);
  });

  // Event delegation for all button actions
  document.addEventListener('click', function (e) {
    var btn = e.target.closest('[data-action]');
    if (!btn) return;

    var action = btn.getAttribute('data-action');
    var id = btn.getAttribute('data-id');

    if (action === 'approve-item') {
      approveItem(id);
    } else if (action === 'reject-item') {
      rejectItem(id);
    } else if (action === 'delete-item') {
      var name = btn.getAttribute('data-name') || 'this item';
      deleteItem(id, name);
    } else if (action === 'view-item') {
      viewItem(id);
    } else if (action === 'close-content-modal') {
      closeContentModal();
    } else if (action === 'go-to-content-page') {
      var page = parseInt(btn.getAttribute('data-page'), 10);
      contentPage = page;
      loadContent();
    }
  });

  await loadContent();
});

async function loadContent() {
  var tbody = document.getElementById('content-tbody');
  var paginationEl = document.getElementById('content-pagination');
  var nameField = TYPE_NAME_FIELD[contentType];
  var categoryField = TYPE_CATEGORY_FIELD[contentType];

  tbody.innerHTML = '<tr><td colspan="7" class="loading"><div class="spinner"></div></td></tr>';

  try {
    var url = '/admin-panel/content/' + contentType + '?page=' + contentPage + '&limit=15';
    if (contentFilter) url += '&contentStatus=' + contentFilter;
    if (contentSearch) url += '&search=' + encodeURIComponent(contentSearch);

    var res = await api.get(url);
    var data = res.data;
    var pagination = res.pagination;

    if (data.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7" class="empty-state"><p>No items found</p></td></tr>';
      paginationEl.innerHTML = '';
      return;
    }

    var html = '';
    for (var i = 0; i < data.length; i++) {
      var item = data[i];
      var name = item[nameField] || '-';
      var category = categoryField ? (item[categoryField] || '-') : '-';
      var partner = item.partner ? item.partner.businessName : '-';
      var date = new Date(item.createdAt).toLocaleDateString();
      var status = item.contentStatus;
      var safeName = name.replace(/"/g, '&quot;');

      var actions = '';

      if (status === 'PENDING') {
        actions += '<button class="btn btn-sm btn-success" data-action="approve-item" data-id="' + item.id + '">Approve</button> ';
        actions += '<button class="btn btn-sm btn-danger" data-action="reject-item" data-id="' + item.id + '">Reject</button> ';
      }
      if (status === 'REJECTED') {
        actions += '<button class="btn btn-sm btn-success" data-action="approve-item" data-id="' + item.id + '">Approve</button> ';
      }
      if (status === 'APPROVED') {
        actions += '<button class="btn btn-sm btn-danger" data-action="reject-item" data-id="' + item.id + '">Reject</button> ';
      }
      actions += '<button class="btn btn-sm btn-outline" data-action="view-item" data-id="' + item.id + '">View</button> ';
      actions += '<button class="btn btn-sm btn-danger" data-action="delete-item" data-id="' + item.id + '" data-name="' + safeName + '">Delete</button>';

      html += '<tr>'
        + '<td><strong>' + name + '</strong></td>'
        + '<td>' + category + '</td>'
        + '<td>' + partner + '</td>'
        + '<td><span class="badge badge-' + status + '">' + status + '</span></td>'
        + '<td>' + date + '</td>'
        + '<td><div class="actions">' + actions + '</div></td>'
        + '</tr>';
    }
    tbody.innerHTML = html;
    renderContentPagination(paginationEl, pagination);
  } catch (err) {
    console.error('loadContent error:', err);
    tbody.innerHTML = '<tr><td colspan="7" class="empty-state"><p>Error: ' + err.message + '</p></td></tr>';
  }
}

async function approveItem(id) {
  try {
    await api.put('/admin-panel/content/' + contentType + '/' + id + '/approve');
    showToast('Item approved');
    await loadContent();
  } catch (err) {
    console.error('approveItem error:', err);
    showToast(err.message, 'error');
  }
}

async function rejectItem(id) {
  try {
    await api.put('/admin-panel/content/' + contentType + '/' + id + '/reject');
    showToast('Item rejected');
    await loadContent();
  } catch (err) {
    console.error('rejectItem error:', err);
    showToast(err.message, 'error');
  }
}

async function deleteItem(id, name) {
  if (!confirm('Are you sure you want to delete "' + name + '"? This cannot be undone.')) return;

  try {
    await api.delete('/admin-panel/content/' + contentType + '/' + id);
    showToast('Item deleted');
    await loadContent();
  } catch (err) {
    console.error('deleteItem error:', err);
    showToast(err.message, 'error');
  }
}

async function viewItem(id) {
  try {
    var publicTypes = {
      'service-providers': '/service-providers',
      'businesses': '/businesses',
      'amenities': '/amenities',
    };

    var item;
    if (publicTypes[contentType]) {
      try {
        var res = await api.get(publicTypes[contentType] + '/' + id);
        item = res.data;
      } catch (e) {
        // Might not be approved — fall back to content list data
        var res2 = await api.get('/admin-panel/content/' + contentType + '?limit=100');
        item = res2.data.find(function (i) { return i.id === id; });
      }
    } else {
      var res3 = await api.get('/admin-panel/content/' + contentType + '?limit=100');
      item = res3.data.find(function (i) { return i.id === id; });
    }

    if (!item) {
      showToast('Item not found', 'error');
      return;
    }

    var modal = document.getElementById('content-modal');
    var nameField = TYPE_NAME_FIELD[contentType];
    document.getElementById('content-modal-title').textContent = item[nameField] || 'Item Details';

    var html = '';
    var keys = Object.keys(item);
    for (var k = 0; k < keys.length; k++) {
      var key = keys[k];
      var value = item[key];

      if (key === 'partner' && value && typeof value === 'object') {
        html += '<div class="detail-row"><div class="detail-label">Partner</div><div class="detail-value">' + (value.businessName || '-') + '</div></div>';
        continue;
      }
      if (key === 'skills' && Array.isArray(value)) {
        var skillNames = value.map(function (s) { return s.tagName || s; }).join(', ');
        html += '<div class="detail-row"><div class="detail-label">Skills</div><div class="detail-value">' + skillNames + '</div></div>';
        continue;
      }
      if (key === 'reviews' || key === 'favorites' || key === 'votes' || key === 'media') continue;
      if (typeof value === 'object' && value !== null) continue;

      var label = key.replace(/([A-Z])/g, ' $1').replace(/^./, function (s) { return s.toUpperCase(); });
      var displayValue = value;

      if (key === 'createdAt' || key === 'updatedAt' || key === 'expiresAt') {
        displayValue = value ? new Date(value).toLocaleString() : '-';
      } else if (key === 'contentStatus') {
        displayValue = '<span class="badge badge-' + value + '">' + value + '</span>';
      } else if (key === 'imageUrl' && value) {
        displayValue = '<img src="' + value + '" alt="Image" style="max-width:200px; border-radius:8px;">';
      } else if (value === null || value === undefined) {
        displayValue = '-';
      }

      html += '<div class="detail-row"><div class="detail-label">' + label + '</div><div class="detail-value">' + displayValue + '</div></div>';
    }

    document.getElementById('content-modal-body').innerHTML = html;
    modal.classList.add('show');
  } catch (err) {
    console.error('viewItem error:', err);
    showToast(err.message, 'error');
  }
}

function closeContentModal() {
  document.getElementById('content-modal').classList.remove('show');
}

function renderContentPagination(el, pagination) {
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

  buttons += '<button ' + (page <= 1 ? 'disabled' : 'data-action="go-to-content-page" data-page="' + (page - 1) + '"') + '>Prev</button>';
  for (var i = 1; i <= Math.min(totalPages, 5); i++) {
    buttons += '<button class="' + (i === page ? 'active' : '') + '" data-action="go-to-content-page" data-page="' + i + '">' + i + '</button>';
  }
  if (totalPages > 5) {
    buttons += '<button disabled>...</button><button data-action="go-to-content-page" data-page="' + totalPages + '">' + totalPages + '</button>';
  }
  buttons += '<button ' + (page >= totalPages ? 'disabled' : 'data-action="go-to-content-page" data-page="' + (page + 1) + '"') + '>Next</button>';

  el.innerHTML = '<span>Showing ' + start + '-' + end + ' of ' + total + '</span><div class="pagination-buttons">' + buttons + '</div>';
}
