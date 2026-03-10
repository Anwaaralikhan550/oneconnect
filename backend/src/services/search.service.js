const { prisma } = require('../config/database');
const {
  normalizeFilterQuery,
  applyDistanceFilterAndSort,
  parseLatLng,
} = require('../utils/filter.util');

async function search(query) {
  const { q, category } = query;
  const filter = normalizeFilterQuery(query);
  const { page, limit } = filter;
  const skip = (page - 1) * limit;
  const approvedPartnerWhere = {
    OR: [{ partnerId: null }, { partner: { status: 'APPROVED' } }],
  };

  const results = { serviceProviders: [], businesses: [], amenities: [] };

  const includeServices =
    (!category || category === 'Service') &&
    (!filter.entityType || filter.entityType === 'SERVICE');
  const includeBusinesses =
    (!category || category === 'Shop') &&
    (!filter.entityType || filter.entityType === 'BUSINESS');
  const includeAmenities =
    (!category || category === 'Shop') &&
    (!filter.entityType || filter.entityType === 'AMENITY');

  if (includeServices) {
    const spWhere = {
      contentStatus: 'APPROVED',
      AND: [
        approvedPartnerWhere,
        {
          OR: [
            { name: { contains: q, mode: 'insensitive' } },
            { skills: { some: { tagName: { contains: q, mode: 'insensitive' } } } },
          ],
        },
      ],
    };
    if (filter.minRating != null) spWhere.rating = { gte: filter.minRating };
    const locationText = filter.area;
    if (locationText && filter.locationMode !== 'DISTANCE') {
      spWhere.AND.push({
        OR: [
          { city: { contains: locationText, mode: 'insensitive' } },
          { address: { contains: locationText, mode: 'insensitive' } },
        ],
      });
    }

    let spOrderBy = { rating: 'desc' };
    if (filter.sortBy === 'NEWLY_OPENED') spOrderBy = { createdAt: 'desc' };

    const serviceRows = await prisma.serviceProvider.findMany({
      where: spWhere,
      include: { skills: { select: { tagName: true } }, category: { select: { name: true } } },
      orderBy: spOrderBy,
      skip,
      take: limit,
    });
    results.serviceProviders = applyDistanceFilterAndSort(
      serviceRows,
      filter,
      (item) => parseLatLng(item.address || ''),
    ).map((item) => ({
      ...item,
      distanceKm:
        item.distanceKm == null ? null : Number(item.distanceKm.toFixed(2)),
    }));
  }

  if (includeBusinesses) {
    const bWhere = {
      contentStatus: 'APPROVED',
      name: { contains: q, mode: 'insensitive' },
      AND: [approvedPartnerWhere],
    };
    if (filter.minRating != null) bWhere.rating = { gte: filter.minRating };
    if (filter.area && filter.locationMode !== 'DISTANCE') {
      bWhere.location = { contains: filter.area, mode: 'insensitive' };
    }

    let bizOrderBy = { rating: 'desc' };
    if (filter.sortBy === 'NEWLY_OPENED') bizOrderBy = { createdAt: 'desc' };

    const businessRows = await prisma.business.findMany({
      where: bWhere,
      orderBy: bizOrderBy,
      skip,
      take: limit,
    });
    results.businesses = applyDistanceFilterAndSort(
      businessRows,
      filter,
      (item) => parseLatLng(item.location),
    ).map((item) => ({
      ...item,
      distanceKm:
        item.distanceKm == null ? null : Number(item.distanceKm.toFixed(2)),
    }));
  }

  if (includeAmenities) {
    const amenityRows = await prisma.amenity.findMany({
      where: {
        contentStatus: 'APPROVED',
        name: { contains: q, mode: 'insensitive' },
        AND: [
          approvedPartnerWhere,
          ...(filter.area && filter.locationMode !== 'DISTANCE'
            ? [{ location: { contains: filter.area, mode: 'insensitive' } }]
            : []),
        ],
        ...(filter.minRating != null ? { rating: { gte: filter.minRating } } : {}),
      },
      orderBy:
        filter.sortBy === 'NEWLY_OPENED' ? { createdAt: 'desc' } : { rating: 'desc' },
      skip,
      take: limit,
    });
    results.amenities = applyDistanceFilterAndSort(
      amenityRows,
      filter,
      (item) => parseLatLng(item.location),
    ).map((item) => ({
      ...item,
      distanceKm:
        item.distanceKm == null ? null : Number(item.distanceKm.toFixed(2)),
    }));
  }

  return results;
}

