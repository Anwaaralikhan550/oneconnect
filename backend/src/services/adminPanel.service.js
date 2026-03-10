const { prisma } = require('../config/database');
const { AppError } = require('../middleware/errorHandler');

// ─── HELPERS ─────────────────────────────────────────

const TYPE_MAP = {
  'service-providers': 'serviceProvider',
  'businesses': 'business',
  'amenities': 'amenity',
  'promotions': 'promotion',
};

function getPrismaModel(type) {
  const modelName = TYPE_MAP[type];
  if (!modelName) throw new AppError(`Invalid content type: ${type}`, 400);
  return { model: prisma[modelName], name: modelName };
}

// ─── DASHBOARD STATS ─────────────────────────────────

async function getDashboardStats() {
  const [
    totalPartners,
    pendingPartners,
    approvedPartners,
    suspendedPartners,
    totalServiceProviders,
    pendingServiceProviders,
    totalBusinesses,
    pendingBusinesses,
    totalAmenities,
    pendingAmenities,
    totalPromotions,
    pendingPromotions,
    totalUsers,
    totalReviews,
    pendingProperties,
    totalAdminOffices,
  ] = await Promise.all([
    prisma.partner.count(),
    prisma.partner.count({ where: { status: 'PENDING_REVIEW' } }),
    prisma.partner.count({ where: { status: 'APPROVED' } }),
    prisma.partner.count({ where: { status: 'SUSPENDED' } }),
    prisma.serviceProvider.count(),
    prisma.serviceProvider.count({ where: { contentStatus: 'PENDING' } }),
    prisma.business.count(),
    prisma.business.count({ where: { contentStatus: 'PENDING' } }),
    prisma.amenity.count(),
    prisma.amenity.count({ where: { contentStatus: 'PENDING' } }),
    prisma.promotion.count(),
    prisma.promotion.count({ where: { contentStatus: 'PENDING' } }),
    prisma.user.count(),
    prisma.review.count(),
    prisma.property.count({ where: { contentStatus: 'PENDING' } }),
    prisma.adminOffice.count(),
  ]);

  return {
    partners: { total: totalPartners, pending: pendingPartners, approved: approvedPartners, suspended: suspendedPartners },
    serviceProviders: { total: totalServiceProviders, pending: pendingServiceProviders },
    businesses: { total: totalBusinesses, pending: pendingBusinesses },
    amenities: { total: totalAmenities, pending: pendingAmenities },
    promotions: { total: totalPromotions, pending: pendingPromotions },
    users: { total: totalUsers },
    reviews: { total: totalReviews },
    properties: { pending: pendingProperties },
    adminOffices: { total: totalAdminOffices },
    totalPending: pendingPartners + pendingServiceProviders + pendingBusinesses + pendingAmenities + pendingPromotions + pendingProperties,
  };
}

// ─── PARTNER MANAGEMENT ─────────────────────────────

async function listPartners(query, adminId) {
  const { status, search } = query;
  const page = parseInt(query.page, 10) || 1;
  const limit = parseInt(query.limit, 10) || 20;
  const skip = (page - 1) * limit;

  const where = {};
  if (status) where.status = status;
  if (search) {
    where.OR = [
      { businessName: { contains: search, mode: 'insensitive' } },
      { ownerFullName: { contains: search, mode: 'insensitive' } },
      { businessId: { contains: search, mode: 'insensitive' } },
      { businessEmail: { contains: search, mode: 'insensitive' } },
    ];
  }

  const [data, total] = await Promise.all([
    prisma.partner.findMany({
      where,
      select: {
        id: true, businessId: true, businessName: true, ownerFullName: true,
        businessEmail: true, businessType: true, status: true, city: true,
        createdAt: true, profilePhotoUrl: true,
      },
      orderBy: { createdAt: 'desc' },
      skip,
      take: limit,
    }),
    prisma.partner.count({ where }),
  ]);

  // Annotate each partner with isFavourited flag
  if (adminId) {
    const favIds = await getFavouritePartnerIds(adminId);
    for (const partner of data) {
      partner.isFavourited = favIds.has(partner.id);
    }
  }

  return { data, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } };
}

