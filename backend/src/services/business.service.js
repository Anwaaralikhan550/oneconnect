const { prisma } = require('../config/database');
const { AppError } = require('../middleware/errorHandler');
const {
  normalizeFilterQuery,
  applyDistanceFilterAndSort,
  parseLatLng,
} = require('../utils/filter.util');

async function list(query) {
  const { category } = query;
  const filter = normalizeFilterQuery(query);
  const { page, limit } = filter;
  const skip = (page - 1) * limit;

  const where = { contentStatus: 'APPROVED' };
  if (category) where.category = category;
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
    prisma.business.findMany({
      where,
      orderBy,
      ...(useDistanceMode ? { take: 500 } : { skip, take: limit }),
    }),
    prisma.business.count({ where }),
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
  const business = await prisma.business.findUnique({
    where: { id },
    include: {
      partner: { select: { status: true } },
      media: { orderBy: { createdAt: 'desc' } },
      promotions: {
        where: { isActive: true, contentStatus: 'APPROVED' },
        orderBy: { createdAt: 'desc' },
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
    !business ||
    business.contentStatus !== 'APPROVED' ||
    (business.partnerId && business.partner?.status !== 'APPROVED')
  ) {
    throw new AppError('Business not found', 404);
  }
  business.reviews = business.reviews.map((review) => {
    const helpfulCount = review.votes.filter((v) => v.voteType === 'helpful').length;
    const unhelpfulCount = review.votes.filter((v) => v.voteType === 'unhelpful').length;
    const currentUserVote = userId
      ? review.votes.find((v) => v.userId === userId)?.voteType ?? null
      : null;
    const { votes, ...rest } = review;
    return { ...rest, helpfulCount, unhelpfulCount, currentUserVote };
  });

  if (userId) {
    const follow = await prisma.follow.findFirst({
      where: { userId, targetType: 'BUSINESS', businessId: id },
      select: { id: true },
    });
    business.isFollowing = Boolean(follow);
  } else {
    business.isFollowing = false;
  }

  return business;
}

async function addReview(businessId, userId, data) {
  const business = await prisma.business.findUnique({ where: { id: businessId } });
  if (!business) throw new AppError('Business not found', 404);

  const review = await prisma.review.create({
    data: {
      userId,
      businessId,
      rating: data.rating,
      ratingText: data.ratingText,
      reviewText: data.reviewText,
      mediaUrl: data.mediaUrl || data.imageUrl || null,
      mediaType: data.mediaType || null,
    },
    include: { user: { select: { name: true, profilePhotoUrl: true } } },
  });

  const agg = await prisma.review.aggregate({
    where: { businessId },
    _avg: { rating: true },
    _count: { rating: true },
  });

  await prisma.business.update({
    where: { id: businessId },
    data: {
      rating: Math.round((agg._avg.rating || 0) * 10) / 10,
      reviewCount: agg._count.rating,
    },
  });

  const submittedMediaUrl = review.mediaUrl || data.mediaUrl || data.imageUrl || null;
  if (!submittedMediaUrl) return review;

  return { ...review, mediaUrl: submittedMediaUrl, mediaType: review.mediaType || data.mediaType || null };
}

async function toggleFavorite(businessId, userId) {
  const existing = await prisma.favorite.findFirst({
    where: { userId, targetType: 'BUSINESS', businessId },
  });

  if (existing) {
    await prisma.favorite.delete({ where: { id: existing.id } });
    return { favorited: false };
  }

  await prisma.favorite.create({
    data: { userId, targetType: 'BUSINESS', businessId },
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
      await prisma.reviewVote.delete({ where: { id: existing.id } });
    } else {
      await prisma.reviewVote.update({
        where: { id: existing.id },
        data: { voteType },
      });
    }
  } else {
    await prisma.reviewVote.create({
      data: { reviewId, userId, voteType },
    });
  }

  const votes = await prisma.reviewVote.findMany({ where: { reviewId } });
  const helpfulCount = votes.filter((v) => v.voteType === 'helpful').length;
  const unhelpfulCount = votes.filter((v) => v.voteType === 'unhelpful').length;
  const currentUserVote = votes.find((v) => v.userId === userId)?.voteType ?? null;

  return { helpfulCount, unhelpfulCount, currentUserVote };
}

module.exports = { list, getById, addReview, toggleFavorite, voteReview };
