const { Router } = require('express');
const { apiLimiter } = require('../middleware/rateLimiter');

const router = Router();

// Apply general rate limiting to all API routes
router.use(apiLimiter);

// Mount all route modules
router.use('/auth', require('./auth.routes'));
router.use('/partner', require('./partner.routes'));
router.use('/bookings', require('./bookings.routes'));
router.use('/service-providers', require('./serviceProviders.routes'));
router.use('/providers', require('./serviceProviders.routes'));
router.use('/businesses', require('./businesses.routes'));
router.use('/amenities', require('./amenities.routes'));
router.use('/properties', require('./properties.routes'));
router.use('/search', require('./search.routes'));
router.use('/users', require('./users.routes'));
router.use('/notifications', require('./notifications.routes'));
router.use('/promotions', require('./promotions.routes'));
router.use('/upload', require('./upload.routes'));
router.use('/admin-offices', require('./admin.routes'));
router.use('/service-categories', require('./serviceCategories.routes'));
router.use('/locations', require('./locations.routes'));
router.use('/admin-auth', require('./adminAuth.routes'));
router.use('/admin-panel', require('./adminPanel.routes'));
router.use('/admin', require('./adminBooking.routes'));

module.exports = router;