async function getPartnerById(id) {
  const partner = await prisma.partner.findUnique({
    where: { id },
    include: {
      phones: true,
      operatingDays: true,
      partnerCategories: { include: { category: true } },
      serviceProviders: { select: { id: true, name: true, serviceType: true, contentStatus: true } },
      businesses: { select: { id: true, name: true, category: true, contentStatus: true } },
      amenities: { select: { id: true, name: true, amenityType: true, contentStatus: true } },
      promotions: { select: { id: true, title: true, isActive: true, contentStatus: true } },
      media: { orderBy: { createdAt: 'desc' } },
    },
  });

  if (!partner) throw new AppError('Partner not found', 404);
  return partner;
}

async function updatePartnerStatus(id, status) {
  const partner = await prisma.partner.findUnique({ where: { id } });
  if (!partner) throw new AppError('Partner not found', 404);

  const validStatuses = ['PENDING_REVIEW', 'APPROVED', 'REJECTED', 'SUSPENDED'];
  if (!validStatuses.includes(status)) {
    throw new AppError(`Invalid status. Must be one of: ${validStatuses.join(', ')}`, 400);
  }

  return prisma.$transaction(async (tx) => {
    const updatedPartner = await tx.partner.update({
      where: { id },
      data: { status },
      select: { id: true, businessId: true, businessName: true, status: true },
    });

    // Keep partner content in sync with admin partner approval.
    // APPROVED partner -> auto-approve pending content created under this partner.
    if (status === 'APPROVED') {
      await Promise.all([
        tx.serviceProvider.updateMany({
          where: { partnerId: id, contentStatus: 'PENDING' },
          data: { contentStatus: 'APPROVED' },
        }),
        tx.business.updateMany({
          where: { partnerId: id, contentStatus: 'PENDING' },
          data: { contentStatus: 'APPROVED' },
        }),
        tx.amenity.updateMany({
          where: { partnerId: id, contentStatus: 'PENDING' },
          data: { contentStatus: 'APPROVED' },
        }),
        tx.promotion.updateMany({
          where: { partnerId: id, contentStatus: 'PENDING' },
          data: { contentStatus: 'APPROVED' },
        }),
      ]);
    }

    return updatedPartner;
  });
}

async function deletePartner(id) {
  const partner = await prisma.partner.findUnique({ where: { id } });
  if (!partner) throw new AppError('Partner not found', 404);

  await prisma.partner.delete({ where: { id } });
  return { message: 'Partner deleted' };
}

// ─── CONTENT MANAGEMENT ─────────────────────────────

async function listContent(type, query) {
  const { model } = getPrismaModel(type);
  const { contentStatus, search } = query;
  const page = parseInt(query.page, 10) || 1;
  const limit = parseInt(query.limit, 10) || 20;
  const skip = (page - 1) * limit;

  const where = {};
  if (contentStatus) where.contentStatus = contentStatus;

  if (search) {
    const nameField = type === 'promotions' ? 'title' : 'name';
    where[nameField] = { contains: search, mode: 'insensitive' };
  }

  // Build include based on type
  const include = {};
  if (type !== 'promotions') {
    include.partner = { select: { id: true, businessName: true } };
  } else {
    include.partner = { select: { id: true, businessName: true } };
  }

  const [data, total] = await Promise.all([
    model.findMany({ where, include, orderBy: { createdAt: 'desc' }, skip, take: limit }),
    model.count({ where }),
  ]);

  return { data, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } };
}

async function approveContent(type, id) {
  const { model, name } = getPrismaModel(type);
  const item = await model.findUnique({ where: { id } });
  if (!item) throw new AppError(`${name} not found`, 404);

  return model.update({
    where: { id },
    data: { contentStatus: 'APPROVED' },
  });
}

