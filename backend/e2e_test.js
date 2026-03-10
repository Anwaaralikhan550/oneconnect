/**
 * End-to-End API Test Script
 * Tests every endpoint against the live server
 *
 * Prerequisites: server running on port 3000, database seeded
 * Usage: node e2e_test.js
 */
const http = require('http');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();
const PORT = 3000;
const BASE = `http://localhost:${PORT}/api/v1`;

let userToken = '';
let userRefreshToken = '';
let partnerToken = '';
let spId = '';
let businessId = '';
let amenityId = '';
let propertyId = '';
let adminOfficeId = '';
let promotionId = '';

const results = [];
let passed = 0;
let failed = 0;

// ─── HTTP Helper ──────────────────────────────────────────
function req(method, path, body, token) {
  return new Promise((resolve) => {
    const url = new URL(BASE + path);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method,
      headers: { 'Content-Type': 'application/json' },
    };
    if (token) options.headers['Authorization'] = 'Bearer ' + token;

    const r = http.request(options, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(data) });
        } catch {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });
    r.on('error', (e) => resolve({ status: 0, body: { error: e.message } }));
    if (body) r.write(JSON.stringify(body));
    r.end();
  });
}

// Raw request bypassing /api/v1 prefix (for /health etc.)
function rawReq(method, path) {
  return new Promise((resolve) => {
    const url = new URL(`http://localhost:${PORT}${path}`);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname,
      method,
      headers: { 'Content-Type': 'application/json' },
    };

    const r = http.request(options, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(data) });
        } catch {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });
    r.on('error', (e) => resolve({ status: 0, body: { error: e.message } }));
    r.end();
  });
}

function test(name, condition, debug) {
  if (condition) {
    passed++;
    results.push(`  ✅ ${name}`);
  } else {
    failed++;
    const extra = debug ? ` [got: ${JSON.stringify(debug).slice(0, 120)}]` : '';
    results.push(`  ❌ ${name}${extra}`);
  }
}

// ─── Cleanup ──────────────────────────────────────────────
async function cleanup() {
  console.log('🧹 Cleaning up test data...');
  try {
    // Find and delete E2E test user
    const testUser = await prisma.user.findUnique({ where: { email: 'e2e@oneconnect.pk' } });
    if (testUser) {
      await prisma.searchHistory.deleteMany({ where: { userId: testUser.id } });
      await prisma.notification.deleteMany({ where: { userId: testUser.id } });
      await prisma.favorite.deleteMany({ where: { userId: testUser.id } });
      await prisma.review.deleteMany({ where: { userId: testUser.id } });
      await prisma.refreshToken.deleteMany({ where: { userId: testUser.id } });
      await prisma.user.delete({ where: { id: testUser.id } });
      console.log('   Deleted test user: e2e@oneconnect.pk');
    }

    // Find and delete E2E test partner
    const testPartner = await prisma.partner.findUnique({ where: { businessEmail: 'e2e.partner@test.com' } });
    if (testPartner) {
      await prisma.partnerPhone.deleteMany({ where: { partnerId: testPartner.id } });
      await prisma.partnerOperatingDay.deleteMany({ where: { partnerId: testPartner.id } });
      await prisma.partnerMedia.deleteMany({ where: { partnerId: testPartner.id } });
      await prisma.partnerCategory.deleteMany({ where: { partnerId: testPartner.id } });
      await prisma.promotion.deleteMany({ where: { partnerId: testPartner.id } });
      await prisma.partnerRefreshToken.deleteMany({ where: { partnerId: testPartner.id } });
      await prisma.partner.delete({ where: { id: testPartner.id } });
      console.log('   Deleted test partner: e2e.partner@test.com');
    }

    console.log('   Cleanup complete.\n');
  } catch (err) {
    console.log('   Cleanup warning:', err.message, '\n');
  }
}

