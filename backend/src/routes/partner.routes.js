const { Router } = require('express');
const partnerController = require('../controllers/partner.controller');
const { validate } = require('../middleware/validate');
const { partnerAuthGuard } = require('../middleware/partnerAuth');
const { authLimiter } = require('../middleware/rateLimiter');
const {
  partnerRegisterSchema,
  partnerLoginSchema,
  partnerRefreshSchema,
  partnerForgotPasswordSchema,
  partnerResetPasswordSchema,
  partnerUpdateSchema,
  partnerPhonesSchema,
} = require('../schemas/partner.schema');
const { refreshSchema } = require('../schemas/auth.schema');
const {
  promotionSchema,
  serviceProviderCreateSchema,
  businessCreateSchema,
  amenityCreateSchema,
  partnerPropertyCreateSchema,
  idParamSchema,
} = require('../schemas/common.schema');

const router = Router();

// Public
router.post('/register', authLimiter, validate(partnerRegisterSchema), partnerController.register);
router.post('/login', authLimiter, validate(partnerLoginSchema), partnerController.login);
router.post('/refresh', validate(partnerRefreshSchema), partnerController.refresh);
router.post('/forgot-password', authLimiter, validate(partnerForgotPasswordSchema), partnerController.forgotPassword);
router.post('/reset-password', authLimiter, validate(partnerResetPasswordSchema), partnerController.resetPassword);
router.post('/logout', partnerAuthGuard, validate(refreshSchema), partnerController.logout);

// Protected
router.get('/me', partnerAuthGuard, partnerController.getProfile);
router.put('/me', partnerAuthGuard, validate(partnerUpdateSchema), partnerController.updateProfile);
router.put('/me/phones', partnerAuthGuard, validate(partnerPhonesSchema), partnerController.updatePhones);

// Promotions
router.get('/me/promotions', partnerAuthGuard, partnerController.getPromotions);
router.post('/me/promotions', partnerAuthGuard, validate(promotionSchema), partnerController.createPromotion);
router.put('/me/promotions/:id', partnerAuthGuard, validate(promotionSchema), partnerController.updatePromotion);
router.delete('/me/promotions/:id', partnerAuthGuard, partnerController.deletePromotion);

// Service Providers
router.get('/me/service-providers', partnerAuthGuard, partnerController.getServiceProviders);
router.post('/me/service-providers', partnerAuthGuard, validate(serviceProviderCreateSchema), partnerController.createServiceProvider);
router.put('/me/service-providers/:id', partnerAuthGuard, validate(serviceProviderCreateSchema), partnerController.updateServiceProvider);
router.delete('/me/service-providers/:id', partnerAuthGuard, partnerController.deleteServiceProvider);
router.get('/me/service-providers/:id/media', partnerAuthGuard, validate(idParamSchema, 'params'), partnerController.getServiceProviderMedia);
router.delete('/me/service-providers/media/:mediaId', partnerAuthGuard, partnerController.deleteServiceProviderMedia);

// Businesses
router.get('/me/businesses', partnerAuthGuard, partnerController.getBusinesses);
router.post('/me/businesses', partnerAuthGuard, validate(businessCreateSchema), partnerController.createBusiness);
router.put('/me/businesses/:id', partnerAuthGuard, validate(businessCreateSchema), partnerController.updateBusiness);
router.delete('/me/businesses/:id', partnerAuthGuard, partnerController.deleteBusiness);

// Properties
router.get('/me/properties', partnerAuthGuard, partnerController.getProperties);
router.post('/me/properties', partnerAuthGuard, validate(partnerPropertyCreateSchema), partnerController.createProperty);
router.put('/me/properties/:id', partnerAuthGuard, validate(idParamSchema, 'params'), validate(partnerPropertyCreateSchema), partnerController.updateProperty);
router.delete('/me/properties/:id', partnerAuthGuard, validate(idParamSchema, 'params'), partnerController.deleteProperty);

// Amenities
router.get('/me/amenities', partnerAuthGuard, partnerController.getAmenities);
router.post('/me/amenities', partnerAuthGuard, validate(amenityCreateSchema), partnerController.createAmenity);
router.put('/me/amenities/:id', partnerAuthGuard, validate(amenityCreateSchema), partnerController.updateAmenity);
router.delete('/me/amenities/:id', partnerAuthGuard, partnerController.deleteAmenity);

// Media
router.get('/me/media', partnerAuthGuard, partnerController.getMedia);
router.delete('/me/media/:id', partnerAuthGuard, partnerController.deleteMedia);

module.exports = router;