async function rejectContent(type, id) {
  const { model, name } = getPrismaModel(type);
  const item = await model.findUnique({ where: { id } });
  if (!item) throw new AppError(`${name} not found`, 404);

  return model.update({
    where: { id },
    data: { contentStatus: 'REJECTED' },
  });
}

async function createContent(type, data) {
  const { model } = getPrismaModel(type);

  // Admin-created content is auto-approved
  const createData = { ...data, contentStatus: 'APPROVED' };

  // Handle special fields for service providers
  if (type === 'service-providers' && !createData.categoryId) {
    throw new AppError('categoryId is required for service providers', 400);
  }

  return model.create({ data: createData });
}

async function updateContent(type, id, data) {
  const { model, name } = getPrismaModel(type);
  const item = await model.findUnique({ where: { id } });
  if (!item) throw new AppError(`${name} not found`, 404);

  // Don't allow changing contentStatus via generic update — use approve/reject
  const { contentStatus, ...updateData } = data;

  return model.update({ where: { id }, data: updateData });
}

async function deleteContent(type, id) {
  const { model, name } = getPrismaModel(type);
  const item = await model.findUnique({ where: { id } });
  if (!item) throw new AppError(`${name} not found`, 404);

  await model.delete({ where: { id } });
  return { message: `${name} deleted` };
}

// ─── ADMIN FAVOURITE PARTNERS ────────────────────────

async function getFavouritePartnerIds(adminId) {
  const rows = await prisma.adminFavouritePartner.findMany({
    where: { adminId },
    select: { partnerId: true },
  });
  return new Set(rows.map((r) => r.partnerId));
}

async function addFavouritePartner(adminId, partnerId) {
  const partner = await prisma.partner.findUnique({ where: { id: partnerId } });
  if (!partner) throw new AppError('Partner not found', 404);

  await prisma.adminFavouritePartner.upsert({
    where: { adminId_partnerId: { adminId, partnerId } },
    create: { adminId, partnerId },
    update: {},
  });

  return { message: 'Partner added to favourites' };
}

async function removeFavouritePartner(adminId, partnerId) {
  await prisma.adminFavouritePartner.deleteMany({
    where: { adminId, partnerId },
  });

  return { message: 'Partner removed from favourites' };
}

async function listFavouritePartners(adminId) {
  const rows = await prisma.adminFavouritePartner.findMany({
    where: { adminId },
    include: {
      partner: {
        select: {
          id: true, businessId: true, businessName: true, ownerFullName: true,
          businessEmail: true, businessType: true, status: true, city: true,
          rating: true, profilePhotoUrl: true, createdAt: true,
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  });

  // Group by businessType
  const grouped = {};
  for (const row of rows) {
    const type = row.partner.businessType;
    if (!grouped[type]) grouped[type] = [];
    grouped[type].push(row.partner);
  }

  return grouped;
}

// ─── USER MANAGEMENT ────────────────────────────────

async function listUsers(query) {
  const { search, isBanned } = query;
  const page = parseInt(query.page, 10) || 1;
  const limit = parseInt(query.limit, 10) || 20;
  const skip = (page - 1) * limit;

  const where = {};
  if (isBanned === 'true') where.isBanned = true;
  else if (isBanned === 'false') where.isBanned = false;

  if (search) {
    where.OR = [
      { name: { contains: search, mode: 'insensitive' } },
      { email: { contains: search, mode: 'insensitive' } },
      { phone: { contains: search, mode: 'insensitive' } },
    ];
  }

  const [data, total] = await Promise.all([
    prisma.user.findMany({
      where,
      select: {
        id: true, name: true, email: true, phone: true,
        isBanned: true, profilePhotoUrl: true, createdAt: true,
      },
      orderBy: { createdAt: 'desc' },
      skip,
      take: limit,
    }),
    prisma.user.count({ where }),
  ]);

  return { data, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } };
}

async function getUserById(id) {
  const user = await prisma.user.findUnique({
    where: { id },
    select: {
      id: true, name: true, email: true, phone: true,
      profilePhotoUrl: true, isBanned: true, createdAt: true,
      _count: { select: { reviews: true, favorites: true } },
    },
  });
  if (!user) throw new AppError('User not found', 404);
  return user;
}

async function toggleUserBan(id) {
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) throw new AppError('User not found', 404);

  return prisma.user.update({
    where: { id },
    data: { isBanned: !user.isBanned },
    select: { id: true, name: true, email: true, isBanned: true },
  });
}

// ─── REVIEW MANAGEMENT ─────────────────────────────

async function listReviews(query) {
  const { search } = query;
  const page = parseInt(query.page, 10) || 1;
  const limit = parseInt(query.limit, 10) || 20;
  const skip = (page - 1) * limit;

  const where = {};
  if (search) {
    where.OR = [
      { reviewText: { contains: search, mode: 'insensitive' } },
      { user: { name: { contains: search, mode: 'insensitive' } } },
    ];
  }

  const [data, total] = await Promise.all([
    prisma.review.findMany({
      where,
      include: {
        user: { select: { id: true, name: true, email: true } },
        serviceProvider: { select: { id: true, name: true } },
        business: { select: { id: true, name: true } },
        amenity: { select: { id: true, name: true } },
      },
      orderBy: { createdAt: 'desc' },
      skip,
      take: limit,
    }),
    prisma.review.count({ where }),
  ]);

  return { data, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } };
}