async function suggestions(q) {
  const [providers, businesses, amenities] = await Promise.all([
    prisma.serviceProvider.findMany({
      where: {
        contentStatus: 'APPROVED',
        AND: [{ OR: [{ partnerId: null }, { partner: { status: 'APPROVED' } }] }],
        name: { contains: q, mode: 'insensitive' },
      },
      select: { name: true, serviceType: true },
      take: 5,
    }),
    prisma.business.findMany({
      where: {
        contentStatus: 'APPROVED',
        AND: [{ OR: [{ partnerId: null }, { partner: { status: 'APPROVED' } }] }],
        name: { contains: q, mode: 'insensitive' },
      },
      select: { name: true, category: true },
      take: 5,
    }),
    prisma.amenity.findMany({
      where: {
        contentStatus: 'APPROVED',
        AND: [{ OR: [{ partnerId: null }, { partner: { status: 'APPROVED' } }] }],
        name: { contains: q, mode: 'insensitive' },
      },
      select: { name: true, amenityType: true },
      take: 5,
    }),
  ]);

  return [
    ...providers.map(p => ({ name: p.name, type: 'service', subType: p.serviceType })),
    ...businesses.map(b => ({ name: b.name, type: 'business', subType: b.category })),
    ...amenities.map(a => ({ name: a.name, type: 'amenity', subType: a.amenityType })),
  ];
}

