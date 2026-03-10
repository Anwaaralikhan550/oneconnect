const adminService = require('../services/admin.service');

async function listOffices(req, res, next) {
  try {
    const result = await adminService.listOffices(req.query);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

async function getOfficeById(req, res, next) {
  try {
    const result = await adminService.getOfficeById(req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

module.exports = { listOffices, getOfficeById };
