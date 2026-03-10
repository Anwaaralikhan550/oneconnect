const { prisma } = require('../config/database');
const { AppError } = require('../middleware/errorHandler');

async function getProfile(userId) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      name: true,
      email: true,
      phone: true,
      profilePhotoUrl: true,
      bio: true,
      address: true,
      country: true,
      gender: true,
      occupation: true,
      dateOfBirth: true,
      locationLat: true,
      locationLng: true,
      notifySound: true,
      notifyVibrate: true,
      notifyEmailUpdates: true,
      notifySmsUpdates: true,
      notifyPushUpdates: true,
      notifyEmailReminders: true,
      notifySmsReminders: true,
      notifyPushReminders: true,
      createdAt: true,
    },
  });

  if (!user) throw new AppError('User not found', 404);
  return user;
}

async function updateProfile(userId, data) {
  const user = await prisma.user.update({
    where: { id: userId },
    data,
    select: {
      id: true,
      name: true,
      email: true,
      phone: true,
      profilePhotoUrl: true,
      bio: true,
      address: true,
      country: true,
      gender: true,
      occupation: true,
      dateOfBirth: true,
      locationLat: true,
      locationLng: true,
      notifySound: true,
      notifyVibrate: true,
      notifyEmailUpdates: true,
      notifySmsUpdates: true,
      notifyPushUpdates: true,
      notifyEmailReminders: true,
      notifySmsReminders: true,
      notifyPushReminders: true,
    },
  });
  return user;
}

async function getNotificationPreferences(userId) {
  const prefs = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      notifySound: true,
      notifyVibrate: true,
      notifyEmailUpdates: true,
      notifySmsUpdates: true,
      notifyPushUpdates: true,
      notifyEmailReminders: true,
      notifySmsReminders: true,
      notifyPushReminders: true,
    },
  });
  if (!prefs) throw new AppError('User not found', 404);
  return prefs;
}

async function updateNotificationPreferences(userId, data) {
  const prefs = await prisma.user.update({
    where: { id: userId },
    data,
    select: {
      notifySound: true,
      notifyVibrate: true,
      notifyEmailUpdates: true,
      notifySmsUpdates: true,
      notifyPushUpdates: true,
      notifyEmailReminders: true,
      notifySmsReminders: true,
      notifyPushReminders: true,
    },
  });
  return prefs;
}

async function deleteAccount(userId) {
  await prisma.user.delete({
    where: { id: userId },
  });
}

async function getFavorites(userId, targetType) {
  const where = { userId };
  if (targetType) where.targetType = targetType;

  return prisma.favorite.findMany({
    where,
    include: {
      serviceProvider: targetType === 'SERVICE_PROVIDER' || !targetType ? {
        select: { id: true, name: true, serviceType: true, rating: true, imageUrl: true },
      } : false,
      business: targetType === 'BUSINESS' || !targetType ? {
        select: { id: true, name: true, category: true, rating: true, imageUrl: true },
      } : false,
      amenity: targetType === 'AMENITY' || !targetType ? {
        select: { id: true, name: true, amenityType: true, rating: true, imageUrl: true },
      } : false,
      property: targetType === 'PROPERTY' || !targetType ? {
        select: { id: true, title: true, location: true, price: true, mainImageUrl: true },
      } : false,
    },
    orderBy: { createdAt: 'desc' },
  });
}

async function getNotifications(userId, unread) {
  const where = { userId };
  if (unread === 'true' || unread === true) where.isRead = false;

  return prisma.notification.findMany({
    where,
    orderBy: { createdAt: 'desc' },
    take: 50,
  });
}

async function markAllNotificationsRead(userId) {
  await prisma.notification.updateMany({
    where: { userId, isRead: false },
    data: { isRead: true },
  });
}

async function updateDeviceToken(userId, fcmToken) {
  await prisma.user.update({
    where: { id: userId },
    data: { fcmToken: String(fcmToken || '').trim() },
  });
  return { message: 'Device token updated' };
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