async function popular(query = {}) {
  const filter = normalizeFilterQuery(query);
  const locationText = filter.area;
  const orderBy =
    filter.sortBy === 'NEWLY_OPENED' ? { createdAt: 'desc' } : { rating: 'desc' };
  const approvedPartnerWhere = [{ OR: [{ partnerId: null }, { partner: { status: 'APPROVED' } }] }];
  const serviceTypeParam =
    typeof query.serviceType === 'string' && query.serviceType.trim().length > 0
      ? query.serviceType.trim().toUpperCase()
      : null;
  const excludeServiceTypeParam =
    typeof query.excludeServiceType === 'string' && query.excludeServiceType.trim().length > 0
      ? query.excludeServiceType.trim().toUpperCase()
      : null;
  const businessCategoryParam =
    typeof query.businessCategory === 'string' && query.businessCategory.trim().length > 0
      ? query.businessCategory.trim().toUpperCase()
      : null;
  const serviceWhereBase = {
    isTopRated: true,
    contentStatus: 'APPROVED',
    ...(filter.minRating != null ? { rating: { gte: filter.minRating } } : {}),
    ...(locationText && filter.locationMode !== 'DISTANCE'
      ? {
          OR: [
            { city: { contains: locationText, mode: 'insensitive' } },
            { address: { contains: locationText, mode: 'insensitive' } },
          ],
        }
      : {}),
    AND: approvedPartnerWhere,
  };
  const businessWhereBase = {
    contentStatus: 'APPROVED',
    ...(filter.minRating != null ? { rating: { gte: filter.minRating } } : {}),
    ...(locationText && filter.locationMode !== 'DISTANCE'
      ? { location: { contains: locationText, mode: 'insensitive' } }
      : {}),
    AND: approvedPartnerWhere,
  };
  const amenityWhereBase = {
    contentStatus: 'APPROVED',
    ...(filter.minRating != null ? { rating: { gte: filter.minRating } } : {}),
    ...(locationText && filter.locationMode !== 'DISTANCE'
      ? { location: { contains: locationText, mode: 'insensitive' } }
      : {}),
    AND: approvedPartnerWhere,
  };

  const serviceSelect = {
    id: true,
    name: true,
    serviceType: true,
    rating: true,
    reviewCount: true,
    imageUrl: true,
    address: true,
    city: true,
    serviceCharge: true,
    jobsCompleted: true,
    createdAt: true,
    skills: { select: { tagName: true } },
    partner: {
      select: {
        isBusinessOpen: true,
        openingTime: true,
        closingTime: true,
        address: true,
        area: true,
        city: true,
        facebookUrl: true,
        instagramUrl: true,
        websiteUrl: true,
      },
    },
    reviews: {
      include: {
        user: { select: { name: true, profilePhotoUrl: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 5,
    },
  };
  const businessSelect = {
    id: true,
    name: true,
    category: true,
    rating: true,
    reviewCount: true,
    imageUrl: true,
    isOpen: true,
    openingTime: true,
    closingTime: true,
    location: true,
    createdAt: true,
    reviews: {
      include: {
        user: { select: { name: true, profilePhotoUrl: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 5,
    },
  };
  const amenitySelect = {
    id: true,
    name: true,
    amenityType: true,
    rating: true,
    reviewCount: true,
    imageUrl: true,
    isOpen: true,
    openingTime: true,
    closingTime: true,
    location: true,
    createdAt: true,
    reviews: {
      include: {
        user: { select: { name: true, profilePhotoUrl: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 5,
    },
  };

  const [
    topServicesRaw,
    topBusinessesRaw,
    topAmenitiesRaw,
    topDoctorsRaw,
    topNonDoctorServicesRaw,
    topEateriesRaw,
    socialPartner,
  ] = await Promise.all([
    prisma.serviceProvider.findMany({
      where: {
        ...serviceWhereBase,
        ...(serviceTypeParam ? { serviceType: serviceTypeParam } : {}),
        ...(excludeServiceTypeParam ? { serviceType: { not: excludeServiceTypeParam } } : {}),
      },
      select: serviceSelect,
      orderBy,
      take: 10,
    }),
    prisma.business.findMany({
      where: {
        ...businessWhereBase,
        ...(businessCategoryParam ? { category: businessCategoryParam } : {}),
      },
      select: businessSelect,
      orderBy,
      take: 10,
    }),
    prisma.amenity.findMany({
      where: amenityWhereBase,
      select: amenitySelect,
      orderBy,
      take: 10,
    }),
    prisma.serviceProvider.findMany({
      where: {
        ...serviceWhereBase,
        serviceType: 'DOCTOR',
      },
      select: serviceSelect,
      orderBy,
      take: 10,
    }),
    prisma.serviceProvider.findMany({
      where: {
        ...serviceWhereBase,
        serviceType: { not: 'DOCTOR' },
      },
      select: serviceSelect,
      orderBy,
      take: 10,
    }),
    prisma.business.findMany({
      where: {
        ...businessWhereBase,
        category: 'RESTAURANT',
      },
      select: businessSelect,
      orderBy,
      take: 10,
    }),
    prisma.partner.findFirst({
      where: {
        status: 'APPROVED',
        followUsEnabled: true,
        OR: [
          { facebookUrl: { not: null } },
          { instagramUrl: { not: null } },
          { websiteUrl: { not: null } },
        ],
      },
      select: {
        facebookUrl: true,
        instagramUrl: true,
        websiteUrl: true,
      },
      orderBy: { updatedAt: 'desc' },
    }),
  ]);

  let topServices = topServicesRaw.map((item) => ({
    ...item,
    entityType: 'service',
    categoryName: item.serviceType,
    isOpen: item.partner?.isBusinessOpen ?? null,
    openingTime: item.partner?.openingTime ?? null,
    closingTime: item.partner?.closingTime ?? null,
    location:
      item.address ||
      item.city ||
      item.partner?.address ||
      item.partner?.area ||
      item.partner?.city ||
      '',
    latitude: null,
    longitude: null,
    distanceKm:
      filter.latitude != null && filter.longitude != null
        ? applyDistanceFilterAndSort([item], filter, (x) => parseLatLng(x.address || ''))[0]
            ?.distanceKm ?? null
        : null,
  }));

  let topBusinesses = topBusinessesRaw.map((item) => ({
    ...item,
    entityType: 'business',
    categoryName: item.category,
    ...parseLatLng(item.location),
    distanceKm:
      filter.latitude != null && filter.longitude != null
        ? applyDistanceFilterAndSort([item], filter, (x) => parseLatLng(x.location))[0]
            ?.distanceKm ?? null
        : null,
  }));

  let topAmenities = topAmenitiesRaw.map((item) => ({
    ...item,
    entityType: 'amenity',
    categoryName: item.amenityType,
    category: item.amenityType,
    ...parseLatLng(item.location),
    distanceKm:
      filter.latitude != null && filter.longitude != null
        ? applyDistanceFilterAndSort([item], filter, (x) => parseLatLng(x.location))[0]
            ?.distanceKm ?? null
        : null,
  }));

  if (filter.locationMode === 'DISTANCE' && filter.latitude != null && filter.longitude != null) {
    const radius = filter.radiusKm;
    topServices = topServices.filter((x) => x.distanceKm != null && x.distanceKm <= radius);
    topBusinesses = topBusinesses.filter((x) => x.distanceKm != null && x.distanceKm <= radius);
    topAmenities = topAmenities.filter((x) => x.distanceKm != null && x.distanceKm <= radius);
  }

  const mapServiceItems = (rows) =>
    rows.map((item) => ({
      ...item,
      entityType: 'service',
      categoryName: item.serviceType,
      isOpen: item.partner?.isBusinessOpen ?? null,
      openingTime: item.partner?.openingTime ?? null,
      closingTime: item.partner?.closingTime ?? null,
      location:
        item.address ||
        item.city ||
        item.partner?.address ||
        item.partner?.area ||
        item.partner?.city ||
        '',
      latitude: null,
      longitude: null,
      distanceKm:
        filter.latitude != null && filter.longitude != null
          ? applyDistanceFilterAndSort([item], filter, (x) => parseLatLng(x.address || ''))[0]
              ?.distanceKm ?? null
          : null,
    }));
  const mapBusinessItems = (rows) =>
    rows.map((item) => ({
      ...item,
      entityType: 'business',
      categoryName: item.category,
      ...parseLatLng(item.location),
      distanceKm:
        filter.latitude != null && filter.longitude != null
          ? applyDistanceFilterAndSort([item], filter, (x) => parseLatLng(x.location))[0]
              ?.distanceKm ?? null
          : null,
    }));
  const mapAmenityItems = (rows) =>
    rows.map((item) => ({
      ...item,
      entityType: 'amenity',
      categoryName: item.amenityType,
      category: item.amenityType,
      ...parseLatLng(item.location),
      distanceKm:
        filter.latitude != null && filter.longitude != null
          ? applyDistanceFilterAndSort([item], filter, (x) => parseLatLng(x.location))[0]
              ?.distanceKm ?? null
          : null,
    }));

  let topDoctors = mapServiceItems(topDoctorsRaw);
  let topNonDoctorServices = mapServiceItems(topNonDoctorServicesRaw);
  let topEateries = mapBusinessItems(topEateriesRaw);

  if (filter.locationMode === 'DISTANCE' && filter.latitude != null && filter.longitude != null) {
    const radius = filter.radiusKm;
    const inRadius = (x) => x.distanceKm != null && x.distanceKm <= radius;
    topDoctors = topDoctors.filter(inRadius);
    topNonDoctorServices = topNonDoctorServices.filter(inRadius);
    topEateries = topEateries.filter(inRadius);
  }

  const latestReviews = [];
  const pushReviews = (items, itemType) => {
    for (const item of items) {
      if (!Array.isArray(item.reviews)) continue;
      for (const review of item.reviews) {
        const reviewText = (review.reviewText || review.comment || '').toString().trim();
        if (!reviewText) continue;
        latestReviews.push({
          id: review.id,
          name: review.name || review.user?.name || 'Anonymous',
          productName: item.name || 'Service',
          rating: Number((review.rating || 0).toFixed(1)),
          ratingText: review.ratingText || '',
          review: reviewText,
          createdAt: review.createdAt,
          productImage: item.imageUrl || '',
          profileImage: review.user?.profilePhotoUrl || '',
          entityType: itemType,
          entityId: item.id,
        });
      }
    }
  };
  pushReviews(topServices, 'service');
  pushReviews(topBusinesses, 'business');
  pushReviews(topAmenities, 'amenity');
  latestReviews.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  const socialLinks = {
    facebook: socialPartner?.facebookUrl ?? null,
    instagram: socialPartner?.instagramUrl ?? null,
    youtube: socialPartner?.websiteUrl ?? null,
  };

  return {
    topServices,
    topBusinesses,
    topAmenities,
    topDoctors,
    topNonDoctorServices,
    topEateries,
    latestReviews: latestReviews.slice(0, 10),
    socialLinks,
  };
}

async function saveSearchHistory(userId, query, category) {
  return prisma.searchHistory.create({
    data: { userId, query, category },
  });
}

async function getSearchHistory(userId) {
  return prisma.searchHistory.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
    take: 20,
  });
}

async function deleteSearchHistory(userId, id) {
  if (id) {
    await prisma.searchHistory.deleteMany({
      where: { id, userId },
    });
  } else {
    await prisma.searchHistory.deleteMany({
      where: { userId },
    });
  }
}

module.exports = {
  search,
  suggestions,
  popular,
  saveSearchHistory,
  getSearchHistory,
  deleteSearchHistory,
};
