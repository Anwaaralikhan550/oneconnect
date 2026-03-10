const { Router } = require('express');
const bookingController = require('../controllers/booking.controller');
const { validate } = require('../middleware/validate');
const { anyAuthGuard } = require('../middleware/anyAuth');
const { bookingCreateSchema, bookingStatusUpdateSchema } = require('../schemas/common.schema');

const router = Router();

router.post('/', anyAuthGuard, validate(bookingCreateSchema), bookingController.createBooking);
router.get('/me', anyAuthGuard, bookingController.getMyBookings);
router.patch('/:id/status', anyAuthGuard, validate(bookingStatusUpdateSchema), bookingController.updateBookingStatus);

module.exports = router;