async function deleteReview(id) {
  const review = await prisma.review.findUnique({ where: { id } });
  if (!review) throw new AppError('Review not found', 404);

  await prisma.review.delete({ where: { id } });
  return { message: 'Review deleted' };
}

// ─── PROPERTY MANAGEMENT ────────────────────────────

async function listProperties(query) {
  const { contentStatus, search } = query;
  const page = parseInt(query.page, 10) || 1;
  const limit = parseInt(query.limit, 10) || 20;
  const skip = (page - 1) * limit;

  const where = {};
  if (contentStatus) where.contentStatus = contentStatus;
  if (search) {
    where.OR = [
      { title: { contains: search, mode: 'insensitive' } },
      { location: { contains: search, mode: 'insensitive' } },
    ];
  }

  const [data, total] = await Promise.all([
    prisma.property.findMany({
      where,
      include: { images: { take: 1, orderBy: { sortOrder: 'asc' } } },
      orderBy: { createdAt: 'desc' },
      skip,
      take: limit,
    }),
    prisma.property.count({ where }),
  ]);

  return { data, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } };
}

async function approveProperty(id) {
  const property = await prisma.property.findUnique({ where: { id } });
  if (!property) throw new AppError('Property not found', 404);

  return prisma.property.update({
    where: { id },
    data: { contentStatus: 'APPROVED' },
  });
}

async function rejectProperty(id) {
  const property = await prisma.property.findUnique({ where: { id } });
  if (!property) throw new AppError('Property not found', 404);

  return prisma.property.update({
    where: { id },
    data: { contentStatus: 'REJECTED' },
  });
}

async function deleteProperty(id) {
  const property = await prisma.property.findUnique({ where: { id } });
  if (!property) throw new AppError('Property not found', 404);

  await prisma.property.delete({ where: { id } });
  return { message: 'Property deleted' };
}

// ─── ADMIN OFFICE CRUD ──────────────────────────────

async function listAdminOffices(query) {
  const { officeType, search } = query;
  const page = parseInt(query.page, 10) || 1;
  const limit = parseInt(query.limit, 10) || 20;
  const skip = (page - 1) * limit;

  const where = {};
  if (officeType) where.officeType = officeType;
  if (search) {
    where.name = { contains: search, mode: 'insensitive' };
  }

  const [data, total] = await Promise.all([
    prisma.adminOffice.findMany({
      where,
      orderBy: { name: 'asc' },
      skip,
      take: limit,
    }),
    prisma.adminOffice.count({ where }),
  ]);

  return { data, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } };
}

async function createAdminOffice(data) {
  return prisma.adminOffice.create({ data });
}

