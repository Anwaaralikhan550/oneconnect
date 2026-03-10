const { Router } = require('express');
const userController = require('../controllers/user.controller');
const { validate } = require('../middleware/validate');
const { authGuard } = require('../middleware/auth');
const {
  userUpdateSchema,
  notificationPreferencesSchema,
  deviceTokenSchema,
} = require('../schemas/common.schema');

const router = Router();

router.get('/me', authGuard, userController.getProfile);
router.put('/me', authGuard, validate(userUpdateSchema), userController.updateProfile);
router.delete('/me', authGuard, userController.deleteAccount);
router.get('/me/notification-preferences', authGuard, userController.getNotificationPreferences);
router.put('/me/notification-preferences', authGuard, validate(notificationPreferencesSchema), userController.updateNotificationPreferences);
router.get('/me/favorites', authGuard, userController.getFavorites);
router.get('/me/notifications', authGuard, userController.getNotifications);
router.put('/me/notifications/read-all', authGuard, userController.markAllNotificationsRead);
router.put('/me/device-token', authGuard, validate(deviceTokenSchema), userController.updateDeviceToken);

module.exports = router;
