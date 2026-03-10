const { Router } = require('express');
const multer = require('multer');
const uploadController = require('../controllers/upload.controller');
const { authGuard } = require('../middleware/auth');
const { partnerAuthGuard } = require('../middleware/partnerAuth');

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'video/mp4'];
    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('File type not allowed'), false);
    }
  },
});

const router = Router();

router.post('/partner-media', partnerAuthGuard, upload.single('file'), uploadController.uploadPartnerMedia);
router.post('/partner-profile', partnerAuthGuard, upload.single('file'), uploadController.uploadPartnerProfile);
router.post('/promotion-image', partnerAuthGuard, upload.single('file'), uploadController.uploadPromotionImage);
router.post('/business-image', partnerAuthGuard, upload.single('file'), uploadController.uploadBusinessImage);
router.post('/amenity-image', partnerAuthGuard, upload.single('file'), uploadController.uploadAmenityImage);
router.post('/service-provider-image', partnerAuthGuard, upload.single('file'), uploadController.uploadServiceProviderImage);
router.post('/provider-media', partnerAuthGuard, upload.single('file'), uploadController.uploadProviderMedia);
router.post('/business-media', partnerAuthGuard, upload.single('file'), uploadController.uploadBusinessMedia);
router.post('/amenity-media', partnerAuthGuard, upload.single('file'), uploadController.uploadAmenityMedia);
router.post('/user-profile', authGuard, upload.single('file'), uploadController.uploadUserProfile);
router.post('/review-media', authGuard, upload.single('file'), uploadController.uploadReviewMedia);

module.exports = router;
