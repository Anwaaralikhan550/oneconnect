const { Router } = require('express');
const searchController = require('../controllers/search.controller');
const { validate } = require('../middleware/validate');
const { authGuard } = require('../middleware/auth');
const {
  searchQuerySchema,
  searchPopularQuerySchema,
  searchSuggestionSchema,
  searchHistorySaveSchema,
} = require('../schemas/common.schema');

const router = Router();

// Public
router.get('/', validate(searchQuerySchema, 'query'), searchController.search);
router.get('/suggestions', validate(searchSuggestionSchema, 'query'), searchController.suggestions);
router.get('/popular', validate(searchPopularQuerySchema, 'query'), searchController.popular);

// Authenticated
router.get('/history', authGuard, searchController.getSearchHistory);
router.post('/history', authGuard, validate(searchHistorySaveSchema), searchController.saveSearchHistory);
router.delete('/history/:id?', authGuard, searchController.deleteSearchHistory);

module.exports = router;