async function updateAdminOffice(id, data) {
  const office = await prisma.adminOffice.findUnique({ where: { id } });
  if (!office) throw new AppError('Admin office not found', 404);

  return prisma.adminOffice.update({ where: { id }, data });
}

async function deleteAdminOffice(id) {
  const office = await prisma.adminOffice.findUnique({ where: { id } });
  if (!office) throw new AppError('Admin office not found', 404);

  await prisma.adminOffice.delete({ where: { id } });
  return { message: 'Admin office deleted' };
}

// ─── BROADCAST NOTIFICATIONS ────────────────────────

async function broadcastNotification({ title, body }) {
  if (!title || !body) throw new AppError('Title and body are required', 400);

  const users = await prisma.user.findMany({ select: { id: true } });
  if (users.length === 0) return { message: 'No users to notify', count: 0 };

  const notifications = users.map((u) => ({
    userId: u.id,
    type: 'SYSTEM',
    title,
    body,
  }));

  const result = await prisma.notification.createMany({ data: notifications });
  return { message: 'Broadcast sent', count: result.count };
}

async function listBroadcastHistory(query) {
  const page = parseInt(query.page, 10) || 1;
  const limit = parseInt(query.limit, 10) || 20;
  const offset = (page - 1) * limit;

  // Get distinct broadcasts by grouping on title+body+truncated timestamp
  const broadcasts = await prisma.$queryRaw`
    SELECT title, body, MIN("createdAt") as "createdAt", COUNT(*)::int as "recipientCount"
    FROM notifications
    WHERE type = 'SYSTEM'
    GROUP BY title, body
    ORDER BY MIN("createdAt") DESC
    LIMIT ${limit} OFFSET ${offset}
  `;

  const countResult = await prisma.$queryRaw`
    SELECT COUNT(*)::int as total FROM (
      SELECT title, body FROM notifications WHERE type = 'SYSTEM' GROUP BY title, body
    ) sub
  `;

  const total = countResult[0]?.total || 0;
  return { data: broadcasts, pagination: { page, limit, total, totalPages: Math.ceil(total / limit) } };
}

// ─── ANALYTICS ──────────────────────────────────────

async function getMonthlySignups() {
  const userSignups = await prisma.$queryRaw`
    SELECT DATE_TRUNC('month', "createdAt") as month, COUNT(*)::int as count
    FROM users
    WHERE "createdAt" >= NOW() - INTERVAL '12 months'
    GROUP BY DATE_TRUNC('month', "createdAt")
    ORDER BY month ASC
  `;

  const partnerSignups = await prisma.$queryRaw`
    SELECT DATE_TRUNC('month', "createdAt") as month, COUNT(*)::int as count
    FROM partners
    WHERE "createdAt" >= NOW() - INTERVAL '12 months'
    GROUP BY DATE_TRUNC('month', "createdAt")
    ORDER BY month ASC
  `;

  return { users: userSignups, partners: partnerSignups };
}

async function getTopSearches() {
  const results = await prisma.$queryRaw`
    SELECT query, COUNT(*)::int as count
    FROM search_history
    GROUP BY query
    ORDER BY count DESC
    LIMIT 20
  `;
  return results;
}

module.exports = {
  getDashboardStats,
  listPartners,
  getPartnerById,
  updatePartnerStatus,
  deletePartner,
  listContent,
  approveContent,
  rejectContent,
  createContent,
  updateContent,
  deleteContent,
  getFavouritePartnerIds,
  addFavouritePartner,
  removeFavouritePartner,
  listFavouritePartners,
  // User management
  listUsers,
  getUserById,
  toggleUserBan,
  // Review management
  listReviews,
  deleteReview,
  // Property management
  listProperties,
  approveProperty,
  rejectProperty,
  deleteProperty,
  // Admin office CRUD
  listAdminOffices,
  createAdminOffice,
  updateAdminOffice,
  deleteAdminOffice,
  // Notifications
  broadcastNotification,
  listBroadcastHistory,
  // Analytics
  getMonthlySignups,
  getTopSearches,
};
