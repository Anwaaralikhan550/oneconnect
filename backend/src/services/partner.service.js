const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const crypto = require('crypto');
const { prisma } = require('../config/database');
const { env } = require('../config/env');
const { AppError } = require('../middleware/errorHandler');
const { getSkillSuggestionsByType } = require('../constants/serviceSkillSuggestions');

const SALT_ROUNDS = 12;
const SERVICE_TYPE_TO_SLUG = {
  LAUNDRY: 'laundry',
  PLUMBER: 'plumber',
  ELECTRICIAN: 'electrician',
  PAINTER: 'painter',
  CARPENTER: 'carpenter',
  BARBER: 'barber',
  MAID: 'maid',
  SALON: 'salon',
  REAL_ESTATE: 'real-estate',
  DOCTOR: 'doctor',
  WATER: 'water',
  GAS: 'gas',
};

function toTitleCase(value) {
  return value
    .toLowerCase()
    .split(' ')
    .map((w) => (w ? w[0].toUpperCase() + w.slice(1) : w))
    .join(' ');
}

function getCategoryNameFromServiceType(serviceType) {
  return toTitleCase(serviceType.replaceAll('_', ' ').replaceAll('-', ' '));
}

function normalizeTagList(list) {
  if (!Array.isArray(list)) return [];

  const seen = new Set();
  const result = [];
  for (const raw of list) {
    const value = String(raw || '').trim();
    if (!value) continue;
    const key = value.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    result.push(value);
  }
  return result;
}

function buildSpecializations(serviceType, incomingSkills) {
  const normalizedIncoming = normalizeTagList(incomingSkills);
  if (normalizedIncoming.length) return normalizedIncoming;

  return normalizeTagList(getSkillSuggestionsByType(serviceType));
}

function hashToken(token) {
  return crypto.createHash('sha256').update(String(token)).digest('hex');
}

function parseExpiry(expiresIn) {
  const match = String(expiresIn || '').match(/^(\d+)([smhd])$/);
  if (!match) return 7 * 24 * 60 * 60 * 1000;
  const num = parseInt(match[1], 10);
  const unit = match[2];
  const multipliers = { s: 1000, m: 60000, h: 3600000, d: 86400000 };
  return num * (multipliers[unit] || 86400000);
}

function normalizeUrlPrefix(value) {
  const raw = String(value || '').trim();
  if (!raw) return '';
  return raw.endsWith('/') ? raw.slice(0, -1) : raw;
}

function isAllowedRedirectUrl(redirectUrl) {
  const candidate = normalizeUrlPrefix(redirectUrl);
  if (!candidate) return false;
  const allowList = String(env.PASSWORD_RESET_ALLOWED_REDIRECTS || '')
    .split(',')
    .map((s) => normalizeUrlPrefix(s))
    .filter(Boolean);
  if (allowList.length === 0) return false;
  return allowList.some((allowed) => candidate.startsWith(allowed));
}

function buildResetLink(token, redirectUrl) {
  const fallbackBase = env.PASSWORD_RESET_URL || 'oneconnect://reset-password';
  const baseUrl = isAllowedRedirectUrl(redirectUrl) ? redirectUrl : fallbackBase;
  const separator = baseUrl.includes('?') ? '&' : '?';
  return `${baseUrl}${separator}token=${encodeURIComponent(token)}`;
}

function partnerPasswordVersion(partner) {
  return crypto.createHash('sha256').update(String(partner.passwordHash || '')).digest('hex').slice(0, 16);
}

