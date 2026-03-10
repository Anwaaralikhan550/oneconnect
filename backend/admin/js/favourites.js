/**
 * Favourites page logic — shows favourite partners grouped by businessType
 */
document.addEventListener('DOMContentLoaded', async function () {
  if (!requireAuth()) return;
  initSidebar();

  // Event delegation
  document.addEventListener('click', function (e) {
    var btn = e.target.closest('[data-action]');
    if (!btn) return;

    var action = btn.getAttribute('data-action');
    var id = btn.getAttribute('data-id');
    var status = btn.getAttribute('data-status');

    if (action === 'view-partner') {
      viewPartner(id);
    } else if (action === 'remove-favourite') {
      removeFavourite(id);
    } else if (action === 'set-partner-status') {
      setPartnerStatus(id, status);
    } else if (action === 'close-modal') {
      closeModal();
    }
  });

  await loadFavourites();
});

async function loadFavourites() {
  var container = document.getElementById('favourites-container');
  container.innerHTML = '<div class="loading"><div class="spinner"></div></div>';

  try {
    var res = await api.get('/admin-panel/favourites');
    var grouped = res.data;
    var types = Object.keys(grouped);

    if (types.length === 0) {
      container.innerHTML = '<div class="card"><div class="empty-state">'
        + '<div class="empty-icon">&#9734;</div>'
        + '<p>No favourite partners yet.</p>'
        + '<p style="margin-top:8px;color:#999;font-size:13px;">Star partners from the <a href="partners.html">Partners</a> page to bookmark them here.</p>'
        + '</div></div>';
      return;
    }

    var html = '';
    for (var i = 0; i < types.length; i++) {
      var type = types[i];
      var partners = grouped[type];

      html += '<div class="card">';
      html += '<div class="favourites-group-title">' + formatBusinessType(type) + ' <span class="group-count">' + partners.length + '</span></div>';
      html += '<div class="card-body"><table><thead><tr>'
        + '<th>Business ID</th><th>Business Name</th><th>Owner</th><th>City</th><th>Status</th><th>Rating</th><th>Actions</th>'
        + '</tr></thead><tbody>';

      for (var j = 0; j < partners.length; j++) {
        var p = partners[j];
        var statusBadge = '<span class="badge badge-' + p.status + '">' + formatStatus(p.status) + '</span>';

        var actions = '<button class="btn-favourite active" data-action="remove-favourite" data-id="' + p.id + '" title="Remove from favourites">&#9733;</button>';
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
          + '<td>' + (p.city || '-') + '</td>'
          + '<td>' + statusBadge + '</td>'
          + '<td>' + p.rating.toFixed(1) + '</td>'
          + '<td><div class="actions">' + actions + '</div></td>'
          + '</tr>';
      }

      html += '</tbody></table></div></div>';
    }

    container.innerHTML = html;
  } catch (err) {
    console.error('loadFavourites error:', err);
    container.innerHTML = '<div class="card"><div class="empty-state"><p>Error: ' + err.message + '</p></div></div>';
  }
}

function formatBusinessType(type) {
  var map = {
    'RESTAURANT': 'Restaurants',
    'RETAIL_STORE': 'Retail Stores',
    'SERVICE_PROVIDER': 'Service Providers',
    'ONLINE_BUSINESS': 'Online Businesses',
    'OTHER': 'Other'
  };
  return map[type] || type;
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

async function removeFavourite(id) {
  try {
    await api.delete('/admin-panel/partners/' + id + '/favourite');
    showToast('Partner removed from favourites');
    await loadFavourites();
  } catch (err) {
    console.error('removeFavourite error:', err);
    showToast(err.message, 'error');
  }
}

async function setPartnerStatus(id, status) {
  try {
    await api.put('/admin-panel/partners/' + id + '/status', { status: status });
    showToast('Partner ' + formatStatus(status).toLowerCase());
    await loadFavourites();
  } catch (err) {
    console.error('setPartnerStatus error:', err);
    showToast(err.message, 'error');
  }
}

async function viewPartner(id) {
  try {
    var res = await api.get('/admin-panel/partners/' + id);
    var p = res.data;

    document.getElementById('modal-title').textContent = p.businessName;

    var phones = p.phones.map(function (ph) { return ph.countryCode + ' ' + ph.phoneNumber; }).join(', ') || '-';
    var days = p.operatingDays.map(function (d) { return d.dayCode; }).join(', ') || '-';
    var categories = p.partnerCategories.map(function (pc) { return pc.category.name; }).join(', ') || '-';
    var location = [p.address, p.area, p.city, p.country].filter(Boolean).join(', ') || '-';

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
      + '<div class="detail-row"><div class="detail-label">Joined</div><div class="detail-value">' + new Date(p.createdAt).toLocaleString() + '</div></div>';

    document.getElementById('partner-modal').classList.add('show');
  } catch (err) {
    console.error('viewPartner error:', err);
    showToast(err.message, 'error');
  }
}

function closeModal() {
  document.getElementById('partner-modal').classList.remove('show');
}
