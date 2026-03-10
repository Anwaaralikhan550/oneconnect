const adminPanelService = require('../services/adminPanel.service');

async function getDashboardStats(req, res, next) {
  try {
    const stats = await adminPanelService.getDashboardStats();
    res.json({ success: true, data: stats });
  } catch (err) {
    next(err);
  }
}

// ─── PARTNERS ────────────────────────────────────────

async function listPartners(req, res, next) {
  try {
    const result = await adminPanelService.listPartners(req.query, req.admin.id);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

async function getPartner(req, res, next) {
  try {
    const partner = await adminPanelService.getPartnerById(req.params.id);
    res.json({ success: true, data: partner });
  } catch (err) {
    next(err);
  }
}

async function updatePartnerStatus(req, res, next) {
  try {
    const result = await adminPanelService.updatePartnerStatus(req.params.id, req.body.status);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deletePartner(req, res, next) {
  try {
    const result = await adminPanelService.deletePartner(req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

// ─── CONTENT ─────────────────────────────────────────

async function listContent(req, res, next) {
  try {
    const result = await adminPanelService.listContent(req.params.type, req.query);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

async function approveContent(req, res, next) {
  try {
    const result = await adminPanelService.approveContent(req.params.type, req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function rejectContent(req, res, next) {
  try {
    const result = await adminPanelService.rejectContent(req.params.type, req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function createContent(req, res, next) {
  try {
    const result = await adminPanelService.createContent(req.params.type, req.body);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function updateContent(req, res, next) {
  try {
    const result = await adminPanelService.updateContent(req.params.type, req.params.id, req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deleteContent(req, res, next) {
  try {
    const result = await adminPanelService.deleteContent(req.params.type, req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

// ─── FAVOURITE PARTNERS ──────────────────────────────

async function addFavouritePartner(req, res, next) {
  try {
    const result = await adminPanelService.addFavouritePartner(req.admin.id, req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function removeFavouritePartner(req, res, next) {
  try {
    const result = await adminPanelService.removeFavouritePartner(req.admin.id, req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function listFavouritePartners(req, res, next) {
  try {
    const grouped = await adminPanelService.listFavouritePartners(req.admin.id);
    res.json({ success: true, data: grouped });
  } catch (err) {
    next(err);
  }
}

// ─── USERS ──────────────────────────────────────────

async function listUsers(req, res, next) {
  try {
    const result = await adminPanelService.listUsers(req.query);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

async function getUser(req, res, next) {
  try {
    const user = await adminPanelService.getUserById(req.params.id);
    res.json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
}

async function toggleUserBan(req, res, next) {
  try {
    const result = await adminPanelService.toggleUserBan(req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

// ─── REVIEWS ────────────────────────────────────────

async function listReviews(req, res, next) {
  try {
    const result = await adminPanelService.listReviews(req.query);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

async function deleteReview(req, res, next) {
  try {
    const result = await adminPanelService.deleteReview(req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

// ─── PROPERTIES ─────────────────────────────────────

async function listProperties(req, res, next) {
  try {
    const result = await adminPanelService.listProperties(req.query);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

async function approveProperty(req, res, next) {
  try {
    const result = await adminPanelService.approveProperty(req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function rejectProperty(req, res, next) {
  try {
    const result = await adminPanelService.rejectProperty(req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deleteProperty(req, res, next) {
  try {
    const result = await adminPanelService.deleteProperty(req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

// ─── ADMIN OFFICES ──────────────────────────────────

async function listAdminOffices(req, res, next) {
  try {
    const result = await adminPanelService.listAdminOffices(req.query);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

async function createAdminOffice(req, res, next) {
  try {
    const result = await adminPanelService.createAdminOffice(req.body);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function updateAdminOffice(req, res, next) {
  try {
    const result = await adminPanelService.updateAdminOffice(req.params.id, req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deleteAdminOffice(req, res, next) {
  try {
    const result = await adminPanelService.deleteAdminOffice(req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

// ─── NOTIFICATIONS ──────────────────────────────────

async function broadcastNotification(req, res, next) {
  try {
    const result = await adminPanelService.broadcastNotification(req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function listBroadcastHistory(req, res, next) {
  try {
    const result = await adminPanelService.listBroadcastHistory(req.query);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

// ─── ANALYTICS ──────────────────────────────────────

async function getMonthlySignups(req, res, next) {
  try {
    const result = await adminPanelService.getMonthlySignups();
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function getTopSearches(req, res, next) {
  try {
    const result = await adminPanelService.getTopSearches();
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getDashboardStats,
  listPartners,
  getPartner,
  updatePartnerStatus,
  deletePartner,
  listContent,
  approveContent,
  rejectContent,
  createContent,
  updateContent,
  deleteContent,
  addFavouritePartner,
  removeFavouritePartner,
  listFavouritePartners,
  // Users
  listUsers,
  getUser,
  toggleUserBan,
  // Reviews
  listReviews,
  deleteReview,
  // Properties
  listProperties,
  approveProperty,
  rejectProperty,
  deleteProperty,
  // Admin Offices
  listAdminOffices,
  createAdminOffice,
  updateAdminOffice,
  deleteAdminOffice,
  // Notifications
  broadcastNotification,
  listBroadcastHistory,
  // Analytics
  getMonthlySignups,
  getTopSearches,
};