async function resolveServiceCategoryId(serviceType) {
  const normalizedType = String(serviceType || '').trim().toUpperCase();
  const fallbackSlug = normalizedType.toLowerCase().replaceAll('_', '-');
  const slug = SERVICE_TYPE_TO_SLUG[normalizedType] || fallbackSlug;
  const categoryName = normalizedType
    ? getCategoryNameFromServiceType(normalizedType)
    : 'General Service';
  if (!slug) {
    const firstAny = await prisma.serviceCategory.findFirst({
      orderBy: [{ isActive: 'desc' }, { sortOrder: 'asc' }, { createdAt: 'asc' }],
      select: { id: true },
    });
    return firstAny?.id ?? null;
  }

  const bySlug = await prisma.serviceCategory.findFirst({
    where: { slug },
    select: { id: true, isActive: true },
  });
  if (bySlug) {
    if (!bySlug.isActive) {
      await prisma.serviceCategory.update({
        where: { id: bySlug.id },
        data: { isActive: true },
      });
    }
    return bySlug.id;
  }

  const byName = await prisma.serviceCategory.findFirst({
    where: {
      name: { equals: categoryName, mode: 'insensitive' },
    },
    select: { id: true, isActive: true },
  });
  if (byName) {
    if (!byName.isActive) {
      await prisma.serviceCategory.update({
        where: { id: byName.id },
        data: { isActive: true, slug },
      });
    }
    return byName.id;
  }

  // Last resort: auto-create category to avoid blocking partner submissions.
  // This keeps relation integrity when service categories are not seeded yet.
  try {
    const created = await prisma.serviceCategory.create({
      data: {
        name: categoryName,
        slug,
        isActive: true,
      },
      select: { id: true },
    });
    return created.id;
  } catch (_) {
    // Handle unique race / schema differences by trying multiple fallbacks.
    const [raceBySlug, raceByName, firstAny] = await Promise.all([
      prisma.serviceCategory.findFirst({
        where: { slug },
        select: { id: true },
      }),
      prisma.serviceCategory.findFirst({
        where: {
          name: { equals: categoryName, mode: 'insensitive' },
        },
        select: { id: true },
      }),
      prisma.serviceCategory.findFirst({
        orderBy: [{ isActive: 'desc' }, { sortOrder: 'asc' }, { createdAt: 'asc' }],
        select: { id: true },
      }),
    ]);
    return raceBySlug?.id ?? raceByName?.id ?? firstAny?.id ?? null;
  }
}

async function generateBusinessId() {
  const year = new Date().getFullYear();
  const count = await prisma.partner.count();
  const seq = String(count + 1).padStart(5, '0');
  return `OC-${year}-${seq}`;
}

function generateTokens(payload) {
  const accessToken = jwt.sign(payload, env.JWT_SECRET, {
    expiresIn: env.JWT_EXPIRES_IN,
  });
  const refreshToken = jwt.sign(
    { ...payload, jti: uuidv4() },
    env.JWT_REFRESH_SECRET,
    { expiresIn: env.JWT_REFRESH_EXPIRES_IN }
  );
  return { accessToken, refreshToken };
}

async function generateUniqueVendorId(db = prisma) {
  for (let i = 0; i < 12; i += 1) {
    const candidate = `V-${String(Math.floor(1000 + Math.random() * 9000))}`;
    const exists = await db.serviceProvider.findFirst({
      where: { vendorId: candidate },
      select: { id: true },
    });
    if (!exists) return candidate;
  }
  // Fallback with wider entropy in rare collision bursts.
  return `V-${Date.now().toString().slice(-6)}`;
}

