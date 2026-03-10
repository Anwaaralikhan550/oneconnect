const { prisma } = require('../config/database');
const { AppError } = require('../middleware/errorHandler');
const { getSkillSuggestionsByType } = require('../constants/serviceSkillSuggestions');
const {
  normalizeFilterQuery,
  applyDistanceFilterAndSort,
  parseLatLng,
} = require('../utils/filter.util');

async function list(query) {
  const { type, city, isTopRated } = query;
  const filter = normalizeFilterQuery(query);
  const { page, limit } = filter;
  const skip = (page - 1) * limit;

  const where = { contentStatus: 'APPROVED' };
  if (type) where.serviceType = type;
  const locationText = filter.area || city;
  if (locationText && filter.locationMode !== 'DISTANCE') {
    where.OR = [
      { city: { contains: locationText, mode: 'insensitive' } },
      { address: { contains: locationText, mode: 'insensitive' } },
    ];
  }
  if (filter.minRating) where.rating = { gte: filter.minRating };
  if (isTopRated !== undefined) where.isTopRated = isTopRated === 'true' || isTopRated === true;

  let orderBy = [{ isTopRated: 'desc' }, { rating: 'desc' }];
  if (filter.sortBy === 'NEWLY_OPENED') {
    orderBy = [{ createdAt: 'desc' }];
  } else if (filter.sortBy === 'FEATURED') {
    orderBy = [{ rating: 'desc' }, { reviewCount: 'desc' }];
  }

  const useDistanceMode = filter.locationMode === 'DISTANCE';
  const [rows, total] = await Promise.all([
    prisma.serviceProvider.findMany({
      where,
      include: {
        skills: { select: { tagName: true } },
        category: { select: { name: true, slug: true } },
      },
      orderBy,
      ...(useDistanceMode ? { take: 500 } : { skip, take: limit }),
    }),
    prisma.serviceProvider.count({ where }),
  ]);

  const distanceAware = applyDistanceFilterAndSort(rows, filter, (item) => {
    const parsed = parseLatLng(item.address || '');
    return parsed;
  }).map((item) => ({
    ...item,
    distanceKm:
      item.distanceKm == null ? null : Number(item.distanceKm.toFixed(2)),
  }));

  const pagedDistanceAware = useDistanceMode
    ? distanceAware.slice(skip, skip + limit)
    : distanceAware;

  return {
    data: pagedDistanceAware,
    pagination: {
      page,
      limit,
      total: useDistanceMode ? distanceAware.length : total,
      totalPages: Math.ceil((useDistanceMode ? distanceAware.length : total) / limit),
    },
  };
}

async function getById(id, userId) {
  const provider = await prisma.serviceProvider.findUnique({
    where: { id },
    include: {
      partner: {
        select: {
          status: true,
          media: { orderBy: { createdAt: 'desc' } },
        },
      },
      media: { orderBy: { createdAt: 'desc' } },
      skills: { select: { tagName: true } },
      category: { select: { name: true, slug: true } },
      reviews: {
        include: {
          user: { select: { name: true, profilePhotoUrl: true } },
          votes: true,
        },
        orderBy: { createdAt: 'desc' },
        take: 10,
      },
    },
  });

  if (
    !provider ||
    provider.contentStatus !== 'APPROVED' ||
    (provider.partnerId && provider.partner?.status !== 'APPROVED')
  ) {
    throw new AppError('Service provider not found', 404);
  }

  // Post-process reviews: add vote counts and current user's vote
  provider.reviews = provider.reviews.map((review) => {
    const helpfulCount = review.votes.filter((v) => v.voteType === 'helpful').length;
    const unhelpfulCount = review.votes.filter((v) => v.voteType === 'unhelpful').length;
    const currentUserVote = userId
      ? review.votes.find((v) => v.userId === userId)?.voteType ?? null
      : null;

    const { votes, ...rest } = review;
    return { ...rest, helpfulCount, unhelpfulCount, currentUserVote };
  });

  return provider;
}

