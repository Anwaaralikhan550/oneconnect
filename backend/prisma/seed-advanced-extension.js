const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const TARGET_REVIEW_COUNT = 120;
const CITIES = ['Lahore', 'Islamabad', 'Peshawar', 'D.I. Khan'];

const RATING_VALUES = [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5];

const REVIEW_TEXT_BY_SCORE = {
  1: [
    'Very disappointing experience. Response was too late and issue remained unresolved.',
    'Not satisfied. Work quality was below expectations and support was poor.',
    'Bad experience overall. I had to follow up multiple times.',
  ],
  2: [
    'Service was below average. Team was polite but execution needs improvement.',
    'Could be much better. Timing and quality both need attention.',
    'Average-to-poor experience. Some parts were done right, others were missed.',
  ],
  3: [
    'Decent service. The job was completed but not as smoothly as expected.',
    'Average experience. Nothing majorly wrong, but there is room for improvement.',
    'Service was okay. Price was fair and delivery was acceptable.',
  ],
  4: [
    'Good experience. Team was responsive and work quality was solid.',
    'Satisfied with the service. Professional staff and timely completion.',
    'Very good overall. Minor delays but the final result was good.',
  ],
  5: [
    'Excellent service. Professional, fast, and exactly as promised.',
    'Outstanding experience. Highly recommended for quality and reliability.',
    'Top-tier service. Great communication and excellent delivery.',
  ],
};

function normalizeRatingText(rating) {
  if (rating >= 4.5) return 'Excellent';
  if (rating >= 3.5) return 'Very Good';
  if (rating >= 2.5) return 'Good';
  if (rating >= 1.5) return 'Average';
  return 'Poor';
}

function pick(arr, index) {
  if (!arr || arr.length === 0) return null;
  return arr[index % arr.length];
}

function buildLocation(base, city) {
  const cleaned = String(base || '').trim();
  if (!cleaned) return `Central Area, ${city}`;
  const firstPart = cleaned.split(',')[0].trim();
  return `${firstPart}, ${city}`;
}

function scoreBucket(rating) {
  if (rating < 1.5) return 1;
  if (rating < 2.5) return 2;
  if (rating < 3.5) return 3;
  if (rating < 4.5) return 4;
  return 5;
}

async function seedNotifications(users, businesses) {
  const notifications = [];

  for (let i = 0; i < users.length; i++) {
    const user = users[i];
    const business = pick(businesses, i);
    const businessName = business?.name || 'your listing';

    notifications.push(
      {
        userId: user.id,
        type: 'SYSTEM',
        title: 'TYPE_APPROVAL',
        body: `Your business ${businessName} has been approved.`,
        isRead: false,
        data: {
          source: 'advanced_seed_extension',
          subtype: 'TYPE_APPROVAL',
          businessId: business?.id || null,
          partnerId: business?.partnerId || null,
        },
      },
      {
        userId: user.id,
        type: 'SYSTEM',
        title: 'TYPE_SYSTEM',
        body: 'Security Alert: New login detected.',
        isRead: false,
        data: {
          source: 'advanced_seed_extension',
          subtype: 'TYPE_SYSTEM',
        },
      },
      {
        userId: user.id,
        type: 'PROMOTION',
        title: 'TYPE_PROMO',
        body: 'Flash Sale! Get 20% off on all Home Services today.',
        isRead: false,
        data: {
          source: 'advanced_seed_extension',
          subtype: 'TYPE_PROMO',
        },
      }
    );
  }

  if (notifications.length > 0) {
    await prisma.notification.createMany({ data: notifications });
  }

  return notifications.length;
}