async function register(data) {
  const normalizedEmail = String(data.businessEmail || '').trim().toLowerCase();

  const existing = await prisma.partner.findUnique({
    where: { businessEmail: normalizedEmail },
  });
  if (existing) {
    if (existing.status !== 'REJECTED') {
      throw new AppError('Business email already registered', 409);
    }

    const passwordHash = await bcrypt.hash(data.password, SALT_ROUNDS);
    const partner = await prisma.$transaction(async (tx) => {
      await tx.partnerRefreshToken.deleteMany({ where: { partnerId: existing.id } });
      await tx.partnerPhone.deleteMany({ where: { partnerId: existing.id } });
      await tx.partnerOperatingDay.deleteMany({ where: { partnerId: existing.id } });
      await tx.partnerCategory.deleteMany({ where: { partnerId: existing.id } });

      return tx.partner.update({
        where: { id: existing.id },
        data: {
          businessName: data.businessName,
          ownerFullName: data.ownerFullName,
          businessEmail: normalizedEmail,
          passwordHash,
          businessType: data.businessType,
          status: 'PENDING_REVIEW',
          address: data.address,
          area: data.area,
          city: data.city,
          country: data.country || 'Pakistan',
          openingTime: data.openingTime,
          closingTime: data.closingTime,
          description: data.description,
          phones: data.phones
              ? {
                  create: data.phones.map((p) => ({
                    phoneNumber: p.phoneNumber,
                    countryCode: p.countryCode || '+92',
                    isPrimary: p.isPrimary || false,
                  })),
                }
              : undefined,
          operatingDays: data.operatingDays
              ? {
                  create: data.operatingDays.map((day) => ({ dayCode: day })),
                }
              : undefined,
          partnerCategories: data.categoryIds
              ? {
                  create: data.categoryIds.map((catId) => ({ categoryId: catId })),
                }
              : undefined,
        },
        include: {
          phones: true,
          operatingDays: true,
        },
      });
    });

    return {
      partner: {
        id: partner.id,
        businessId: partner.businessId,
        businessName: partner.businessName,
        ownerFullName: partner.ownerFullName,
        status: partner.status,
      },
    };
  }

  const businessId = await generateBusinessId();
  const passwordHash = await bcrypt.hash(data.password, SALT_ROUNDS);

  const partner = await prisma.partner.create({
    data: {
      businessId,
      businessName: data.businessName,
      ownerFullName: data.ownerFullName,
      businessEmail: normalizedEmail,
      passwordHash,
      businessType: data.businessType,
      address: data.address,
      area: data.area,
      city: data.city,
      country: data.country || 'Pakistan',
      openingTime: data.openingTime,
      closingTime: data.closingTime,
      description: data.description,
      phones: data.phones ? {
        create: data.phones.map(p => ({
          phoneNumber: p.phoneNumber,
          countryCode: p.countryCode || '+92',
          isPrimary: p.isPrimary || false,
        })),
      } : undefined,
      operatingDays: data.operatingDays ? {
        create: data.operatingDays.map(day => ({ dayCode: day })),
      } : undefined,
      partnerCategories: data.categoryIds ? {
        create: data.categoryIds.map(catId => ({ categoryId: catId })),
      } : undefined,
    },
    include: {
      phones: true,
      operatingDays: true,
    },
  });

  return {
    partner: {
      id: partner.id,
      businessId: partner.businessId,
      businessName: partner.businessName,
      ownerFullName: partner.ownerFullName,
      status: partner.status,
    },
  };
}

async function login({ businessId, password }) {
  const normalizedBusinessId = String(businessId || '').trim().toUpperCase();
  const partner = await prisma.partner.findUnique({
    where: { businessId: normalizedBusinessId },
    include: { phones: true, operatingDays: true },
  });

  if (!partner) {
    throw new AppError('Invalid business ID or password', 401);
  }

  const valid = await bcrypt.compare(password, partner.passwordHash);
  if (!valid) {
    throw new AppError('Invalid business ID or password', 401);
  }

  if (partner.status === 'SUSPENDED') {
    throw new AppError('Account suspended. Contact support.', 403);
  }
  if (partner.status === 'REJECTED') {
    throw new AppError('Account was rejected. Contact support.', 403);
  }
  if (partner.status !== 'APPROVED' && partner.status !== 'PENDING_REVIEW') {
    throw new AppError('Unable to login with current account status', 403);
  }

  const tokens = generateTokens({
    sub: partner.id,
    businessId: partner.businessId,
    role: 'partner',
  });

  // Store refresh token
  const expiresAt = new Date(Date.now() + parseExpiry(env.JWT_REFRESH_EXPIRES_IN));
  await prisma.partnerRefreshToken.create({
    data: { partnerId: partner.id, token: hashToken(tokens.refreshToken), expiresAt },
  });

  const { passwordHash, ...partnerData } = partner;
  return { partner: partnerData, ...tokens };
}