// ─── Main Test Runner ─────────────────────────────────────
async function run() {
  console.log('🧪 OneConnect E2E API Test\n');

  // Clean up data from previous runs
  await cleanup();

  // ═══════════════ HEALTH ═══════════════
  console.log('━━━ HEALTH CHECK ━━━');
  let r = await rawReq('GET', '/health');
  test('GET /health → 200', r.status === 200 && r.body.status === 'ok', r);

  // ═══════════════ AUTH ═══════════════
  console.log('━━━ AUTH ENDPOINTS (7) ━━━');

  r = await req('POST', '/auth/register', {
    name: 'E2E User',
    email: 'e2e@oneconnect.pk',
    password: 'e2epass123',
    phone: '+92-333-1234567',
  });
  test('POST /auth/register → 201', r.status === 201 && r.body.data?.user?.email === 'e2e@oneconnect.pk', r);
  userToken = r.body.data?.accessToken || '';
  userRefreshToken = r.body.data?.refreshToken || '';

  r = await req('POST', '/auth/register', {
    name: 'Dup',
    email: 'e2e@oneconnect.pk',
    password: 'pass123456',
  });
  test('POST /auth/register duplicate → 409', r.status === 409, r);

  r = await req('POST', '/auth/register', {
    name: 'X',
    email: 'bad',
    password: '12',
  });
  test('POST /auth/register validation → 400', r.status === 400, r);

  r = await req('POST', '/auth/login', {
    email: 'e2e@oneconnect.pk',
    password: 'e2epass123',
  });
  test('POST /auth/login → 200', r.status === 200 && r.body.data?.accessToken, r);
  userToken = r.body.data?.accessToken || userToken;
  userRefreshToken = r.body.data?.refreshToken || userRefreshToken;

  r = await req('POST', '/auth/login', {
    email: 'e2e@oneconnect.pk',
    password: 'wrongpass',
  });
  test('POST /auth/login invalid → 401', r.status === 401, r);

  r = await req('POST', '/auth/refresh', { refreshToken: userRefreshToken });
  test('POST /auth/refresh → 200 (token rotation)', r.status === 200 && r.body.data?.accessToken, r);
  // Update BOTH tokens after refresh (rotation gives new pair)
  if (r.body.data?.accessToken) userToken = r.body.data.accessToken;
  if (r.body.data?.refreshToken) userRefreshToken = r.body.data.refreshToken;

  r = await req('POST', '/auth/forgot-password', { email: 'e2e@oneconnect.pk' });
  test('POST /auth/forgot-password → 200', r.status === 200, r);

  r = await req('POST', '/auth/forgot-password', { email: 'nonexistent@x.com' });
  test('POST /auth/forgot-password (no leak) → 200', r.status === 200, r);

  r = await req('POST', '/auth/verify-otp', { email: 'e2e@oneconnect.pk', otp: '000000' });
  test('POST /auth/verify-otp invalid → 400', r.status === 400, r);

  r = await req('POST', '/auth/logout', { refreshToken: userRefreshToken }, userToken);
  test('POST /auth/logout → 200', r.status === 200, r);

  // Re-login after logout to get fresh tokens
  r = await req('POST', '/auth/login', {
    email: 'e2e@oneconnect.pk',
    password: 'e2epass123',
  });
  test('POST /auth/login (re-login) → 200', r.status === 200 && !!r.body.data?.accessToken, r);
  userToken = r.body.data?.accessToken || '';
  userRefreshToken = r.body.data?.refreshToken || '';

  // Verify we have a valid user token before proceeding
  if (!userToken) {
    console.log('⚠️  WARNING: userToken is empty! Authenticated tests will fail.\n');
  }

  // ═══════════════ PARTNER ═══════════════
  console.log('━━━ PARTNER ENDPOINTS (11) ━━━');

  r = await req('POST', '/partner/register', {
    businessName: 'E2E Electric',
    ownerFullName: 'E2E Owner',
    businessEmail: 'e2e.partner@test.com',
    password: 'partner123',
    businessType: 'SERVICE_PROVIDER',
    city: 'Lahore',
    phones: [{ phoneNumber: '3001234567', isPrimary: true }],
    operatingDays: ['M', 'T', 'W', 'Th', 'F'],
  });
  test('POST /partner/register → 201', r.status === 201 && r.body.data?.partner?.businessId, r);
  const newBizId = r.body.data?.partner?.businessId;

  r = await req('POST', '/partner/register', {
    businessName: 'Dup',
    ownerFullName: 'Dup',
    businessEmail: 'e2e.partner@test.com',
    password: 'pass123',
    businessType: 'RETAIL_STORE',
  });
  test('POST /partner/register duplicate → 409', r.status === 409, r);

  // Login with seed partner (already APPROVED, seeded as OC-2024-00001)
  r = await req('POST', '/partner/login', {
    businessId: 'OC-2024-00001',
    password: 'partner123',
  });
  test('POST /partner/login → 200', r.status === 200 && r.body.data?.partner, r);
  partnerToken = r.body.data?.accessToken || '';

  r = await req('POST', '/partner/login', {
    businessId: 'OC-2024-00001',
    password: 'wrong',
  });
  test('POST /partner/login invalid → 401', r.status === 401, r);

  // Verify we have a valid partner token
  if (!partnerToken) {
    console.log('⚠️  WARNING: partnerToken is empty! Partner tests will fail.\n');
  }

  r = await req('GET', '/partner/me', null, partnerToken);
  test('GET /partner/me → 200', r.status === 200 && r.body.data?.businessName, r);
  test('GET /partner/me hides password', !r.body.data?.passwordHash);

  r = await req('PUT', '/partner/me', { description: 'Updated via E2E' }, partnerToken);
  test('PUT /partner/me → 200', r.status === 200 && r.body.data?.description === 'Updated via E2E', r);

  r = await req('PUT', '/partner/me/phones', {
    phones: [{ phoneNumber: '3111111111', isPrimary: true }],
  }, partnerToken);
  test('PUT /partner/me/phones → 200', r.status === 200, r);

  r = await req('GET', '/partner/me/promotions', null, partnerToken);
  test('GET /partner/me/promotions → 200', r.status === 200 && Array.isArray(r.body.data), r);

  r = await req('POST', '/partner/me/promotions', {
    title: 'E2E Promo',
    price: 100,
    discountPct: 10,
  }, partnerToken);
  test('POST /partner/me/promotions → 201', r.status === 201, r);
  promotionId = r.body.data?.id;

  if (promotionId) {
    r = await req('PUT', '/partner/me/promotions/' + promotionId, {
      title: 'E2E Promo Updated',
      price: 200,
      discountPct: 20,
    }, partnerToken);
    test('PUT /partner/me/promotions/:id → 200', r.status === 200, r);

    r = await req('DELETE', '/partner/me/promotions/' + promotionId, null, partnerToken);
    test('DELETE /partner/me/promotions/:id → 200', r.status === 200, r);
  } else {
    test('PUT /partner/me/promotions/:id → 200', false, 'skipped: no promotionId');
    test('DELETE /partner/me/promotions/:id → 200', false, 'skipped: no promotionId');
  }

  r = await req('GET', '/partner/me/media', null, partnerToken);
  test('GET /partner/me/media → 200', r.status === 200 && Array.isArray(r.body.data), r);

  // ═══════════════ SERVICE PROVIDERS ═══════════════
  console.log('━━━ SERVICE PROVIDERS (all 12 types + pagination + detail) ━━━');

  r = await req('GET', '/service-providers');
  test('GET /service-providers → 200', r.status === 200 && r.body.data?.length > 0, r);
  test('GET /service-providers has pagination', r.body.pagination?.total > 0);
  spId = r.body.data?.[0]?.id || '';

  const spTypes = ['ELECTRICIAN', 'PLUMBER', 'DOCTOR', 'BARBER', 'MAID', 'PAINTER', 'CARPENTER', 'LAUNDRY', 'SALON', 'WATER', 'GAS'];
  for (const type of spTypes) {
    r = await req('GET', `/service-providers?type=${type}`);
    test(`GET /service-providers?type=${type}`, r.status === 200, r);
  }

  r = await req('GET', '/service-providers?city=Lahore');
  test('GET /service-providers?city=Lahore', r.status === 200 && r.body.data?.length > 0, r);

  r = await req('GET', '/service-providers?page=1&limit=2');
  test('GET /service-providers pagination (limit=2)', r.status === 200 && r.body.data?.length <= 2, r);

  if (spId) {
    r = await req('GET', '/service-providers/' + spId);
    test('GET /service-providers/:id → 200 (detail)', r.status === 200 && r.body.data?.name, r);
    test('GET /service-providers/:id includes skills', Array.isArray(r.body.data?.skills));
  }

  r = await req('GET', '/service-providers/00000000-0000-0000-0000-000000000000');
  test('GET /service-providers/:id not found → 404', r.status === 404, r);

  // ═══════════════ BUSINESSES ═══════════════
  console.log('━━━ BUSINESSES (6 categories) ━━━');

  r = await req('GET', '/businesses');
  test('GET /businesses → 200', r.status === 200 && r.body.data?.length > 0, r);
  businessId = r.body.data?.[0]?.id || '';

  const bizCategories = ['STORE', 'RESTAURANT', 'BANK', 'SOLAR', 'HOME_CHEF', 'REAL_ESTATE'];
  for (const cat of bizCategories) {
    r = await req('GET', `/businesses?category=${cat}`);
    test(`GET /businesses?category=${cat}`, r.status === 200, r);
  }

  if (businessId) {
    r = await req('GET', '/businesses/' + businessId);
    test('GET /businesses/:id → 200', r.status === 200 && r.body.data?.name, r);
  }

  // ═══════════════ AMENITIES ═══════════════
  console.log('━━━ AMENITIES (8 types) ━━━');

  r = await req('GET', '/amenities');
  test('GET /amenities → 200', r.status === 200 && r.body.data?.length > 0, r);
  amenityId = r.body.data?.[0]?.id || '';

  const amenityTypes = ['MASJID', 'PARK', 'GYM', 'HEALTHCARE', 'SCHOOL', 'PHARMACY', 'CAFE'];
  for (const type of amenityTypes) {
    r = await req('GET', `/amenities?type=${type}`);
    test(`GET /amenities?type=${type}`, r.status === 200, r);
  }

  if (amenityId) {
    r = await req('GET', '/amenities/' + amenityId);
    test('GET /amenities/:id → 200', r.status === 200, r);
  }

  // ═══════════════ PROPERTIES ═══════════════
  console.log('━━━ PROPERTIES ━━━');

  r = await req('GET', '/properties');
  test('GET /properties → 200', r.status === 200 && r.body.data?.length > 0, r);
  propertyId = r.body.data?.[0]?.id || '';

  r = await req('GET', '/properties?propertyType=House');
  test('GET /properties?propertyType=House', r.status === 200, r);

  r = await req('GET', '/properties?minPrice=5000000&maxPrice=20000000');
  test('GET /properties with price filter', r.status === 200, r);

  if (propertyId) {
    r = await req('GET', '/properties/' + propertyId);
    test('GET /properties/:id → 200', r.status === 200 && r.body.data?.title, r);
  }

  // ═══════════════ ADMIN OFFICES ═══════════════
  console.log('━━━ ADMIN OFFICES ━━━');

  r = await req('GET', '/admin-offices');
  test('GET /admin-offices → 200', r.status === 200 && r.body.data?.length > 0, r);
  adminOfficeId = r.body.data?.[0]?.id || '';

  r = await req('GET', '/admin-offices?type=administration');
  test('GET /admin-offices?type=administration', r.status === 200 && r.body.data?.every(o => o.officeType === 'administration'), r);

  r = await req('GET', '/admin-offices?type=emergency');
  test('GET /admin-offices?type=emergency', r.status === 200, r);

  if (adminOfficeId) {
    r = await req('GET', '/admin-offices/' + adminOfficeId);
    test('GET /admin-offices/:id → 200', r.status === 200, r);
  }

  // ═══════════════ PROMOTIONS (Public) ═══════════════
  console.log('━━━ PROMOTIONS (Public) ━━━');

  r = await req('GET', '/promotions');
  test('GET /promotions → 200', r.status === 200 && Array.isArray(r.body.data), r);

  // ═══════════════ REVIEWS (Authenticated) ═══════════════
  console.log('━━━ REVIEWS ━━━');

  if (spId && userToken) {
    r = await req('POST', '/service-providers/' + spId + '/reviews', {
      rating: 5,
      ratingText: 'Excellent',
      reviewText: 'Amazing work!',
    }, userToken);
    test('POST /service-providers/:id/reviews → 201', r.status === 201, r);
  } else {
    test('POST /service-providers/:id/reviews → 201', false, 'skipped: no spId or userToken');
  }

  if (businessId && userToken) {
    r = await req('POST', '/businesses/' + businessId + '/reviews', {
      rating: 4,
      ratingText: 'Good',
      reviewText: 'Nice store',
    }, userToken);
    test('POST /businesses/:id/reviews → 201', r.status === 201, r);
  } else {
    test('POST /businesses/:id/reviews → 201', false, 'skipped: no businessId or userToken');
  }

  // Review without auth → 401
  if (spId) {
    r = await req('POST', '/service-providers/' + spId + '/reviews', { rating: 3 });
    test('POST review without auth → 401', r.status === 401, r);
  }

  // Invalid rating → 400
  if (spId && userToken) {
    r = await req('POST', '/service-providers/' + spId + '/reviews', { rating: 10 }, userToken);
    test('POST review invalid rating → 400', r.status === 400, r);
  }

  // ═══════════════ FAVORITES (Authenticated) ═══════════════
  console.log('━━━ FAVORITES ━━━');

  if (spId && userToken) {
    r = await req('POST', '/service-providers/' + spId + '/favorite', null, userToken);
    test('POST /service-providers/:id/favorite (toggle on)', r.status === 200 && r.body.data?.favorited === true, r);

    r = await req('POST', '/service-providers/' + spId + '/favorite', null, userToken);
    test('POST /service-providers/:id/favorite (toggle off)', r.status === 200 && r.body.data?.favorited === false, r);
  } else {
    test('POST /service-providers/:id/favorite (toggle on)', false, 'skipped');
    test('POST /service-providers/:id/favorite (toggle off)', false, 'skipped');
  }

  if (businessId && userToken) {
    r = await req('POST', '/businesses/' + businessId + '/favorite', null, userToken);
    test('POST /businesses/:id/favorite', r.status === 200, r);
  } else {
    test('POST /businesses/:id/favorite', false, 'skipped');
  }

  r = await req('GET', '/users/me/favorites', null, userToken);
  test('GET /users/me/favorites → 200', r.status === 200 && Array.isArray(r.body.data), r);

  // ═══════════════ SEARCH ═══════════════
  console.log('━━━ SEARCH ━━━');

  r = await req('GET', '/search?q=electrician');
  test('GET /search?q=electrician → 200', r.status === 200 && r.body.data, r);

  r = await req('GET', '/search?q=Al-Fatah&category=Shop');
  test('GET /search?q=Al-Fatah&category=Shop', r.status === 200, r);

  r = await req('GET', '/search/suggestions?q=Ba');
  test('GET /search/suggestions → 200', r.status === 200 && Array.isArray(r.body.data), r);

  r = await req('GET', '/search/popular');
  test('GET /search/popular → 200', r.status === 200 && r.body.data?.topServices, r);

  // Search history (authenticated)
  if (userToken) {
    r = await req('POST', '/search/history', { query: 'plumber', category: 'Service' }, userToken);
    test('POST /search/history → 201', r.status === 201, r);

    r = await req('GET', '/search/history', null, userToken);
    test('GET /search/history → 200', r.status === 200 && r.body.data?.length > 0, r);

    r = await req('DELETE', '/search/history', null, userToken);
    test('DELETE /search/history → 200', r.status === 200, r);
  } else {
    test('POST /search/history → 201', false, 'skipped: no userToken');
    test('GET /search/history → 200', false, 'skipped');
    test('DELETE /search/history → 200', false, 'skipped');
  }

  // ═══════════════ USER PROFILE ═══════════════
  console.log('━━━ USER PROFILE ━━━');

  if (userToken) {
    r = await req('GET', '/users/me', null, userToken);
    test('GET /users/me → 200', r.status === 200 && r.body.data?.email === 'e2e@oneconnect.pk', r);
    test('GET /users/me hides passwordHash', !r.body.data?.passwordHash);

    r = await req('PUT', '/users/me', { name: 'E2E Updated', phone: '+92-333-9999999' }, userToken);
    test('PUT /users/me → 200', r.status === 200 && r.body.data?.name === 'E2E Updated', r);
  } else {
    test('GET /users/me → 200', false, 'skipped: no userToken');
    test('GET /users/me hides passwordHash', false, 'skipped');
    test('PUT /users/me → 200', false, 'skipped');
  }

  // ═══════════════ NOTIFICATIONS ═══════════════
  console.log('━━━ NOTIFICATIONS ━━━');

  if (userToken) {
    r = await req('GET', '/users/me/notifications', null, userToken);
    test('GET /users/me/notifications → 200', r.status === 200 && Array.isArray(r.body.data), r);

    r = await req('PUT', '/users/me/notifications/read-all', null, userToken);
    test('PUT /users/me/notifications/read-all → 200', r.status === 200, r);

    r = await req('GET', '/notifications', null, userToken);
    test('GET /notifications → 200', r.status === 200, r);

    r = await req('PUT', '/notifications/read-all', null, userToken);
    test('PUT /notifications/read-all → 200', r.status === 200, r);
  } else {
    test('GET /users/me/notifications → 200', false, 'skipped');
    test('PUT /users/me/notifications/read-all → 200', false, 'skipped');
    test('GET /notifications → 200', false, 'skipped');
    test('PUT /notifications/read-all → 200', false, 'skipped');
  }

  // ═══════════════ SECURITY CHECKS ═══════════════
  console.log('━━━ SECURITY ━━━');

  // No auth → 401
  r = await req('GET', '/users/me');
  test('GET /users/me without auth → 401', r.status === 401, r);

  r = await req('GET', '/partner/me');
  test('GET /partner/me without auth → 401', r.status === 401, r);

  // Cross-role access → 403
  if (userToken) {
    r = await req('GET', '/partner/me', null, userToken);
    test('GET /partner/me with user token → 403', r.status === 403, r);
  } else {
    test('GET /partner/me with user token → 403', false, 'skipped: no userToken');
  }

  if (partnerToken) {
    r = await req('GET', '/users/me', null, partnerToken);
    test('GET /users/me with partner token → 403', r.status === 403, r);
  } else {
    test('GET /users/me with partner token → 403', false, 'skipped: no partnerToken');
  }

  // 404 for nonexistent route
  r = await req('GET', '/nonexistent');
  test('GET /nonexistent → 404', r.status === 404, r);

  // ═══════════════ REPORT ═══════════════
  console.log('\n' + '═'.repeat(60));
  console.log('📊 END-TO-END TEST REPORT');
  console.log('═'.repeat(60));
  results.forEach((r) => console.log(r));
  console.log('─'.repeat(60));
  const total = passed + failed;
  console.log(`\n  Total: ${total} | ✅ Passed: ${passed} | ❌ Failed: ${failed}`);
  console.log(`  Success Rate: ${((passed / total) * 100).toFixed(1)}%`);
  console.log('═'.repeat(60));

  // Cleanup Prisma connection
  await prisma.$disconnect();

  if (failed > 0) process.exit(1);
}

run().catch(async (err) => {
  console.error('Fatal error:', err);
  await prisma.$disconnect();
  process.exit(1);
});
