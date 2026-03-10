const { Router } = require('express');
const adminPanelController = require('../controllers/adminPanel.controller');
const { adminAuthGuard } = require('../middleware/adminAuth');

const router = Router();

// All admin panel routes require admin authentication
router.use(adminAuthGuard);

// Dashboard
router.get('/dashboard/stats', adminPanelController.getDashboardStats);

// Partner management
router.get('/partners', adminPanelController.listPartners);
router.get('/partners/:id', adminPanelController.getPartner);
router.put('/partners/:id/status', adminPanelController.updatePartnerStatus);
router.delete('/partners/:id', adminPanelController.deletePartner);

// Favourite partners
router.get('/favourites', adminPanelController.listFavouritePartners);
router.post('/partners/:id/favourite', adminPanelController.addFavouritePartner);
router.delete('/partners/:id/favourite', adminPanelController.removeFavouritePartner);

// Content management (type = service-providers|businesses|amenities|promotions)
router.get('/content/:type', adminPanelController.listContent);
router.put('/content/:type/:id/approve', adminPanelController.approveContent);
router.put('/content/:type/:id/reject', adminPanelController.rejectContent);
router.post('/content/:type', adminPanelController.createContent);
router.put('/content/:type/:id', adminPanelController.updateContent);
router.delete('/content/:type/:id', adminPanelController.deleteContent);

// User management
router.get('/users', adminPanelController.listUsers);
router.get('/users/:id', adminPanelController.getUser);
router.put('/users/:id/ban', adminPanelController.toggleUserBan);

// Review management
router.get('/reviews', adminPanelController.listReviews);
router.delete('/reviews/:id', adminPanelController.deleteReview);

// Property management
router.get('/properties', adminPanelController.listProperties);
router.put('/properties/:id/approve', adminPanelController.approveProperty);
router.put('/properties/:id/reject', adminPanelController.rejectProperty);
router.delete('/properties/:id', adminPanelController.deleteProperty);

// Admin Office CRUD
router.get('/admin-offices', adminPanelController.listAdminOffices);
router.post('/admin-offices', adminPanelController.createAdminOffice);
router.put('/admin-offices/:id', adminPanelController.updateAdminOffice);
router.delete('/admin-offices/:id', adminPanelController.deleteAdminOffice);

// Broadcast notifications
router.post('/notifications/broadcast', adminPanelController.broadcastNotification);
router.get('/notifications/history', adminPanelController.listBroadcastHistory);

// Analytics
router.get('/analytics/signups', adminPanelController.getMonthlySignups);
router.get('/analytics/top-searches', adminPanelController.getTopSearches);

module.exports = router;
