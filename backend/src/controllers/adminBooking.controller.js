const adminBookingService = require('../services/adminBooking.service');

async function getBookingStats(req, res, next) {
  try {
    const result = await adminBookingService.getBookingStats(req.query);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

module.exports = { getBookingStats };
