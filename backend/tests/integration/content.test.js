const request = require('supertest');
const app = require('../../src/app');
const { prisma, cleanDatabase } = require('../setup');

describe('Content API', () => {
  let categoryId;
  let serviceProviderId;
  let userToken;
  let userId;

  beforeAll(async () => {
    await cleanDatabase();

    // Create a service category
    const cat = await prisma.serviceCategory.create({
      data: { name: 'Electrician', slug: 'electrician', sortOrder: 1 },
    });
    categoryId = cat.id;

    // Create service providers
    const sp1 = await prisma.serviceProvider.create({
      data: {
        name: 'Baber M Rizwan',
        categoryId,
        serviceType: 'ELECTRICIAN',
        rating: 4.8,
        reviewCount: 127,
        city: 'Lahore',
        address: 'Naval Anchorage',
        isTopRated: true,
        jobsCompleted: 342,
        vendorId: 'VE-001',
        serviceCharge: 500,
        skills: {
          create: [
            { tagName: 'Wiring & Rewiring' },
            { tagName: 'Circuit Breaker Repair' },
          ],
        },
      },
    });
    serviceProviderId = sp1.id;

    await prisma.serviceProvider.create({
      data: {
        name: 'Ali Hassan Electric',
        categoryId,
        serviceType: 'ELECTRICIAN',
        rating: 4.6,
        city: 'Lahore',
      },
    });

    // Create a business
    await prisma.business.create({
      data: {
        name: 'Al-Fatah Store',
        category: 'STORE',
        rating: 4.5,
        location: 'Gulberg III, Lahore',
      },
    });

    // Create amenity
    await prisma.amenity.create({
      data: {
        name: 'Badshahi Mosque',
        amenityType: 'MASJID',
        location: 'Walled City, Lahore',
        rating: 4.9,
      },
    });

    // Create property
    await prisma.property.create({
      data: {
        title: '5 Marla House in DHA',
        location: 'DHA Phase 5, Lahore',
        beds: 3,
        baths: 2,
        price: 15000000,
        propertyType: 'House',
      },
    });

    // Create admin office
    await prisma.adminOffice.create({
      data: {
        name: 'DC Office Lahore',
        officeType: 'administration',
        rating: 4.0,
        phone: '+92-42-99210101',
      },
    });

    // Create test user
    const registerRes = await request(app)
      .post('/api/v1/auth/register')
      .send({
        name: 'Test User',
        email: 'content@test.com',
        password: 'Password123!',
      });
    userToken = registerRes.body.data.accessToken;
    userId = registerRes.body.data.user.id;
  });

  afterAll(async () => {
    await cleanDatabase();
    await prisma.$disconnect();
  });

  describe('GET /api/v1/service-providers', () => {
    it('should list service providers', async () => {
      const res = await request(app)
        .get('/api/v1/service-providers');

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.length).toBeGreaterThanOrEqual(2);
      expect(res.body.pagination).toBeDefined();
    });

    it('should filter by service type', async () => {
      const res = await request(app)
        .get('/api/v1/service-providers?type=ELECTRICIAN');

      expect(res.status).toBe(200);
      res.body.data.forEach(sp => {
        expect(sp.serviceType).toBe('ELECTRICIAN');
      });
    });

    it('should filter by city', async () => {
      const res = await request(app)
        .get('/api/v1/service-providers?city=Lahore');

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBeGreaterThan(0);
    });

    it('should paginate results', async () => {
      const res = await request(app)
        .get('/api/v1/service-providers?page=1&limit=1');

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBe(1);
      expect(res.body.pagination.page).toBe(1);
      expect(res.body.pagination.limit).toBe(1);
      expect(res.body.pagination.total).toBeGreaterThanOrEqual(2);
    });
  });

  describe('GET /api/v1/service-providers/:id', () => {
    it('should return provider detail with skills', async () => {
      const res = await request(app)
        .get(`/api/v1/service-providers/${serviceProviderId}`);

      expect(res.status).toBe(200);
      expect(res.body.data.name).toBe('Baber M Rizwan');
      expect(res.body.data.skills).toBeDefined();
      expect(res.body.data.skills.length).toBeGreaterThan(0);
    });

    it('should return 404 for non-existent provider', async () => {
      const res = await request(app)
        .get('/api/v1/service-providers/00000000-0000-0000-0000-000000000000');

      expect(res.status).toBe(404);
    });
  });

  describe('POST /api/v1/service-providers/:id/reviews', () => {
    it('should submit a review', async () => {
      const res = await request(app)
        .post(`/api/v1/service-providers/${serviceProviderId}/reviews`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          rating: 5,
          ratingText: 'Excellent',
          reviewText: 'Great service!',
        });

      expect(res.status).toBe(201);
      expect(res.body.data.rating).toBe(5);
    });

    it('should reject review without auth', async () => {
      const res = await request(app)
        .post(`/api/v1/service-providers/${serviceProviderId}/reviews`)
        .send({ rating: 4 });

      expect(res.status).toBe(401);
    });

    it('should reject invalid rating', async () => {
      const res = await request(app)
        .post(`/api/v1/service-providers/${serviceProviderId}/reviews`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({ rating: 6 });

      expect(res.status).toBe(400);
    });
  });

  describe('POST /api/v1/service-providers/:id/favorite', () => {
    it('should toggle favorite on', async () => {
      const res = await request(app)
        .post(`/api/v1/service-providers/${serviceProviderId}/favorite`)
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.status).toBe(200);
      expect(res.body.data.favorited).toBe(true);
    });

    it('should toggle favorite off', async () => {
      // First, favorite it
      await request(app)
        .post(`/api/v1/service-providers/${serviceProviderId}/favorite`)
        .set('Authorization', `Bearer ${userToken}`);

      // Then unfavorite
      const res = await request(app)
        .post(`/api/v1/service-providers/${serviceProviderId}/favorite`)
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.body.data.favorited).toBe(false);
    });
  });

  describe('GET /api/v1/businesses', () => {
    it('should list businesses', async () => {
      const res = await request(app).get('/api/v1/businesses');

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBeGreaterThan(0);
    });

    it('should filter by category', async () => {
      const res = await request(app).get('/api/v1/businesses?category=STORE');

      expect(res.status).toBe(200);
      res.body.data.forEach(b => {
        expect(b.category).toBe('STORE');
      });
    });
  });

  describe('GET /api/v1/amenities', () => {
    it('should list amenities', async () => {
      const res = await request(app).get('/api/v1/amenities');

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBeGreaterThan(0);
    });

    it('should filter by type', async () => {
      const res = await request(app).get('/api/v1/amenities?type=MASJID');

      expect(res.status).toBe(200);
      res.body.data.forEach(a => {
        expect(a.amenityType).toBe('MASJID');
      });
    });
  });

  describe('GET /api/v1/properties', () => {
    it('should list properties', async () => {
      const res = await request(app).get('/api/v1/properties');

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBeGreaterThan(0);
    });

    it('should filter by property type', async () => {
      const res = await request(app).get('/api/v1/properties?propertyType=House');

      expect(res.status).toBe(200);
      res.body.data.forEach(p => {
        expect(p.propertyType).toBe('House');
      });
    });
  });

  describe('GET /api/v1/admin-offices', () => {
    it('should list admin offices', async () => {
      const res = await request(app).get('/api/v1/admin-offices');

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBeGreaterThan(0);
    });

    it('should filter by type', async () => {
      const res = await request(app).get('/api/v1/admin-offices?type=administration');

      expect(res.status).toBe(200);
      res.body.data.forEach(o => {
        expect(o.officeType).toBe('administration');
      });
    });
  });

  describe('GET /api/v1/users/me/favorites', () => {
    it('should list user favorites', async () => {
      // Add a favorite first
      await request(app)
        .post(`/api/v1/service-providers/${serviceProviderId}/favorite`)
        .set('Authorization', `Bearer ${userToken}`);

      const res = await request(app)
        .get('/api/v1/users/me/favorites')
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBeGreaterThan(0);
    });
  });
});

