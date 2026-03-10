const bookingService = require('../services/booking.service');

async function createBooking(req, res, next) {
  try {
    if (!req.actor || req.actor.role !== 'user') {
      return res.status(403).json({ success: false, error: 'User access required for booking' });
    }
    const result = await bookingService.createBooking(req.actor.id, req.body);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function getMyBookings(req, res, next) {
  try {
    const result = await bookingService.listMyBookings(req.actor, req.query);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function updateBookingStatus(req, res, next) {
  try {
    const result = await bookingService.updateBookingStatus(
      req.actor,
      req.params.id,
      req.body.status
    );
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  createBooking,
  getMyBookings,
  updateBookingStatus,
};
