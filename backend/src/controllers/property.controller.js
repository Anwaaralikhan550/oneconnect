const propertyService = require('../services/property.service');

async function list(req, res, next) {
  try {
    const result = await propertyService.list(req.query);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

async function getById(req, res, next) {
  try {
    const result = await propertyService.getById(req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

module.exports = { list, getById };