async function refresh(refreshToken) {
  const incomingToken = String(refreshToken || '');
  if (!incomingToken) throw new AppError('Refresh token required', 400);

  let decoded;
  try {
    decoded = jwt.verify(incomingToken, env.JWT_REFRESH_SECRET);
  } catch {
    throw new AppError('Invalid refresh token', 401);
  }
  if (decoded.role !== 'partner') {
    throw new AppError('Invalid refresh token', 401);
  }

  const tokenHash = hashToken(incomingToken);
  const stored = await prisma.partnerRefreshToken.findFirst({
    where: { OR: [{ token: tokenHash }, { token: incomingToken }] },
  });

  if (!stored || stored.expiresAt < new Date()) {
    if (stored) await prisma.partnerRefreshToken.delete({ where: { id: stored.id } });
    throw new AppError('Refresh token expired or revoked', 401);
  }

  const partner = await prisma.partner.findUnique({
    where: { id: decoded.sub },
    select: { id: true, businessId: true, businessEmail: true, status: true },
  });
  if (!partner) {
    await prisma.partnerRefreshToken.delete({ where: { id: stored.id } });
    throw new AppError('Invalid refresh token', 401);
  }
  if (partner.status === 'SUSPENDED') {
    await prisma.partnerRefreshToken.deleteMany({ where: { partnerId: partner.id } });
    throw new AppError('Account suspended. Contact support.', 403);
  }
  if (partner.status !== 'APPROVED') {
    await prisma.partnerRefreshToken.delete({ where: { id: stored.id } });
    throw new AppError('Account is pending approval', 403);
  }

  await prisma.partnerRefreshToken.delete({ where: { id: stored.id } });

  const tokens = generateTokens({
    sub: partner.id,
    businessId: partner.businessId,
    email: partner.businessEmail,
    role: 'partner',
  });

  await prisma.partnerRefreshToken.create({
    data: {
      partnerId: partner.id,
      token: hashToken(tokens.refreshToken),
      expiresAt: new Date(Date.now() + parseExpiry(env.JWT_REFRESH_EXPIRES_IN)),
    },
  });

  return tokens;
}

async function forgotPassword(businessId, redirectUrl) {
  const normalizedBusinessId = String(businessId || '').trim();
  if (!normalizedBusinessId) {
    return { message: 'If the business ID exists, a reset link has been sent' };
  }

  const partner = await prisma.partner.findUnique({
    where: { businessId: normalizedBusinessId },
    select: { id: true, businessEmail: true, passwordHash: true },
  });

  if (!partner) {
    return { message: 'If the business ID exists, a reset link has been sent' };
  }

  const token = jwt.sign(
    { sub: partner.id, role: 'partner_reset', ver: partnerPasswordVersion(partner) },
    env.JWT_REFRESH_SECRET,
    { expiresIn: '15m' }
  );

  const resetLink = buildResetLink(token, redirectUrl);
  if (env.ALLOW_PLAINTEXT_RESET_LOGS && env.NODE_ENV !== 'production') {
    console.log(`[PARTNER_PASSWORD_RESET_LINK] ${partner.businessEmail}: ${resetLink}`);
  } else {
    console.log(`[PARTNER_PASSWORD_RESET_REQUESTED] ${partner.businessEmail}`);
  }

  return { message: 'If the business ID exists, a reset link has been sent' };
}

