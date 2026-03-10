const { Router } = require('express');
const adminBookingController = require('../controllers/adminBooking.controller');
const { adminAuthGuard } = require('../middleware/adminAuth');

const router = Router();

router.use(adminAuthGuard);
router.get('/bookings/stats', adminBookingController.getBookingStats);

module.exports = router;