async function seedReviews(users, serviceProviders, businesses, amenities) {
  const targets = [];
  if (serviceProviders.length > 0) targets.push('SERVICE_PROVIDER');
  if (businesses.length > 0) targets.push('BUSINESS');
  if (amenities.length > 0) targets.push('AMENITY');
  if (targets.length === 0) return { inserted: 0, touched: { sp: [], biz: [], am: [] } };

  const reviewRows = [];
  const touchedSp = new Set();
  const touchedBiz = new Set();
  const touchedAm = new Set();

  for (let i = 0; i < TARGET_REVIEW_COUNT; i++) {
    const targetType = targets[i % targets.length];
    const rating = RATING_VALUES[i % RATING_VALUES.length];
    const bucket = scoreBucket(rating);
    const text = pick(REVIEW_TEXT_BY_SCORE[bucket], i) || 'Service experience shared by user.';
    const user = pick(users, i);

    const row = {
      userId: user.id,
      rating,
      ratingText: normalizeRatingText(rating),
      reviewText: text,
      serviceProviderId: null,
      businessId: null,
      amenityId: null,
    };

    if (targetType === 'SERVICE_PROVIDER') {
      const entity = pick(serviceProviders, i);
      row.serviceProviderId = entity.id;
      touchedSp.add(entity.id);
    } else if (targetType === 'BUSINESS') {
      const entity = pick(businesses, i);
      row.businessId = entity.id;
      touchedBiz.add(entity.id);
    } else {
      const entity = pick(amenities, i);
      row.amenityId = entity.id;
      touchedAm.add(entity.id);
    }

    reviewRows.push(row);
  }

  if (reviewRows.length > 0) {
    await prisma.review.createMany({ data: reviewRows });
  }

  return {
    inserted: reviewRows.length,
    touched: {
      sp: [...touchedSp],
      biz: [...touchedBiz],
      am: [...touchedAm],
    },
  };
}

async function refreshAggregates(touched) {
  for (const id of touched.sp) {
    const agg = await prisma.review.aggregate({
      where: { serviceProviderId: id },
      _avg: { rating: true },
      _count: { rating: true },
    });
    await prisma.serviceProvider.update({
      where: { id },
      data: {
        rating: Math.round((agg._avg.rating || 0) * 10) / 10,
        reviewCount: agg._count.rating,
      },
    });
  }

  for (const id of touched.biz) {
    const agg = await prisma.review.aggregate({
      where: { businessId: id },
      _avg: { rating: true },
      _count: { rating: true },
    });
    await prisma.business.update({
      where: { id },
      data: {
        rating: Math.round((agg._avg.rating || 0) * 10) / 10,
        reviewCount: agg._count.rating,
      },
    });
  }

  for (const id of touched.am) {
    const agg = await prisma.review.aggregate({
      where: { amenityId: id },
      _avg: { rating: true },
      _count: { rating: true },
    });
    await prisma.amenity.update({
      where: { id },
      data: {
        rating: Math.round((agg._avg.rating || 0) * 10) / 10,
        reviewCount: agg._count.rating,
      },
    });
  }
}

async function distributeGeoData(businesses, properties) {
  let businessUpdates = 0;
  let propertyUpdates = 0;

  for (let i = 0; i < businesses.length; i++) {
    const city = CITIES[i % CITIES.length];
    const business = businesses[i];
    const location = buildLocation(business.location || business.name, city);
    await prisma.business.update({
      where: { id: business.id },
      data: { location },
    });
    businessUpdates++;
  }

  for (let i = 0; i < properties.length; i++) {
    const city = CITIES[i % CITIES.length];
    const property = properties[i];
    const location = buildLocation(property.location || property.title, city);
    await prisma.property.update({
      where: { id: property.id },
      data: { location },
    });
    propertyUpdates++;
  }

  return { businessUpdates, propertyUpdates };
}

async function main() {
  console.log('Starting advanced seed extension...');

  const [users, businesses, serviceProviders, amenities, properties] = await Promise.all([
    prisma.user.findMany({ select: { id: true } }),
    prisma.business.findMany({ select: { id: true, name: true, location: true, partnerId: true } }),
    prisma.serviceProvider.findMany({ select: { id: true, name: true } }),
    prisma.amenity.findMany({ select: { id: true, name: true } }),
    prisma.property.findMany({ select: { id: true, title: true, location: true } }),
  ]);

  if (users.length === 0) {
    throw new Error('No users found. Run base seed first.');
  }

  if (businesses.length === 0 && serviceProviders.length === 0 && amenities.length === 0) {
    throw new Error('No review targets found. Run base seed first.');
  }

  const notificationCount = await seedNotifications(users, businesses);
  const reviewResult = await seedReviews(users, serviceProviders, businesses, amenities);
  await refreshAggregates(reviewResult.touched);
  const geo = await distributeGeoData(businesses, properties);

  console.log('Advanced seed extension completed.');
  console.log(`Notifications added: ${notificationCount}`);
  console.log(`Reviews added: ${reviewResult.inserted}`);
  console.log(`Businesses geo-updated: ${geo.businessUpdates}`);
  console.log(`Properties geo-updated: ${geo.propertyUpdates}`);
}

main()
  .catch((e) => {
    console.error('Advanced seed extension failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

