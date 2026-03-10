const businessService = require('../services/business.service');
const followService = require('../services/follow.service');

async function list(req, res, next) {
  try {
    const result = await businessService.list(req.query);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

async function getById(req, res, next) {
  try {
    const userId = req.user?.id ?? null;
    const result = await businessService.getById(req.params.id, userId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function addReview(req, res, next) {
  try {
    const result = await businessService.addReview(req.params.id, req.user.id, req.body);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function toggleFavorite(req, res, next) {
  try {
    const result = await businessService.toggleFavorite(req.params.id, req.user.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function toggleFollow(req, res, next) {
  try {
    const result = await followService.toggleBusinessFollow(req.params.id, req.user.id);
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
    const result = await businessService.voteReview(req.params.reviewId, req.user.id, voteType);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

module.exports = { list, getById, addReview, toggleFavorite, toggleFollow, voteReview };
