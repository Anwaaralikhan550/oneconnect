const { prisma } = require('../config/database');
const { AppError } = require('../middleware/errorHandler');

async function toggleBusinessFollow(businessId, userId) {
  const business = await prisma.business.findUnique({
    where: { id: businessId },
    include: {
      partner: { select: { status: true, followUsEnabled: true } },
    },
  });

  if (
    !business ||
    business.contentStatus !== 'APPROVED' ||
    (business.partnerId && business.partner?.status !== 'APPROVED')
  ) {
    throw new AppError('Business not found', 404);
  }

  if (!business.isFollowEnabled || (business.partnerId && !business.partner?.followUsEnabled)) {
    throw new AppError('Following is disabled for this business', 400);
  }

  const existing = await prisma.follow.findFirst({
    where: {
      userId,
      targetType: 'BUSINESS',
      businessId,
    },
    select: { id: true },
  });

  return prisma.$transaction(async (tx) => {
    if (existing) {
      await tx.follow.delete({ where: { id: existing.id } });
      const updated = await tx.business.update({
        where: { id: businessId },
        data: { followersCount: { decrement: 1 } },
        select: { followersCount: true },
      });
      return { isFollowing: false, followersCount: Math.max(updated.followersCount, 0) };
    }

    await tx.follow.create({
      data: {
        userId,
        targetType: 'BUSINESS',
        businessId,
      },
    });
    const updated = await tx.business.update({
      where: { id: businessId },
      data: { followersCount: { increment: 1 } },
      select: { followersCount: true },
    });
    return { isFollowing: true, followersCount: updated.followersCount };
  });
}

async function toggleServiceProviderFollow(serviceProviderId, userId) {
  const provider = await prisma.serviceProvider.findUnique({
    where: { id: serviceProviderId },
    include: {
      partner: { select: { status: true, followUsEnabled: true } },
    },
  });

  if (
    !provider ||
    provider.contentStatus !== 'APPROVED' ||
    (provider.partnerId && provider.partner?.status !== 'APPROVED')
  ) {
    throw new AppError('Service provider not found', 404);
  }

  if (
    !provider.isProfessionalProfileEnabled ||
    !provider.isFollowEnabled ||
    (provider.partnerId && !provider.partner?.followUsEnabled)
  ) {
    throw new AppError('Following is disabled for this service provider', 400);
  }

  const existing = await prisma.follow.findFirst({
    where: {
      userId,
      targetType: 'SERVICE_PROVIDER',
      serviceProviderId,
    },
    select: { id: true },
  });

  return prisma.$transaction(async (tx) => {
    if (existing) {
      await tx.follow.delete({ where: { id: existing.id } });
      const updated = await tx.serviceProvider.update({
        where: { id: serviceProviderId },
        data: { followersCount: { decrement: 1 } },
        select: { followersCount: true },
      });
      return { isFollowing: false, followersCount: Math.max(updated.followersCount, 0) };
    }

    await tx.follow.create({
      data: {
        userId,
        targetType: 'SERVICE_PROVIDER',
        serviceProviderId,
      },
    });
    const updated = await tx.serviceProvider.update({
      where: { id: serviceProviderId },
      data: { followersCount: { increment: 1 } },
      select: { followersCount: true },
    });
    return { isFollowing: true, followersCount: updated.followersCount };
  });
}

module.exports = {
  toggleBusinessFollow,
  toggleServiceProviderFollow,
};
