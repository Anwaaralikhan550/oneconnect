const { prisma } = require('../config/database');
const { AppError } = require('../middleware/errorHandler');

async function list(query) {
  const { city, minPrice, maxPrice, propertyType, partnerId, page = 1, limit = 20 } = query;
  const skip = (page - 1) * limit;

  const where = { contentStatus: 'APPROVED' };
  if (city) where.location = { contains: city, mode: 'insensitive' };
  if (propertyType) where.propertyType = propertyType;
  if (partnerId) where.partnerId = partnerId;
  if (minPrice || maxPrice) {
    where.price = {};
    if (minPrice) where.price.gte = parseFloat(minPrice);
    if (maxPrice) where.price.lte = parseFloat(maxPrice);
  }

  const [data, total] = await Promise.all([
    prisma.property.findMany({
      where,
      include: {
        images: { orderBy: { sortOrder: 'asc' } },
        serviceProvider: { select: { id: true, name: true, imageUrl: true, serviceType: true } },
        partner: {
          select: {
            id: true,
            businessId: true,
            businessName: true,
            ownerFullName: true,
            profilePhotoUrl: true,
            openingTime: true,
            closingTime: true,
            isBusinessOpen: true,
            address: true,
            city: true,
            rating: true,
            phones: {
              where: { isPrimary: true },
              select: { phoneNumber: true, countryCode: true },
              take: 1,
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip,
      take: limit,
    }),
    prisma.property.count({ where }),
  ]);

  return {
    data,
    pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
  };
}

async function getById(id) {
  const property = await prisma.property.findUnique({
    where: { id },
    include: {
      images: { orderBy: { sortOrder: 'asc' } },
      serviceProvider: { select: { id: true, name: true, imageUrl: true, serviceType: true } },
      partner: {
        select: {
          id: true,
          businessId: true,
          businessName: true,
          ownerFullName: true,
          profilePhotoUrl: true,
          openingTime: true,
          closingTime: true,
          isBusinessOpen: true,
          address: true,
          city: true,
          rating: true,
          phones: {
            where: { isPrimary: true },
            select: { phoneNumber: true, countryCode: true },
            take: 1,
          },
        },
      },
    },
  });

  if (!property || property.contentStatus !== 'APPROVED') throw new AppError('Property not found', 404);
  return property;
}

module.exports = { list, getById };