async function resetPassword(token, newPassword) {
  const incomingToken = String(token || '');
  if (!incomingToken) throw new AppError('Invalid or expired reset token', 400);

  let decoded;
  try {
    decoded = jwt.verify(incomingToken, env.JWT_REFRESH_SECRET);
  } catch {
    throw new AppError('Invalid or expired reset token', 400);
  }

  if (decoded.role !== 'partner_reset' || !decoded.sub || !decoded.ver) {
    throw new AppError('Invalid or expired reset token', 400);
  }

  const partner = await prisma.partner.findUnique({
    where: { id: decoded.sub },
    select: { id: true, passwordHash: true },
  });
  if (!partner) {
    throw new AppError('Invalid or expired reset token', 400);
  }

  // Prevent replay after password changes by binding token to old password hash.
  if (decoded.ver !== partnerPasswordVersion(partner)) {
    throw new AppError('Invalid or expired reset token', 400);
  }

  const passwordHash = await bcrypt.hash(newPassword, SALT_ROUNDS);
  await prisma.partner.update({
    where: { id: partner.id },
    data: { passwordHash },
  });

  await prisma.partnerRefreshToken.deleteMany({ where: { partnerId: partner.id } });
  return { message: 'Password reset successful' };
}

async function logout(partnerId, refreshToken) {
  const incomingToken = String(refreshToken || '');
  if (!incomingToken) throw new AppError('refreshToken is required', 400);

  let decoded;
  try {
    decoded = jwt.verify(incomingToken, env.JWT_REFRESH_SECRET);
  } catch {
    throw new AppError('Invalid refresh token', 401);
  }
  if (decoded.role !== 'partner') {
    throw new AppError('Invalid refresh token', 401);
  }

  const ownerId = partnerId || decoded.sub;
  if (ownerId !== decoded.sub) {
    throw new AppError('Invalid refresh token', 401);
  }

  const tokenHash = hashToken(incomingToken);
  await prisma.partnerRefreshToken.deleteMany({
    where: { partnerId: ownerId, OR: [{ token: tokenHash }, { token: incomingToken }] },
  });
}

async function getProfile(partnerId) {
  const partner = await prisma.partner.findUnique({
    where: { id: partnerId },
    include: {
      phones: true,
      operatingDays: true,
      partnerCategories: { include: { category: true } },
      media: true,
      promotions: { where: { isActive: true } },
    },
  });

  if (!partner) throw new AppError('Partner not found', 404);

  const { passwordHash, ...data } = partner;
  return data;
}

async function updateProfile(partnerId, updates) {
  const partner = await prisma.partner.update({
    where: { id: partnerId },
    data: updates,
    include: { phones: true, operatingDays: true },
  });

  const { passwordHash, ...data } = partner;
  return data;
}

async function updatePhones(partnerId, phones) {
  // Replace all phones
  await prisma.partnerPhone.deleteMany({ where: { partnerId } });
  await prisma.partnerPhone.createMany({
    data: phones.map(p => ({
      partnerId,
      phoneNumber: p.phoneNumber,
      countryCode: p.countryCode || '+92',
      isPrimary: p.isPrimary || false,
    })),
  });

  return prisma.partnerPhone.findMany({ where: { partnerId } });
}

// Promotions CRUD
async function getPromotions(partnerId) {
  return prisma.promotion.findMany({
    where: { partnerId },
    orderBy: { createdAt: 'desc' },
  });
}

async function createPromotion(partnerId, data) {
  if (data.businessId) {
    const biz = await prisma.business.findFirst({
      where: { id: data.businessId, partnerId },
    });
    if (!biz) throw new AppError('Business not found', 404);
  }
  return prisma.promotion.create({
    data: { ...data, partnerId },
  });
}

async function updatePromotion(partnerId, promotionId, data) {
  const promo = await prisma.promotion.findFirst({
    where: { id: promotionId, partnerId },
  });
  if (!promo) throw new AppError('Promotion not found', 404);

  if (data.businessId) {
    const biz = await prisma.business.findFirst({
      where: { id: data.businessId, partnerId },
    });
    if (!biz) throw new AppError('Business not found', 404);
  }

  return prisma.promotion.update({
    where: { id: promotionId },
    data,
  });
}

