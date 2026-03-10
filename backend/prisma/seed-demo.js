const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

// ─── IMAGE HELPERS ─────────────────────────────────────────
const avatar = (name, bg = '0D8ABC') =>
  `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&size=200&background=${bg}&color=fff&format=png&bold=true`;

const img = (keyword, w = 400, h = 300) =>
  `https://picsum.photos/seed/${keyword}/${w}/${h}`;

async function main() {
  console.log('🌱 Seeding demo data — one per category...\n');

  const hashedPw = await bcrypt.hash('password123', 12);
  const partnerPw = await bcrypt.hash('partner123', 12);

  // ═══════════════════════════════════════════════════════════
  // 1. DEMO USER
  // ═══════════════════════════════════════════════════════════
  const user = await prisma.user.create({
    data: {
      name: 'Ali Khan',
      email: 'demo@oneconnect.pk',
      passwordHash: hashedPw,
      phone: '+92-300-1234567',
      profilePhotoUrl: avatar('Ali Khan', '1E88E5'),
    },
  });
  console.log('  ✓ User: demo@oneconnect.pk / password123');

  // ═══════════════════════════════════════════════════════════
  // 2. PARTNER
  // ═══════════════════════════════════════════════════════════
  const partner = await prisma.partner.create({
    data: {
      businessId: 'OC-2024-00001',
      businessName: 'OneConnect Services',
      ownerFullName: 'Ahmed Hassan',
      businessEmail: 'partner@oneconnect.pk',
      passwordHash: partnerPw,
      businessType: 'SERVICE_PROVIDER',
      status: 'APPROVED',
      address: '45-B Commercial Area, DHA Phase 6',
      area: 'DHA Phase 6',
      city: 'Lahore',
      country: 'Pakistan',
      isBusinessOpen: true,
      openingTime: '08:00',
      closingTime: '22:00',
      rating: 4.5,
      profilePhotoUrl: avatar('OneConnect Services', '1565C0'),
      description: 'OneConnect Services — your trusted partner for all services in Lahore.',
      phones: {
        create: [
          { phoneNumber: '3001234567', countryCode: '+92', isPrimary: true },
        ],
      },
      operatingDays: {
        create: [
          { dayCode: 'M' }, { dayCode: 'T' }, { dayCode: 'W' },
          { dayCode: 'Th' }, { dayCode: 'F' }, { dayCode: 'S' },
        ],
      },
    },
  });
  console.log('  ✓ Partner: OC-2024-00001 / partner123');

  // ═══════════════════════════════════════════════════════════
  // 3. GET SERVICE CATEGORIES
  // ═══════════════════════════════════════════════════════════
  const categories = await prisma.serviceCategory.findMany();
  const catMap = {};
  for (const c of categories) catMap[c.slug] = c.id;

  // ═══════════════════════════════════════════════════════════
  // 4. SERVICE PROVIDERS — 1 per type (12 total)
  // ═══════════════════════════════════════════════════════════
  const serviceData = [
    { type: 'LAUNDRY', slug: 'laundry', name: 'Clean Express Laundry', skills: ['Dry Cleaning', 'Steam Press', 'Stain Removal'], charge: 500, img: 'laundry-service' },
    { type: 'PLUMBER', slug: 'plumber', name: 'Pro Plumbing Solutions', skills: ['Pipe Repair', 'Drainage Fix', 'Water Tank'], charge: 1500, img: 'plumber-tools' },
    { type: 'ELECTRICIAN', slug: 'electrician', name: 'Bright Spark Electricians', skills: ['Wiring', 'AC Repair', 'Generator'], charge: 1200, img: 'electrician-work' },
    { type: 'PAINTER', slug: 'painter', name: 'Color Masters Painting', skills: ['Interior Paint', 'Exterior Paint', 'Wallpaper'], charge: 2000, img: 'house-painting' },
    { type: 'CARPENTER', slug: 'carpenter', name: 'Wood Craft Carpentry', skills: ['Furniture Making', 'Door Repair', 'Cabinet Work'], charge: 2500, img: 'carpenter-wood' },
    { type: 'BARBER', slug: 'barber', name: 'Royal Cuts Barber Shop', skills: ['Hair Cut', 'Beard Trim', 'Hair Color'], charge: 800, img: 'barber-shop' },
    { type: 'MAID', slug: 'maid', name: 'Home Care Maid Service', skills: ['House Cleaning', 'Cooking', 'Laundry'], charge: 3000, img: 'house-cleaning' },
    { type: 'SALON', slug: 'salon', name: 'Glamour Beauty Salon', skills: ['Hair Styling', 'Facial', 'Manicure'], charge: 1500, img: 'beauty-salon' },
    { type: 'REAL_ESTATE', slug: 'real-estate', name: 'Prime Property Advisors', skills: ['Buying', 'Selling', 'Renting'], charge: 0, img: 'real-estate-house' },
    { type: 'DOCTOR', slug: 'doctor', name: 'Dr. Fatima Zahid', skills: ['General Physician', 'Family Medicine', 'Pediatrics'], charge: 2000, img: 'doctor-clinic' },
    { type: 'WATER', slug: 'water', name: 'Pure Aqua Water Supply', skills: ['Tanker Delivery', 'Filter Installation', 'Testing'], charge: 1000, img: 'water-delivery' },
    { type: 'GAS', slug: 'gas', name: 'Quick Gas Services', skills: ['Gas Leak Repair', 'Pipeline', 'Geyser Repair'], charge: 1500, img: 'gas-pipeline' },
  ];

  for (const s of serviceData) {
    const sp = await prisma.serviceProvider.create({
      data: {
        partnerId: partner.id,
        categoryId: catMap[s.slug],
        serviceType: s.type,
        name: s.name,
        rating: 4.3 + Math.random() * 0.6,
        reviewCount: 0,
        address: 'DHA Phase 6, Lahore',
        city: 'Lahore',
        serviceCharge: s.charge,
        isTopRated: true,
        jobsCompleted: Math.floor(50 + Math.random() * 200),
        vendorId: `VND-${s.type.slice(0, 3)}-001`,
        responseTime: 'Within 1 hour',
        workingSince: '2020',
        imageUrl: img(s.img, 400, 400),
        contentStatus: 'APPROVED',
        ...(s.type === 'DOCTOR' ? {
          patientsCount: 1500,
          doctorId: 'DR-001',
          experienceYears: 12,
          hospitalName: 'Shaukat Khanum Hospital',
          consultationCharge: 2000,
        } : {}),
        skills: {
          create: s.skills.map(sk => ({ tagName: sk })),
        },
      },
    });
  }
  console.log(`  ✓ 12 service providers (1 per type) — all APPROVED`);

  // ═══════════════════════════════════════════════════════════
  // 5. BUSINESSES — 1 per category (6 total)
  // ═══════════════════════════════════════════════════════════
  const businessData = [
    { cat: 'STORE', name: 'Lahore General Store', desc: 'Your neighborhood grocery and essentials store.', img: 'grocery-store' },
    { cat: 'SOLAR', name: 'SunPower Solar Solutions', desc: 'Premium solar panels and installation services.', img: 'solar-panels' },
    { cat: 'BANK', name: 'HBL - DHA Branch', desc: 'Habib Bank Limited, full banking services.', img: 'bank-building' },
    { cat: 'RESTAURANT', name: 'Spice Garden Restaurant', desc: 'Authentic Pakistani and continental cuisine.', img: 'restaurant-food' },
    { cat: 'REAL_ESTATE', name: 'DHA Homes Real Estate', desc: 'Trusted real estate agency for DHA properties.', img: 'real-estate-office' },
    { cat: 'HOME_CHEF', name: 'Ammi Jaan Home Kitchen', desc: 'Homemade Pakistani food delivered fresh daily.', img: 'home-cooking' },
  ];

  for (const b of businessData) {
    await prisma.business.create({
      data: {
        partnerId: partner.id,
        name: b.name,
        category: b.cat,
        rating: 4.2 + Math.random() * 0.7,
        location: 'DHA Phase 6, Lahore',
        isOpen: true,
        imageUrl: img(b.img, 400, 300),
        phone: '+92-300-1234567',
        description: b.desc,
        contentStatus: 'APPROVED',
      },
    });
  }
  console.log(`  ✓ 6 businesses (1 per category) — all APPROVED`);

  // ═══════════════════════════════════════════════════════════
  // 6. AMENITIES — 1 per type (8 total)
  // ═══════════════════════════════════════════════════════════
  const amenityData = [
    { type: 'MASJID', name: 'Masjid Al-Noor', desc: 'Beautiful mosque with 5 daily prayers and Jummah.', img: 'mosque-building' },
    { type: 'PARK', name: 'Jilani Park', desc: 'Large public park with jogging track, playground, and lake.', img: 'city-park' },
    { type: 'GYM', name: 'FitZone Gym', desc: 'Modern gym with latest equipment and personal trainers.', img: 'modern-gym' },
    { type: 'HEALTHCARE', name: 'City Care Hospital', desc: 'Multi-specialty hospital with 24/7 emergency services.', img: 'hospital-building' },
    { type: 'SCHOOL', name: 'Lahore Grammar School', desc: 'Premier educational institution from playgroup to A-levels.', img: 'school-building' },
    { type: 'PHARMACY', name: 'D.Watson Pharmacy', desc: '24-hour pharmacy with home delivery service.', img: 'pharmacy-store' },
    { type: 'CAFE', name: 'Coffee Planet Cafe', desc: 'Cozy cafe with premium coffee and fresh pastries.', img: 'coffee-cafe' },
    { type: 'ADMIN', name: 'DC Office Lahore', desc: 'Deputy Commissioner office, Lahore district administration.', img: 'government-office' },
  ];

  for (const a of amenityData) {
    await prisma.amenity.create({
      data: {
        partnerId: partner.id,
        name: a.name,
        amenityType: a.type,
        location: 'DHA Phase 6, Lahore',
        isOpen: true,
        rating: 4.0 + Math.random() * 0.9,
        imageUrl: img(a.img, 400, 300),
        phone: '+92-300-1234567',
        description: a.desc,
        contentStatus: 'APPROVED',
      },
    });
  }
  console.log(`  ✓ 8 amenities (1 per type) — all APPROVED`);

  // ═══════════════════════════════════════════════════════════
  // 7. PROPERTIES — 3 types
  // ═══════════════════════════════════════════════════════════
  const propertyData = [
    { title: '5 Marla House in DHA Phase 6', type: 'House', beds: 3, baths: 2, kitchen: 1, price: 18500000, sqft: 1125, img: 'modern-house' },
    { title: 'Luxury Apartment in Gulberg', type: 'Apartment', beds: 2, baths: 2, kitchen: 1, price: 12000000, sqft: 950, img: 'luxury-apartment' },
    { title: '10 Marla Plot in Bahria Town', type: 'Plot', beds: 0, baths: 0, kitchen: 0, price: 8500000, sqft: 2250, img: 'land-plot' },
  ];

  for (const p of propertyData) {
    await prisma.property.create({
      data: {
        title: p.title,
        location: 'Lahore, Pakistan',
        beds: p.beds,
        baths: p.baths,
        kitchen: p.kitchen,
        propertyType: p.type,
        price: p.price,
        mainImageUrl: img(p.img, 600, 400),
        description: `Beautiful ${p.type.toLowerCase()} in prime location with all modern amenities.`,
        sqft: p.sqft,
        contentStatus: 'APPROVED',
        images: {
          create: [
            { imageUrl: img(`${p.img}-1`, 600, 400), sortOrder: 1 },
            { imageUrl: img(`${p.img}-2`, 600, 400), sortOrder: 2 },
            { imageUrl: img(`${p.img}-3`, 600, 400), sortOrder: 3 },
          ],
        },
      },
    });
  }
  console.log(`  ✓ 3 properties (House, Apartment, Plot) — all APPROVED`);

  // ═══════════════════════════════════════════════════════════
  // 8. PROMOTIONS — 3 different
  // ═══════════════════════════════════════════════════════════
  const promoData = [
    { title: '50% Off Laundry Service', price: 500, discount: 50, desc: 'Get your clothes cleaned at half price! Limited time offer.', img: 'laundry-promo' },
    { title: 'Free AC Checkup', price: 0, discount: 100, desc: 'Book any electrician service and get free AC checkup.', img: 'ac-checkup' },
    { title: 'Haircut + Beard @ Rs.600', price: 600, discount: 25, desc: 'Complete grooming package at Royal Cuts.', img: 'barber-promo' },
  ];

  for (const pr of promoData) {
    await prisma.promotion.create({
      data: {
        partnerId: partner.id,
        title: pr.title,
        imageUrl: img(pr.img, 400, 250),
        price: pr.price,
        discountPct: pr.discount,
        description: pr.desc,
        isActive: true,
        contentStatus: 'APPROVED',
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
      },
    });
  }
  console.log(`  ✓ 3 promotions — all APPROVED`);

  // ═══════════════════════════════════════════════════════════
  // 9. ADMIN OFFICES — 2
  // ═══════════════════════════════════════════════════════════
  await prisma.adminOffice.createMany({
    data: [
      { name: 'DC Office Lahore', officeType: 'administration', rating: 4.0, phone: '+92-42-99200100', isOpen: true, address: 'Katchery Road, Lahore' },
      { name: 'Rescue 1122', officeType: 'emergency', rating: 4.8, phone: '1122', isOpen: true, address: 'Mall Road, Lahore' },
    ],
  });
  console.log(`  ✓ 2 admin offices`);

  // ═══════════════════════════════════════════════════════════
  // 10. REVIEWS — 1 per some services/businesses
  // ═══════════════════════════════════════════════════════════
  const allSPs = await prisma.serviceProvider.findMany({ take: 4 });
  const allBiz = await prisma.business.findMany({ take: 3 });
  const allAm = await prisma.amenity.findMany({ take: 3 });

  const reviewTexts = [
    { rating: 5, text: 'Excellent service! Very professional and on time.', ratingText: 'Excellent' },
    { rating: 4, text: 'Good work, would recommend to others.', ratingText: 'Good' },
    { rating: 4.5, text: 'Very satisfied with the quality. Will use again.', ratingText: 'Very Good' },
  ];

  let reviewIdx = 0;
  for (const sp of allSPs) {
    const r = reviewTexts[reviewIdx % reviewTexts.length];
    await prisma.review.create({
      data: {
        userId: user.id,
        rating: r.rating,
        ratingText: r.ratingText,
        reviewText: r.text,
        serviceProviderId: sp.id,
      },
    });
    await prisma.serviceProvider.update({ where: { id: sp.id }, data: { reviewCount: 1 } });
    reviewIdx++;
  }
  for (const bz of allBiz) {
    const r = reviewTexts[reviewIdx % reviewTexts.length];
    await prisma.review.create({
      data: {
        userId: user.id,
        rating: r.rating,
        ratingText: r.ratingText,
        reviewText: r.text,
        businessId: bz.id,
      },
    });
    await prisma.business.update({ where: { id: bz.id }, data: { reviewCount: 1 } });
    reviewIdx++;
  }
  for (const am of allAm) {
    const r = reviewTexts[reviewIdx % reviewTexts.length];
    await prisma.review.create({
      data: {
        userId: user.id,
        rating: r.rating,
        ratingText: r.ratingText,
        reviewText: r.text,
        amenityId: am.id,
      },
    });
    await prisma.amenity.update({ where: { id: am.id }, data: { reviewCount: 1 } });
    reviewIdx++;
  }
  console.log(`  ✓ ${reviewIdx} reviews`);

  // ═══════════════════════════════════════════════════════════
  // SUMMARY
  // ═══════════════════════════════════════════════════════════
  console.log('\n' + '═'.repeat(55));
  console.log('✅ DEMO SEED COMPLETE');
  console.log('═'.repeat(55));
  console.log('');
  console.log('👤 User:     demo@oneconnect.pk / password123');
  console.log('🏢 Partner:  OC-2024-00001 / partner123');
  console.log('🔑 Admin:    admin@oneconnect.pk / admin123 (already exists)');
  console.log('');
  console.log('📊 Data:');
  console.log('   12 Service Providers (1 per type)');
  console.log('   6  Businesses (1 per category)');
  console.log('   8  Amenities (1 per type)');
  console.log('   3  Properties (House, Apartment, Plot)');
  console.log('   3  Promotions');
  console.log('   2  Admin Offices');
  console.log(`   ${reviewIdx} Reviews`);
  console.log('');
  console.log('🖼️  All images: picsum.photos (category-specific seeds)');
  console.log('   All content: APPROVED status');
  console.log('═'.repeat(55));
}

main()
  .catch((e) => {
    console.error('❌ Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
