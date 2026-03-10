const { Router } = require('express');
const amenityController = require('../controllers/amenity.controller');
const { validate } = require('../middleware/validate');
const { authGuard, optionalAuth } = require('../middleware/auth');
const { amenityQuerySchema, reviewSchema, idParamSchema } = require('../schemas/common.schema');

const router = Router();

router.get('/', validate(amenityQuerySchema, 'query'), amenityController.list);
router.get('/:id', optionalAuth, validate(idParamSchema, 'params'), amenityController.getById);
router.post('/:id/reviews', authGuard, validate(idParamSchema, 'params'), validate(reviewSchema), amenityController.addReview);
router.post('/:id/favorite', authGuard, validate(idParamSchema, 'params'), amenityController.toggleFavorite);
router.post('/:id/reviews/:reviewId/vote', authGuard, amenityController.voteReview);

module.exports = router;