async function deletePromotion(partnerId, promotionId) {
  const promo = await prisma.promotion.findFirst({
    where: { id: promotionId, partnerId },
  });
  if (!promo) throw new AppError('Promotion not found', 404);

  await prisma.promotion.delete({ where: { id: promotionId } });
}

// Service Providers CRUD
async function getServiceProviders(partnerId) {
  return prisma.serviceProvider.findMany({
    where: { partnerId },
    include: { skills: true, category: true },
    orderBy: { createdAt: 'desc' },
  });
}

async function createServiceProvider(partnerId, data) {
  const { skills, categoryId, vendorId: _ignoredVendorId, ...rest } = data;
  let resolvedCategoryId = categoryId;
  if (!resolvedCategoryId) {
    resolvedCategoryId = await resolveServiceCategoryId(rest.serviceType);
  }
  if (!resolvedCategoryId) {
    const fallbackCategory = await prisma.serviceCategory.findFirst({
      orderBy: [{ isActive: 'desc' }, { sortOrder: 'asc' }, { createdAt: 'asc' }],
      select: { id: true },
    });
    resolvedCategoryId = fallbackCategory?.id;
  }
  if (!resolvedCategoryId) {
    throw new AppError('Unable to resolve category for selected service type', 400);
  }

  const normalizedSkills = buildSpecializations(rest.serviceType, skills);
  const autoVendorId = await generateUniqueVendorId();

  return prisma.serviceProvider.create({
    data: {
      ...rest,
      categoryId: resolvedCategoryId,
      partnerId,
      vendorId: autoVendorId,
      skills: normalizedSkills.length
        ? { create: normalizedSkills.map((tagName) => ({ tagName })) }
        : undefined,
    },
    include: { skills: true, category: true },
  });
}

async function updateServiceProvider(partnerId, id, data) {
  const { skills, categoryId, vendorId: _ignoredVendorId, ...rest } = data;
  const sp = await prisma.serviceProvider.findFirst({
    where: { id, partnerId },
  });
  if (!sp) throw new AppError('Service provider not found', 404);

  return prisma.$transaction(async (tx) => {
    const updateData = {
      ...rest,
      // Any partner edit must go back to admin moderation queue.
      contentStatus: 'PENDING',
    };
    if (!sp.vendorId) {
      updateData.vendorId = await generateUniqueVendorId(tx);
    }
    if (categoryId) {
      updateData.categoryId = categoryId;
    } else if (rest.serviceType) {
      const resolvedCategoryId = await resolveServiceCategoryId(rest.serviceType);
      if (resolvedCategoryId) {
        updateData.categoryId = resolvedCategoryId;
      }
    }

    if (skills || rest.serviceType) {
      const normalizedSkills = buildSpecializations(
        rest.serviceType || sp.serviceType,
        skills
      );
      await tx.serviceProviderSkill.deleteMany({ where: { serviceProviderId: id } });
      if (normalizedSkills.length) {
        await tx.serviceProviderSkill.createMany({
          data: normalizedSkills.map((tagName) => ({ serviceProviderId: id, tagName })),
        });
      }
    }

    return tx.serviceProvider.update({
      where: { id },
      data: updateData,
      include: { skills: true, category: true },
    });
  });
}

async function deleteServiceProvider(partnerId, id) {
  const sp = await prisma.serviceProvider.findFirst({
    where: { id, partnerId },
  });
  if (!sp) throw new AppError('Service provider not found', 404);

  await prisma.serviceProvider.delete({ where: { id } });
}

async function getServiceProviderMedia(partnerId, id) {
  const sp = await prisma.serviceProvider.findFirst({
    where: { id, partnerId },
    select: { id: true },
  });
  if (!sp) throw new AppError('Service provider not found', 404);

  return prisma.providerMedia.findMany({
    where: { serviceProviderId: id },
    orderBy: { createdAt: 'desc' },
  });
}

