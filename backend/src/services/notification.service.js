const { prisma } = require('../config/database');

async function create(userId, { type, title, body, data }) {
  return prisma.notification.create({
    data: { userId, type, title, body, data },
  });
}

async function list(userId, { unread, page = 1, limit = 20 }) {
  const skip = (page - 1) * limit;
  const where = { userId };
  if (unread === 'true' || unread === true) where.isRead = false;

  const [data, total] = await Promise.all([
    prisma.notification.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip,
      take: limit,
    }),
    prisma.notification.count({ where }),
  ]);

  return {
    data,
    pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
  };
}

async function markAllRead(userId) {
  const result = await prisma.notification.updateMany({
    where: { userId, isRead: false },
    data: { isRead: true },
  });
  return { markedRead: result.count };
}

module.exports = { create, list, markAllRead };