async function getMedia(id) {
  const provider = await prisma.serviceProvider.findUnique({
    where: { id },
    include: {
      partner: { select: { status: true } },
    },
  });

  if (
    !provider ||
    provider.contentStatus !== 'APPROVED' ||
    (provider.partnerId && provider.partner?.status !== 'APPROVED')
  ) {
    throw new AppError('Service provider not found', 404);
  }

  return prisma.providerMedia.findMany({
    where: { serviceProviderId: id },
    orderBy: { createdAt: 'desc' },
  });
}

async function addReview(serviceProviderId, userId, data) {
  const provider = await prisma.serviceProvider.findUnique({
    where: { id: serviceProviderId },
  });
  if (!provider) throw new AppError('Service provider not found', 404);

  const review = await prisma.review.create({
    data: {
      userId,
      serviceProviderId,
      rating: data.rating,
      ratingText: data.ratingText,
      reviewText: data.reviewText,
    },
    include: { user: { select: { name: true, profilePhotoUrl: true } } },
  });

  // Update aggregate rating
  const agg = await prisma.review.aggregate({
    where: { serviceProviderId },
    _avg: { rating: true },
    _count: { rating: true },
  });

  await prisma.serviceProvider.update({
    where: { id: serviceProviderId },
    data: {
      rating: Math.round((agg._avg.rating || 0) * 10) / 10,
      reviewCount: agg._count.rating,
    },
  });

  const submittedMediaUrl = data.mediaUrl || data.imageUrl || null;
  if (!submittedMediaUrl) return review;

  return { ...review, mediaUrl: submittedMediaUrl };
}

async function toggleFavorite(serviceProviderId, userId) {
  const existing = await prisma.favorite.findFirst({
    where: {
      userId,
      targetType: 'SERVICE_PROVIDER',
      serviceProviderId,
    },
  });

  if (existing) {
    await prisma.favorite.delete({ where: { id: existing.id } });
    return { favorited: false };
  }

  await prisma.favorite.create({
    data: {
      userId,
      targetType: 'SERVICE_PROVIDER',
      serviceProviderId,
    },
  });
  return { favorited: true };
}

async function voteReview(reviewId, userId, voteType) {
  const review = await prisma.review.findUnique({ where: { id: reviewId } });
  if (!review) throw new AppError('Review not found', 404);

  const existing = await prisma.reviewVote.findUnique({
    where: { reviewId_userId: { reviewId, userId } },
  });

  if (existing) {
    if (existing.voteType === voteType) {
      // Same vote type → toggle off (delete)
      await prisma.reviewVote.delete({ where: { id: existing.id } });
    } else {
      // Different vote type → update
      await prisma.reviewVote.update({
        where: { id: existing.id },
        data: { voteType },
      });
    }
  } else {
    // No existing vote → create
    await prisma.reviewVote.create({
      data: { reviewId, userId, voteType },
    });
  }

  // Return updated counts
  const votes = await prisma.reviewVote.findMany({ where: { reviewId } });
  const helpfulCount = votes.filter((v) => v.voteType === 'helpful').length;
  const unhelpfulCount = votes.filter((v) => v.voteType === 'unhelpful').length;
  const currentUserVote = votes.find((v) => v.userId === userId)?.voteType ?? null;

  return { helpfulCount, unhelpfulCount, currentUserVote };
}

async function getSkillSuggestions(type) {
  const normalizedType = String(type || '').trim().toUpperCase();
  const baseSuggestions = getSkillSuggestionsByType(normalizedType);

  // Use existing ServiceProviderSkill table data so suggestions evolve with real partner data.
  const dbSkillsRows = normalizedType
    ? await prisma.serviceProviderSkill.findMany({
        where: {
          serviceProvider: {
            serviceType: normalizedType,
          },
        },
        select: { tagName: true },
        take: 200,
      })
    : [];

  const seen = new Set();
  const merged = [];
  for (const raw of [...baseSuggestions, ...dbSkillsRows.map((r) => r.tagName)]) {
    const value = String(raw || '').trim();
    if (!value) continue;
    const key = value.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    merged.push(value);
  }

  return { type: normalizedType, skills: merged };
}

module.exports = { list, getById, getMedia, addReview, toggleFavorite, voteReview, getSkillSuggestions };