async function deleteServiceProviderMedia(partnerId, mediaId) {
  const media = await prisma.providerMedia.findFirst({
    where: {
      id: mediaId,
      serviceProvider: { partnerId },
    },
    select: { id: true },
  });
  if (!media) throw new AppError('Media not found', 404);

  await prisma.providerMedia.delete({ where: { id: mediaId } });
}

// Businesses CRUD
async function getBusinesses(partnerId) {
  return prisma.business.findMany({
    where: {
      partnerId,
      category: { not: 'REAL_ESTATE' },
    },
    include: { media: { orderBy: { createdAt: 'desc' } } },
    orderBy: { createdAt: 'desc' },
  });
}

async function createBusiness(partnerId, data) {
  if (data.category === 'REAL_ESTATE') {
    throw new AppError('REAL_ESTATE is managed via properties', 400);
  }
  return prisma.business.create({
    data: { ...data, partnerId },
  });
}

async function updateBusiness(partnerId, id, data) {
  const biz = await prisma.business.findFirst({
    where: { id, partnerId },
  });
  if (!biz) throw new AppError('Business not found', 404);
  if (biz.category === 'REAL_ESTATE' || data.category === 'REAL_ESTATE') {
    throw new AppError('REAL_ESTATE is managed via properties', 400);
  }

  return prisma.business.update({
    where: { id },
    data: {
      ...data,
      // Any partner edit must go back to admin moderation queue.
      contentStatus: 'PENDING',
    },
  });
}

async function deleteBusiness(partnerId, id) {
  const biz = await prisma.business.findFirst({
    where: { id, partnerId },
  });
  if (!biz) throw new AppError('Business not found', 404);

  await prisma.business.delete({ where: { id } });
}

// Properties CRUD (partner-owned)
async function getProperties(partnerId) {
  return prisma.property.findMany({
    where: { partnerId },
    include: {
      images: { orderBy: { sortOrder: 'asc' } },
      serviceProvider: { select: { id: true, name: true, serviceType: true, imageUrl: true } },
    },
    orderBy: { createdAt: 'desc' },
  });
}

async function createProperty(partnerId, data) {
  const serviceProviderId = String(data.serviceProviderId || '').trim();
  if (!serviceProviderId) throw new AppError('serviceProviderId is required', 400);

  const agent = await prisma.serviceProvider.findFirst({
    where: { id: serviceProviderId, partnerId, serviceType: 'REAL_ESTATE' },
    select: { id: true },
  });
  if (!agent) throw new AppError('Valid real estate agent profile is required', 400);

  const { imageUrls, ...rest } = data;
  return prisma.$transaction(async (tx) => {
    const created = await tx.property.create({
      data: {
        ...rest,
        partnerId,
        serviceProviderId,
        images: Array.isArray(imageUrls) && imageUrls.length
          ? {
              create: imageUrls.map((url, index) => ({
                imageUrl: url,
                sortOrder: index,
              })),
            }
          : undefined,
      },
      include: {
        images: { orderBy: { sortOrder: 'asc' } },
        serviceProvider: { select: { id: true, name: true, serviceType: true, imageUrl: true } },
      },
    });

    if (Array.isArray(imageUrls) && imageUrls.length) {
      await tx.providerMedia.createMany({
        data: imageUrls.map((url) => ({
          serviceProviderId,
          mediaType: 'PHOTO',
          fileUrl: url,
        })),
        skipDuplicates: true,
      });
    }

    return created;
  });
}

