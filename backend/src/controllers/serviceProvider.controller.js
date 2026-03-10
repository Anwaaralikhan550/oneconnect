const spService = require('../services/serviceProvider.service');

async function list(req, res, next) {
  try {
    const result = await spService.list(req.query);
    res.json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

async function getSkillSuggestions(req, res, next) {
  try {
    const result = await spService.getSkillSuggestions(req.query.type);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function getById(req, res, next) {
  try {
    const userId = req.user?.id ?? null;
    const result = await spService.getById(req.params.id, userId);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function getMedia(req, res, next) {
  try {
    const result = await spService.getMedia(req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function addReview(req, res, next) {
  try {
    const result = await spService.addReview(req.params.id, req.user.id, req.body);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function toggleFavorite(req, res, next) {
  try {
    const result = await spService.toggleFavorite(req.params.id, req.user.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function voteReview(req, res, next) {
  try {
    const { voteType } = req.body;
    if (!voteType || !['helpful', 'unhelpful'].includes(voteType)) {
      return res.status(400).json({ success: false, message: 'voteType must be "helpful" or "unhelpful"' });
    }
    const result = await spService.voteReview(req.params.reviewId, req.user.id, voteType);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

module.exports = { list, getSkillSuggestions, getById, getMedia, addReview, toggleFavorite, voteReview };
