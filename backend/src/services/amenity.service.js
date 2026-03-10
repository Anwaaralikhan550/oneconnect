const { prisma } = require('../config/database');
const { AppError } = require('../middleware/errorHandler');
const {
  normalizeFilterQuery,
  applyDistanceFilterAndSort,
  parseLatLng,
} = require('../utils/filter.util');

async function list(query) {
  const { type } = query;
  const filter = normalizeFilterQuery(query);
  const { page, limit } = filter;
  const skip = (page - 1) * limit;

  const where = { contentStatus: 'APPROVED' };
  if (type) where.amenityType = type;
  if (filter.minRating != null) where.rating = { gte: filter.minRating };
  const locationText = filter.area;
  if (locationText && filter.locationMode !== 'DISTANCE') {
    where.location = { contains: locationText, mode: 'insensitive' };
  }

  let orderBy = [{ rating: 'desc' }];
  if (filter.sortBy === 'NEWLY_OPENED') {
    orderBy = [{ createdAt: 'desc' }];
  } else if (filter.sortBy === 'FEATURED') {
    orderBy = [{ rating: 'desc' }, { reviewCount: 'desc' }];
  }
  const useDistanceMode = filter.locationMode === 'DISTANCE';

  const [rows, total] = await Promise.all([
    prisma.amenity.findMany({
      where,
      orderBy,
      ...(useDistanceMode ? { take: 500 } : { skip, take: limit }),
    }),
    prisma.amenity.count({ where }),
  ]);

  const distanceAware = applyDistanceFilterAndSort(rows, filter, (item) =>
    parseLatLng(item.location),
  ).map((item) => ({
    ...item,
    distanceKm:
      item.distanceKm == null ? null : Number(item.distanceKm.toFixed(2)),
  }));
  const data = useDistanceMode
    ? distanceAware.slice(skip, skip + limit)
    : distanceAware;
  const effectiveTotal = useDistanceMode ? distanceAware.length : total;

  return {
    data,
    pagination: {
      page,
      limit,
      total: effectiveTotal,
      totalPages: Math.ceil(effectiveTotal / limit),
    },
  };
}

async function getById(id, userId = null) {
  const amenity = await prisma.amenity.findUnique({
    where: { id },
    include: {
      media: { orderBy: { createdAt: 'desc' } },
      partner: {
        select: {
          status: true,
          promotions: {
            where: {
              contentStatus: 'APPROVED',
              isActive: true,
              OR: [{ expiresAt: null }, { expiresAt: { gte: new Date() } }],
            },
            orderBy: { createdAt: 'desc' },
            take: 10,
          },
        },
      },
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
    !amenity ||
    amenity.contentStatus !== 'APPROVED' ||
    (amenity.partnerId && amenity.partner?.status !== 'APPROVED')
  ) {
    throw new AppError('Amenity not found', 404);
  }
  amenity.reviews = amenity.reviews.map((review) => {
    const helpfulCount = review.votes.filter((v) => v.voteType === 'helpful').length;
    const unhelpfulCount = review.votes.filter((v) => v.voteType === 'unhelpful').length;
    const currentUserVote = userId
      ? review.votes.find((v) => v.userId === userId)?.voteType ?? null
      : null;
    const { votes, ...rest } = review;
    return { ...rest, helpfulCount, unhelpfulCount, currentUserVote };
  });

  amenity.promotions = amenity.partner?.promotions || [];

  return amenity;
}

async function addReview(amenityId, userId, data) {
  const amenity = await prisma.amenity.findUnique({ where: { id: amenityId } });
  if (!amenity) throw new AppError('Amenity not found', 404);

  const review = await prisma.review.create({
    data: {
      userId,
      amenityId,
      rating: data.rating,
      ratingText: data.ratingText,
      reviewText: data.reviewText,
      mediaUrl: data.mediaUrl || data.imageUrl || null,
      mediaType: data.mediaType || null,
    },
    include: { user: { select: { name: true, profilePhotoUrl: true } } },
  });

  const agg = await prisma.review.aggregate({
    where: { amenityId },
    _avg: { rating: true },
    _count: { rating: true },
  });

  await prisma.amenity.update({
    where: { id: amenityId },
    data: {
      rating: Math.round((agg._avg.rating || 0) * 10) / 10,
      reviewCount: agg._count.rating,
    },
  });

  const submittedMediaUrl = review.mediaUrl || data.mediaUrl || data.imageUrl || null;
  if (!submittedMediaUrl) return review;

  return { ...review, mediaUrl: submittedMediaUrl, mediaType: review.mediaType || data.mediaType || null };
}

async function toggleFavorite(amenityId, userId) {
  const existing = await prisma.favorite.findFirst({
    where: { userId, targetType: 'AMENITY', amenityId },
  });

  if (existing) {
    await prisma.favorite.delete({ where: { id: existing.id } });
    return { favorited: false };
  }

  await prisma.favorite.create({
    data: { userId, targetType: 'AMENITY', amenityId },
  });
  return { favorited: true };
}

async function voteReview(reviewId, userId, voteType) {
  const existing = await prisma.reviewVote.findUnique({
    where: { reviewId_userId: { reviewId, userId } },
  });

  if (existing) {
    if (existing.voteType === voteType) {
      await prisma.reviewVote.delete({ where: { id: existing.id } });
    } else {
      await prisma.reviewVote.update({ where: { id: existing.id }, data: { voteType } });
    }
  } else {
    await prisma.reviewVote.create({ data: { reviewId, userId, voteType } });
  }

  const [helpfulCount, unhelpfulCount] = await Promise.all([
    prisma.reviewVote.count({ where: { reviewId, voteType: 'helpful' } }),
    prisma.reviewVote.count({ where: { reviewId, voteType: 'unhelpful' } }),
  ]);

  const currentUserVote = await prisma.reviewVote.findUnique({
    where: { reviewId_userId: { reviewId, userId } },
  });

  return { helpfulCount, unhelpfulCount, currentUserVote: currentUserVote?.voteType || null };
}

module.exports = { list, getById, addReview, toggleFavorite, voteReview };
