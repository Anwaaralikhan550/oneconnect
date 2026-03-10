const { Router } = require('express');
const businessController = require('../controllers/business.controller');
const { validate } = require('../middleware/validate');
const { authGuard, optionalAuth } = require('../middleware/auth');
const { businessQuerySchema, reviewSchema, idParamSchema } = require('../schemas/common.schema');

const router = Router();

router.get('/', validate(businessQuerySchema, 'query'), businessController.list);
router.get('/:id', optionalAuth, validate(idParamSchema, 'params'), businessController.getById);
router.post('/:id/reviews', authGuard, validate(idParamSchema, 'params'), validate(reviewSchema), businessController.addReview);
router.post('/:id/favorite', authGuard, validate(idParamSchema, 'params'), businessController.toggleFavorite);
router.post('/:id/reviews/:reviewId/vote', authGuard, businessController.voteReview);

module.exports = router;
