const userService = require('../services/user.service');

async function getProfile(req, res, next) {
  try {
    const result = await userService.getProfile(req.user.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function updateProfile(req, res, next) {
  try {
    const result = await userService.updateProfile(req.user.id, req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function getFavorites(req, res, next) {
  try {
    const result = await userService.getFavorites(req.user.id, req.query.targetType);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function getNotifications(req, res, next) {
  try {
    const result = await userService.getNotifications(req.user.id, req.query.unread);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function markAllNotificationsRead(req, res, next) {
  try {
    await userService.markAllNotificationsRead(req.user.id);
    res.json({ success: true, data: { message: 'All notifications marked as read' } });
  } catch (err) {
    next(err);
  }
}

async function updateDeviceToken(req, res, next) {
  try {
    const result = await userService.updateDeviceToken(req.user.id, req.body.fcmToken);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function getNotificationPreferences(req, res, next) {
  try {
    const result = await userService.getNotificationPreferences(req.user.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function updateNotificationPreferences(req, res, next) {
  try {
    const result = await userService.updateNotificationPreferences(req.user.id, req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deleteAccount(req, res, next) {
  try {
    await userService.deleteAccount(req.user.id);
    res.json({ success: true, data: { message: 'Account deleted' } });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getProfile,
  updateProfile,
  getFavorites,
  getNotifications,
  markAllNotificationsRead,
  updateDeviceToken,
  getNotificationPreferences,
  updateNotificationPreferences,
  deleteAccount,
};
