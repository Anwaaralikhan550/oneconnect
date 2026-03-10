const searchService = require('../services/search.service');

async function search(req, res, next) {
  try {
    const result = await searchService.search(req.query);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function suggestions(req, res, next) {
  try {
    const result = await searchService.suggestions(req.query.q);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function popular(req, res, next) {
  try {
    const result = await searchService.popular(req.query);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function getSearchHistory(req, res, next) {
  try {
    const result = await searchService.getSearchHistory(req.user.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function saveSearchHistory(req, res, next) {
  try {
    const result = await searchService.saveSearchHistory(
      req.user.id,
      req.body.query,
      req.body.category
    );
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deleteSearchHistory(req, res, next) {
  try {
    await searchService.deleteSearchHistory(req.user.id, req.params.id);
    res.json({ success: true, data: { message: 'Search history cleared' } });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  search,
  suggestions,
  popular,
  getSearchHistory,
  saveSearchHistory,
  deleteSearchHistory,
};
