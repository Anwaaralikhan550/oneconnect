const { Router } = require('express');
const spController = require('../controllers/serviceProvider.controller');
const { validate } = require('../middleware/validate');
const { authGuard, optionalAuth } = require('../middleware/auth');
const { serviceProviderQuerySchema, serviceSkillSuggestionsQuerySchema, reviewSchema, idParamSchema } = require('../schemas/common.schema');

const router = Router();

// Public (optionalAuth to include currentUserVote if logged in)
router.get('/', validate(serviceProviderQuerySchema, 'query'), spController.list);
router.get('/suggestions/skills', validate(serviceSkillSuggestionsQuerySchema, 'query'), spController.getSkillSuggestions);
router.get('/:id', optionalAuth, validate(idParamSchema, 'params'), spController.getById);
router.get('/:id/media', validate(idParamSchema, 'params'), spController.getMedia);

// Authenticated
router.post('/:id/reviews', authGuard, validate(idParamSchema, 'params'), validate(reviewSchema), spController.addReview);
router.post('/:id/favorite', authGuard, validate(idParamSchema, 'params'), spController.toggleFavorite);
router.post('/:id/follow', authGuard, validate(idParamSchema, 'params'), spController.toggleFollow);
router.post('/:id/reviews/:reviewId/vote', authGuard, spController.voteReview);

module.exports = router;
