const amenityService = require('../services/amenity.service');

async function list(req, res, next) {
  try {
    const result = await amenityService.list(req.query);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

async function getById(req, res, next) {
  try {
    const userId = req.user?.id ?? null;
    const result = await amenityService.getById(req.params.id, userId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function addReview(req, res, next) {
  try {
    const result = await amenityService.addReview(req.params.id, req.user.id, req.body);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function toggleFavorite(req, res, next) {
  try {
    const result = await amenityService.toggleFavorite(req.params.id, req.user.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function voteReview(req, res, next) {
  try {
    const { voteType } = req.body;
    if (!['helpful', 'unhelpful'].includes(voteType)) {
      return res.status(400).json({ success: false, error: 'voteType must be helpful or unhelpful' });
    }
    const result = await amenityService.voteReview(req.params.reviewId, req.user.id, voteType);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

module.exports = { list, getById, addReview, toggleFavorite, voteReview };
