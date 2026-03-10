const { Router } = require('express');
const multer = require('multer');
const path = require('path');
const uploadController = require('../controllers/upload.controller');
const { authGuard } = require('../middleware/auth');
const { partnerAuthGuard } = require('../middleware/partnerAuth');
const { AppError } = require('../middleware/errorHandler');

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 25 * 1024 * 1024 }, // 25MB
  fileFilter: (req, file, cb) => {
    const mime = (file.mimetype || '').toLowerCase().trim();
    const ext = path.extname(file.originalname || '').toLowerCase();
    const isImage = mime.startsWith('image/');
    const isAllowedVideo = ['video/mp4', 'video/quicktime', 'video/webm', 'video/x-m4v']
      .includes(mime);
    const allowedExt = [
      '.jpg', '.jpeg', '.png', '.webp', '.gif', '.heic', '.heif',
      '.mp4', '.mov', '.webm', '.m4v', '.3gp',
    ].includes(ext);
    const isOctetStream = mime === 'application/octet-stream';

    if (isImage || isAllowedVideo || (isOctetStream && allowedExt) || (isOctetStream && !ext)) {
      cb(null, true);
    } else {
      cb(new AppError(`File type not allowed: ${mime || 'unknown'}`, 415), false);
    }
  },
});

const router = Router();

function uploadSingle(req, res, next) {
  upload.single('file')(req, res, (err) => {
    if (!err) return next();

    if (err instanceof multer.MulterError) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return next(new AppError('File too large. Max allowed size is 25MB.', 413));
      }
      return next(new AppError(`Upload error: ${err.message}`, 400));
    }

    if (err?.statusCode) return next(err);
    return next(new AppError(err?.message || 'Invalid multipart upload payload', 400));
  });
}

router.post('/partner-media', partnerAuthGuard, uploadSingle, uploadController.uploadPartnerMedia);
router.post('/partner-profile', partnerAuthGuard, uploadSingle, uploadController.uploadPartnerProfile);
router.post('/promotion-image', partnerAuthGuard, uploadSingle, uploadController.uploadPromotionImage);
router.post('/business-image', partnerAuthGuard, uploadSingle, uploadController.uploadBusinessImage);
router.post('/amenity-image', partnerAuthGuard, uploadSingle, uploadController.uploadAmenityImage);
router.post('/service-provider-image', partnerAuthGuard, uploadSingle, uploadController.uploadServiceProviderImage);
router.post('/provider-media', partnerAuthGuard, uploadSingle, uploadController.uploadProviderMedia);
router.post('/business-media', partnerAuthGuard, uploadSingle, uploadController.uploadBusinessMedia);
router.post('/amenity-media', partnerAuthGuard, uploadSingle, uploadController.uploadAmenityMedia);
router.post('/user-profile', authGuard, uploadSingle, uploadController.uploadUserProfile);
router.post('/review-media', authGuard, uploadSingle, uploadController.uploadReviewMedia);

module.exports = router;