async function updateProperty(partnerId, id, data) {
  const property = await prisma.property.findFirst({
    where: { id, partnerId },
    include: { images: true },
  });
  if (!property) throw new AppError('Property not found', 404);

  const { imageUrls, ...rest } = data;
  if (rest.serviceProviderId) {
    const agent = await prisma.serviceProvider.findFirst({
      where: {
        id: rest.serviceProviderId,
        partnerId,
        serviceType: 'REAL_ESTATE',
      },
      select: { id: true },
    });
    if (!agent) throw new AppError('Valid real estate agent profile is required', 400);
  }

  return prisma.$transaction(async (tx) => {
    if (Array.isArray(imageUrls)) {
      await tx.propertyImage.deleteMany({ where: { propertyId: id } });
      if (imageUrls.length) {
        await tx.propertyImage.createMany({
          data: imageUrls.map((url, index) => ({
            propertyId: id,
            imageUrl: url,
            sortOrder: index,
          })),
        });
        const targetServiceProviderId = rest.serviceProviderId || property.serviceProviderId;
        if (targetServiceProviderId) {
          const existingMedia = await tx.providerMedia.findMany({
            where: { serviceProviderId: targetServiceProviderId, fileUrl: { in: imageUrls } },
            select: { fileUrl: true },
          });
          const existingUrls = new Set(existingMedia.map((m) => m.fileUrl));
          const newUrls = imageUrls.filter((url) => !existingUrls.has(url));
          if (newUrls.length) {
            await tx.providerMedia.createMany({
              data: newUrls.map((url) => ({
                serviceProviderId: targetServiceProviderId,
                mediaType: 'PHOTO',
                fileUrl: url,
              })),
              skipDuplicates: true,
            });
          }
        }
      }
    }

    return tx.property.update({
      where: { id },
      data: rest,
      include: {
        images: { orderBy: { sortOrder: 'asc' } },
        serviceProvider: { select: { id: true, name: true, serviceType: true, imageUrl: true } },
      },
    });
  });
}

async function deleteProperty(partnerId, id) {
  const property = await prisma.property.findFirst({
    where: { id, partnerId },
  });
  if (!property) throw new AppError('Property not found', 404);

  await prisma.property.delete({ where: { id } });
}

// Amenities CRUD
async function getAmenities(partnerId) {
  return prisma.amenity.findMany({
    where: { partnerId },
    include: { media: { orderBy: { createdAt: 'desc' } } },
    orderBy: { createdAt: 'desc' },
  });
}

async function createAmenity(partnerId, data) {
  return prisma.amenity.create({
    data: { ...data, partnerId },
  });
}

async function updateAmenity(partnerId, id, data) {
  const amenity = await prisma.amenity.findFirst({
    where: { id, partnerId },
  });
  if (!amenity) throw new AppError('Amenity not found', 404);

  return prisma.amenity.update({
    where: { id },
    data: {
      ...data,
      // Any partner edit must go back to admin moderation queue.
      contentStatus: 'PENDING',
    },
  });
}

async function deleteAmenity(partnerId, id) {
  const amenity = await prisma.amenity.findFirst({
    where: { id, partnerId },
  });
  if (!amenity) throw new AppError('Amenity not found', 404);

  await prisma.amenity.delete({ where: { id } });
}

// Media
async function getMedia(partnerId) {
  return prisma.partnerMedia.findMany({
    where: { partnerId },
    orderBy: { createdAt: 'desc' },
  });
}

async function deleteMedia(partnerId, mediaId) {
  const media = await prisma.partnerMedia.findFirst({
    where: { id: mediaId, partnerId },
  });
  if (!media) throw new AppError('Media not found', 404);

  await prisma.partnerMedia.delete({ where: { id: mediaId } });
}

module.exports = {
  register,
  login,
  refresh,
  forgotPassword,
  resetPassword,
  logout,
  getProfile,
  updateProfile,
  updatePhones,
  getPromotions,
  createPromotion,
  updatePromotion,
  deletePromotion,
  getServiceProviders,
  createServiceProvider,
  updateServiceProvider,
  deleteServiceProvider,
  getServiceProviderMedia,
  deleteServiceProviderMedia,
  getBusinesses,
  createBusiness,
  updateBusiness,
  deleteBusiness,
  getProperties,
  createProperty,
  updateProperty,
  deleteProperty,
  getAmenities,
  createAmenity,
  updateAmenity,
  deleteAmenity,
  getMedia,
  deleteMedia,
};
